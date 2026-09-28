# Tóm tắt: Chọn agent khi cài vào một project

Spec: [2026-09-23-project-agent-selection-design.md](../specs/2026-09-23-project-agent-selection-design.md)

Plan: [2026-09-23-project-agent-selection.md](../plans/2026-09-23-project-agent-selection.md)

## Đã làm gì

- Thêm khả năng cài riêng Codex hoặc Claude Code vào một project bằng selector có sẵn `--codex` hoặc `--claude`.
- Giữ mặc định cài cả hai agent khi chạy `--project` không selector; `--all` cũng chọn cả hai.
- Giới hạn preflight, cập nhật rules, cài skills và cảnh báo Claude theo lựa chọn agent.
- Cập nhật help của installer và README với ví dụ selector kết hợp `--check` và `--rules-only`.

## File chính

- `install.sh`: chọn đúng đích và rules theo agent được chọn trong chế độ project.
- `README.md`: ghi cú pháp cài toàn project hoặc từng agent.
- `docs/superpowers/specs/2026-09-23-project-agent-selection-design.md`: quyết định và tiêu chí nghiệm thu.
- `docs/superpowers/plans/2026-09-23-project-agent-selection.md`: các bước thực thi đã hoàn tất.

## Khác với plan

Không lệch.

## Còn dở / cần lưu ý

Kiểm tra whitespace bằng `git diff --check` đã qua. Không chạy test suite.
