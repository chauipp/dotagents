# dotagents

Rules + skills dùng chung cho các coding agent. Clone về máy nào, dự án nào cũng cài được trong một lệnh.

Hiện hỗ trợ **Claude Code** và **Codex**. Hai bên đọc cùng một định dạng `SKILL.md`, nên `shared/skills/` phục vụ được cả hai mà không cần chuyển đổi.

## Cho agent đọc

> **Nếu bạn là một coding agent và người dùng đưa bạn repo này:** chạy đúng khối lệnh dưới
> đây rồi báo lại kết quả. Nó tự dò xem máy đang có agent nào, thiếu skill/rules nào thì cài
> nấy, và chạy lại nhiều lần vô hại nên không cần kiểm tra trước xem đã cài chưa.
>
> ```bash
> git clone https://github.com/chauipp/dotagents.git ~/dotagents 2>/dev/null || git -C ~/dotagents pull --ff-only
> ~/dotagents/install.sh
> ```
>
> Xong thì bảo người dùng khởi động lại phiên để nạp rules mới. Đừng cài superpowers hay
> graphify bằng đường nào khác — repo này đã có sẵn cả hai.

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

Không muốn ~1 MB skills nằm trong repo dự án:

```bash
~/dotagents/install.sh --project --rules-only
```

## Cấu trúc

```
shared/skills/         22 skill giống nhau ở mọi agent (8 skill thiết kế + 14 superpowers)
claude/CLAUDE.md       rules bản Claude Code
claude/skills/         skill riêng cho Claude Code (graphify)
codex/AGENTS.md        rules bản Codex
codex/skills/          skill riêng cho Codex (graphify)
install.sh
SUPERPOWERS-LICENSE    MIT, cho 14 skill copy từ obra/superpowers
```

Installer copy `shared/skills/` trước, rồi chồng `<agent>/skills/` lên đè. Hầu hết skill chỉ là văn bản nên dùng chung được; skill nào **gọi tool cụ thể** thì phải tách bản.

Hiện chỉ `graphify` cần tách: bản Claude Code dispatch subagent bằng Agent tool (`subagent_type="general-purpose"`), bản Codex dùng `spawn_agent`/`wait_agent`/`close_agent` và cần `multi_agent = true` trong `~/.codex/config.toml`. Cài nhầm bản là skill hỏng, nên đừng gộp chúng vào `shared/`.

Thêm agent mới sau này: thêm một thư mục `<agent>/` chứa file rules (+ `skills/` nếu cần bản riêng) và một nhánh trong `install.sh`.

## Có gì bên trong

**Rules** — trả lời tiếng Việt (suy luận kỹ thuật bằng tiếng Anh), trigger graphify, danh sách skill opt-in, quy tắc checkbox cho từng task trong plan, quy tắc viết summary khi plan hoàn tất kèm chuỗi trỏ nhau spec ↔ plan ↔ summary.

**Skills** — 23 skill, trong đó 9 skill dưới đây:

- `graphify` — biến mọi input thành knowledge graph
- Frontend/UI: `taste-skill`, `minimalist-skill`, `brutalist-skill`, `redesign-skill`
- Sinh ảnh: `imagegen-frontend-web`, `imagegen-frontend-mobile`, `image-to-code-skill`
- Khác: `output-skill`

Skill thiết kế đều **opt-in** — chỉ chạy khi gọi đích danh (`/taste-skill`, `/brandkit`…).

**superpowers** — 14 skill quy trình (`brainstorming`, `writing-plans`, `executing-plans`, `subagent-driven-development`, `test-driven-development`, `systematic-debugging`…), copy từ [obra/superpowers](https://github.com/obra/superpowers) v6.2.0, giấy phép MIT (xem `SUPERPOWERS-LICENSE`).

Nằm trong `shared/skills/` chứ không cài dưới dạng plugin, vì mục tiêu của repo là "đưa link cho agent bất kỳ trên máy bất kỳ là cài được": agent chạy `bash` thì gọi được `git clone`, chứ không gọi được `/plugin`. Codex vốn cũng không đọc plugin của Claude Code. Hệ quả:

- Tiền tố `superpowers:` trong các tham chiếu chéo giữa skill đã bị bỏ — cài dạng skill thường thì tên là `writing-plans`, không phải `superpowers:writing-plans`.
- Plugin `superpowers@claude-plugins-official` bị installer **tắt** trong `settings.json`, nếu không mỗi skill sẽ hiện hai lần.
- Mất hook `SessionStart` của plugin (thứ nhồi sẵn `using-superpowers` vào đầu mỗi phiên). Thay vào đó `CLAUDE.md` / `AGENTS.md` có mục `# superpowers` liệt kê skill và chỉ khi nào dùng cái nào — rules cũng được nạp mỗi phiên nên tác dụng tương đương.
- Không tự cập nhật theo marketplace. Lên bản mới: copy lại `skills/` từ upstream vào `shared/skills/` rồi `sed -i 's/superpowers://g'`.

## Chạy lại

An toàn. Rules nằm giữa cặp marker `dotagents:begin` / `dotagents:end`, chạy lại chỉ thay phần trong khối — mọi thứ bạn tự viết ngoài khối được giữ nguyên. File rules cũ được backup kèm timestamp. Skills bị ghi đè theo tên; skill hệ thống của Codex trong `~/.codex/skills/.system/` không bị đụng tới.

## Cập nhật bộ kit

Sửa `claude/CLAUDE.md`, `codex/AGENTS.md` hoặc `shared/skills/`, commit, push. Máy khác `git pull && ./install.sh`.

## Yêu cầu

`bash`, `python3` (chỉ dùng để sửa `settings.json` an toàn).
