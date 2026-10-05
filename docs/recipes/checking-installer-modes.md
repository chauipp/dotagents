# Kiểm tra các mode của installer

## Khi nào gặp lại

Khi sửa cờ có thể kết hợp với global/project, hoặc thêm một kiểu cài mới vào `install.sh`.

## Cách làm đúng

Lần theo cờ từ parser tới từng nhánh thực thi. Với mỗi mode, ghi rõ phần nào được phép đổi: rules, skills, manifest hay config. Chạy kiểm tra bằng thư mục config tạm cho global và project; các cờ dùng chung như `--rules-only` phải có assertion ở cả hai nhánh.

Khi test installer global, đặt `GIT_CONFIG_GLOBAL` trỏ tới file config tạm và `XDG_CONFIG_HOME` trỏ tới thư mục tạm để cô lập cả Git config lẫn file ignore mặc định. Chỉ đổi `CODEX_HOME`/`CLAUDE_CONFIG_DIR` chưa đủ. Nếu cần đổi `TMPDIR` vì `/tmp` hết chỗ, chọn thư mục trên phân vùng còn dung lượng và nằm ngoài repo.

## Cái bẫy

Một cờ được parse đúng chưa có nghĩa là mọi mode đều tôn trọng nó. Global và project có các nhánh thực thi riêng; `--rules-only` trước đây chỉ ngăn copy skills ở project, còn global vẫn copy skills và chỉnh config. Test rules cũng không nên cấm sự xuất hiện của một cụm từ chung: tài liệu có thể nhắc đến trigger để định nghĩa nó là opt-in. Kiểm tra cấu trúc hoặc điều kiện kích hoạt thực tế thay vì grep cấm cụm từ.

Installer global có thể sửa `core.excludesFile` và file ignore của máy dù config agent đã được cô lập. Ngoài ra, `tests/install.sh` có bước sao chép cả kit để kiểm nguồn rules lỗi; nếu `TMPDIR` nằm trong repo thì test sẽ cố sao chép repo vào chính nó và thất bại vì đường dẫn, không phải vì logic installer.

## Kiểm thế nào là đúng

`bash tests/install.sh` phải xác nhận global `--codex --rules-only` tạo `AGENTS.md` nhưng không tạo `skills/` hoặc `config.toml`; các assertion project hiện có cũng phải tiếp tục qua. Khi rules chứa hướng dẫn trigger opt-in, installer vẫn phải giữ nguyên nội dung đó và test không được hiểu việc nhắc tới trigger là đang kích hoạt nó.

Chạy thêm `python3 tests/uninstall.py`: test global ignore phải xác nhận `git check-ignore` có hiệu lực ở hai repo mới, cài lại không nhân đôi block, uninstall giữ rule riêng và restore khôi phục file. Cả hai bộ test phải dùng Git config/XDG tạm; nếu đổi `TMPDIR`, dùng đường dẫn ngoài repo cho cả hai lệnh.
