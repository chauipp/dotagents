# Kết quả triển khai skill model updater

[Spec thiết kế](../specs/2026-09-25-skill-model-updater-design.md) · [Plan thực thi](../plans/2026-09-25-skill-model-updater.md)

## Đã làm gì

- Tạo `$ch-updating-skill-models` ở chế độ explicit-only và chỉ cài cho Codex.
- Tách quy trình thành AUDIT read-only và APPLY cần proposal ID cùng scope được duyệt.
- Buộc AUDIT xác minh capability của Codex host, dùng `ch-research`, đánh giá từng role/profile và xuất proposal có evidence.
- Thêm digest tái lập cùng các gate `BLOCKED_*` và `STALE_PROPOSAL` để tránh sửa sớm, đoán model khả dụng hoặc ghi đè skill đã đổi.
- Chạy RED-GREEN với evaluator độc lập: control đã sửa model trước proposal; sau khi có skill, 5/5 mẫu giữ approval gate, capability thiếu bị block và proposal stale bị chặn.
- Ghi lại recipe cho bẫy validator chuẩn không hiểu extension `agents: codex` của repo.

## File chính

- `skills/ch-updating-skill-models/SKILL.md`: entrypoint, routing AUDIT/APPLY và hard gate.
- `skills/ch-updating-skill-models/references/evaluation.md`: tiêu chí chọn model/reasoning theo role, profile và chất lượng bằng chứng.
- `skills/ch-updating-skill-models/references/proposal-contract.md`: schema proposal, thuật toán digest, cú pháp duyệt và stale check.
- `skills/ch-updating-skill-models/agents/openai.yaml`: metadata UI và policy explicit-only.
- `docs/superpowers/specs/2026-09-25-skill-model-updater-design.md`: thiết kế đã duyệt.
- `docs/superpowers/plans/2026-09-25-skill-model-updater.md`: các bước triển khai và bằng chứng hoàn tất.
- `docs/recipes/validating-codex-only-skills.md`: cách validate skill Codex-only mà không làm mất bộ lọc installer.

## Khác với plan

- Validator `skill-creator` không chấp nhận key mở rộng `agents: codex` mà installer của repo dùng. Bản sao tạm bỏ riêng key này trả `Skill is valid!`; bản thật được xác minh Codex-only bằng installer regression.
- Không sửa `tests/install.sh`: test hiện có tự sinh expected manifest từ `skills/*/`, nên đã kiểm đúng việc cài skill mới cho Codex và không cài cho Claude mà không cần thêm assertion trùng lặp.
- Sau khi task pass, `ch-capturing-what-worked` xác định khác biệt schema validator/installer đáng ghi thành recipe riêng.

## Còn dở / cần lưu ý

- Skill cần được cài lại bằng `install.sh --codex` và phiên Codex cần khởi động lại trước khi tên skill mới xuất hiện trong danh sách khả dụng.
- Khi dùng AUDIT thật, nếu host không cung cấp capability model/reasoning hoặc runtime không chạy được đúng `ch-research`, skill sẽ dừng theo gate thay vì đưa đề xuất.
