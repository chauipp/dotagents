#!/usr/bin/env bash
# claude-kit installer — cài rules + skills vào Claude Code.
#
#   ./install.sh                    # global: áp cho MỌI dự án trên máy này
#   ./install.sh --project [DIR]    # per-project: nhét vào repo dự án (mặc định: thư mục hiện tại)
#   ./install.sh --project DIR --rules-only   # chỉ rules, không copy skills
#
# Chạy lại nhiều lần vô hại: rules nằm trong khối đánh dấu, skills bị ghi đè.

set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BEGIN_MARK="<!-- claude-kit:begin — KHÔNG sửa tay, chạy lại install.sh để cập nhật -->"
END_MARK="<!-- claude-kit:end -->"

MODE=global
TARGET=""
RULES_ONLY=0

while [ $# -gt 0 ]; do
  case "$1" in
    --global)     MODE=global ;;
    --project)    MODE=project
                  if [ $# -gt 1 ] && [ "${2#-}" = "$2" ]; then TARGET="$2"; shift; fi ;;
    --rules-only) RULES_ONLY=1 ;;
    -h|--help)    sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Tham số lạ: $1" >&2; exit 2 ;;
  esac
  shift
done

# Ghép khối rules vào file CLAUDE.md, thay thế khối cũ nếu đã có.
merge_rules() {
  local dest="$1" tmp
  tmp="$(mktemp)"
  if [ -f "$dest" ] && grep -qF "$BEGIN_MARK" "$dest"; then
    # Giữ nguyên phần người dùng tự viết ngoài khối.
    awk -v b="$BEGIN_MARK" -v e="$END_MARK" '
      index($0,b){skip=1} !skip{print} index($0,e){skip=0}' "$dest" > "$tmp"
  elif [ -f "$dest" ]; then
    cat "$dest" > "$tmp"
    printf '\n' >> "$tmp"
  fi
  {
    printf '%s\n' "$BEGIN_MARK"
    cat "$KIT_DIR/CLAUDE.md"
    printf '%s\n' "$END_MARK"
  } >> "$tmp"
  mv "$tmp" "$dest"
  echo "  rules  -> $dest"
}

copy_skills() {
  local dest="$1"
  mkdir -p "$dest"
  cp -R "$KIT_DIR/skills/." "$dest/"
  echo "  skills -> $dest ($(ls -1 "$dest" | wc -l | tr -d ' ') skill)"
}

# Bật plugin superpowers trong settings.json mà không đụng các key khác.
enable_plugins() {
  local settings="$1"
  [ -f "$settings" ] || echo '{}' > "$settings"
  python3 - "$settings" <<'PY'
import json, sys
p = sys.argv[1]
try:
    with open(p) as f: cfg = json.load(f)
except (ValueError, FileNotFoundError):
    print("  settings.json hỏng hoặc trống — bỏ qua, hãy bật plugin bằng /plugin", file=sys.stderr)
    sys.exit(0)
cfg.setdefault("enabledPlugins", {})["superpowers@claude-plugins-official"] = True
with open(p, "w") as f: json.dump(cfg, f, indent=2, ensure_ascii=False)
print("  plugin -> superpowers bật trong " + p)
PY
}

if [ "$MODE" = global ]; then
  CFG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
  mkdir -p "$CFG"
  echo "Cài GLOBAL vào $CFG"
  [ -f "$CFG/CLAUDE.md" ] && cp "$CFG/CLAUDE.md" "$CFG/CLAUDE.md.bak.$(date +%Y%m%d%H%M%S)"
  merge_rules "$CFG/CLAUDE.md"
  copy_skills "$CFG/skills"
  enable_plugins "$CFG/settings.json"
else
  TARGET="${TARGET:-$PWD}"
  [ -d "$TARGET" ] || { echo "Không thấy thư mục: $TARGET" >&2; exit 1; }
  TARGET="$(cd "$TARGET" && pwd)"
  echo "Cài PER-PROJECT vào $TARGET"
  merge_rules "$TARGET/CLAUDE.md"
  if [ "$RULES_ONLY" = 0 ]; then
    copy_skills "$TARGET/.claude/skills"
  else
    echo "  skills -> bỏ qua (--rules-only)"
  fi
fi

echo
echo "Xong. Khởi động lại phiên Claude Code để nạp rules mới."
