# English Git Profile

[Spec](../specs/2026-10-14-english-git-profile-design.md) · [Plan](../plans/2026-10-14-english-git-profile.md)

## Đã làm gì

- Cho phép gọi skill sync và sync --push; hook giữ nguyên chế độ ON/OFF.
- Hướng dẫn agent fetch, commit riêng knowledge.json, merge upstream và push khi được yêu cầu.
- Thêm README thiết lập private repo, chuyển dữ liệu, cấu hình môi trường trên nhiều máy và giải quyết conflict.
- Chặn báo đồng bộ thành công khi Git hoặc kiểm tra JSON thất bại; không force-push.
- Kiểm chứng 21 helper tests và 13 hook installer tests, gồm regression sync ở cả ON/OFF.
- Cập nhật bản Codex global bằng install.sh --codex.

## File chính

- skills/ch-learn-english/README.md: hướng dẫn người dùng quản lý profile bằng Git.
- skills/ch-learn-english/SKILL.md: quy trình Git do agent thực hiện khi gọi sync.
- skills/ch-learn-english/scripts/english_state.py: hook nhận hai lời gọi sync.
- tests/learn_english.py: kiểm sync không đổi ngôn ngữ và không bị báo sai đối số.

## Khác với plan

Không lệch. Sync là workflow của agent theo skill, không phải subcommand Python.

## Còn dở / cần lưu ý

- Chưa có địa chỉ remote của profile cá nhân; chưa tạo repo, chuyển dữ liệu thật hoặc push.
- Khởi động lại phiên Codex để nạp skill mới; review/trust hook nếu ứng dụng yêu cầu.
- Git merge văn bản có thể conflict; người dùng giải quyết trước khi tiếp tục.
- Chưa thử sync với remote thật; kiểm tra hiện tại tập trung hook/control và regression helper.
