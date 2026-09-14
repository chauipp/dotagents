# Ngôn ngữ
- Luôn trả lời người dùng bằng tiếng Việt.

# Bảo toàn danh tính Git
- Trước mọi commit hoặc push, **bắt buộc** dùng skill `preserving-user-git-identity`.
- Chỉ dùng `user.name` và `user.email` Git hiện tại; không tự đặt/sửa chúng, không dùng `--author`, tài khoản bot hay danh tính công cụ tự động.
- Nếu thiếu một trong hai giá trị, dừng trước commit/push và yêu cầu người dùng cấu hình hoặc xác nhận.
- Không thêm hoặc giữ attribution công cụ tự động trong code, commit message/template/trailer, PR, changelog hay metadata do mình tạo; vẫn giữ copyright, license và provenance đã có nếu người dùng không yêu cầu xóa.

# superpowers
- Bộ 14 skill quy trình đã cài sẵn. Việc nhiều bước thì **gọi Skill tool với `using-superpowers`
  trước** — nó là mục lục, chỉ ra việc nào dùng skill nào.
- Ánh xạ nhanh: "làm tính năng X" → `brainstorming` rồi `writing-plans`; "sửa bug này" →
  `systematic-debugging`; đã có plan → `subagent-driven-development` (dispatch bằng Agent tool),
  hoặc `executing-plans` nếu không dùng subagent.
- Đây là bản copy trong repo, KHÔNG phải plugin, nên các skill gọi nhau bằng tên trần
  (`writing-plans`) chứ không có tiền tố `superpowers:`.

# Worktree cho mỗi task
- **Đây là tuyên bố sẵn cho skill `using-git-worktrees` — nó được phép làm luôn, KHÔNG phải
  hỏi xin phép nữa.**
- Mặc định mọi task đều làm trong một worktree riêng. Xong và đúng rồi mới merge về nhánh chính,
  qua skill `finishing-a-development-branch`.
- Chỉ làm thẳng trên nhánh chính khi người dùng nói rõ, ví dụ "sửa thẳng trên main", "khỏi
  worktree". Việc gấp hay việc nhỏ KHÔNG phải là lý do bỏ qua.
- Đang ở sẵn trong một worktree rồi thì làm tiếp tại đó, đừng tạo worktree lồng nhau.

# Kiểm UI trước khi báo xong
- Task có đụng tới thứ người dùng nhìn thấy trên trình duyệt (component, trang, CSS, form,
  luồng bấm) thì **bắt buộc** dùng skill `verifying-ui-with-playwright` trước khi nói là xong.
- Test unit xanh không thay được việc mở trình duyệt xem tận mắt.
- Không dựng được app thì nói thẳng là chưa kiểm được và nhờ người dùng xem giúp — không được
  báo xong.

# Ghi lại cách làm đúng
- **Đầu mỗi task, nếu repo có `docs/recipes/` thì `ls` nó trước.** Skill thì tự hiện trong danh
  sách, còn recipe nằm im — không chủ động nhìn thì viết ra cũng vô ích.
- Làm xong một task VÀ đã kiểm chứng là đúng thì chạy skill `capturing-what-worked` để cân nhắc
  ghi lại. Nó có cổng chặn riêng, hầu hết task sẽ không đáng ghi — cứ để nó tự quyết.
- Ba chỗ ghi, `capturing-what-worked` có cây quyết định đầy đủ:
  - Đúng ở mọi dự án → `~/dotagents/shared/skills/` rồi chạy `~/dotagents/install.sh`
  - Quy trình riêng của dự án này → `<dự án>/.claude/skills/<tên>/SKILL.md` (Claude) hoặc `<dự án>/.codex/skills/<tên>/SKILL.md` (Codex)
  - Kiến thức riêng của dự án này → `<dự án>/docs/recipes/<slug>.md`
- Viết skill mà cần chặt chẽ (loại luật agent hay lách) thì dùng skill `writing-skills` — nó bắt
  chạy subagent thử trước để xem agent lách bằng cớ gì. Chỉ là tài liệu hướng dẫn thì viết thẳng.

# Không commit skill của bộ kit vào repo dự án
- `.claude/skills/` và `.codex/skills/` trong dự án chứa bản sao kit do `~/dotagents/install.sh --project` cài, cùng các skill viết riêng cho dự án.
  **Chỉ skill viết riêng cho dự án mới được commit.**
- Installer tự ghi khối `# dotagents:begin skills` vào `.gitignore` liệt kê đích danh skill của
  kit. Đừng xoá khối đó, cũng đừng `git add -f` những đường dẫn nằm trong đó.
- Máy khác thiếu skill thì chạy `~/dotagents/install.sh --project`, chứ không phải lấy từ repo
  dự án — commit bản sao vào là tạo một nhánh sẽ lệch dần khỏi bộ kit mà không ai nhớ cập nhật.

# Skill thiết kế (opt-in)
- Các skill sau **chỉ chạy khi người dùng gọi đích danh**, không tự kích hoạt:
  - Frontend/UI: `taste-skill` (mặc định), `minimalist-skill`, `brutalist-skill`, `redesign-skill`
  - Khác: `output-skill` (chống cắt ngắn output)

# Tài liệu kế hoạch: spec, plan, summary
- Ba file nằm trong `docs/superpowers/{specs,plans,summaries}/`. Dự án chưa có thì tạo đủ cả ba
  folder ngay lần đầu chạy `writing-plans`. (Tên folder giữ nguyên vì các dự án cũ đang dùng.)
