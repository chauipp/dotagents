# ch-learn-english

Skill opt-in cho Codex, cài global hoặc project, mặc định tắt cho từng chat. Người dùng đã duyệt thiết kế trong hội thoại và yêu cầu triển khai.

## Hành vi

- `$ch-learn-english on|off|status`: hook UserPromptSubmit xử lý lệnh độc lập với model, lưu theo session_id; thiếu tham số chỉ báo trạng thái. Chat mới tắt, resume giữ trạng thái, fork ID mới tắt.
- Khi bật: sửa ngữ pháp yêu cầu tiếng Anh trước khi xử lý, giữ nguyên ý; trả lời tiếng Anh và chú thích mọi từ/cụm chưa biết bằng `(từ loại | nghĩa tiếng Việt)`. Không chèn chú thích vào code, URL, tên file hoặc lệnh chạy được. Lặp cùng mục trong một câu trả lời chỉ chú thích lần đầu.
- Giải thích cấu trúc chưa biết ở cuối câu trả lời, với câu ví dụ từ chính câu trả lời. Nhận diện từ gốc/dạng biến đổi do agent cung cấp rõ; cụm và cấu trúc xét độc lập.
- Xác nhận đã biết bằng ngôn ngữ tự nhiên: agent gọi helper lưu đúng mục; mơ hồ thì hỏi rõ; không tự ghi từ chỉ vì đã nhìn thấy. Có helper forget để sửa đánh dấu sai.
- Từ/cụm/cấu trúc dùng chung trên máy: `$XDG_STATE_HOME/dotagents/ch-learn-english` hoặc `~/.local/state/dotagents/ch-learn-english`; env `DOTAGENTS_ENGLISH_STATE_DIR` hỗ trợ test/đường dẫn riêng. JSON version 1; khóa và atomic replace, quyền riêng tư; dữ liệu lỗi báo rõ, không reset.
- Hook nạp phương pháp cùng danh sách ở mỗi lượt bật. Danh sách lớn chuyển sang lookup helper và catalog grammar phân trang, không cắt dữ liệu âm thầm. Off chèn chỉ dẫn ngắn hủy phương pháp cũ, kể cả chat ID mới để không kế thừa on từ lịch sử fork. Turn receipt dùng chung theo session_id/turn_id để global và project không nạp phương pháp hai lần.

## Cài/gỡ

V1 chỉ Codex (agents: codex); không tuyên bố hỗ trợ Claude chưa kiểm chứng. Full install đăng ký hook, giữ hook riêng, ghi ownership; --check không ghi; --rules-only không cài hook; gỡ đầy đủ loại bỏ riêng group hook thuộc ownership và không xóa knowledge/sessions. Cần review/trust hook; không tự thay trust. Command trỏ script nằm trong skill đã copy, quote an toàn đường dẫn có khoảng trắng. Cài không bật chat.

## Kiểm chứng

Unit/integration: session isolation, commands, dictionary updates, forms, independence, concurrent writes, corruption, large list, hook ownership and installer modes. Baseline agent chưa có skill và agent có skill. Runtime thật: on → reply → learned → reply → off, kiểm tra injected context và phản hồi model; UI chưa có công cụ điều khiển app thì ghi rõ hạn chế.

## Plan thực thi

[Plan](../plans/2026-10-13-ch-learn-english.md)

[Kết quả](../summaries/2026-10-13-ch-learn-english-summary.md)
