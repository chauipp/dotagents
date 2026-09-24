# Thiết kế: chuyển checklist Git identity vào rules

## Mục tiêu

Rules luôn được nạp phải chứa đầy đủ quy trình bảo toàn danh tính Git. Gỡ skill riêng `preserving-user-git-identity` để tránh duy trì hai nơi cho một quy định luôn bắt buộc.

## Phạm vi

- Chuyển toàn bộ checklist thao tác từ skill vào rules của Claude Code và Codex.
- Gỡ skill khỏi danh mục canonical; installer sẽ ngừng cài và dọn bản cũ theo manifest.
- Cập nhật README và số lượng skill.

## Hành vi bắt buộc giữ lại

Rules cần bao gồm lệnh kiểm tra identity và staged diff trước mỗi commit/push; dừng nếu thiếu tên/email; cấm sửa identity, dùng author/bot identity hoặc viết lại attribution người khác; rà nội dung source và metadata mới tạo để loại attribution tự động; giữ copyright/license/provenance có sẵn; kiểm tra commit sắp push và chỉ push khi được người dùng cho phép.

## Kiểm tra

Đọc diff và rà mọi tham chiếu hiện hành tới skill đã gỡ. Không thay đổi Git identity người dùng và không tạo attribution tự động.

## Plan thực thi

Xem [plan thực thi](../plans/2026-09-24-move-git-identity-checks-to-rules.md).
