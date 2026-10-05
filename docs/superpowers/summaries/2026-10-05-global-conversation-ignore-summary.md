# Global conversation ignore

[Spec](../specs/2026-10-05-global-conversation-ignore-design.md) · [Plan](../plans/2026-10-05-global-conversation-ignore.md)

## Đã làm gì

- Cài global đầy đủ thêm block conversation vào file ignore Git global; dùng file cấu hình sẵn hoặc tạo file mặc định XDG và đặt core.excludesFile.
- Cài lại không nhân đôi block; giữ nội dung ngoài block và quyền file.
- Uninstall global gỡ block ở các đường dẫn đã ghi trong ledger, kể cả sau khi đổi cấu hình Git; giữ file, rule riêng và core.excludesFile.
- Ignore được đưa vào backup/restore hiện có; check và rules-only không sửa ignore.
- Installer regression qua; 22 test uninstall qua; bash syntax và diff check qua. Test kiểm hiệu lực Git ở hai repository riêng.

## File chính

- `install.sh`: preflight và gọi helper quản lý ignore khi cài global đầy đủ.
- `scripts/dotagents_lifecycle.py`: resolve Git ignore, ghi block/ledger, lập kế hoạch gỡ có backup.
- `tests/install.sh`: cô lập Git global và XDG trong regression installer.
- `tests/uninstall.py`: thêm bốn test global ignore, preservation, malformed marker và nhiều đường dẫn ledger.
- `rules/common.md`: agent chấp nhận global ignore đã có hiệu lực, không bắt tạo gitignore project.
- `README.md`: mô tả global install/uninstall và block dùng chung giữa agent.

## Khác với plan

Không lệch về chức năng. /tmp trên phân vùng hệ thống hết dung lượng nên test chạy với TMPDIR trên /home. Một lỗi gọi helper trong test được sửa trước lần chạy toàn bộ 22 test thành công.

## Còn dở / cần lưu ý

Chưa chạy installer lên cấu hình runtime thật của máy; chạy installer global đầy đủ để áp dụng. Uninstall một agent global cũng gỡ block dùng chung. Ignore không untrack file đã commit. Không push.
