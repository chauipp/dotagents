# Kết quả triển khai skill model updater

[Spec thiết kế](../specs/2026-09-25-skill-model-updater-design.md) · [Plan thực thi](../plans/2026-09-25-skill-model-updater.md)

## Đã làm gì

- Tạo `$ch-updating-skill-models` explicit-only, chỉ cài cho Codex, với hai pha AUDIT read-only và APPLY sau khi người dùng duyệt proposal cụ thể.
- Cho AUDIT tiếp tục khi host không expose capability; đánh dấu `UNVERIFIED` và yêu cầu preflight/fail-closed toàn profile cho parent cùng mọi worker trước khi dispatch.
- Phân biệt target `default` với `profiled`, giữ nguyên tập profile hiện có và không tự tạo level.
- Yêu cầu evidence theo đúng task, rubric/eval, giá và chi phí trên đầu ra đạt chuẩn; không dùng giá API làm phí subscription, và ghi `UNKNOWN`/`ESTIMATE` khi thiếu số đo.
- Bảo vệ APPLY bằng source ledger/digest, approval có scope, stale check và kiểm tra các chỉnh sửa phụ thuộc.

## File chính

- `skills/ch-updating-skill-models/SKILL.md`: định tuyến AUDIT/APPLY, profile mode và các gate.
- `skills/ch-updating-skill-models/references/evaluation.md`: tiêu chí bằng chứng task-specific, billing surface, chi phí thực tế và hiệu năng.
- `skills/ch-updating-skill-models/references/proposal-contract.md`: snapshot/digest, schema row/evidence card, approval và stale check.
- `skills/ch-updating-skill-models/agents/openai.yaml`: metadata UI và policy explicit-only.
- `docs/superpowers/specs/2026-09-25-skill-model-updater-design.md` và `docs/superpowers/plans/2026-09-25-skill-model-updater.md`: thiết kế và các bước đã kiểm chứng.
- `docs/recipes/validating-codex-only-skills.md`: phân biệt validator chuẩn với installer extension `agents: codex`.

## Khác với plan

- Thay cổng chặn thiếu host capability bằng trạng thái `UNVERIFIED`, tiếp tục audit có điều kiện và yêu cầu fail-closed toàn profile cho parent và workers; nếu target chỉ gate parent thì rows đổi worker phải `BLOCKED`.
- Bổ sung đánh giá chi phí theo billing surface và một đầu ra đạt chuẩn; không quy đổi giá API thành khoản phí Codex subscription khi không có căn cứ.
- Installer regression không cần thêm assertion vì test hiện có tự dựng manifest và xác minh skill Codex-only.

## Còn dở / cần lưu ý

- Chưa chạy một AUDIT thật để đề xuất model cho skill đích; thiếu dữ liệu hiệu năng riêng cần được biểu thị `UNKNOWN` và xử lý bằng eval/A-B, không phải ước lượng chắc chắn.
- `ch-writing-prompts-map` hiện chỉ preflight parent; khi capability host `UNVERIFIED`, các row đổi worker cần `BLOCKED` trừ khi proposal được duyệt bổ sung preflight toàn profile.
- Muốn thấy metadata skill mới/cập nhật trong Codex có thể cần chạy installer `--codex` và khởi động lại phiên.
