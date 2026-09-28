# Plan: Hợp nhất skill viết prompt map theo level

Spec: [thiết kế](../specs/2026-09-25-merge-map-prompt-levels-design.md)

- [x] Task 1: Hợp nhất hai profile thành skill canonical theo level
  - [x] Chuyển workflow và role contract dùng chung sang `skills/ch-writing-prompts-map/`.
  - [x] Khai báo profile med/high, trạng thái low và gate xác nhận parent.
  - [x] Giới hạn skill cho Codex và cập nhật metadata gọi skill.
- [x] Task 2: Cập nhật cài đặt và regression coverage
  - [x] Đổi kiểm tra installer từ hai tên profile cũ sang tên canonical.
  - [x] Kiểm tra canonical chỉ vào manifest Codex, profile mapping và không cài tên legacy.
- [x] Task 3: Đồng bộ tài liệu hướng dẫn
  - [x] Cập nhật hướng dẫn ở README và local README.
  - [x] Thêm liên kết spec/plan/summary hai chiều theo quy ước repo.
- [x] Task 4: Xác minh thay đổi
  - [x] Chạy installer regression test.
  - [x] Pressure-test parent gate; xác nhận đủ model/reasoning chỉ có hiệu lực một lần và hết hạn khi có bằng chứng mâu thuẫn.
  - [x] Ghi recipe về đồng bộ source skill với bản Codex đã cài.
  - [x] Rà diff trong phạm vi writing prompt và kiểm tra whitespace.

## Kết quả

[Summary](../summaries/2026-09-25-merge-map-prompt-levels-summary.md)
