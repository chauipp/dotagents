# Validate skill chỉ dành cho Codex

## Khi nào gặp lại

Khi tạo hoặc sửa skill trong `skills/` có frontmatter `agents: codex` và cần chạy validator của `skill-creator`.

## Cách làm đúng

Giữ `agents: codex` trong source canonical. Chạy `quick_validate.py` trên một bản sao tạm đã bỏ riêng dòng đó để kiểm phần schema chuẩn, rồi chạy `bash tests/install.sh` trên bản thật để kiểm installer đưa skill vào manifest Codex và không đưa vào manifest Claude.

## Cái bẫy

Validator hệ thống chỉ hiểu schema agentskills.io nên báo `Unexpected key(s): agents`. Nếu xóa key khỏi bản thật để validator xanh, installer vẫn cài được nhưng skill sẽ âm thầm lọt sang Claude. Đây là hai schema phục vụ hai lớp kiểm tra khác nhau, không phải lỗi nội dung skill.

## Kiểm thế nào là đúng

Bản sao tạm trả `Skill is valid!`; bản thật vẫn có dòng `agents: codex`; `bash tests/install.sh` pass và manifest sinh ra chỉ chứa skill ở phía Codex.
