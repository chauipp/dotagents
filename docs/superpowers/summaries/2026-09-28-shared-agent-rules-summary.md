# Kết quả đồng bộ rules Codex và Claude Code

[Thiết kế](../specs/2026-09-28-shared-agent-rules-design.md) · [Plan thực thi](../plans/2026-09-28-shared-agent-rules.md)

## Đã làm gì

- Codex và Claude Code nhận cùng các quy tắc chung từ `rules/common.md`, tiếp theo là overlay riêng đúng agent, ở cả chế độ global và project.
- Installer kiểm tra cả common và overlay trước khi ghi, dừng khi source thiếu, không đọc được, rỗng, chứa marker quản lý hoặc resolve ra ngoài kit.
- Rules chưa có marker được giữ nguyên phía trên block mới; cảnh báo nêu file đích và số tiêu đề trùng để người dùng review. Cài lại thay block dotagents và giữ nội dung ngoài marker.
- `--check` báo source, file runtime, trạng thái marker, số tiêu đề trùng và hành động dự kiến; source tạm được dọn khi lệnh kết thúc.
- Regression kiểm tra overlay đúng agent, common xuất hiện một lần, preservation và vị trí rules cũ, idempotency, source lỗi cùng các kiểm tra collision, manifest, rules-only và dry-run đã có. `bash tests/install.sh` exit 0 với kết quả `PASS: installer preserves custom skills, detects collisions, and supports dry-run checks`; `git diff --check` không báo lỗi.
- Ánh xạ Superpowers nằm trong common; bỏ các mục Claude lặp lại quy tắc plan và theo dõi task. Dọn/compact conversation do các skill phụ trách, không chép lại thành rules. Hai overlay chỉ giữ cách gọi công cụ. README mô tả source common/overlay, các đường dẫn runtime và cách xử lý cảnh báo migration; spec, plan và summary có liên kết qua lại.

## File chính

- `rules/common.md`: chứa quy tắc chung về ngôn ngữ, Git identity, worktree, kiểm UI, tài liệu kế hoạch và conversation.
- `codex/AGENTS.md`: chỉ giữ cách đọc file skill trong runtime Codex.
- `claude/CLAUDE.md`: chỉ giữ cách gọi Skill/Agent tool trong runtime Claude Code.
- `install.sh`: dựng source common + overlay, kiểm tra source và báo migration trong global/project install cùng `--check`.
- `tests/install.sh`: bổ sung regression common/overlay, migration preservation, vị trí block, idempotency và source lỗi.
- `README.md`: hướng dẫn sửa nguồn rules, cài vào runtime và review nội dung cũ.
- `docs/superpowers/specs/2026-09-28-shared-agent-rules-design.md`: ghi đúng đường dẫn project runtime và liên kết plan/kết quả.
- `docs/superpowers/plans/2026-09-28-shared-agent-rules.md`: lưu checkbox tiến độ và liên kết spec/summary.

## Khác với plan

Không lệch về kiến trúc hoặc hành vi cài đặt. Làm trực tiếp trên nhánh main theo yêu cầu trong phiên; các test migration được bổ sung assertion preservation và vị trí block sau review.

## Còn dở / cần lưu ý

- File runtime có rules cũ ngoài marker vẫn cần người dùng review và tự xóa phần đã xác nhận lỗi thời; installer bảo toàn nội dung này.
