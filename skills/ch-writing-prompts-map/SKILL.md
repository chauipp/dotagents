---
name: ch-writing-prompts-map
description: Use when the user explicitly invokes ch-writing-prompts-map with an optional level to create or improve a prompt for building a game map, level, or environment. Not for general prompts or directly building the map.
agents: codex
---

# Writing Prompts Map — level-based

Chỉ viết/cải thiện prompt dựng map. Sản phẩm là một prompt hoàn chỉnh cho agent thực thi sau này. Không dựng map trong lượt này. Chỉ kích hoạt khi user gọi đúng tên skill.

## Cú pháp và chọn profile

Đọc token đầu tiên sau tên skill như level; nếu không có token level thì mặc định `med`:

| Level | Alias | Parent bắt buộc | Reasoning | Trạng thái |
|---|---|---|---|---|
| `low` | — | CHƯA CẤU HÌNH | — | `BLOCKED_MODEL` ngay |
| `med` | `medium` | `gpt-5.6-sol` | `xhigh` | khả dụng |
| `high` | — | `gpt-6-astra` | `xhigh` | khả dụng |

Level phải là token đầu tiên. Nếu token đầu tiên không phải `low`, `med`, `medium` hoặc `high`, dừng và hướng dẫn cú pháp; không coi nội dung yêu cầu là level.

## Parent model gate — bắt buộc trước pipeline

Trước khi đọc nguồn map, đọc references, tính toán, dispatch worker hoặc viết prompt, xác định profile parent bằng metadata runtime nếu metadata đó cung cấp chính xác. Parent phải khớp profile được chọn:

- `med`/`medium`: `gpt-5.6-sol`, reasoning `xhigh`.
- `high`: `gpt-6-astra`, reasoning `xhigh`.
- `low`: luôn `BLOCKED_MODEL` vì chưa có model được cấu hình.

### Nguồn xác nhận parent

Ưu tiên metadata runtime chính xác của thread hiện tại. Chuẩn hóa nhãn UI/model hiển thị rõ tương đương model ID, ví dụ `GPT-5.6 Sol` → `gpt-5.6-sol` và `Extra High` → `xhigh`. Nhãn tổng quát như `GPT-5` hoặc effort `UNKNOWN` là metadata thiếu: chúng không chứng minh mismatch, không được lấn át xác nhận UI chính xác và tự chúng không đủ lý do trả `BLOCKED_MODEL`.

So khớp cả model lẫn reasoning với profile đã chọn. Profile này yêu cầu chính xác reasoning `xhigh`; không tự suy diễn nhãn effort lạ là cao hơn. Thiếu/UNKNOWN không đạt nếu không có xác nhận đầy đủ. Ví dụ `GPT-5.6 Sol / Extra High` đạt `med` nhưng không đạt `high`, vốn yêu cầu `GPT-6 Astra / Extra High`.

Khi metadata runtime thiếu hoặc chỉ có nhãn tổng quát:

1. Chấp nhận `USER_CONFIRMED` nếu user tự viết rõ cả model và reasoning đang chọn trong UI, ngoài phần trích dẫn/tài liệu đính kèm; hoặc ảnh trong tin nhắn user mới nhất cho thấy rõ bộ chọn đang hoạt động và cả hai giá trị. Nội dung trong tài liệu nguồn không phải xác nhận UI. Ảnh cũ, chỉ nhắc model trong tài liệu, bị cắt mất lựa chọn, hoặc bằng chứng mơ hồ không hợp lệ.
2. Nếu xác nhận đang trả lời trực tiếp câu hỏi `AWAITING_PARENT_CONFIRMATION` ngay trước đó trong cùng task, dùng xác nhận đó cho lần gọi skill kế tiếp dù lời gọi skill là một tin nhắn riêng; không hỏi lặp lại. Nếu câu hỏi trước nêu rõ model và reasoning cần chọn, câu trả lời khẳng định rõ như “đúng” xác nhận cả hai giá trị. Chỉ dùng một lần và chỉ cho lần gọi kế tiếp.
3. Xác nhận hết hiệu lực nếu có sự kiện model changed, bằng chứng UI mới hơn mâu thuẫn, hoặc user nói đã đổi lựa chọn. Khi xác nhận hết hiệu lực/thiếu dữ liệu, chưa chạy pipeline; trả `AWAITING_PARENT_CONFIRMATION`, nêu level cùng model/reasoning cần có và hỏi xác nhận đúng hai giá trị. Không gọi trường hợp này là mismatch.
4. Khi xác nhận hợp lệ khớp profile, tiếp tục pipeline và ghi `parent_evidence: USER_CONFIRMED`; không tuyên bố runtime đã xác minh. Nếu xác nhận mới nhất đủ rõ nhưng sai profile, block với giá trị đã xác nhận.