- Cùng ngày, cùng slug: `<ngày>-<slug>-design.md` / `<ngày>-<slug>.md` / `<ngày>-<slug>-summary.md`.
- **Trỏ nhau cả ba mắt**, để mở file nào cũng đi tới hai file kia:
  - Cuối spec: `## Plan thực thi` → `../plans/…`, thêm ngay khi plan vừa tạo.
  - Cuối plan: `## Kết quả` → `../summaries/…` (thay cho mục `## Summary` cũ).
  - Đầu summary: dòng trỏ về `../specs/…` và `../plans/…`.

# Tài liệu kế hoạch: checkbox theo từng task
- Trong plan, mỗi TASK cấp cao phải có checkbox riêng trên dòng heading — `- [ ] Task N: [tên]`,
  không phải `### Task N:` trơn. Step nhỏ vẫn có checkbox như skill mặc định yêu cầu.
- Làm xong task nào (và pass review nếu có) thì **sửa file plan tick `- [x]` ngay lúc đó**, đừng
  dồn tới cuối phiên và đừng coi TodoWrite là đủ.
- Lý do: phiên bị ngắt hay hit rate limit thì mở file plan ra là biết đang dở ở đâu. TodoWrite
  không persist.

# Tài liệu kế hoạch: viết summary khi plan xong
- Tất cả task đã `- [x]` thì viết summary thành **file riêng** trước khi báo xong. Không nhét
  summary vào trong file plan.
- Bốn mục: **Đã làm gì** (3–6 gạch, kết quả người dùng thấy được, không chép lại tên task) /
  **File chính** (file tạo–sửa đáng kể, mỗi file một câu vai trò) / **Khác với plan** (lệch chỗ
  nào, vì sao; không lệch thì ghi "không lệch") / **Còn dở / cần lưu ý** (TODO, hạn chế, việc
  người dùng phải tự làm như đổi config hay khai key; không có thì ghi "không").
- Viết dựa trên diff và commit, không chép mô tả trong plan — plan là dự định, summary là kết quả.
- Lý do tách file: `ls docs/superpowers/summaries/` là thấy hết việc đã xong, khỏi mở từng plan
  dài hàng trăm dòng để dò; và mỗi summary dùng thẳng được làm mô tả PR hay changelog.

# Quy tắc lưu conversation

- Mỗi conversation độc lập phải có một folder riêng tại `conversation/<tên-conversation>/`, tính từ root của worktree đang làm việc.
- `<tên-conversation>` là slug ngắn, dấu cách đổi thành `-`, ưu tiên chữ thường không dấu. Khi user tiếp tục cùng conversation, dùng lại đúng folder đó; không tạo folder mới.
- Với mỗi cặp chat gồm một tin nhắn của user và câu trả lời tương ứng của agent, tạo một file riêng tại `conversation/<tên-conversation>/<YY-MM-DD_HH-mm-ss>.md`.
- Mỗi file chỉ được chứa hai phần: nguyên văn đầy đủ câu hỏi/yêu cầu của user và nguyên văn đầy đủ câu trả lời của agent. Không tóm tắt, rút gọn, diễn giải lại hoặc gộp nhiều cặp chat vào một file.
- Không ghi metadata, branch, danh sách file, kết quả kiểm tra, log công cụ, chain-of-thought/nội suy nội bộ, lời chào riêng, hoặc nội dung ngoài câu hỏi và câu trả lời. Không ghi secrets, token, API key, password, cookie hay dữ liệu nhạy cảm; nếu xuất hiện trong nội dung cần lưu thì thay bằng `[REDACTED]`.
- Tên file dùng mốc thời gian lúc cặp chat được ghi, định dạng `YY-MM-DD_HH-mm-ss.md`. Nếu hai cặp chat có cùng giây, thêm hậu tố ngắn để tránh ghi đè.
- Ghi file sau mỗi câu trả lời của agent. Nếu context bị compact hoặc thiếu, chỉ lưu phần thực sự nhìn thấy; không được bịa hoặc khôi phục phần không còn trong context.
- Nếu user yêu cầu không lưu conversation, tôn trọng yêu cầu đó. Không thêm `conversation/` vào `.gitignore`.

# Quy tắc dọn conversation

- Khi user gõ `dọn conversation`, `clear chat` hoặc `clear conversation` (không phân biệt hoa/thường), duyệt toàn bộ file chat trong `conversation/` của worktree đang làm việc rồi dọn chúng.
- Giữ lại mọi cặp chat có ích cho việc thực hiện task hoặc luồng làm việc: yêu cầu, tiêu chí nghiệm thu, quyết định, bối cảnh, thiết kế, trạng thái/tiến độ, lỗi, blocker, phản hồi hoặc chỉ dẫn thay đổi cách làm.
- Xóa các cặp chat không còn mục đích hay ý nghĩa cho task/coding/luồng làm việc, như chào hỏi, xác nhận xã giao, lặp lại vô ích hoặc nội dung không liên quan. Nếu không chắc một chat có ích hay không, phải giữ lại.
- Không tạo file conversation cho tin nhắn kích hoạt dọn, các cập nhật trong lúc dọn, hoặc câu trả lời kết quả dọn. Quy tắc này là ngoại lệ của yêu cầu ghi file sau mỗi câu trả lời.
