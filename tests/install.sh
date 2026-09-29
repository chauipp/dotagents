#!/usr/bin/env bash
# Regression coverage for installer outputs. Run with: bash tests/install.sh
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_file_equal() {
  cmp -s "$1" "$2" || fail "Expected $1 and $2 to match"
}

assert_skill_set() {
  local agent="$1" skills_dir="$2"
  local manifest="$skills_dir/.dotagents-manifest"
  local expected="$TMP_DIR/$agent-expected" actual="$TMP_DIR/$agent-actual"

  : > "$expected"
  for skill_dir in "$KIT_DIR"/skills/*/; do
    [ -d "$skill_dir" ] || continue
    if awk -v agent="$agent" '
      NR == 1 && $0 != "---" { exit 0 }
      NR > 1 && $0 == "---" { exit }
      NR > 1 && /^agents:[[:space:]]*/ {
        value=$0; sub(/^agents:[[:space:]]*/, "", value); gsub(/[\[\],]/, " ", value)
        for (i=1; i<=split(value, names, /[[:space:]]+/); i++) if (names[i] == agent) found=1
        seen=1
      }
      END { if (!seen || found) exit 0; exit 1 }
    ' "$skill_dir/SKILL.md"; then
      basename "$skill_dir" >> "$expected"
    fi
  done
  [ -f "$manifest" ] || fail "$agent skills were not installed"
  sort "$manifest" > "$actual"
  sort -o "$expected" "$expected"
  assert_file_equal "$expected" "$actual"
  assert_file_equal "$KIT_DIR/skills/graphify/SKILL.md" "$skills_dir/graphify/SKILL.md"
}

project="$TMP_DIR/project"
mkdir -p "$project"
git -C "$project" init -q

CLAUDE_CONFIG_DIR="$TMP_DIR/claude-config" CODEX_HOME="$TMP_DIR/codex-config" \
  "$KIT_DIR/install.sh" --project "$project" >/dev/null
CLAUDE_CONFIG_DIR="$TMP_DIR/claude-config" CODEX_HOME="$TMP_DIR/codex-config" \
  "$KIT_DIR/install.sh" --project "$project" >/dev/null
[ "$(grep -c '^# dotagents:begin skills$' "$project/.gitignore")" = 1 ] \
  || fail 'Project reinstall duplicated the managed .gitignore block'
[ "$(grep -c '^# dotagents:begin conversations$' "$project/.gitignore")" = 1 ] \
  || fail 'Project install did not create exactly one conversation ignore block'
awk '/^# dotagents:end skills$/ { getline; if ($0 != "") exit 1; found=1 } END { if (!found) exit 1 }' "$project/.gitignore" \
  || fail 'Managed .gitignore blocks are not separated by a blank line'

grep -q 'dotagents:begin' "$project/CLAUDE.md" || fail 'Project install did not write Claude rules'
grep -q 'dotagents:begin' "$project/AGENTS.md" || fail 'Project install did not write Codex rules'
assert_skill_set claude "$project/.claude/skills"
assert_skill_set codex "$project/.codex/skills"
[ ! -e "$KIT_DIR/skills/preserving-user-git-identity" ] || fail "Git identity skill should be removed"
for rules_file in "$project/CLAUDE.md" "$project/AGENTS.md"; do
  for required_rule in 'git config user.name' 'git config user.email' 'git diff --cached --check' 'git diff --cached' 'commit --author' 'release note' 'copyright' 'trailer' 'chỉ push khi người dùng đã cho phép'; do
    grep -Fq "$required_rule" "$rules_file" || fail "Git identity rules omit '$required_rule' in $rules_file"
  done
