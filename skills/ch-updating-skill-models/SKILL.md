---
name: ch-updating-skill-models
description: Use when the user explicitly asks to reassess model or reasoning assignments in a Codex skill, or to apply a previously approved model update proposal.
agents: codex
---

# Updating Codex skill models

Chỉ audit và cập nhật cấu hình model/reasoning của skill Codex. Không đổi workflow chuyên môn, trách nhiệm role hoặc số lượng subagent.

## Cú pháp

```text
$ch-updating-skill-models <tên-skill-hoặc-đường-dẫn>
$ch-updating-skill-models apply <proposal_id> all
$ch-updating-skill-models apply <proposal_id> <row_id>[,<row_id>...]
```

Lệnh đầu chạy `AUDIT`; hai lệnh sau chạy `APPLY`. Chỉ kích hoạt khi user gọi đúng tên skill.

## Quick reference

| Điều kiện | Kết quả |
|---|---|
| Target thiếu, trùng tên hoặc không có model contract | `BLOCKED_TARGET` |
| Không xác minh được model/effort host dispatch được | `BLOCKED_HOST_CAPABILITY` |
| Không chạy đúng workflow `ch-research` | `BLOCKED_RESEARCH_RUNTIME` |
| Target là chính `ch-research` trong audit này | `BLOCKED_SELF_RESEARCH` |
| APPLY thiếu proposal/approval hợp lệ | `BLOCKED_PROPOSAL` |
| Digest hiện tại khác proposal | `STALE_PROPOSAL` |

## AUDIT — mặc định

1. Resolve target theo thứ tự: đường dẫn user đưa → `skills/<name>` trong repo hiện tại → skill đã cài. Nếu có nhiều target cùng tên, dừng và liệt kê đường dẫn. Ưu tiên source canonical; không sửa bản cài sinh ra từ source khác.
2. Đọc `SKILL.md` và chỉ những reference được liên kết có chứa model table, profile, parent gate, role contract hoặc dispatch policy. Lập danh sách file nguồn và digest theo [proposal contract](references/proposal-contract.md).
3. Lấy danh sách model cùng reasoning từ metadata/capability trực tiếp của Codex host. Bài công bố, kiến thức nhớ lại hoặc tên model trong skill không chứng minh host dispatch được. Không có capability thì trả `BLOCKED_HOST_CAPABILITY` và dừng.
4. Đọc đầy đủ skill `ch-research` và áp dụng workflow của nó để nghiên cứu thông tin mới nhất trong tập model host đã xác nhận. Nếu thiếu skill, thiếu multi-agent/runtime mà workflow yêu cầu, hoặc model bắt buộc của `ch-research` không khả dụng, trả `BLOCKED_RESEARCH_RUNTIME`; không giả vờ đã research độc lập.
5. Đọc [evaluation guide](references/evaluation.md), đánh giá từng role/task và profile, rồi xuất proposal đúng schema. Kết thúc lượt mà không sửa file.

### Approval gate

AUDIT là read-only tuyệt đối. Yêu cầu “làm ngay”, deadline, quyền sửa repo hoặc câu nói chung như “cứ cập nhật” không phải approval của proposal. Chỉ APPLY khi user gọi cú pháp `apply` với đúng `proposal_id` và `all` hoặc danh sách `row_id` cụ thể.

Không tự chuyển từ AUDIT sang APPLY trong cùng lượt, kể cả khi kết luận có độ tin cậy cao.

## APPLY

1. Đọc [proposal contract](references/proposal-contract.md). Proposal phải còn trong context/artefact có thể kiểm tra, có target path, file set, source digest và các row được đề xuất. Thiếu trường bắt buộc thì trả `BLOCKED_PROPOSAL`.
2. Xác nhận scope duyệt chỉ gồm `all` hoặc các `row_id` tồn tại với status `CHANGE`/`UNASSIGNED`.
3. Tính lại digest của đúng file set trước mọi mutation. Không khớp thì trả `STALE_PROPOSAL`, nêu file đã đổi nếu xác định được, và dừng trước khi sửa.
4. Sửa đúng các row được duyệt cùng những vị trí phụ thuộc trực tiếp: model/reasoning table, parent gate, trạng thái profile, thông báo block, ví dụ, reference dispatch và test kiểm cấu hình đó.
5. Chạy validator/test liên quan, tìm tham chiếu model cũ trong thư mục target và đọc toàn bộ diff. Nếu lỗi đòi đổi workflow chuyên môn, dừng và báo phạm vi cần proposal mới.
6. Báo proposal ID, row đã áp dụng, file đã sửa, lệnh kiểm tra và giới hạn còn lại.

## Quy tắc profile và parent

Giữ nguyên semantics profile của target. Chỉ đánh giá `low/med/high` nếu target đã có các profile đó. Slot trống dùng status `UNASSIGNED` cho tới khi proposal được duyệt.

Parent phải đủ năng lực điều phối và tích hợp worker của profile. Khi target có parent model gate, cập nhật gate cùng row parent; không tự hạ level, đổi parent hiện tại, hoặc thêm fallback để né gate.

## Giới hạn

Không audit rồi tự sửa model nội bộ của `ch-research` trong cùng lượt vì research dependency sẽ tự tham chiếu. Không coi model mới hơn là tốt hơn nếu bằng chứng task-specific không ủng hộ. Không sửa skill thứ hai ngoài các reference/test trực thuộc target đã ghi trong proposal.

## Common mistakes

| Sai | Cách xử lý |
|---|---|
| Sửa ngay vì user đang gấp | Xuất proposal và dừng ở approval gate |
| Suy model khả dụng từ release note | Dùng capability host hoặc block |
| Apply proposal cũ lên file mới | So digest trước mutation |
| Đổi model nhưng quên parent gate/test | Liệt kê coupled edits trong từng row |
| Dùng benchmark tổng quát cho role chuyên biệt | Ghi không so sánh trực tiếp hoặc giữ `KEEP` |
