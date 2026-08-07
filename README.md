# dotagents

Rules + skills dùng chung cho các coding agent. Clone về máy nào, dự án nào cũng cài được trong một lệnh.

Hiện hỗ trợ **Claude Code** và **Codex**. Hai bên đọc cùng một định dạng `SKILL.md`, nên `shared/skills/` phục vụ được cả hai mà không cần chuyển đổi.

## Cho agent đọc

> **Nếu bạn là một coding agent và người dùng đưa bạn repo này:** làm hết 4 bước dưới đây theo
> đúng thứ tự, rồi báo lại. Mọi bước đều chạy lại được nhiều lần mà vô hại, nên đừng mất công
> kiểm tra trước xem đã cài chưa — cứ chạy.

### Bước 1 — Cài

```bash
git clone https://github.com/chauipp/dotagents.git ~/dotagents 2>/dev/null || git -C ~/dotagents pull --ff-only
~/dotagents/install.sh
```

Repo public, clone ẩn danh được, không cần SSH key.

Không cần truyền `CLAUDE_CONFIG_DIR` — Claude Code tự export biến đó xuống tiến trình con, nên
installer luôn trúng đúng thư mục config của phiên đang chạy.

Nếu nó báo `Không thấy ... lẫn ...` thì máy chưa từng chạy agent nào nên chưa có thư mục config.
Chạy lại với `--claude` hoặc `--codex` để nó tạo:

```bash
~/dotagents/install.sh --claude    # hoặc --codex, hoặc --all
```

### Bước 2 — Kiểm phần mềm máy phải có sẵn

Installer khai đúng config nhưng **không tải hộ phần mềm**. Chạy khối này và đọc kết quả:

```bash
for c in git node npx python3; do
  command -v "$c" >/dev/null && echo "  có    $c" || echo "  THIẾU $c"
done
command -v uv >/dev/null && echo "  có    uv" || echo "  (không có uv — graphify sẽ dùng pip, vẫn chạy được)"
if ls ~/.cache/ms-playwright/chromium-* >/dev/null 2>&1 \
  || ls ~/Library/Caches/ms-playwright/chromium-* >/dev/null 2>&1; then
  echo "  có    chromium"
else
  echo "  THIẾU chromium"
fi
```

Xử lý theo kết quả:

| Thiếu | Hậu quả | Làm gì |
|---|---|---|
| `node` / `npx` | `verifying-ui-with-playwright` **không chạy được** — không có công cụ `browser_*` nào | Báo người dùng cài Node.js. Đừng tự cài bằng package manager hệ thống mà không hỏi |
| `chromium` | Playwright mở được server nhưng không có trình duyệt | `npx playwright install chromium` (vài trăm MB, cần mạng) |
| `python3` | Installer đã không chạy nổi từ bước 1 | Báo người dùng |
| `uv` | Không sao | Bỏ qua, `graphify` sẽ dùng `pip` |

Thiếu thứ nào mà không xử lý được thì **nói thẳng ra trong báo cáo**. Đừng im lặng bỏ qua rồi
để người dùng phát hiện lúc gọi tới skill.

### Bước 3 — Kiểm đã cài đúng chưa

```bash
for d in ~/.claude* ~/.codex; do
  [ -f "$d/skills/.dotagents-manifest" ] || continue
  r="$d/CLAUDE.md"; [ -f "$r" ] || r="$d/AGENTS.md"
  echo "  $d — $(wc -l < "$d/skills/.dotagents-manifest") skill, $(grep -c 'dotagents:begin' "$r") khối rules"
done
```

Chỉ liệt kê thư mục có `.dotagents-manifest`, tức thư mục thật sự do dotagents cài — thư mục
config của account khác trên cùng máy không lọt vào.

