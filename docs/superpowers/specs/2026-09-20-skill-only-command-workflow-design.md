# Skill-only Command Workflow — Spec

## Mục tiêu

Ba workflow `no-clarify`, `clear-conversation` và `compact-conversation` phải là
explicit-only skills, được gọi bằng `$no-clarify`, `$clear-conversation` và
`$compact-conversation` trên mọi agent hiện có.

## Phạm vi và yêu cầu

- Gỡ các action trigger tương ứng khỏi `AGENTS.md` và `CLAUDE.md`, nhưng giữ nguyên
  các quy tắc không liên quan.
- Refresh toàn bộ skill shared và skill `graphify` đúng biến thể trong bộ cài Codex
  managed; giữ nguyên skill hệ thống ngoài manifest.
- Với bộ cài Claude unmanaged, chỉ thêm ba thư mục canonical nếu chưa tồn tại; không
  ghi đè hoặc tạo manifest toàn bộ, bảo toàn mọi skill hiện có và skill trùng tên.
- Kiểm tra manifest, thư mục, hash source/installed, explicit-only metadata, absence
  của command triggers và validation của cả hai agent.
- Ghi nhận giới hạn môi trường: `bash tests/install.sh` không chạy được vì Bash/Git
  executable không khả dụng trên môi trường Windows này.

## Kết quả mong đợi

Codex có bộ cài managed đồng bộ; Claude có đủ ba workflow canonical mà không làm
thay đổi các skill unmanaged khác; hành vi workflow chỉ được cung cấp qua giao diện
explicit `$` skill.

## Plan thực thi

`../plans/2026-09-20-skill-only-command-workflow.md`