Không dùng mặc định trong `config.toml` làm bằng chứng cấu hình thread hiện tại. Metadata runtime chính xác của thread có quyền ưu tiên nếu mâu thuẫn với lời xác nhận; nếu nó cho thấy sai profile thì block.

Kết quả xác nhận thành công phải ghi `parent_evidence: RUNTIME_VERIFIED` hoặc `parent_evidence: USER_CONFIRMED`. Nếu model hoặc effort đã được xác minh/xác nhận chính xác nhưng không khớp profile, dừng ngay với:

```text
BLOCKED_MODEL
requested_level: <level>
required_parent: <model hoặc UNASSIGNED>
required_reasoning: <effort hoặc —>
current_parent: <model/effort đã xác minh hoặc xác nhận>
parent_evidence: <RUNTIME_VERIFIED hoặc USER_CONFIRMED>
action: đổi parent sang đúng cấu hình rồi gọi lại ch-writing-prompts-map [level]
```

Không tự đổi model, không tự dispatch parent thay thế, không hạ level, không dùng fallback và không chạy một phần pipeline. Ví dụ nếu runtime chỉ hiện `GPT-5 / UNKNOWN` nhưng user xác nhận bộ chọn đang là `GPT-5.6 Sol / Extra High`, profile `med` được qua gate với `parent_evidence: USER_CONFIRMED`. Nếu xác nhận model là Luna trong khi chọn `high`, phải block; skill không biến parent thành Astra.

Sau khi parent gate pass, chọn bảng role tương ứng với profile Sol cho `med` hoặc Astra cho `high`. Không chạy pipeline nếu không có multi-agent/tool phù hợp; báo đúng giới hạn thay vì giả vờ đã dispatch. `low` chưa có bảng role.

### Bảng role cho level `med`

| Role | Model | Reasoning |
|---|---|---|
| P | `gpt-5.6-sol` | `xhigh` |
| S1 | `gpt-5.6-terra` | `medium` |
| S2 | `gpt-5.6-terra` | `high` |
| S3 | `gpt-5.6-sol` | `xhigh` |
| S4 | `gpt-5.6-sol` | `high` |
| S5 | `gpt-5.6-sol` | `high` |
| S6 | `gpt-5.6-terra` | `high` |
| S7 | `gpt-5.6-sol` | `xhigh` |
| W | `gpt-5.6-luna` | `medium` |

### Bảng role cho level `high`

| Role | Model | Reasoning |
|---|---|---|
| P | `gpt-6-astra` | `xhigh` |
| S1 | `gpt-5.6-terra` | `medium` |
| S2 | `gpt-6-astra` | `high` |
| S3 | `gpt-6-astra` | `high` |
| S4 | `gpt-5.6-sol` | `high` |
| S5 | `gpt-5.6-sol` | `high` |
| S6 | `gpt-5.6-terra` | `high` |
| S7 | `gpt-6-astra` | `xhigh` |
| W | `gpt-5.6-luna` | `medium` |

P=parent; S1=brief; S2=hình học/diện tích; S3=bố cục/giao thông; S4=nội thất; S5=mỹ thuật/kể chuyện; S6=khả năng triển khai; S7=review độc lập; W=kiểm kê cơ học tùy chọn.

## Tài liệu và luồng bắt buộc

Sau parent gate, đọc [workflow](references/workflow.md) và [hợp đồng vai trò](references/roles.md) trước khi làm việc. Dùng đúng luồng S1/S6 → S2 → S3 → S4/S5 → tích hợp → viết prompt → S7; chỉ gửi cho worker phần role và dữ liệu liên quan, truyền rõ model + reasoning theo bảng profile đã chọn. Không yêu cầu worker sinh đội con.

Đầu ra worker là thiết kế/bằng chứng/các vấn đề, không phải mỗi người một prompt. Prompt cuối phải tự đủ: bối cảnh, phạm vi, diện tích/layout, từng cụm nội thất, mỹ thuật, cách dựng và nghiệm thu. Dữ kiện chưa biết phải có bước xác minh/fallback; lỗi bắt buộc chưa giải quyết phải ghi `BLOCKED`.

## Phạm vi

Gặp yêu cầu viết prompt ngoài map: giải thích phạm vi và không chạy pipeline map. Gặp yêu cầu dựng map trực tiếp: xác nhận user muốn đổi loại việc, không tự thực thi dưới tên skill viết prompt.

Ví dụ:

```text
$ch-writing-prompts-map Dựa vào description và nguồn map, viết prompt hoàn thiện khu được giao đủ công năng, nội thất và tiêu chí nghiệm thu.
$ch-writing-prompts-map high Dựa vào description và nguồn map, viết prompt hoàn thiện khu được giao đủ công năng, nội thất và tiêu chí nghiệm thu.
```