Mỗi thư mục phải ra **22 skill và đúng 1 khối rules**. Ra 2 khối là file đang chứa rules hai lần —
xem mục [Lần đầu chạy trên máy đã có sẵn CLAUDE.md](#lần-đầu-chạy-trên-máy-đã-có-sẵn-claudemd).
Không ra dòng nào là bước 1 chưa chạy được.

### Bước 4 — Báo lại

Nói rõ: cài cho agent nào, bao nhiêu skill, thiếu phần mềm gì chưa xử lý được.

Rồi bảo người dùng **khởi động lại phiên** — skill và rules chỉ có hiệu lực sau khi khởi động lại,
nhìn ngay bây giờ là chưa thấy.

**Đừng** cài superpowers hay graphify bằng đường nào khác (marketplace, `/plugin`, `pip`) — repo
này đã có sẵn cả hai, cài chồng là mỗi skill hiện hai lần.

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
shared/skills/         21 skill giống nhau ở mọi agent (5 thiết kế + 14 superpowers + 2 tự viết)
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

**Rules** — trả lời tiếng Việt (suy luận kỹ thuật bằng tiếng Anh), trigger graphify, danh sách skill opt-in, mặc định mỗi task một worktree (tuyên bố sẵn để `using-git-worktrees` khỏi hỏi), bắt kiểm UI trước khi báo xong, quy tắc checkbox cho từng task trong plan, quy tắc viết summary khi plan hoàn tất kèm chuỗi trỏ nhau spec ↔ plan ↔ summary.

**Skills** — 22 skill, trong đó 8 skill dưới đây:

- `graphify` — biến mọi input thành knowledge graph
- Tự viết: `verifying-ui-with-playwright` (bắt kiểm UI bằng trình duyệt thật trước khi báo xong), `capturing-what-worked` (ghi lại cách làm đúng vào `docs/recipes/` để lần sau khỏi mò lại)
- Frontend/UI: `taste-skill`, `minimalist-skill`, `brutalist-skill`, `redesign-skill`
- Khác: `output-skill`

Skill thiết kế đều **opt-in** — chỉ chạy khi gọi đích danh (`/taste-skill`, `/redesign-skill`…).

**superpowers** — 14 skill quy trình (`brainstorming`, `writing-plans`, `executing-plans`, `subagent-driven-development`, `test-driven-development`, `systematic-debugging`…), copy từ [obra/superpowers](https://github.com/obra/superpowers) v6.2.0, giấy phép MIT (xem `SUPERPOWERS-LICENSE`).

Nằm trong `shared/skills/` chứ không cài dưới dạng plugin, vì mục tiêu của repo là "đưa link cho agent bất kỳ trên máy bất kỳ là cài được": agent chạy `bash` thì gọi được `git clone`, chứ không gọi được `/plugin`. Codex vốn cũng không đọc plugin của Claude Code. Hệ quả:

- Tiền tố `superpowers:` trong các tham chiếu chéo giữa skill đã bị bỏ — cài dạng skill thường thì tên là `writing-plans`, không phải `superpowers:writing-plans`.
- Plugin `superpowers@claude-plugins-official` bị installer **tắt** trong `settings.json`, nếu không mỗi skill sẽ hiện hai lần.
- Mất hook `SessionStart` của plugin (thứ nhồi sẵn `using-superpowers` vào đầu mỗi phiên). Thay vào đó `CLAUDE.md` / `AGENTS.md` có mục `# superpowers` liệt kê skill và chỉ khi nào dùng cái nào — rules cũng được nạp mỗi phiên nên tác dụng tương đương.
- Không tự cập nhật theo marketplace. Lên bản mới: copy lại `skills/` từ upstream vào `shared/skills/` rồi `sed -i 's/superpowers://g'`.

## Chạy lại

An toàn. Rules nằm giữa cặp marker `dotagents:begin` / `dotagents:end`, chạy lại chỉ thay phần trong khối — mọi thứ bạn tự viết ngoài khối được giữ nguyên. File rules cũ được backup kèm timestamp.

Skills bị ghi đè theo tên. Skill nào lần trước dotagents cài mà nay repo không còn thì bị gỡ — đối chiếu qua file `.dotagents-manifest` nằm trong chính thư mục skills, nên skill bạn tự thêm tay và `~/.codex/skills/.system/` của Codex không bị đụng tới.

### Lần đầu chạy trên máy đã có sẵn CLAUDE.md

Installer giữ nguyên nội dung cũ và nối khối `dotagents` xuống dưới. Nó **không** tự xoá phần cũ, vì không có cách nào chắc chắn phân biệt rules bản cũ với ghi chú riêng của bạn.

Nếu phần cũ **trùng tiêu đề mục** với rules mới, installer sẽ cảnh báo: gần như chắc chắn đó là bản cũ của chính bộ rules này, và để lại thì hai bản mâu thuẫn nhau — danh sách skill đã đổi qua nhiều lần cắt, agent đọc bản cũ sẽ tưởng những skill đã gỡ vẫn còn. Lúc đó mở file ra, xoá phần nằm **trên** dòng `dotagents:begin`.

## Cập nhật bộ kit

Sửa `claude/CLAUDE.md`, `codex/AGENTS.md` hoặc `shared/skills/`, commit, push. Máy khác `git pull && ./install.sh`.

## Máy mới cần gì thêm

Installer lo hết phần config, nhưng ba thứ dưới đây là phần mềm phải có sẵn trên máy:

- **`node` / `npx`** — cho MCP server playwright (`npx @playwright/mcp@latest`). Lần chạy đầu npx tự tải về. Chưa có trình duyệt thì `npx playwright install chromium`.
- **`uv` hoặc `pip`** — `graphify` tự cài gói `graphifyy` lần đầu chạy, qua `uv tool install` nếu có `uv`, không thì `pip install`.
- **`GEMINI_API_KEY`** (tuỳ chọn) — chỉ cần nếu muốn graphify trích ngữ nghĩa bằng Gemini.

Những gì installer TỰ làm, không phải đụng tay:

| | Claude Code | Codex |
|---|---|---|
| Rules | `CLAUDE.md` | `AGENTS.md` |
| Skills | `skills/` | `skills/` |
| MCP playwright | `.claude.json` | `[mcp_servers.playwright]` trong `config.toml` |
| Subagent | có sẵn | `[features] multi_agent = true` |
| Tắt plugin superpowers trùng | `settings.json` | — |
| Bỏ trailer `Co-Authored-By` | `settings.json` | — |

Sửa config đều là **nối thêm phần còn thiếu**, không đụng gì đang có: `.claude.json` đã khai `playwright` rồi thì bỏ qua, `config.toml` đã có `[features]` thì chỉ cảnh báo chứ không sửa (khai trùng tên bảng là lỗi cú pháp TOML).

## Yêu cầu

`bash`, `python3` (sửa `settings.json` và `.claude.json` an toàn).