done
grep -q '^\.claude/skills/graphify/$' "$project/.gitignore" || fail 'Claude kit skills are not ignored'
grep -q '^\.codex/skills/graphify/$' "$project/.gitignore" || fail 'Codex kit skills are not ignored'
mkdir -p "$project/.claude/skills/project-only" "$project/.codex/skills/project-only"
touch "$project/.claude/skills/project-only/SKILL.md" "$project/.codex/skills/project-only/SKILL.md"
git -C "$project" check-ignore -q .claude/skills/graphify/SKILL.md || fail 'Claude kit skill is not ignored by Git'
git -C "$project" check-ignore -q .codex/skills/graphify/SKILL.md || fail 'Codex kit skill is not ignored by Git'
git -C "$project" check-ignore -q conversation/example.md || fail 'Conversation files are not ignored by Git'
if git -C "$project" check-ignore -q .claude/skills/project-only/SKILL.md; then fail 'Project Claude skill was incorrectly ignored'; fi
if git -C "$project" check-ignore -q .codex/skills/project-only/SKILL.md; then fail 'Project Codex skill was incorrectly ignored'; fi
check_project="$TMP_DIR/check-project"
mkdir -p "$check_project/.codex"
printf "existing ignore\n" > "$check_project/.gitignore"
printf "existing config\n" > "$check_project/.codex/config.toml"
check_gitignore_hash=$(sha256sum "$check_project/.gitignore")
check_config_hash=$(sha256sum "$check_project/.codex/config.toml")
"$KIT_DIR/install.sh" --check --project "$check_project" > "$TMP_DIR/check-output"
[ "$check_gitignore_hash" = "$(sha256sum "$check_project/.gitignore")" ] || fail "--check modified project .gitignore"
[ "$check_config_hash" = "$(sha256sum "$check_project/.codex/config.toml")" ] || fail "--check modified project config"
[ ! -e "$check_project/CLAUDE.md" ] || fail '--check wrote project Claude rules'
[ ! -e "$check_project/AGENTS.md" ] || fail '--check wrote project Codex rules'
[ ! -e "$check_project/.claude/skills" ] || fail '--check wrote project Claude skills'
[ ! -e "$check_project/.codex/skills" ] || fail '--check wrote project Codex skills'
grep -q 'Kiểm tra an toàn' "$TMP_DIR/check-output" || fail '--check did not report its plan'

collision_project="$TMP_DIR/collision-project"
mkdir -p "$collision_project/.claude/skills/brainstorming"
printf 'project skill' > "$collision_project/.claude/skills/brainstorming/SKILL.md"
if "$KIT_DIR/install.sh" --project "$collision_project" > "$TMP_DIR/collision-output" 2>&1; then
  fail 'Project install accepted a custom skill collision'
fi
grep -q 'brainstorming' "$TMP_DIR/collision-output" || fail 'Project collision did not name the skill'
[ ! -e "$collision_project/CLAUDE.md" ] || fail 'Project collision wrote rules before stopping'
grep -qx 'project skill' "$collision_project/.claude/skills/brainstorming/SKILL.md" \
  || fail 'Project collision changed the custom skill'

legacy_project="$TMP_DIR/legacy-project"
mkdir -p "$legacy_project/.claude/skills/brandkit"
printf 'legacy project skill' > "$legacy_project/.claude/skills/brandkit/SKILL.md"
"$KIT_DIR/install.sh" --project "$legacy_project" >/dev/null
grep -qx 'legacy project skill' "$legacy_project/.claude/skills/brandkit/SKILL.md" \
  || fail 'Installer removed a legacy-name custom skill outside the manifest'


mkdir -p "$TMP_DIR/codex-config"
printf '[features]\nexisting_feature = true\n' > "$TMP_DIR/codex-config/config.toml"
CODEX_HOME="$TMP_DIR/codex-config" "$KIT_DIR/install.sh" --codex >/dev/null
grep -q '^multi_agent = true$' "$TMP_DIR/codex-config/config.toml" \
  || fail 'Codex install did not enable multi_agent inside an existing features table'

