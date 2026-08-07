#!/usr/bin/env bash
# dotagents — cài rules + skills dùng chung cho các coding agent.
#
#   ./install.sh                     # global, cài cho mọi agent phát hiện được
#   ./install.sh --claude            # chỉ Claude Code  -> $CLAUDE_CONFIG_DIR (mặc định ~/.claude)
#   ./install.sh --codex             # chỉ Codex        -> $CODEX_HOME (mặc định ~/.codex)
#   ./install.sh --project [DIR]     # nhét vào repo dự án (mặc định: thư mục hiện tại)
#   ./install.sh --project DIR --rules-only    # chỉ rules, không copy skills
#
# Chạy lại nhiều lần vô hại: rules nằm trong khối đánh dấu, skills bị ghi đè.

set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BEGIN_MARK="<!-- dotagents:begin — KHÔNG sửa tay, chạy lại install.sh để cập nhật -->"
END_MARK="<!-- dotagents:end -->"

MODE=global
TARGET=""
RULES_ONLY=0
WANT_CLAUDE=0
WANT_CODEX=0

while [ $# -gt 0 ]; do
  case "$1" in
    --claude)     WANT_CLAUDE=1 ;;
    --codex)      WANT_CODEX=1 ;;
    --all)        WANT_CLAUDE=1; WANT_CODEX=1 ;;
    --project)    MODE=project
                  if [ $# -gt 1 ] && [ "${2#-}" = "$2" ]; then TARGET="$2"; shift; fi ;;
    --rules-only) RULES_ONLY=1 ;;
    -h|--help)    sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Tham số lạ: $1" >&2; exit 2 ;;
  esac
  shift
done

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
CODEX_DIR="${CODEX_HOME:-$HOME/.codex}"

# Không chỉ định agent nào -> tự phát hiện theo thư mục config đã tồn tại.
if [ "$MODE" = global ] && [ "$WANT_CLAUDE" = 0 ] && [ "$WANT_CODEX" = 0 ]; then
  [ -d "$CLAUDE_DIR" ] && WANT_CLAUDE=1
  [ -d "$CODEX_DIR" ]  && WANT_CODEX=1
  if [ "$WANT_CLAUDE" = 0 ] && [ "$WANT_CODEX" = 0 ]; then
    echo "Không thấy $CLAUDE_DIR lẫn $CODEX_DIR." >&2
    echo "Chỉ định rõ bằng --claude hoặc --codex." >&2
    exit 1
  fi
fi

# Ghép khối rules vào file đích, thay thế khối cũ nếu đã có.
# $1 = file đích, $2 = file rules nguồn
merge_rules() {
  local dest="$1" src="$2" tmp
  tmp="$(mktemp)"
  if [ -f "$dest" ] && grep -qF "$BEGIN_MARK" "$dest"; then
    # Giữ nguyên phần người dùng tự viết ngoài khối.
    awk -v b="$BEGIN_MARK" -v e="$END_MARK" '
      index($0,b){skip=1} !skip{print} index($0,e){skip=0}' "$dest" > "$tmp"
  elif [ -f "$dest" ] && [ -s "$dest" ]; then
    cat "$dest" > "$tmp"
    printf '\n' >> "$tmp"
  fi
  {
    printf '%s\n' "$BEGIN_MARK"
    cat "$src"
    printf '%s\n' "$END_MARK"
  } >> "$tmp"
  mv "$tmp" "$dest"
  echo "  rules  -> $dest"
}

