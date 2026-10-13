# ch-learn-english Implementation Plan

> Thực thi theo executing-plans, dùng subagent cho baseline/review và phần installer độc lập.

**Goal:** Tạo skill học tiếng Anh có trạng thái chat bền vững và từ điển cá nhân.

**Architecture:** Python stdlib helper lưu JSON có khóa/atomic replace; UserPromptSubmit nạp phương pháp mỗi lượt; SKILL.md hướng dẫn sửa câu, chú thích và cập nhật learned.

**Tech Stack:** Python 3.11+, Bash installer, Codex hooks.

## Global Constraints

- Skill Codex-only, cài không bật chế độ; on/off riêng session; learned dùng chung.
- Không tự sửa Git identity/trust; không push; không sửa attribution có sẵn.
- Giữ dữ liệu learned khi update/uninstall; không mất dữ liệu khi concurrent writes.
- --check chỉ đọc; --rules-only không cài hooks; giữ hooks của người dùng.

- [x] Task 1: Helper và skill
  - [x] Baseline agent không có skill; test trước core helper.
  - [x] Tạo skills/ch-learn-english/scripts/english_state.py: status, set, learn, forget, lookup, hook.
  - [x] Tạo SKILL.md và references/response-contract.md; học words/phrases/grammar rõ ràng, không suy đoán.
  - [x] Chạy python3 tests/learn_english.py, kiểm concurrent/corruption/large list.

- [x] Task 2: Installer và lifecycle hook
  - [x] Test full/global/project/check/rules-only/collision/ownership/uninstall trước implement.
  - [x] Tích hợp scripts/english_hook_install.py và lifecycle; thêm ngoại lệ ngôn ngữ Codex, README.
  - [x] Chạy bash tests/install.sh và python3 tests/uninstall.py trong TMPDIR riêng ngoài repo.

- [x] Task 3: Runtime, review và kết quả
  - [x] Test agent có skill; đọc phản hồi sửa câu, chú thích, known omission, grammar notes.
  - [x] Test runtime thật cùng hook trong môi trường riêng; test on/off và learned.
  - [x] Review diff, sửa lỗi, chạy covering tests, tick task ngay khi hoàn tất.
  - [x] Viết summary riêng; Git identity và staged diff là cổng bắt buộc trước commit cuối.

## Kết quả

[Summary](../summaries/2026-10-13-ch-learn-english-summary.md)

[Spec](../specs/2026-10-13-ch-learn-english-design.md)
