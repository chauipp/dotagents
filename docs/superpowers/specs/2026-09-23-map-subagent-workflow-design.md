# Map Subagent Workflow — Spec

## Mục tiêu

Thêm skill `map-subagent-workflow` vào bộ skill shared của dotagents để các agent
được cài từ bộ kit có thể dùng quy trình này khi xây dựng hoặc chỉnh sửa Unreal
Engine map theo spatial specification chi tiết.

## Phạm vi và yêu cầu

- Sao chép nội dung `SKILL.md` hiện có từ
  `C:\Users\royal\.agents\skills\map-subagent-workflow\SKILL.md` vào
  `shared/skills/map-subagent-workflow/SKILL.md`, giữ nguyên nội dung và yêu cầu
  routing trong skill nguồn.
- Đóng gói như skill shared thông thường: không thêm metadata giới hạn invocation;
  agent tiếp tục nhận diện skill theo frontmatter `name` và `description`.
- Cập nhật README để số skill shared là 27, tổng số skill Codex/Claude là 28, và
  liệt kê workflow Unreal mới.
- Không sửa installer: nó đã tự đọc các thư mục trong `shared/skills/` khi cài và
  test hiện có tự so khớp manifest với danh sách thư mục đó.
- Kiểm tra nội dung nguồn và bản chép khớp, số lượng/tài liệu nhất quán; không sửa
  file cài đặt cá nhân ngoài repository.

## Kết quả mong đợi

`install.sh` đưa skill mới vào cả bộ cài Codex lẫn Claude; người dùng có thể gọi
`$map-subagent-workflow` hoặc agent tự chọn skill này khi task khớp description.
Các yêu cầu model và quality gate bên trong skill được giữ nguyên.

## Plan thực thi

`../plans/2026-09-23-map-subagent-workflow.md`
