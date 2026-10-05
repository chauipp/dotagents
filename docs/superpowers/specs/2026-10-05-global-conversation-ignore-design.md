# Ignore conversation khi cài global

Thiết kế đã được người dùng duyệt trong conversation: cài global một lần để mọi repository ignore conversation, uninstall gỡ đúng block quản lý.

Installer đầy đủ dùng `git config --global --path --get core.excludesFile`; nếu chưa có thì chọn `$XDG_CONFIG_HOME/git/ignore` (mặc định `~/.config/git/ignore`) và cấu hình Git trỏ tới đó. Block `dotagents:begin conversations` chứa `conversation/` và được cập nhật idempotent, giữ byte ngoài block. Không thay identity Git. Project giữ hành vi hiện có.

`--check` chỉ báo đích; `--rules-only` không sửa ignore/config Git. Uninstall global đầy đủ gỡ block dùng chung, kể cả khi chỉ chọn một agent. Giữ file ignore và `core.excludesFile` để bảo toàn rule riêng và tránh thay đổi cấu hình không cần thiết. Đích ignore được ghi vào ledger từng agent để gỡ được cả khi người dùng đổi `core.excludesFile` sau cài. Backup/restore hiện có bao gồm file ignore. Không untrack conversation đã commit.

## Plan thực thi

[Plan](../plans/2026-10-05-global-conversation-ignore.md)
[Kết quả](../summaries/2026-10-05-global-conversation-ignore-summary.md)
