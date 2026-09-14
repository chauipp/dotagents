# Kết quả: bảo toàn danh tính Git của người dùng

Liên quan: [spec](../specs/2026-09-14-preserving-user-git-identity-design.md) · [plan](../plans/2026-09-14-preserving-user-git-identity.md)

## Đã làm gì

- Thêm skill dùng chung yêu cầu xác minh identity Git hiện có trước commit và push.
- Chặn việc tự thay đổi identity, dùng `--author`, bot identity hay trailer đồng tác giả của công cụ tự động.
- Thêm bước rà staged diff, commit metadata và nội dung chuẩn bị publish để tránh attribution không mang ý nghĩa kỹ thuật.
- Nạp quy tắc bắt buộc cho cả Claude Code và Codex.
- Bổ sung regression test xác nhận installer chuyển giao skill và rule cho cả hai runtime.

## File chính

- `shared/skills/preserving-user-git-identity/SKILL.md`: quy trình và các điều kiện dừng bảo vệ danh tính Git.
- `claude/CLAUDE.md`: rule luôn nạp cho Claude Code.
- `codex/AGENTS.md`: rule luôn nạp cho Codex.
- `tests/install.sh`: regression coverage cho hai bản cài theo dự án.

## Khác với plan

Không lệch. Assertion trong regression test được viết gọn trên một dòng thay vì xuống dòng để tránh lỗi tiếp dòng Bash.

## Còn dở / cần lưu ý

Không. Skill yêu cầu người dùng tự cấu hình `user.name` và `user.email` nếu Git chưa có hai giá trị này; nó không tự thiết lập hay thay thế chúng.
