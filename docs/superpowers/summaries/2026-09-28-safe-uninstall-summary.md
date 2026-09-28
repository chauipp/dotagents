# Kết quả gỡ dotagents an toàn

[Spec](../specs/2026-09-28-safe-uninstall-design.md) · [Plan](../plans/2026-09-28-safe-uninstall.md)

## Đã làm gì

- Có uninstall.sh chọn global/project, Claude/Codex/all, rules-only và check; chỉ gỡ dữ liệu có marker/manifest ownership.
- Giữ rules ngoài block, skill riêng, .system và Git index. Marker, manifest, symlink ancestor hoặc ledger lỗi dừng trước mutation.
- Installer snapshot trước cài và ghi ledger sau cài, chỉ quản lý key config thực sự đổi; reinstall giữ nguồn gốc ban đầu.
- Config có sẵn hoặc đã sửa tiếp được giữ; config có ledger và chưa sửa tiếp được khôi phục từng key, không đè toàn file cũ.
- Mỗi lần gỡ tạo backup và journal, hỗ trợ restore cả lỗi giữa chừng; từ chối restore đè đích đã sửa hoặc backup bị đổi.
- 18 test uninstall PASS; regression installer PASS, shell syntax và git diff --check sạch.

## File chính

- uninstall.sh: entrypoint cho CLI gỡ và restore.
- scripts/dotagents_lifecycle.py: ledger, preflight, removal plan, backup/journal và restore.
- install.sh: hook snapshot/record và ignore ledger project; sửa nhánh Codex-only thiếu manifest Claude và nhận .git dạng file.
- tests/uninstall.py: regression đích tạm cho selectors, preservation, config, lỗi metadata/path, check, idempotency và restore.
- README.md: cách gỡ, xem trước, restore, yêu cầu Python 3.11+ và giới hạn legacy.

## Khác với plan

Không lệch về mục tiêu. Bổ sung kiểm comment trong TOML để giữ ghi chú người dùng; thêm test gitfile project và đích đổi sau preflight.
File config rỗng và thư mục container được giữ; chỉ xóa file rules rỗng khi có ownership.

## Còn dở / cần lưu ý

- Chưa chạy uninstall trên cấu hình thật; kiểm tra dùng đích tạm.
- Bản cài cũ không có ledger không thể khôi phục giá trị trước lần cài đầu; giữ config chưa xác định ownership.
- Symlink ancestor và cấu trúc TOML không thể sửa an toàn bị từ chối, không cố sửa bằng suy đoán.
- Backup có thể chứa config nhạy cảm; backup directory mới được tạo private, giữ backup sau restore.
- Chưa xóa file backup cũ của installer, chưa sửa Git index hoặc gỡ file đang tracked khỏi Git.
