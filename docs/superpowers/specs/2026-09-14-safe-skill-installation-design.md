# Thiết kế: cài skill an toàn

## Mục tiêu

Ngăn `install.sh` ghi đè hoặc xóa skill riêng đã tồn tại, đồng thời cho phép agent kiểm tra trước khi cài.

## Hành vi

- Chỉ ghi đè skill có tên trong `.dotagents-manifest` của đúng thư mục đích.
- Nếu skill kit cùng tên đã tồn tại nhưng không có trong manifest, báo tất cả collision và thoát trước mọi thay đổi.
- `--check` chỉ in kế hoạch/collision, không tạo hoặc sửa file.
- Áp dụng nhất quán cho cài global và `--project`.
- Skill cũ chỉ bị xóa khi manifest xác nhận dotagents từng cài nó.

## Ngoài phạm vi

Không tự đổi tên, di chuyển hoặc ghi đè skill riêng; người dùng quyết định cách giải quyết collision.

## Kiểm thử

Regression test xác minh dry-run không ghi file, collision ở project/global không thay đổi state, và cài lại skill có manifest vẫn thành công.

## Plan thực thi

Xem [plan thực thi](../plans/2026-09-14-safe-skill-installation.md).