rules_only_global="$TMP_DIR/rules-only-global"
CODEX_HOME="$rules_only_global" "$KIT_DIR/install.sh" --codex --rules-only >/dev/null
[ -f "$rules_only_global/AGENTS.md" ] || fail 'Global --rules-only did not write Codex rules'
[ ! -e "$rules_only_global/skills" ] || fail 'Global --rules-only copied skills'
[ ! -e "$rules_only_global/config.toml" ] || fail 'Global --rules-only changed Codex config'

global_claude="$TMP_DIR/global-claude"
mkdir -p "$global_claude/skills/brainstorming"
printf 'global skill' > "$global_claude/skills/brainstorming/SKILL.md"
if CLAUDE_CONFIG_DIR="$global_claude" "$KIT_DIR/install.sh" --claude > "$TMP_DIR/global-collision-output" 2>&1; then
  fail 'Global install accepted a custom skill collision'
fi
grep -q 'brainstorming' "$TMP_DIR/global-collision-output" || fail 'Global collision did not name the skill'
[ ! -e "$global_claude/CLAUDE.md" ] || fail 'Global collision wrote rules before stopping'
grep -qx 'global skill' "$global_claude/skills/brainstorming/SKILL.md" \
  || fail 'Global collision changed the custom skill'

# Prompt-map skill is canonical and only installed for Codex.
name=ch-writing-prompts-map
[ -f "$KIT_DIR/skills/$name/SKILL.md" ] || fail "Missing Codex skill: $name"
grep -qxF "$name" "$project/.codex/skills/.dotagents-manifest" || fail "Codex skill not installed: $name"
if grep -qxF "$name" "$project/.claude/skills/.dotagents-manifest"; then fail "Codex skill leaked into Claude: $name"; fi
for old_name in ch-writing-prompts-map-sol ch-writing-prompts-map-astra; do
  [ ! -e "$KIT_DIR/skills/$old_name" ] || fail "Legacy profile still present: $old_name"
  if grep -qxF "$old_name" "$project/.codex/skills/.dotagents-manifest"; then fail "Legacy profile installed: $old_name"; fi
done
grep -q 'BLOCKED_MODEL' "$KIT_DIR/skills/$name/SKILL.md" || fail 'Parent model gate is missing'
grep -q 'AWAITING_PARENT_CONFIRMATION' "$KIT_DIR/skills/$name/SKILL.md" || fail 'Incomplete parent metadata must request confirmation'
grep -q 'USER_CONFIRMED' "$KIT_DIR/skills/$name/SKILL.md" || fail 'Confirmed UI parent evidence is missing'
grep -q 'tài liệu nguồn không phải xác nhận UI' "$KIT_DIR/skills/$name/SKILL.md" || fail 'Attached documents must not count as UI confirmation'
grep -q 'lần gọi kế tiếp' "$KIT_DIR/skills/$name/SKILL.md" || fail 'Parent confirmation must apply only to the next call'
grep -q 'Xác nhận hết hiệu lực' "$KIT_DIR/skills/$name/SKILL.md" || fail 'Parent confirmation invalidation is missing'
grep -q 'gpt-5.6-sol' "$KIT_DIR/skills/$name/SKILL.md" || fail 'Medium profile mapping is missing'
grep -q 'gpt-6-astra' "$KIT_DIR/skills/$name/SKILL.md" || fail 'High profile mapping is missing'
grep -q 'UNASSIGNED' "$KIT_DIR/skills/$name/SKILL.md" || fail 'Low profile must remain unassigned'


# Both runtime rules must contain the complete common policy as one contiguous block.
for rules_file in "$project/CLAUDE.md" "$project/AGENTS.md"; do
  awk '/^<!-- dotagents:begin/{inside=1; next} inside && !started && /^$/ {next} inside {started=1; print; count++; if (count == common_lines) exit}' \
    common_lines="$(wc -l < "$KIT_DIR/rules/common.md")" "$rules_file" > "$TMP_DIR/common-output"
  assert_file_equal "$KIT_DIR/rules/common.md" "$TMP_DIR/common-output"
