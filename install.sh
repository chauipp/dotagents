#!/usr/bin/env bash
# dotagents — cài rules + skills dùng chung cho các coding agent.
#
#   ./install.sh                     # global, cài cho mọi agent phát hiện được
#   ./install.sh --claude            # chỉ Claude Code  -> $CLAUDE_CONFIG_DIR (mặc định ~/.claude)
#   ./install.sh --codex             # chỉ Codex        -> $CODEX_HOME (mặc định ~/.codex)
#   ./install.sh --all               # cả Claude Code và Codex global
#   ./install.sh --rules-only        # global: chỉ cài rules
#   ./install.sh --project [DIR]     # cả Claude Code và Codex (mặc định: thư mục hiện tại)
#   ./install.sh --project DIR --claude       # chỉ Claude Code trong project
#   ./install.sh --project DIR --codex        # chỉ Codex trong project
#   ./install.sh --project DIR --all          # cả hai agent trong project
#   ./install.sh --project DIR --rules-only   # chỉ rules, không copy skills
#   ./install.sh --check --project DIR        # kiểm tra an toàn, không ghi file
#
# Chạy lại nhiều lần vô hại: rules nằm trong khối đánh dấu, skills do dotagents
# quản lý qua manifest mới được ghi đè hoặc xóa.

set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BEGIN_MARK="<!-- dotagents:begin — KHÔNG sửa tay, chạy lại install.sh để cập nhật -->"
END_MARK="<!-- dotagents:end -->"

MODE=global
TARGET=""
RULES_ONLY=0
CHECK=0
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
    --check)      CHECK=1 ;;
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

# Resolve cả symlink để nguồn luôn thuộc kit hiện tại.
resolve_rules_source() {
  local src="$1"
  if [ ! -f "$src" ] || [ ! -r "$src" ] || [ ! -s "$src" ]; then
    echo "Nguồn rules không tồn tại, không đọc được hoặc rỗng: $src" >&2
    return 1
  fi
  python3 - "$KIT_DIR" "$src" <<'PYTHON'
import os, sys
kit, source = map(os.path.realpath, sys.argv[1:])
if os.path.commonpath([kit, source]) != kit:
    print("Nguồn rules resolve ra ngoài kit: " + sys.argv[2] + " -> " + source, file=sys.stderr)
    sys.exit(1)
print(source)
PYTHON
}

rules_overlay_path() {
  case "$1" in
    claude) printf '%s\n' "$KIT_DIR/claude/CLAUDE.md" ;;
    codex) printf '%s\n' "$KIT_DIR/codex/AGENTS.md" ;;
    *) echo "Agent không hợp lệ khi dựng rules: $1" >&2; return 1 ;;
  esac
}

