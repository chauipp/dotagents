Spec: [thiết kế](../specs/2026-09-25-merge-map-prompt-levels-design.md) · Plan: [thực thi](../plans/2026-09-25-merge-map-prompt-levels.md)

## Đã làm gì

- Thay hai skill chọn theo model bằng một skill Codex canonical chọn profile qua `low`, `med`/`medium`, `high`; workflow và role contracts dùng chung.
- Bổ sung xử lý parent metadata thiếu: hỏi xác nhận rõ thay vì báo sai model; dùng `USER_CONFIRMED` khi user/UI xác nhận, vẫn block khi có bằng chứng mismatch.
- Gỡ hai skill profile legacy khỏi source và bản cài Codex; installer hiện chỉ quản lý skill canonical.
- Cập nhật hướng dẫn gọi skill và regression assertions cho profile, manifest, trạng thái xác nhận, hạn dùng xác nhận, reasoning chính xác, provenance của xác nhận (loại trừ nội dung trích dẫn/tài liệu nguồn) và tên legacy.
- Ghi recipe để lần sau đồng bộ source skill với bản Codex đã cài và nạp lại phiên.
- Hoàn thiện spec/plan/summary có liên kết chéo.

## File chính

- `skills/ch-writing-prompts-map/`: skill canonical, bảng model theo level, workflow và role contract dùng chung.
- `skills/ch-writing-prompts-map-sol/` và `skills/ch-writing-prompts-map-astra/`: gỡ các bản skill profile cũ để installer không phát hành trùng.
- `tests/install.sh`: xác nhận cài đúng skill Codex và gate parent mới.
- `README.md` và `local/README.md`: hướng dẫn gọi skill, profile và hành vi xác nhận parent.
- `docs/recipes/updating-installed-codex-skills.md`: cách cập nhật và kiểm tra bản skill Codex được cài.
- `docs/superpowers/specs/2026-09-25-merge-map-prompt-levels-design.md`, `docs/superpowers/plans/2026-09-25-merge-map-prompt-levels.md`, `docs/superpowers/summaries/2026-09-25-merge-map-prompt-levels-summary.md`: tài liệu thiết kế, tiến độ và kết quả.

## Khác với plan

- Khi chạy regression test, phát hiện `SKILL.md` ở hai thư mục legacy vẫn còn dù các file con đã bị xóa. Đã gỡ luôn hai file gốc và thêm assertion để lần sau phát hiện lỗi này.
- Cập nhật thêm README để phản ánh gate xác nhận mới; mô tả cũ nói metadata không đọc được thì luôn block.

## Còn dở / cần lưu ý

- `bash tests/install.sh` pass. Installer cảnh báo môi trường chưa khai MCP Playwright; phần này không liên quan đến installer test.
- Đã chạy `./install.sh --codex`; hai skill legacy đã bị gỡ khỏi `~/.codex/skills`, bản canonical khớp source. Khởi động phiên Codex mới để nạp bản cài mới.
- Chưa xác minh gate bằng một lượt chạy map thật; test installer chỉ kiểm cấu trúc/nội dung cài đặt và các contract string.
- Các thay đổi khác đang có trong worktree chưa được rà hoặc đưa vào phạm vi commit này.
