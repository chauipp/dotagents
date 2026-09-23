Spec: `../specs/2026-09-20-skill-only-command-workflow-design.md`

Plan: `../plans/2026-09-20-skill-only-command-workflow.md`

# Summary: Skill-only Command Workflow

## Đã làm gì

- Loại bỏ các action block command-specific khỏi rules Codex/Claude ở source và cập nhật assertion installer.
- Cập nhật README để dùng giao diện skill `$` cho ba workflow canonical; `/skills` chỉ là selector.
- Refresh đầy đủ 27 skill và manifest của bộ cài Codex, giữ nguyên skill hệ thống ngoài manifest.
- Thêm `no-clarify`, `clear-conversation`, `compact-conversation` vào Claude unmanaged chỉ khi thư mục chưa tồn tại.
- Xác minh manifest, thư mục, hash source/installed, hash ba skill Claude và absence của slash triggers.
- Chạy `quick_validate.py` thành công trên cả sáu thư mục canonical đã cài của Codex và Claude.

## File chính

- `README.md`: tài liệu cài đặt và cách gọi skill explicit-only.
- `codex/AGENTS.md`, `claude/CLAUDE.md`: rules source không còn action block trùng lặp.
- `tests/install.sh`: assertion cho marker và absence của command-specific triggers.
- `C:\Users\royal\.codex\AGENTS.md`: rules deployment đã refresh.
- `C:\Users\royal\.codex\skills\` và `.dotagents-manifest`: 27 skill Codex đã đồng bộ.
- `C:\Users\royal\.claude\skills\`: chỉ ba skill canonical còn thiếu được bổ sung.

## Khác với plan

- Không lệch: Claude là bộ unmanaged có collision, nên chỉ bổ sung đúng ba thư mục canonical chưa tồn tại theo yêu cầu bảo toàn dữ liệu người dùng.
- `quick_validate.py` đã chạy và pass cả sáu thư mục; không còn lệch so với plan ở bước validation này.

## Còn dở / cần lưu ý

- Không có thay đổi chức năng còn dở. Claude vẫn không có manifest dotagents và các skill trùng tên khác vẫn giữ nguyên.
- `bash tests/install.sh` chưa chạy được do môi trường không có Bash/Git executable khả dụng.
