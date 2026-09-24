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

grep -q 'dotagents:begin' "$project/CLAUDE.md" || fail 'Project install did not write Claude rules'
grep -q 'dotagents:begin' "$project/AGENTS.md" || fail 'Project install did not write Codex rules'
assert_skill_set claude "$project/.claude/skills"
assert_skill_set codex "$project/.codex/skills"
[ -f "$KIT_DIR/skills/preserving-user-git-identity/SKILL.md" ] || fail "Missing Git identity skill"
assert_file_equal "$KIT_DIR/skills/preserving-user-git-identity/SKILL.md" "$project/.claude/skills/preserving-user-git-identity/SKILL.md"
assert_file_equal "$KIT_DIR/skills/preserving-user-git-identity/SKILL.md" "$project/.codex/skills/preserving-user-git-identity/SKILL.md"
grep -q "preserving-user-git-identity" "$project/CLAUDE.md" || fail "Claude rules omit Git identity safeguard"
grep -q "preserving-user-git-identity" "$project/AGENTS.md" || fail "Codex rules omit Git identity safeguard"
grep -q '^\.claude/skills/graphify/$' "$project/.gitignore" || fail 'Claude kit skills are not ignored'
grep -q '^\.codex/skills/graphify/$' "$project/.gitignore" || fail 'Codex kit skills are not ignored'
mkdir -p "$project/.claude/skills/project-only" "$project/.codex/skills/project-only"
touch "$project/.claude/skills/project-only/SKILL.md" "$project/.codex/skills/project-only/SKILL.md"
git -C "$project" check-ignore -q .claude/skills/graphify/SKILL.md || fail 'Claude kit skill is not ignored by Git'
git -C "$project" check-ignore -q .codex/skills/graphify/SKILL.md || fail 'Codex kit skill is not ignored by Git'
if git -C "$project" check-ignore -q .claude/skills/project-only/SKILL.md; then fail 'Project Claude skill was incorrectly ignored'; fi
if git -C "$project" check-ignore -q .codex/skills/project-only/SKILL.md; then fail 'Project Codex skill was incorrectly ignored'; fi
check_project="$TMP_DIR/check-project"
mkdir -p "$check_project"
"$KIT_DIR/install.sh" --check --project "$check_project" > "$TMP_DIR/check-output"
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

# Prompt-map profiles are in the canonical catalog and only installed for Codex.
for name in writing-prompts-map-sol writing-prompts-map-astra; do
  [ -f "$KIT_DIR/skills/$name/SKILL.md" ] || fail "Missing Codex profile: $name"
  grep -qxF "$name" "$project/.codex/skills/.dotagents-manifest" || fail "Codex profile not installed: $name"
  if grep -qxF "$name" "$project/.claude/skills/.dotagents-manifest"; then fail "Codex profile leaked into Claude: $name"; fi
done
cmp "$KIT_DIR/skills/writing-prompts-map-sol/references/workflow.md" \
  "$KIT_DIR/skills/writing-prompts-map-astra/references/workflow.md" || fail 'Profile workflow drift'
cmp "$KIT_DIR/skills/writing-prompts-map-sol/references/roles.md" \
  "$KIT_DIR/skills/writing-prompts-map-astra/references/roles.md" || fail 'Profile role drift'

echo 'PASS: installer preserves custom skills, detects collisions, and supports dry-run checks'