done
for overlay in "$KIT_DIR/claude/CLAUDE.md" "$KIT_DIR/codex/AGENTS.md"; do
  if grep -q '^# Quy tắc\|^# Tài liệu kế hoạch\|^# Tạo thư mục\|^# Theo dõi task\|^# superpowers$' "$overlay"; then
    fail "Platform overlay contains a shared policy: $overlay"
  fi
done

# Shared rules, platform overlays, migration preservation, and idempotency.
grep -qx $'# Ng\u00f4n ng\u1eef' "$project/CLAUDE.md" || fail 'Common rules missing from Claude output'
grep -qx $'# Ng\u00f4n ng\u1eef' "$project/AGENTS.md" || fail 'Common rules missing from Codex output'
grep -q '^# Rules .*Claude Code$' "$project/CLAUDE.md" || fail 'Claude overlay missing from Claude output'
if grep -q '^# Rules .*Claude Code$' "$project/AGENTS.md"; then fail 'Claude overlay leaked into Codex output'; fi
grep -q '^# Rules .*Codex$' "$project/AGENTS.md" || fail 'Codex overlay missing from Codex output'
if grep -q '^# Rules .*Codex$' "$project/CLAUDE.md"; then fail 'Codex overlay leaked into Claude output'; fi
[ "$(grep -c $'^# Ng\u00f4n ng\u1eef$' "$project/CLAUDE.md")" = 1 ] || fail 'Common rules duplicated in Claude output'
[ "$(grep -c $'^# Ng\u00f4n ng\u1eef$' "$project/AGENTS.md")" = 1 ] || fail 'Common rules duplicated in Codex output'

legacy_rules_project="$TMP_DIR/legacy-rules-project"
mkdir -p "$legacy_rules_project"
printf '# Ng\u00f4n ng\u1eef\nlegacy user rule\n# Legacy project rule\n' > "$legacy_rules_project/CLAUDE.md"
printf '# Ng\u00f4n ng\u1eef\nlegacy user rule\n# Legacy project rule\n' > "$legacy_rules_project/AGENTS.md"
printf '# Ng\u00f4n ng\u1eef\nlegacy user rule\n# Legacy project rule\n' > "$TMP_DIR/legacy-rules-prefix"
"$KIT_DIR/install.sh" --project "$legacy_rules_project" --rules-only > "$TMP_DIR/legacy-rules-output" 2>&1
grep -q 'legacy user rule' "$legacy_rules_project/CLAUDE.md" || fail 'Legacy Claude rules were not preserved'
grep -q 'legacy user rule' "$legacy_rules_project/AGENTS.md" || fail 'Legacy Codex rules were not preserved'
[ "$(grep -c '^<!-- dotagents:begin' "$legacy_rules_project/CLAUDE.md")" = 1 ] || fail 'Claude migration block count is wrong'
[ "$(grep -c '^<!-- dotagents:begin' "$legacy_rules_project/AGENTS.md")" = 1 ] || fail 'Codex migration block count is wrong'
head -n 3 "$legacy_rules_project/CLAUDE.md" > "$TMP_DIR/legacy-claude-prefix"
head -n 3 "$legacy_rules_project/AGENTS.md" > "$TMP_DIR/legacy-codex-prefix"
assert_file_equal "$TMP_DIR/legacy-rules-prefix" "$TMP_DIR/legacy-claude-prefix"
assert_file_equal "$TMP_DIR/legacy-rules-prefix" "$TMP_DIR/legacy-codex-prefix"
[ "$(tail -n 1 "$legacy_rules_project/CLAUDE.md")" = "<!-- dotagents:end -->" ] || fail 'Claude managed block was not appended at end'
[ "$(tail -n 1 "$legacy_rules_project/AGENTS.md")" = "<!-- dotagents:end -->" ] || fail 'Codex managed block was not appended at end'
grep -q $'1 m\u1ee5c tr\u00f9ng ti\u00eau \u0111\u1ec1' "$TMP_DIR/legacy-rules-output" || fail 'Migration warning did not report duplicate headings'
printf '\nlegacy user edit after install\n' >> "$legacy_rules_project/CLAUDE.md"
printf '\nlegacy user edit after install\n' >> "$legacy_rules_project/AGENTS.md"
"$KIT_DIR/install.sh" --project "$legacy_rules_project" --rules-only > /dev/null 2>&1
grep -qx 'legacy user edit after install' "$legacy_rules_project/CLAUDE.md" || fail 'Claude edit outside marker was not preserved'
grep -qx 'legacy user edit after install' "$legacy_rules_project/AGENTS.md" || fail 'Codex edit outside marker was not preserved'
legacy_claude_hash=$(sha256sum "$legacy_rules_project/CLAUDE.md")
legacy_codex_hash=$(sha256sum "$legacy_rules_project/AGENTS.md")
"$KIT_DIR/install.sh" --project "$legacy_rules_project" --rules-only > /dev/null 2>&1
[ "$legacy_claude_hash" = "$(sha256sum "$legacy_rules_project/CLAUDE.md")" ] || fail 'Claude reinstall is not idempotent'
[ "$legacy_codex_hash" = "$(sha256sum "$legacy_rules_project/AGENTS.md")" ] || fail 'Codex reinstall is not idempotent'

