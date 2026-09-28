# Safe Uninstall Implementation Plan

**Goal:** Gỡ dotagents theo ownership, hỗ trợ khôi phục mà giữ dữ liệu người dùng.
**Architecture:** Bash entrypoint gọi helper Python chuẩn. Installer snapshot trước/sau và ghi ledger.
**Tech Stack:** Bash, Python 3.11+, unittest, JSON/TOML.

[Spec](../specs/2026-09-28-safe-uninstall-design.md)

- [x] Task 1: Regression và hợp đồng ledger
  - [x] Tạo tests/uninstall.py dùng temp dirs, chạy install/uninstall thật với config env tạm.
  - [x] Kiểm check no mutation, project preserve/selector, legacy marker/manifest errors, restore.
  - [x] Chạy python3 tests/uninstall.py; xác nhận lỗi vì uninstall.sh chưa có.
- [x] Task 2: Helper lifecycle và entrypoint
  - [x] Tạo scripts/dotagents_lifecycle.py với snapshot/record/uninstall/restore CLI.
  - [x] Validate marker/path/manifest/config trước toàn bộ mutation; backup dữ liệu và journal.
  - [x] Tạo uninstall.sh exec Python, hỗ trợ --help/check/project/selectors/rules-only/restore.
  - [x] Hook snapshot/record vào install.sh, không đụng check mode.
  - [x] Chạy regression; sửa từng failure, tick task sau pass.
- [x] Task 3: Tài liệu và kiểm tra cuối
  - [x] README cách uninstall/restore và legacy limitations.
  - [x] Chạy bash tests/install.sh, python3 tests/uninstall.py, bash -n install.sh uninstall.sh, git diff --check.
  - [x] Viết summary riêng, trỏ cả spec và plan; giữ dirty khác ngoài phạm vi.

## Kết quả

[Summary](../summaries/2026-09-28-safe-uninstall-summary.md)