validate_rules_markers() {
  local src="$1" counts begins ends
  counts=$(awk '{ b += gsub(/<!-- dotagents:begin/, "&"); e += gsub(/<!-- dotagents:end/, "&") }
    END { print b+0, e+0 }' "$src") || return 1
  read -r begins ends <<< "$counts"
  if [ "$begins" -ne 0 ] || [ "$ends" -ne 0 ]; then
    echo "Nguồn rules chứa marker quản lý: $src (begin=$begins, end=$ends); không được lồng marker." >&2
    return 1
  fi
}

# Dựng common trước overlay; chỉ ghi source tạm sau khi cả hai đã hợp lệ.
build_rules_source() {
  local agent="$1" output="$2" common overlay
  overlay=$(rules_overlay_path "$agent") || return 1
  common=$(resolve_rules_source "$KIT_DIR/rules/common.md") || return 1
  overlay=$(resolve_rules_source "$overlay") || return 1
  validate_rules_markers "$common" || return 1
  validate_rules_markers "$overlay" || return 1
  {
    printf '\n' || return 1
    cat "$common" || return 1
    printf '\n\n' || return 1
    cat "$overlay" || return 1
    printf '\n\n' || return 1
  } > "$output"
}

prepare_rules_sources() {
  RULES_TMP_DIR=$(mktemp -d) || return 1
  if [ "$WANT_CLAUDE" = 1 ]; then
    CLAUDE_RULES_SOURCE="$RULES_TMP_DIR/claude.md"
    build_rules_source claude "$CLAUDE_RULES_SOURCE" || return 1
  fi
  if [ "$WANT_CODEX" = 1 ]; then
    CODEX_RULES_SOURCE="$RULES_TMP_DIR/codex.md"
    build_rules_source codex "$CODEX_RULES_SOURCE" || return 1
  fi
}

# Chỉ đếm heading ngoài khối được quản lý, kể cả khi --check file đã cài.
duplicate_rules_headings() {
  local dest="$1" src="$2"
  if [ ! -f "$dest" ]; then
    printf '0\n'
    return 0
  fi
  comm -12 <(awk -v b="$BEGIN_MARK" -v e="$END_MARK" '
    index($0,b){skip=1} !skip && /^# /{print} index($0,e){skip=0}' "$dest" | sort -u) \
    <(awk '/^# /{print}' "$src" | sort -u) | wc -l | tr -d ' '
}

warn_rules_migration() {
  local dest="$1" src="$2" kept dup
  [ -f "$dest" ] && [ -s "$dest" ] || return 0
  grep -qF "$BEGIN_MARK" "$dest" && return 0
  kept=$(wc -l < "$dest" | tr -d ' ')
  dup=$(duplicate_rules_headings "$dest" "$src")
  echo "  ! $dest chưa có marker: giữ nguyên $kept dòng phía trên khối dotagents; $dup mục trùng tiêu đề với rules mới." >&2
  if [ "$dup" -gt 0 ]; then
    echo "    Có thể là rules bản cũ gây mâu thuẫn. Review nội dung TRÊN dòng dotagents:begin; chỉ xoá nếu xác nhận là bản cũ." >&2
  else
    echo "    Review nội dung cũ cùng block mới để tránh quy tắc mâu thuẫn." >&2
  fi
}

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
    # Lần đầu trên file đã có nội dung: giữ nguyên phần cũ ở trên, khối mới nối
    # xuống dưới. Không tự xoá phần cũ — không cách nào chắc chắn phân biệt được
    # rules bản cũ với ghi chú riêng của người dùng.
    cat "$dest" > "$tmp"
    printf '\n' >> "$tmp"
    warn_rules_migration "$dest" "$src"
  fi
  {
    printf '%s\n' "$BEGIN_MARK"
    cat "$src"
    printf '%s\n' "$END_MARK"
  } >> "$tmp"
  mv "$tmp" "$dest"
  echo "  rules  -> $dest"
}

REMOVED_SKILLS="brandkit gpt-tasteskill image-to-code-skill imagegen-frontend-mobile
imagegen-frontend-web soft-skill stitch-skill taste-skill-v1"

# Chỉ manifest là bằng chứng dotagents sở hữu skill ở thư mục đích. Một skill
# cùng tên nhưng ngoài manifest là tài sản dự án/người dùng, không được đụng vào.
is_managed_skill() {
  local manifest="$1" name="$2"
  [ -f "$manifest" ] && grep -qxF "$name" "$manifest"
}

is_identical_kit_skill() {
  local dest="$1" name="$2"
  [ -d "$dest/$name" ] && diff -qr "$KIT_DIR/skills/$name" "$dest/$name" >/dev/null 2>&1
}

skill_supports_agent() {
  local skill_file="$1" agent="$2"
  [ -f "$skill_file" ] || return 1
  awk -v agent="$agent" '
    NR == 1 && $0 != "---" { exit 0 }
    NR > 1 && $0 == "---" { exit }
    NR > 1 && /^agents:[[:space:]]*/ {
      value=$0
      sub(/^agents:[[:space:]]*/, "", value)
      gsub(/[\[\],]/, " ", value)
      for (i=1; i<=split(value, names, /[[:space:]]+/); i++)
        if (names[i] == agent) found=1
      seen=1
    }
    END { if (!seen || found) exit 0; exit 1 }
  ' "$skill_file"
}

kit_skill_names() {
  local agent="$1" src
  for src in "$KIT_DIR"/skills/*/; do
    [ -d "$src" ] || continue
    if skill_supports_agent "$src/SKILL.md" "$agent"; then
      basename "$src"
    fi
  done | sort -u
}

# Kiểm tra TẤT CẢ collision trước mutation. Hàm không mkdir, không copy, không
# sửa manifest; caller phải chạy cho mọi đích trước merge_rules/copy_skills.
preflight_skills() {
  local dest="$1" agent="$2" manifest="$1/.dotagents-manifest" name failed=0
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    if { [ -e "$dest/$name" ] || [ -L "$dest/$name" ]; } \
      && ! is_managed_skill "$manifest" "$name" \
      && ! is_identical_kit_skill "$dest" "$name"; then
      echo "  ! Collision: $dest/$name là skill có sẵn nhưng không thuộc manifest dotagents." >&2
      failed=1
    fi
  done < <(kit_skill_names "$agent")
  return "$failed"
}

preflight_targets() {
  local failed=0
  while [ "$#" -gt 0 ]; do
    preflight_skills "$1" "$2" || failed=1
    shift 2
  done
  if [ "$failed" = 1 ]; then
    echo "Hủy cài đặt: đổi tên hoặc di chuyển skill riêng đang collision rồi chạy lại." >&2
    return 1
  fi
}

report_rules_check() {
  local agent="$1" dest="$2" src="$3" overlay marker action dup
  overlay=$(rules_overlay_path "$agent")
  if [ ! -f "$dest" ]; then
    marker="file chưa tồn tại"; action="tạo một khối dotagents"
  elif [ ! -s "$dest" ]; then
    marker="file rỗng"; action="ghi một khối dotagents"
  elif grep -qF "$BEGIN_MARK" "$dest"; then
    marker="có marker dotagents"; action="thay khối dotagents, giữ nội dung ngoài marker"
  else
    marker="chưa có marker dotagents"; action="giữ nội dung cũ, nối một khối dotagents"
  fi
  dup=$(duplicate_rules_headings "$dest" "$src")
  echo "  source -> common: $KIT_DIR/rules/common.md; overlay: $overlay"
  echo "  rules  -> $dest ($marker; $dup mục trùng tiêu đề ngoài marker); sẽ $action"
  warn_rules_migration "$dest" "$src"
}

report_check() {
  local scope="$1"
  echo "Kiểm tra an toàn: $scope"
  if [ "$RULES_ONLY" = 1 ]; then
    echo "  skills -> bỏ qua (--rules-only)"
  else
    echo "  skills -> không có collision; sẽ cập nhật các skill trong manifest"
  fi
}

# Copy các skill từ danh mục duy nhất, lọc theo metadata agents trong SKILL.md.
# $1 = thư mục đích, $2 = tên agent (claude | codex)
copy_skills() {
  local dest="$1" agent="$2" name n=0 gone=0 manifest="$1/.dotagents-manifest" new src
  mkdir -p "$dest"
  new="$(mktemp)"
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    src="$KIT_DIR/skills/$name"
    # Xoá trước rồi mới copy: nếu đích đang là symlink, cp -R sẽ báo lỗi
    # "cannot overwrite non-directory with directory" và làm script dừng giữa chừng.
    rm -rf "$dest/$name"
    cp -R "$src" "$dest/$name"
    printf '%s\n' "$name" >> "$new"
    n=$((n + 1))
  done < <(kit_skill_names "$agent")
  # Skill từng phát hành rồi bị cắt. Máy cài từ thời chưa có manifest thì manifest
  # không hề biết chúng tồn tại, nên chạy lại bao nhiêu lần cũng không gỡ được —
  # phải gọi thẳng tên ra đây. Chỉ thêm vào đây tên ĐÃ TỪNG nằm trong repo.
  for name in $REMOVED_SKILLS; do
    grep -qxF "$name" "$new" && continue
    is_managed_skill "$manifest" "$name" || continue
    [ -e "$dest/$name" ] || continue
    rm -rf "$dest/$name"
    echo "  gỡ    -> $name (đã cắt khỏi bộ kit)"
    gone=$((gone + 1))
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

# Skill do dotagents cài là bản sao, commit vào repo dự án là tự đẻ một nhánh sẽ
# lệch dần và không ai nhớ cập nhật. Nhưng KHÔNG ignore cả .claude/skills/ được:
# skill riêng của dự án (ch-capturing-what-worked sinh ra) phải đi theo git thì đồng
# đội clone về mới có. Nên liệt kê đích danh từng tên trong manifest, và ghi lại
# cả khối mỗi lần cài để danh sách không bị cũ.
ensure_gitignore_block_spacing() {
  local file="$1"
  [ -s "$file" ] || return 0
  [ -z "$(tail -c 1 "$file")" ] || printf '\n' >> "$file"
  [ -z "$(tail -n 1 "$file")" ] || printf '\n' >> "$file"
}

ignore_kit_skills() {
  local target="$1" gi="$1/.gitignore" manifest="$1/.claude/skills/.dotagents-manifest" codex_manifest="$1/.codex/skills/.dotagents-manifest"
  local b="# dotagents:begin skills" e="# dotagents:end skills" tmp
  [ -f "$manifest" ] || [ -f "$codex_manifest" ] || return 0
  tmp="$(mktemp)"
  if [ -f "$gi" ]; then
    awk -v b="$b" -v e="$e" '$0==b{s=1} !s{print} $0==e{s=0}' "$gi" > "$tmp"
  fi
  ensure_gitignore_block_spacing "$tmp"
  {
    printf '%s\n' "$b"
    printf '# Skill do ~/dotagents cài — mỗi máy tự chạy install.sh --project.\n'
    printf '# Skill riêng của dự án nằm cạnh đây thì VẪN được commit bình thường.\n'
    printf '.dotagents-state.json\n'
    if [ -f "$manifest" ]; then
      while IFS= read -r name; do
        [ -n "$name" ] && printf '.claude/skills/%s/\n' "$name"
      done < "$manifest"
      printf '.claude/skills/.dotagents-manifest\n'
    fi
    if [ -f "$codex_manifest" ]; then
      while IFS= read -r name; do
        [ -n "$name" ] && printf '.codex/skills/%s/\n' "$name"
      done < "$codex_manifest"
      printf '.codex/skills/.dotagents-manifest\n'
    fi
    printf '%s\n' "$e"
  } >> "$tmp"
  mv "$tmp" "$gi"
  echo "  ignore -> skill của kit thêm vào .gitignore"
}

# Conversation được bỏ qua mặc định ở mọi project đã cài rules. Giữ block riêng
# để installer có thể cập nhật mà không đụng tới các rule khác của dự án.
ignore_conversations() {
  local target="$1" gi="$1/.gitignore" b="# dotagents:begin conversations" e="# dotagents:end conversations" tmp
  tmp="$(mktemp)"
  if [ -f "$gi" ]; then
    awk -v b="$b" -v e="$e" '$0==b{s=1} !s{print} $0==e{s=0}' "$gi" > "$tmp"
  fi
  ensure_gitignore_block_spacing "$tmp"
  {
    printf '%s\n' "$b"
    printf '# Conversation được ignore mặc định; muốn commit file cụ thể thì dùng git add -f.\n'
    printf '/conversation/\n'
    printf '%s\n' "$e"
  } >> "$tmp"
  mv "$tmp" "$gi"
  echo "  ignore -> conversation/"
}

# Giữ 3 bản gần nhất. Rules nằm trong marker nên các bản backup gần như trùng
# nhau — cài lại vài chục lần là vài chục file rác, mà bản thứ tư trở đi chưa
# bao giờ dùng tới. Xoá theo đúng tiền tố "<file>.bak." nên không đụng file khác.
backup() {
  local f="$1" old
  [ -f "$f" ] && [ -s "$f" ] || return 0
  cp "$f" "$f.bak.$(date +%Y%m%d%H%M%S)"
  old="$(ls -1t "$f".bak.* 2>/dev/null | tail -n +4)"
  [ -n "$old" ] && printf '%s\n' "$old" | while IFS= read -r b; do rm -f "$b"; done
  return 0
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

# Khai MCP server playwright cho Claude Code. Không có nó thì skill
# ch-verifying-ui-with-playwright nằm đó mà không có công cụ browser_* nào để chạy.
add_playwright_claude() {
  local f="$1/.claude.json"
  [ -f "$f" ] || echo '{}' > "$f"
  python3 - "$f" <<'PY'
import json, sys
p = sys.argv[1]
try:
    with open(p) as f: cfg = json.load(f)
except ValueError:
    print("  .claude.json hỏng — bỏ qua, tự khai playwright bằng: claude mcp add", file=sys.stderr)
    sys.exit(0)
srv = cfg.setdefault("mcpServers", {})
if "playwright" in srv:
    sys.exit(0)
srv["playwright"] = {"type": "stdio", "command": "npx",
                     "args": ["@playwright/mcp@latest"], "env": {}}
with open(p, "w") as f: json.dump(cfg, f, indent=2, ensure_ascii=False)
print("  mcp    -> playwright thêm vào " + p)
PY
}

# Codex: bật subagent và khai playwright. Chỉ nối thêm bảng còn thiếu vào cuối
# file, không sửa gì đang có — TOML mà khai trùng tên bảng là lỗi cú pháp.
tune_codex_config() {
  local f="$1/config.toml" added=0
  [ -f "$f" ] || : > "$f"
  if ! grep -q '^\[features\]' "$f"; then
    printf '\n[features]\nmulti_agent = true\n' >> "$f"
    echo "  config -> [features] multi_agent = true"
    added=1
  elif ! grep -q 'multi_agent' "$f"; then
    sed -i '/^\[features\]$/a multi_agent = true' "$f"
    echo "  config -> multi_agent = true thêm vào [features]"
    added=1
  fi
  if ! grep -q '^\[mcp_servers\.playwright\]' "$f"; then
    printf '\n[mcp_servers.playwright]\ncommand = "npx"\nargs = ["@playwright/mcp@latest"]\n' >> "$f"
    echo "  mcp    -> playwright thêm vào $f"
    added=1
  fi
  [ "$added" = 0 ] && echo "  config -> $f đã đủ"
  return 0
}

# Ledger snapshots stay in installer temp storage; --check never records state.
snapshot_install_state() {
  local agent="$1" root="$2"
  local config_args=()
  [ "$MODE" = global ] && [ "$RULES_ONLY" = 0 ] && config_args+=(--config)
  python3 "$KIT_DIR/scripts/dotagents_lifecycle.py" snapshot "$root" "$agent" "$RULES_TMP_DIR/$agent-before.json" "${config_args[@]}"
}

record_install_state() {
  local agent="$1" root="$2"
  local config_args=()
  [ "$MODE" = global ] && [ "$RULES_ONLY" = 0 ] && config_args+=(--config)
  python3 "$KIT_DIR/scripts/dotagents_lifecycle.py" record "$root" "$agent" "$RULES_TMP_DIR/$agent-before.json" "${config_args[@]}"
}

RULES_TMP_DIR=""
trap '[ -z "$RULES_TMP_DIR" ] || rm -rf "$RULES_TMP_DIR"' EXIT

if [ "$MODE" = project ]; then
  TARGET="${TARGET:-$PWD}"
  [ -d "$TARGET" ] || { echo "Không thấy thư mục: $TARGET" >&2; exit 1; }
  TARGET="$(cd "$TARGET" && pwd)"
  # Project không chọn agent thì giữ hành vi cũ: cài cho cả hai.
  if [ "$WANT_CLAUDE" = 0 ] && [ "$WANT_CODEX" = 0 ]; then
    WANT_CLAUDE=1
    WANT_CODEX=1
  fi
  prepare_rules_sources || exit 1
  project_targets=()
  [ "$WANT_CLAUDE" = 1 ] && project_targets+=("$TARGET/.claude/skills" claude)
  [ "$WANT_CODEX" = 1 ] && project_targets+=("$TARGET/.codex/skills" codex)
  if [ "$RULES_ONLY" = 0 ]; then
    preflight_targets "${project_targets[@]}" || exit 1
  fi
  project_scope="PER-PROJECT tại $TARGET"
  [ "$WANT_CLAUDE" = 1 ] && project_scope+=" + Claude Code"
  [ "$WANT_CODEX" = 1 ] && project_scope+=" + Codex"
  if [ "$CHECK" = 1 ]; then
    report_check "$project_scope"
    [ "$WANT_CLAUDE" = 1 ] && report_rules_check claude "$TARGET/CLAUDE.md" "$CLAUDE_RULES_SOURCE"
    [ "$WANT_CODEX" = 1 ] && report_rules_check codex "$TARGET/AGENTS.md" "$CODEX_RULES_SOURCE"
    exit 0
  fi
  [ "$WANT_CLAUDE" = 1 ] && snapshot_install_state claude "$TARGET"
  [ "$WANT_CODEX" = 1 ] && snapshot_install_state codex "$TARGET"
  echo "Cài $project_scope"
  if [ "$WANT_CLAUDE" = 1 ]; then
    merge_rules "$TARGET/CLAUDE.md" "$CLAUDE_RULES_SOURCE"
  fi
  if [ "$WANT_CODEX" = 1 ]; then
    merge_rules "$TARGET/AGENTS.md" "$CODEX_RULES_SOURCE"
  fi
  if [ "$RULES_ONLY" = 0 ]; then
    [ "$WANT_CLAUDE" = 1 ] && copy_skills "$TARGET/.claude/skills" claude
    [ "$WANT_CODEX" = 1 ] && copy_skills "$TARGET/.codex/skills" codex
    [ -e "$TARGET/.git" ] && ignore_kit_skills "$TARGET"
    ignore_conversations "$TARGET"
    # Cấu hình machine-level của Claude chỉ liên quan khi cài Claude vào project.
    if [ "$WANT_CLAUDE" = 1 ]; then
      if [ -f "$CLAUDE_DIR/settings.json" ] && python3 -c "
import json,sys
c=json.load(open('$CLAUDE_DIR/settings.json'))
sys.exit(0 if c.get('enabledPlugins',{}).get('superpowers@claude-plugins-official') else 1)
" 2>/dev/null; then
        echo "  ! Máy đang bật plugin superpowers ($CLAUDE_DIR/settings.json), mà dự án vừa" >&2
        echo "    nhận bản superpowers trong repo — phiên sau mỗi skill sẽ hiện HAI lần." >&2
        echo "    Tắt bằng /plugin, hoặc chạy '$0 --claude' để installer tắt hộ." >&2
      fi
      if ! python3 -c "
import json,sys,os
p=os.path.expanduser('$CLAUDE_DIR/.claude.json')
sys.exit(0 if os.path.exists(p) and 'playwright' in json.load(open(p)).get('mcpServers',{}) else 1)
" 2>/dev/null; then
        echo "  ! Máy chưa khai MCP playwright, nên skill ch-verifying-ui-with-playwright sẽ không" >&2
        echo "    có công cụ browser_* nào để gọi. Chạy '$0 --claude' để khai (cấp máy)." >&2
      fi
    fi
  else
    echo "  skills -> bỏ qua (--rules-only)"
  fi
  [ "$WANT_CLAUDE" = 1 ] && record_install_state claude "$TARGET"
  [ "$WANT_CODEX" = 1 ] && record_install_state codex "$TARGET"
else
  prepare_rules_sources || exit 1
  if [ "$RULES_ONLY" = 0 ]; then
    targets=()
    [ "$WANT_CLAUDE" = 1 ] && targets+=("$CLAUDE_DIR/skills" claude)
    [ "$WANT_CODEX" = 1 ] && targets+=("$CODEX_DIR/skills" codex)
    preflight_targets "${targets[@]}" || exit 1
  fi
  if [ "$CHECK" = 1 ]; then
    report_check "GLOBAL"
    [ "$WANT_CLAUDE" = 1 ] && report_rules_check claude "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_RULES_SOURCE"
    [ "$WANT_CODEX" = 1 ] && report_rules_check codex "$CODEX_DIR/AGENTS.md" "$CODEX_RULES_SOURCE"
    exit 0
  fi
  [ "$WANT_CLAUDE" = 1 ] && snapshot_install_state claude "$CLAUDE_DIR"
  [ "$WANT_CODEX" = 1 ] && snapshot_install_state codex "$CODEX_DIR"
  if [ "$WANT_CLAUDE" = 1 ]; then
    echo "Cài CLAUDE CODE vào $CLAUDE_DIR"
    mkdir -p "$CLAUDE_DIR"
    backup "$CLAUDE_DIR/CLAUDE.md"
    merge_rules "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_RULES_SOURCE"
    if [ "$RULES_ONLY" = 0 ]; then
      copy_skills "$CLAUDE_DIR/skills" claude
      tune_settings "$CLAUDE_DIR/settings.json"
      add_playwright_claude "$CLAUDE_DIR"
    else
      echo "  skills -> bỏ qua (--rules-only)"
    fi
  fi
  if [ "$WANT_CODEX" = 1 ]; then
    echo "Cài CODEX vào $CODEX_DIR"
    mkdir -p "$CODEX_DIR"
    backup "$CODEX_DIR/AGENTS.md"
    merge_rules "$CODEX_DIR/AGENTS.md" "$CODEX_RULES_SOURCE"
    if [ "$RULES_ONLY" = 0 ]; then
      copy_skills "$CODEX_DIR/skills" codex
      tune_codex_config "$CODEX_DIR"
    else
      echo "  skills -> bỏ qua (--rules-only)"
    fi
  fi
  [ "$WANT_CLAUDE" = 1 ] && record_install_state claude "$CLAUDE_DIR"
  [ "$WANT_CODEX" = 1 ] && record_install_state codex "$CODEX_DIR"
fi

echo
echo "Xong. Khởi động lại phiên agent để nạp rules mới."
