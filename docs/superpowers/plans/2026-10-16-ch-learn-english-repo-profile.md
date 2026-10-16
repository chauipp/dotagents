# Chuẩn hóa profile repo-local cho ch-learn-english

**Mục tiêu:** Dùng `learning/ch-learn-english` làm profile trực tiếp bằng đường dẫn tương đối với root repo trên mọi máy.

**Cách tiếp cận:** Chỉ sửa tài liệu/cấu hình mẫu; helper tiếp tục nhận thư mục state qua `DOTAGENTS_ENGLISH_STATE_DIR`. Không thêm auto-discovery.

**Công nghệ:** Markdown, shell environment, installer hiện có.

## Tasks

- [x] Task 1: Cập nhật hướng dẫn profile repo-local
  - [x] Đặt profile trong repo là lựa chọn được khuyến nghị khi dùng repo `dotagents`.
  - [x] Dùng `$PWD/learning/ch-learn-english` thay cho đường dẫn tuyệt đối cố định.
  - [x] Nêu rõ phải export trước khi khởi động Codex và helper.
- [ ] Task 2: Kiểm tra source và bản skill đã cài
  - [x] Chạy các kiểm tra cú pháp/tài liệu phù hợp; installer bị chặn bởi config hook hiện có.
  - [ ] So sánh file skill source với bản cài đặt.
- [ ] Task 3: Ghi summary kết quả
  - [ ] Tạo summary riêng và liên kết ngược tới spec/plan.

## Kết quả

[Summary](../summaries/2026-10-16-ch-learn-english-repo-profile-summary.md)
