Spec: `../specs/2026-09-23-map-subagent-workflow-design.md`
Plan: `../plans/2026-09-23-map-subagent-workflow.md`

# Summary: Map Subagent Workflow

## Đã làm gì

- Thêm `map-subagent-workflow` vào bộ skill shared, giữ nguyên file nguồn.
- Installer sẽ đưa skill mới vào các bộ cài Codex và Claude khi chạy lại.
- Cập nhật README: 27 skill shared, 28 skill tổng cộng và danh sách skill nổi bật có thêm workflow Unreal.
- Đối chiếu SHA-256 nguồn/bản chép và số lượng thư mục shared; các số README khớp.

## File chính

- `shared/skills/map-subagent-workflow/SKILL.md`: bản shared nguyên vẹn của skill map nguồn.
- `README.md`: số lượng và mô tả skill đã cập nhật.
- `docs/superpowers/specs/2026-09-23-map-subagent-workflow-design.md`: yêu cầu và cách đóng gói.
- `docs/superpowers/plans/2026-09-23-map-subagent-workflow.md`: các bước triển khai và trạng thái.

## Khác với plan

- Không lệch. Không cần sửa logic installer vì installer tự quét thư mục shared.

## Còn dở / cần lưu ý

- Chưa chạy test suite theo plan; đã kiểm tra hash file nguồn/bản chép, số thư mục shared và các con số README.
- Ma trận model trong skill giữ nguyên theo file nguồn. Nếu runtime không hỗ trợ một cặp model/reasoning được yêu cầu, skill hướng dẫn dừng và báo lỗi.
