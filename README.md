# dotagents

Rules + skills dùng chung cho các coding agent. Clone về máy nào, dự án nào cũng cài được trong một lệnh.

Hiện hỗ trợ **Claude Code** và **Codex**. Hai bên đọc cùng một định dạng `SKILL.md`, nên `shared/skills/` phục vụ được cả hai mà không cần chuyển đổi.

## Cài

```bash
git clone git@github.com:chauipp/dotagents.git ~/dotagents
cd ~/dotagents
./install.sh
```

Không tham số thì script tự dò: thấy `~/.claude` thì cài cho Claude Code, thấy `~/.codex` thì cài cho Codex, có cả hai thì cài cả hai. Làm một lần mỗi máy, sau đó mọi dự án trên máy đều có.

Chỉ định rõ nếu muốn:

```bash
./install.sh --claude
./install.sh --codex
./install.sh --all
```

Dùng config dir khác mặc định:

```bash
CLAUDE_CONFIG_DIR=~/.claude-acc2 ./install.sh --claude
CODEX_HOME=~/.codex-work         ./install.sh --codex
```

### Cài riêng cho một dự án

```bash
cd ~/duong/dan/du-an
~/dotagents/install.sh --project
```

Ghi rules vào `CLAUDE.md` + `AGENTS.md` và skills vào `.claude/skills/` của chính dự án. Commit những thứ đó thì đồng đội clone repo về là có sẵn, không cần cài gì.

Không muốn ~500 KB skills nằm trong repo dự án:

```bash
~/dotagents/install.sh --project --rules-only
```

## Cấu trúc

```
shared/skills/     14 skill, dùng chung cho mọi agent
claude/CLAUDE.md   rules bản Claude Code
codex/AGENTS.md    rules bản Codex
install.sh
```

Thêm agent mới sau này chỉ cần thêm một thư mục rules và một nhánh trong `install.sh`; `shared/skills/` giữ nguyên.

## Có gì bên trong

**Rules** — trả lời tiếng Việt (suy luận kỹ thuật bằng tiếng Anh), trigger graphify, danh sách skill opt-in, quy tắc checkbox cho từng task trong plan, quy tắc viết summary khi plan hoàn tất kèm chuỗi trỏ nhau spec ↔ plan ↔ summary.

**Skills** — 14 skill:

- `graphify` — biến mọi input thành knowledge graph
- Frontend/UI: `taste-skill`, `taste-skill-v1`, `soft-skill`, `minimalist-skill`, `brutalist-skill`, `gpt-tasteskill`, `redesign-skill`
- Sinh ảnh: `imagegen-frontend-web`, `imagegen-frontend-mobile`, `image-to-code-skill`, `brandkit`
- Khác: `stitch-skill`, `output-skill`

Skill thiết kế đều **opt-in** — chỉ chạy khi gọi đích danh (`/taste-skill`, `/brandkit`…).

**Plugin superpowers** (chỉ Claude Code) — installer bật sẵn trong `settings.json`. Lần đầu trên máy mới, nếu plugin chưa tự tải về thì cài bằng `/plugin`.

## Chạy lại

An toàn. Rules nằm giữa cặp marker `dotagents:begin` / `dotagents:end`, chạy lại chỉ thay phần trong khối — mọi thứ bạn tự viết ngoài khối được giữ nguyên. File rules cũ được backup kèm timestamp. Skills bị ghi đè theo tên; skill hệ thống của Codex trong `~/.codex/skills/.system/` không bị đụng tới.

## Cập nhật bộ kit

Sửa `claude/CLAUDE.md`, `codex/AGENTS.md` hoặc `shared/skills/`, commit, push. Máy khác `git pull && ./install.sh`.

## Yêu cầu

`bash`, `python3` (chỉ dùng để sửa `settings.json` an toàn).
