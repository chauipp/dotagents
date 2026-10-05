# Global conversation ignore Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Cài global một lần để Git ignore conversation, uninstall gỡ block quản lý.

**Architecture:** Dùng lifecycle Python hiện có để resolve file Git ignore, ghi block và đưa việc gỡ vào RemovalPlan có backup/restore. Installer gọi helper chỉ khi global đầy đủ.

**Tech Stack:** Bash, Python 3.11+, Git, unittest.

## Global Constraints

Giữ nội dung ngoài block, identity Git, project behavior; không ghi với --check/--rules-only. Test cô lập Git global và XDG.

- [x] Task 1: Installer và uninstall global
  - [x] Thêm regression trong `tests/uninstall.py`: Git check-ignore ở repo mới, cài lại, custom excludesFile, check/rules-only, gỡ và restore.
  - [x] Chạy test mới trước implementation và xác nhận lỗi do thiếu block.
  - [x] Thêm `global-ignore` command trong `scripts/dotagents_lifecycle.py`: resolve Git excludesFile, strip_block rồi append block; lưu đường dẫn trong ledger; uninstall đưa file vào RemovalPlan.
  - [x] Gọi helper từ nhánh global `install.sh`, kể cả check để báo đích nhưng không ghi.
  - [x] Chạy `bash tests/install.sh` và `python3 tests/uninstall.py` với Git global cô lập.

- [x] Task 2: Tài liệu và kiểm chứng
  - [x] Cập nhật `README.md`, `rules/common.md` cho global ignore và uninstall shared block.
  - [x] Review diff, chạy kiểm tra cuối, tick plan và viết summary riêng.

Sau các task: kiểm identity/staged diff, commit và merge local theo yêu cầu repo; không push.

## Spec

[Thiết kế](../specs/2026-10-05-global-conversation-ignore-design.md)

## Kết quả

[Summary](../summaries/2026-10-05-global-conversation-ignore-summary.md)
