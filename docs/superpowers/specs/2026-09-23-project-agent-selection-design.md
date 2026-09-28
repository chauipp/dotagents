# Chọn agent khi cài vào một project

## Mục tiêu

Cho phép cài rules và skills vào một project duy nhất cho Codex hoặc Claude Code, trong khi giữ nguyên hành vi hiện tại nếu người dùng không chọn agent.

## Thiết kế

`install.sh --project [DIR]` tiếp tục cài cho cả Codex và Claude Code khi không có cờ chọn agent. Khi có `--codex`, chỉ xử lý `.codex/skills/` và `AGENTS.md`; khi có `--claude`, chỉ xử lý `.claude/skills/` và `CLAUDE.md`. `--all` có thể dùng để diễn đạt rõ việc chọn cả hai. Cờ chọn agent cũng áp dụng nhất quán cho `--check` và `--rules-only`.

Trong chế độ global, ý nghĩa hiện tại của `--codex`, `--claude`, và `--all` không đổi. Nếu `--project` được kết hợp với cả `--codex` lẫn `--claude`, cả hai agent được cài. Không sửa cấu hình cài đặt của người dùng ở `~/.agents/skills/`.

## Giao diện dòng lệnh

```bash
./install.sh --project /path/to/project --codex
./install.sh --project /path/to/project --claude
./install.sh --project /path/to/project --all
./install.sh --check --project /path/to/project --codex
./install.sh --project /path/to/project --claude --rules-only
```

## Tiêu chí nghiệm thu

- `--project DIR --codex` chỉ preflight, cập nhật rules Codex và chép skill vào `.codex/` của project.
- `--project DIR --claude` chỉ preflight, cập nhật rules Claude và chép skill vào `.claude/` của project.
- Không truyền agent hoặc truyền `--all` thì giữ hành vi cài cả hai.
- `--check` chỉ kiểm tra những đích được chọn và không ghi file.
- `--rules-only` chỉ ghi rules của agent được chọn, không tạo/copy thư mục skills.
- Hành vi cài global hiện tại không đổi; installer không thao tác `~/.agents/skills/`.
- README có ví dụ cho lựa chọn agent theo project.

## Ngoài phạm vi

Không thay đổi cấu trúc skill, nội dung rules, hành vi cài global, hay cài đặt ở `~/.agents/skills/`.

## Plan thực thi

`../plans/2026-09-23-project-agent-selection.md`
