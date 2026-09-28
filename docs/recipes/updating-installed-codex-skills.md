# Cập nhật skill Codex đã cài

## Khi nào gặp lại

Khi sửa skill trong source `skills/` mà Codex vẫn thể hiện hành vi cũ.

## Cách làm đúng

Chạy `./install.sh --check --codex`, sau đó `./install.sh --codex`. So sánh `skills/<tên>/SKILL.md` với `~/.codex/skills/<tên>/SKILL.md`; mở phiên Codex mới để nạp nội dung vừa cài.

## Cái bẫy

Installer cài bản sao vào `~/.codex/skills/`; sửa source không tự sửa bản Codex đang dùng. Vì vậy file source đúng nhưng phiên agent vẫn có thể tiếp tục theo bản cũ mà không báo lỗi.

## Kiểm thế nào là đúng

`cmp -s skills/<tên>/SKILL.md ~/.codex/skills/<tên>/SKILL.md` trả mã 0; chạy lại skill trong phiên mới và quan sát hành vi theo luật vừa sửa.
