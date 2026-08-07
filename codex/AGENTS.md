# Ngôn ngữ
- Luôn trả lời người dùng bằng tiếng Việt.

# superpowers
- Bộ 14 skill quy trình đã cài sẵn. Việc nhiều bước thì **đọc `using-superpowers` trước** — nó là
  mục lục, chỉ ra việc nào dùng skill nào.
- Ánh xạ nhanh: "làm tính năng X" → `brainstorming` rồi `writing-plans`; "sửa bug này" →
  `systematic-debugging`; đã có plan → `subagent-driven-development`, hoặc `executing-plans` nếu
  không dùng subagent.
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
  - Quy trình riêng của dự án này → `<dự án>/.claude/skills/<tên>/SKILL.md`
  - Kiến thức riêng của dự án này → `<dự án>/docs/recipes/<slug>.md`
- Viết skill mà cần chặt chẽ (loại luật agent hay lách) thì dùng skill `writing-skills` — nó bắt
  chạy subagent thử trước để xem agent lách bằng cớ gì. Chỉ là tài liệu hướng dẫn thì viết thẳng.

# Không commit skill của bộ kit vào repo dự án
- `.claude/skills/` trong một dự án chứa hai loại: skill do `~/dotagents/install.sh --project`
  cài (bản sao của bộ kit) và skill viết riêng cho dự án. **Chỉ loại thứ hai được commit.**
- Installer tự ghi khối `# dotagents:begin skills` vào `.gitignore` liệt kê đích danh skill của
  kit. Đừng xoá khối đó, cũng đừng `git add -f` những đường dẫn nằm trong đó.
- Máy khác thiếu skill thì chạy `~/dotagents/install.sh --project`, chứ không phải lấy từ repo
  dự án — commit bản sao vào là tạo một nhánh sẽ lệch dần khỏi bộ kit mà không ai nhớ cập nhật.

# Skill thiết kế (opt-in)
- Các skill sau **chỉ chạy khi người dùng gọi đích danh**, không tự kích hoạt:
  - Frontend/UI: `taste-skill` (mặc định), `minimalist-skill`, `brutalist-skill`, `redesign-skill`
  - Khác: `output-skill` (chống cắt ngắn output)

# Tài liệu kế hoạch: checkbox theo từng task
- Khi viết plan nhiều bước: ngoài checkbox cho từng step nhỏ (`- [ ] Step N: ...`), mỗi TASK cấp cao cũng phải có checkbox riêng ngay trên dòng heading, ví dụ `- [ ] Task N: [Tên component]` thay vì chỉ `### Task N: ...`.
- Khi thực thi plan: làm xong (và pass review nếu có) task nào phải sửa ngay file plan để tick checkbox của TASK đó thành `- [x]` — không chỉ cập nhật todo list nội bộ. Làm ngay lúc đó, đừng dồn lại cuối phiên.
- Lý do: nếu phiên bị ngắt hoặc hit rate limit, chỉ cần mở lại file plan là biết ngay đã làm đến task nào, không cần dựa vào trạng thái todo list (không persist).

# Tài liệu kế hoạch: summary khi xong plan
- Khi TẤT CẢ task của một plan đã tick `- [x]` (plan hoàn tất): viết summary thành **file riêng** trong folder `docs/superpowers/summaries/`, trước khi báo cáo là xong. **Không** ghi summary vào trong file plan nữa.
- Tên file summary theo đúng khuôn của spec và plan: spec là `<ngày>-<slug>-design.md`, plan là `<ngày>-<slug>.md`, thì summary là `<ngày>-<slug>-summary.md`. Cùng ngày, cùng slug — nhìn tên là biết ba file thuộc cùng một việc.
- **Chuỗi trỏ nhau — bắt buộc cả ba mắt**, để mở bất kỳ file nào cũng đi được tới hai file kia:
  - Đầu file summary: dòng trỏ tới spec và tới plan (đường dẫn tương đối, `../specs/…` và `../plans/…`).
  - Cuối file plan: mục `## Kết quả` trỏ tới file summary (`../summaries/…`).
  - Cuối file spec: mục `## Plan thực thi` trỏ tới file plan (`../plans/…`). Thêm ngay khi plan được tạo, không đợi tới lúc xong.
- Nội dung file summary gồm:
  - **Đã làm gì**: 3–6 gạch đầu dòng mô tả kết quả thực tế (tính năng/hành vi người dùng thấy được), không lặp lại tên task.
  - **File chính**: danh sách file được tạo/sửa đáng kể, kèm một câu vai trò của từng file.
  - **Khác với plan**: chỗ nào làm khác thiết kế ban đầu và vì sao. Nếu không lệch gì thì ghi "không lệch".
  - **Còn dở / cần lưu ý**: phần bị hoãn, TODO, hạn chế đã biết, hoặc thao tác thủ công người dùng phải tự làm (đổi config, khai báo key...). Không có thì ghi "không".
- Viết summary dựa trên những gì THỰC SỰ đã làm (diff, commit), không chép lại mô tả trong plan — plan là dự định, summary là kết quả.
- Lý do tách file: plan dài hàng trăm dòng và là tài liệu *dự định*, đọc lại vài tuần sau chỉ muốn biết cuối cùng ra cái gì. Để summary riêng thì `ls docs/superpowers/summaries/` là thấy toàn bộ những việc đã làm xong, không phải mở từng plan để dò; và mỗi file summary dùng trực tiếp được làm mô tả PR / changelog.

# Dự án mới
- Ở dự án chưa có `docs/superpowers/`, tạo đủ ba folder `specs/`, `plans/`, `summaries/` ngay lần đầu viết plan — đừng để spec và plan nằm lạc chỗ khác.
