# Reasoning language
- For technical/code reasoning (reading code, debugging, writing functions, logic): think internally in English — technical corpora (code, docs, error messages) are overwhelmingly English, so English reasoning is more accurate.
- For Vietnamese-specific business terminology (role names, approval workflows, process names...): keep the original Vietnamese terms when reasoning; don't translate to English and back, to avoid meaning drift or loss of nuance.
- Always give the final answer to the user in Vietnamese, regardless of the internal reasoning language.

# graphify
- **graphify** — biến bất kỳ input nào (code, docs, papers, ảnh, video) thành knowledge graph. Trigger: `/graphify`
- Khi người dùng gõ `/graphify`, dùng skill `graphify` trước khi làm bất cứ việc gì khác.

# superpowers
- Bộ 14 skill quy trình đã cài sẵn: `brainstorming`, `writing-plans`, `executing-plans`,
  `subagent-driven-development`, `dispatching-parallel-agents`, `test-driven-development`,
  `systematic-debugging`, `requesting-code-review`, `receiving-code-review`,
  `verification-before-completion`, `using-git-worktrees`, `finishing-a-development-branch`,
  `writing-skills`, `using-superpowers`.
- **Đọc `using-superpowers` trước** khi bắt đầu một việc nhiều bước — nó là mục lục, chỉ ra
  việc nào thì dùng skill nào.
- Quy tắc rút gọn: "làm tính năng X" → `brainstorming` rồi `writing-plans`;
  "sửa bug này" → `systematic-debugging`; đã có plan → `subagent-driven-development`
  (hoặc `executing-plans` nếu không có subagent).
- Muốn dùng subagent (`spawn_agent`/`wait_agent`/`close_agent`) thì cần bật trong
  `~/.codex/config.toml`:
  ```toml
  [features]
  multi_agent = true
  ```
- Các skill này tham chiếu lẫn nhau bằng tên trần (`writing-plans`), không có tiền tố
  `superpowers:` — bản trong repo đã bỏ tiền tố đó vì không cài dưới dạng plugin.

# Skill thiết kế (opt-in)
- Các skill sau **chỉ chạy khi người dùng gọi đích danh**, không tự kích hoạt:
  - Frontend/UI: `taste-skill` (mặc định), `minimalist-skill`, `brutalist-skill`, `redesign-skill`
  - Sinh ảnh / design reference: `imagegen-frontend-web`, `imagegen-frontend-mobile`, `image-to-code-skill`, `brandkit`
  - Khác: `stitch-skill` (sinh DESIGN.md cho Google Stitch), `output-skill` (chống cắt ngắn output)

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
