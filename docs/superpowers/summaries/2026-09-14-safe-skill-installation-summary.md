# Kết quả: cài skill an toàn

Liên quan: [spec](../specs/2026-09-14-safe-skill-installation-design.md) · [plan](../plans/2026-09-14-safe-skill-installation.md)

## Đã làm gì

- Thêm preflight kiểm tra collision cho mọi đích Claude/Codex trước bất kỳ thao tác ghi nào.
- Thêm `--check` để kiểm tra kế hoạch cài mà không tạo, sửa hoặc xóa file.
- Chỉ cập nhật hoặc gỡ skill khi `.dotagents-manifest` xác nhận dotagents đã sở hữu skill đó.
- Bổ sung regression coverage cho dry-run, collision project/global và skill legacy ngoài manifest.
- Viết hướng dẫn README để agent dừng khi collision thay vì tự xử lý.

## File chính

- `install.sh`: preflight ownership, `--check` và xóa có điều kiện theo manifest.
- `tests/install.sh`: regression coverage cho các trường hợp bảo toàn skill riêng.
- `README.md`: quy trình cài và cập nhật an toàn cho người dùng/agent.

## Khác với plan

Không lệch.

## Còn dở / cần lưu ý

Không. Khi collision xảy ra, người dùng vẫn cần tự quyết định đổi tên, di chuyển hoặc xử lý skill riêng; installer chủ ý không tự động làm thay.
