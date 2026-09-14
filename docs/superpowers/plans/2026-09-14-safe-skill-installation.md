# Kế hoạch: cài skill an toàn

> **Cho agent thực thi:** Dùng `executing-plans`, làm test trước rồi mới sửa installer.

**Mục tiêu:** Bảo vệ skill riêng khỏi collision và cung cấp chế độ kiểm tra không ghi file.

**Kiến trúc:** Preflight đọc manifest trước mutation. `--check` dùng chính preflight nhưng dừng sau khi in kế hoạch. Installer chỉ xóa skill có bằng chứng ownership trong manifest.

**Công nghệ:** Bash, Markdown.

- [x] Task 1: Viết regression coverage cho dry-run và collision

- [x] Step 1: Thêm test project `--check` không tạo file.
- [x] Step 2: Thêm test collision project/global dừng không mutation.
- [x] Step 3: Chạy `bash tests/install.sh`, xác nhận fail vì chưa có `--check`/guard.

- [x] Task 2: Thêm preflight và `--check` vào installer

- [x] Step 1: Parse cờ `--check` và xây hàm xác minh ownership từ manifest.
- [x] Step 2: Chạy preflight cho mọi đích trước `merge_rules`, `copy_skills` hoặc tạo thư mục.
- [x] Step 3: Chỉ dọn skill cũ khi manifest xác nhận ownership.
- [x] Step 4: Chạy test, xác nhận pass.

- [x] Task 3: Cập nhật tài liệu và hoàn tất

- [x] Step 1: Mô tả `--check`, collision và cách agent cài an toàn trong README.
- [x] Step 2: Chạy `bash tests/install.sh`, `bash -n install.sh`, `git diff --check`.
- [x] Step 3: Tick plan, viết summary và commit sau khi xác minh Git identity.

## Kết quả

Summary sẽ nằm tại [2026-09-14-safe-skill-installation-summary.md](../summaries/2026-09-14-safe-skill-installation-summary.md).
