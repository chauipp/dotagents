# ch-learn-english

[Spec](../specs/2026-10-13-ch-learn-english-design.md) · [Plan](../plans/2026-10-13-ch-learn-english.md)

## Đã làm gì

- Bật/tắt/báo trạng thái bằng `$ch-learn-english on/off/status`, lưu riêng từng chat; hook nạp phương pháp ở mỗi lượt thay vì chỉ dựa vào lịch sử.
- Khi bật, sửa yêu cầu tiếng Anh sai ngữ pháp trước, trả lời tiếng Anh với chú thích từ/cụm chưa biết và giải thích cấu trúc ở cuối; giữ code/lệnh/đường dẫn nguyên vẹn.
- Lưu từ, dạng biến đổi, cụm và cấu trúc đã biết dùng chung trên máy; có learn/forget/lookup và catalog phân trang có revision khi dữ liệu lớn. Không tự coi mục đã nhìn thấy là đã biết.
- Khóa và ghi atomic, fsync, từ chối dữ liệu hỏng/JSON trùng khóa; khử context trùng và control lặp đến muộn khi cài cả global lẫn project.
- Installer đăng ký hook theo ownership, giữ hook riêng, tôn trọng check/rules-only; uninstall/restore giữ dữ liệu học. Preflight TOML kiểm candidate trước mutation để tránh làm hỏng config inline/quoted.
- Kiểm chứng 20 test helper + 13 test hook/config + 28 test uninstall, regression installer, schema skill và shell syntax. Runtime desktop 0.159.2 thực sự sửa câu, chú thích, đọc lại từ đã biết và trả lời tiếng Việt ở lượt sau off; agent kiểm thử thực sự gọi helper lưu browser/browsers.

## File chính

- `skills/ch-learn-english/SKILL.md`: điều kiện opt-in, lệnh điều khiển và cách ghi nhận đã học.
- `skills/ch-learn-english/references/response-contract.md`: định dạng sửa câu, chú thích và giải thích cấu trúc.
- `skills/ch-learn-english/scripts/english_state.py`: storage, helper CLI và UserPromptSubmit hook.
- `scripts/english_hook_install.py`: preflight, đăng ký và ownership group hook.
- `install.sh`: cài hook trong full global/project Codex, bỏ qua với rules-only.
- `scripts/dotagents_lifecycle.py`: planner TOML bảo toàn config và gỡ/backup/restore hook.
- `codex/AGENTS.md`: ngoại lệ tiếng Anh khi hook xác nhận bật.
- `README.md`: hướng dẫn cài, trust, sử dụng và giới hạn.
- `tests/learn_english.py`: regression persistence, validation, concurrency, lookup và idempotency.
- `tests/english_hook_install.py`: regression hook ownership/config/collision.
- `tests/install.sh`: regression installer, thêm case TOML inline/quoted và các mode hook.
- `tests/uninstall.py`: regression gỡ/restore, bảo toàn hooks và dữ liệu học.

## Khác với plan

- Bổ sung reset OFF ngắn cho ID mới để tránh kế thừa chỉ dẫn ON khi lịch sử được fork; test helper xác nhận, chưa thử fork UI/runtime.
- Review dẫn tới catalog grammar có metadata/revision, receipt bất biến theo session/turn và validation JSON/metadata chặt hơn.
- Planner TOML thay grep/sed cũ sau regression chứng minh inline features có thể làm config lỗi sau khi đã sửa rules/skills.
- Kiểm thử lưu learned qua CLI bị lỗi công cụ/sandbox trong môi trường cô lập; kiểm tra lưu thực bằng agent có tools, rồi tiếp tục CLI để xác nhận hook nạp dữ liệu mới và off. Không tuyên bố toàn bộ chuỗi lưu đã qua một lần CLI liền mạch.

## Còn dở / cần lưu ý

- V1 chỉ Codex; chưa hỗ trợ Claude. Chưa cài vào config cá nhân. Sau cài phải restart và review/trust hook; project hook cần trust project.
- Chưa thao tác picker skill/trust trong UI desktop hoặc kiểm fork trên runtime thật. Không thay code UI trình duyệt.
- Receipt khử trùng lần xử lý, không có bảo đảm exactly-once delivery nếu tiến trình chết giữa ghi receipt và giao stdout cho runtime; runtime không cung cấp delivery acknowledgment. Không lưu prompt hoặc transcript trong state.
- Hook đã được người dùng sửa sẽ được giữ khi gỡ, nhưng helper có thể bị gỡ theo manifest; cần rà command còn giữ. Các chỉnh sửa TOML không thể thực hiện an toàn bị từ chối trước mutation.
- Dữ liệu học nằm trên máy, không tự đồng bộ. Lỗi filesystem/permission được báo rõ, không báo lưu thành công giả.