broken_kit="$TMP_DIR/broken-kit"
cp -a "$KIT_DIR" "$broken_kit"
broken_project="$TMP_DIR/broken-project"
mkdir -p "$broken_project"
cp "$broken_kit/rules/common.md" "$broken_kit/rules/common.md.backup"
mv "$broken_kit/rules/common.md" "$broken_kit/rules/common.md.disabled"
if "$broken_kit/install.sh" --project "$broken_project" --rules-only > "$TMP_DIR/missing-common-output" 2>&1; then
  fail 'Install accepted a missing common source'
fi
[ ! -e "$broken_project/CLAUDE.md" ] || fail 'Missing common source wrote Claude rules'
[ ! -e "$broken_project/AGENTS.md" ] || fail 'Missing common source wrote Codex rules'
mv "$broken_kit/rules/common.md.disabled" "$broken_kit/rules/common.md"
: > "$broken_kit/rules/common.md"
if "$broken_kit/install.sh" --project "$broken_project" --rules-only > "$TMP_DIR/empty-common-output" 2>&1; then
  fail 'Install accepted an empty common source'
fi
[ ! -e "$broken_project/CLAUDE.md" ] || fail 'Empty common source wrote Claude rules'
[ ! -e "$broken_project/AGENTS.md" ] || fail 'Empty common source wrote Codex rules'
mv "$broken_kit/rules/common.md.backup" "$broken_kit/rules/common.md"
mv "$broken_kit/claude/CLAUDE.md" "$broken_kit/claude/CLAUDE.md.disabled"
if "$broken_kit/install.sh" --project "$broken_project" --rules-only > "$TMP_DIR/missing-overlay-output" 2>&1; then
  fail 'Install accepted a missing overlay source'
fi
[ ! -e "$broken_project/CLAUDE.md" ] || fail 'Missing overlay source wrote Claude rules'
[ ! -e "$broken_project/AGENTS.md" ] || fail 'Missing overlay source wrote Codex rules'
mv "$broken_kit/claude/CLAUDE.md.disabled" "$broken_kit/claude/CLAUDE.md"
printf '\n<!-- dotagents:begin invalid-source -->\n' >> "$broken_kit/rules/common.md"
if "$broken_kit/install.sh" --project "$broken_project" --rules-only > "$TMP_DIR/marker-source-output" 2>&1; then
  fail 'Install accepted a marker in source rules'
fi
[ ! -e "$broken_project/CLAUDE.md" ] || fail 'Invalid source marker wrote Claude rules'
[ ! -e "$broken_project/AGENTS.md" ] || fail 'Invalid source marker wrote Codex rules'

echo 'PASS: installer preserves custom skills, detects collisions, and supports dry-run checks'
