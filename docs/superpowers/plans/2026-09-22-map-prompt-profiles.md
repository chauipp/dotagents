# Map prompt profiles implementation plan

Goal: hai skill local chuyên viết prompt map, cùng hợp đồng chất lượng, khác model.
Architecture: self-contained local/skills packages; identical reference documents; explicit model dispatch tables; no global install.
Tech: Markdown, YAML; behavior trials với subagent; shell installer sandbox regression.
Constraints: không Astra trong các lượt test; không push; bảo toàn dirty files; không sửa engine/map.

- [x] Task 1: Khảo sát và baseline
  - [x] Đọc source, workflow và installer; tạo worktree codex/map-prompt-profiles từ main.
  - [x] Chạy bash tests/install.sh trong sandbox tạm; chạy baseline sector 60°, R12/r4, protected union 16m².
  - [x] Ghi lỗi baseline: tự đổi 80% phủ sàn sang phủ thị giác; giả định tuyến khi cửa chưa biết.
- [x] Task 2: Profile Sol
  - [x] Tạo local/skills/writing-prompts-map-sol/{SKILL.md,agents/openai.yaml,references/workflow.md,references/roles.md}.
  - [x] Test áp dụng với sector + rectangle + missing geometry; reviewer Sol kiểm hợp đồng.
- [x] Task 3: Profile Astra và migration
  - [x] Tạo package Astra từ cùng reference; chỉ đổi model policy/table.
  - [x] Test routing/mismatch bằng Terra; parity references và schema metadata.
  - [x] Xóa generic shared/skills/writing-prompts, cập nhật README counts và cách gọi local.
- [x] Task 4: Tích hợp và bàn giao
  - [x] Chạy installer regression trên cây cuối; chứng minh global không có hai profile.
  - [x] Review/fix; viết summary và bằng chứng test (nêu rõ chưa chạy đội Astra).
  - [x] Kiểm Git identity, hoàn tất review để commit/merge local; đã cài copies local và so checksum. Không push/global install.

## Spec
[Spec](../specs/2026-09-22-map-prompt-profiles-design.md)
## Kết quả
[Summary](../summaries/2026-09-22-map-prompt-profiles-summary.md)