# Copy shared/skills/, rồi chồng <agent>/skills/ lên đè.
# Một vài skill (graphify) có biến thể riêng cho từng agent vì gọi tool khác nhau:
# Claude Code dùng Agent tool, Codex dùng spawn_agent — dùng nhầm bản là hỏng skill.
# $1 = thư mục đích, $2 = tên agent (claude | codex)
copy_skills() {
  local dest="$1" agent="$2" name n=0 gone=0 manifest="$1/.dotagents-manifest" new
  mkdir -p "$dest"
  new="$(mktemp)"
  for src in "$KIT_DIR"/shared/skills/*/ "$KIT_DIR/$agent"/skills/*/; do
    [ -d "$src" ] || continue
    name="$(basename "$src")"
    # Xoá trước rồi mới copy: nếu đích đang là symlink, cp -R sẽ báo lỗi
    # "cannot overwrite non-directory with directory" và làm script dừng giữa chừng.
    rm -rf "$dest/$name"
    cp -R "$src" "$dest/$name"
    printf '%s\n' "$name" >> "$new"
    n=$((n + 1))
  done
  # Dọn skill lần trước dotagents cài mà nay repo không còn. Chỉ đụng vào tên có
  # trong manifest cũ, nên skill bạn tự thêm tay và .system/ của Codex vẫn nguyên.
  if [ -f "$manifest" ]; then
    while IFS= read -r name; do
      [ -n "$name" ] || continue
      grep -qxF "$name" "$new" && continue
      [ -e "$dest/$name" ] || continue
      rm -rf "$dest/$name"
      echo "  gỡ    -> $name (không còn trong repo)"
      gone=$((gone + 1))
    done < "$manifest"
  fi
  mv "$new" "$manifest"
  echo "  skills -> $dest ($n skill, bản $agent$([ "$gone" -gt 0 ] && echo ", gỡ $gone"))"
}

backup() {
  [ -f "$1" ] && [ -s "$1" ] && cp "$1" "$1.bak.$(date +%Y%m%d%H%M%S)" || true
}

# superpowers được copy thẳng vào skills/ nên plugin cùng tên phải tắt,
# không thì mỗi skill hiện hai lần (bản plugin + bản repo).
# Cũng tắt luôn trailer Co-Authored-By: Claude trong commit.
tune_settings() {
  local settings="$1"
  [ -f "$settings" ] || echo '{}' > "$settings"
  python3 - "$settings" <<'PY'
import json, sys
p = sys.argv[1]
try:
    with open(p) as f: cfg = json.load(f)
except ValueError:
    print("  settings.json hỏng — bỏ qua", file=sys.stderr)
    sys.exit(0)
cfg.setdefault("enabledPlugins", {})["superpowers@claude-plugins-official"] = False
cfg["includeCoAuthoredBy"] = False
with open(p, "w") as f: json.dump(cfg, f, indent=2, ensure_ascii=False)
print("  config -> plugin superpowers tắt (dùng bản trong repo), bỏ trailer Co-Authored-By")
PY
}

if [ "$MODE" = project ]; then
  TARGET="${TARGET:-$PWD}"
  [ -d "$TARGET" ] || { echo "Không thấy thư mục: $TARGET" >&2; exit 1; }
  TARGET="$(cd "$TARGET" && pwd)"
  echo "Cài PER-PROJECT vào $TARGET"
  merge_rules "$TARGET/CLAUDE.md" "$KIT_DIR/claude/CLAUDE.md"
  merge_rules "$TARGET/AGENTS.md" "$KIT_DIR/codex/AGENTS.md"
  if [ "$RULES_ONLY" = 0 ]; then
    copy_skills "$TARGET/.claude/skills" claude
  else
    echo "  skills -> bỏ qua (--rules-only)"
  fi
else
  if [ "$WANT_CLAUDE" = 1 ]; then
    echo "Cài CLAUDE CODE vào $CLAUDE_DIR"
    mkdir -p "$CLAUDE_DIR"
    backup "$CLAUDE_DIR/CLAUDE.md"
    merge_rules "$CLAUDE_DIR/CLAUDE.md" "$KIT_DIR/claude/CLAUDE.md"
    copy_skills "$CLAUDE_DIR/skills" claude
    tune_settings "$CLAUDE_DIR/settings.json"
  fi
  if [ "$WANT_CODEX" = 1 ]; then
    echo "Cài CODEX vào $CODEX_DIR"
    mkdir -p "$CODEX_DIR"
    backup "$CODEX_DIR/AGENTS.md"
    merge_rules "$CODEX_DIR/AGENTS.md" "$KIT_DIR/codex/AGENTS.md"
    copy_skills "$CODEX_DIR/skills" codex
  fi
fi

echo
echo "Xong. Khởi động lại phiên agent để nạp rules mới."
