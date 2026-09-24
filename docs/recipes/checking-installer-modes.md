# Kiểm tra các mode của installer

## Khi nào gặp lại

Khi sửa cờ có thể kết hợp với global/project, hoặc thêm một kiểu cài mới vào `install.sh`.

## Cách làm đúng

Lần theo cờ từ parser tới từng nhánh thực thi. Với mỗi mode, ghi rõ phần nào được phép đổi: rules, skills, manifest hay config. Chạy kiểm tra bằng thư mục config tạm cho global và project; các cờ dùng chung như `--rules-only` phải có assertion ở cả hai nhánh.

## Cái bẫy

Một cờ được parse đúng chưa có nghĩa là mọi mode đều tôn trọng nó. Global và project có các nhánh thực thi riêng; `--rules-only` trước đây chỉ ngăn copy skills ở project, còn global vẫn copy skills và chỉnh config.

## Kiểm thế nào là đúng

`bash tests/install.sh` phải xác nhận global `--codex --rules-only` tạo `AGENTS.md` nhưng không tạo `skills/` hoặc `config.toml`; các assertion project hiện có cũng phải tiếp tục qua.
