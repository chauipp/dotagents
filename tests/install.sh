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

  find "$KIT_DIR/shared/skills" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort > "$expected"
  printf 'graphify\n' >> "$expected"
  [ -f "$manifest" ] || fail "$agent skills were not installed"
  sort "$manifest" > "$actual"
  sort -o "$expected" "$expected"
  assert_file_equal "$expected" "$actual"
  assert_file_equal "$KIT_DIR/$agent/skills/graphify/SKILL.md" "$skills_dir/graphify/SKILL.md"
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
for rules in "$project/CLAUDE.md" "$project/AGENTS.md"; do
  if grep -qE '/no-clarify|clear chat|clear conversation|compact conversation|compacting-conversations' "$rules"; then
    fail "Command-specific trigger is still active in $rules"
  fi
done
assert_skill_set claude "$project/.claude/skills"
assert_skill_set codex "$project/.codex/skills"
[ -f "$KIT_DIR/shared/skills/preserving-user-git-identity/SKILL.md" ] || fail "Missing shared Git identity skill"
assert_file_equal "$KIT_DIR/shared/skills/preserving-user-git-identity/SKILL.md" "$project/.claude/skills/preserving-user-git-identity/SKILL.md"
assert_file_equal "$KIT_DIR/shared/skills/preserving-user-git-identity/SKILL.md" "$project/.codex/skills/preserving-user-git-identity/SKILL.md"
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

echo 'PASS: installer preserves custom skills, detects collisions, and supports dry-run checks'
