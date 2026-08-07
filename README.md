# claude-kit

Bộ rules + skills dùng chung cho Claude Code. Clone về máy nào, dự án nào cũng cài được trong một lệnh.

## Cài

```bash
git clone <url-repo-cua-ban> ~/claude-kit
cd ~/claude-kit
./install.sh
```

Mặc định là **global** — cài vào `~/.claude/` (hoặc `$CLAUDE_CONFIG_DIR` nếu bạn đặt biến đó), áp dụng cho mọi dự án trên máy. Làm một lần mỗi máy.

### Cài riêng cho một dự án

```bash
cd ~/duong/dan/du-an
~/claude-kit/install.sh --project
```

Copy rules vào `CLAUDE.md` và skills vào `.claude/skills/` của chính dự án. Commit hai thứ đó thì đồng đội clone repo về là có sẵn — không cần cài gì.

Nếu không muốn 492 KB skills nằm trong repo dự án:

```bash
~/claude-kit/install.sh --project --rules-only
```

## Có gì bên trong

- **`CLAUDE.md`** — rules: trả lời tiếng Việt, trigger graphify, danh sách skill opt-in, quy tắc checkbox theo task của superpowers, quy tắc viết summary khi xong plan.
- **`skills/`** — 14 skill:
  - `graphify` — biến mọi input thành knowledge graph
  - Frontend/UI: `taste-skill`, `taste-skill-v1`, `soft-skill`, `minimalist-skill`, `brutalist-skill`, `gpt-tasteskill`, `redesign-skill`
  - Sinh ảnh: `imagegen-frontend-web`, `imagegen-frontend-mobile`, `image-to-code-skill`, `brandkit`
  - Khác: `stitch-skill`, `output-skill`

  Tất cả skill thiết kế đều **opt-in** — chỉ chạy khi gọi đích danh (`/taste-skill`, `/brandkit`…).
- **Plugin superpowers** — installer bật sẵn trong `settings.json`. Lần đầu mở Claude Code trên máy mới, nếu plugin chưa tự tải về thì cài bằng `/plugin`.

## Chạy lại

An toàn. Rules nằm giữa cặp marker `claude-kit:begin` / `claude-kit:end`, chạy lại chỉ thay phần trong khối — mọi thứ bạn tự viết ngoài khối được giữ nguyên. Bản `CLAUDE.md` global cũ được backup kèm timestamp.

## Cập nhật bộ kit

Sửa `CLAUDE.md` hoặc `skills/` trong repo này, commit, push. Máy khác `git pull && ./install.sh` là đồng bộ.

## Yêu cầu

`bash`, `python3` (chỉ dùng để sửa `settings.json` an toàn).
