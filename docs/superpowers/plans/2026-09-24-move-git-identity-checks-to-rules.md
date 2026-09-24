# Kế hoạch: chuyển checklist Git identity vào rules

- [x] Task 1: Chuyển quy trình đầy đủ vào rules hai agent và gỡ skill khỏi catalog
  - Cập nhật `claude/CLAUDE.md` và `codex/AGENTS.md` với checklist trước commit/push, điều kiện dừng, quy tắc attribution và bảo toàn provenance.
  - Xóa `skills/preserving-user-git-identity/SKILL.md`; installer lấy danh sách động nên bản trong manifest cũ sẽ được dọn khi cập nhật.
- [x] Task 2: Đồng bộ README và rà tham chiếu hiện hành
  - Cập nhật số lượng còn 29 tổng, 27 cho Claude, 29 cho Codex; bỏ hàng skill khỏi danh mục.
  - Xác nhận không còn tham chiếu hiện hành trong catalog/installer tới skill đã gỡ.

## Kết quả

Xem [summary](../summaries/2026-09-24-move-git-identity-checks-to-rules-summary.md).
