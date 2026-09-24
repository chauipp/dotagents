Liên quan: [spec](../specs/2026-09-24-move-git-identity-checks-to-rules-design.md) · [plan](../plans/2026-09-24-move-git-identity-checks-to-rules.md)

## Đã làm gì

- Đưa checklist kiểm tra Git identity và metadata trực tiếp vào rules của Claude Code và Codex.
- Gỡ skill riêng `preserving-user-git-identity` khỏi catalog để installer không cài nó nữa.
- Cập nhật README và số lượng skill phân phối.

## File chính

- `claude/CLAUDE.md`, `codex/AGENTS.md`: quy trình bảo toàn danh tính Git được nạp mặc định.
- `skills/preserving-user-git-identity/SKILL.md`: xóa bản skill trùng vai trò với rules.
- `README.md`: đồng bộ danh mục và số lượng.

## Khác với plan

Không lệch.

## Còn dở / cần lưu ý

Không chạy test theo yêu cầu quy trình phiên này. Installer đọc danh mục skill động, nên khi chạy cập nhật nó sẽ bỏ skill cũ khỏi manifest và gỡ bản đã quản lý.
