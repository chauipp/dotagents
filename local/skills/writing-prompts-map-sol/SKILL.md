---
name: writing-prompts-map-sol
description: Use when the user explicitly invokes writing-prompts-map-sol to create or improve a prompt for building a game map, level, or environment. Not for general prompts or directly building the map.
---

# Writing Prompts Map — Sol

Chỉ viết/cải thiện prompt dựng map. Sản phẩm là một prompt hoàn chỉnh cho agent thực thi sau này. Không dựng map trong lượt này. Chỉ kích hoạt khi user gọi đúng profile; không tự kích hoạt cả hai skill. Cài project-local, không cài global.

## Model bắt buộc

Các worker chỉ dùng gpt-5.6-sol, gpt-5.6-terra, gpt-5.6-luna với reasoning không vượt xhigh; không dùng Astra làm worker hoặc tự fallback sang Astra. Parent tối thiểu là Sol xhigh theo gate bên dưới; nếu user xác nhận dùng parent cấp cao hơn thì chỉ parent được nâng, bảng worker vẫn giữ nguyên. Khi role Terra/Luna gặp vấn đề cần nâng cấp, parent có thể giao lại trong allowlist, tối đa Sol xhigh, ghi lý do. Không tự nâng mọi role lên Sol.

| Role | Model ID | Reasoning |
|---|---|---|
| P | `gpt-5.6-sol` minimum; higher tier only after user confirmation | `xhigh` |
| S1 | `gpt-5.6-terra` | `medium` |
| S2 | `gpt-5.6-terra` | `high` |
| S3 | `gpt-5.6-sol` | `xhigh` |
| S4 | `gpt-5.6-sol` | `high` |
| S5 | `gpt-5.6-sol` | `high` |
| S6 | `gpt-5.6-terra` | `high` |
| S7 | `gpt-5.6-sol` | `xhigh` |
| W | `gpt-5.6-luna` | `medium` |

P=parent; S1=brief; S2=hình học/diện tích; S3=bố cục/giao thông; S4=nội thất; S5=mỹ thuật/kể chuyện; S6=khả năng triển khai; S7=review độc lập; W=kiểm kê cơ học tùy chọn.

### Parent model gate

- Tối thiểu: `gpt-5.6-sol` ở `xhigh`.
- So sánh theo credit dùng cho cùng lượng token vào/ra: `gpt-5.6-luna < gpt-5.6-terra < gpt-5.6-sol < gpt-6-astra`. Không xếp hạng theo tổng token phát sinh của một câu trả lời.
- Xác minh model parent trước mọi bước pipeline.
- Parent thấp hơn Sol, hoặc reasoning thấp hơn `xhigh`: dừng với `BLOCKED_MODEL`; không chạy một phần pipeline.
- Parent cao hơn Sol: hỏi user có muốn dùng model đó không. Chỉ sau khi user đồng ý mới tiếp tục, và dùng model đã xác nhận cho mọi nhiệm vụ parent.
- User từ chối: dừng và yêu cầu chuyển parent sang Sol. Không tự đổi model.
- Không xác minh được model: block và yêu cầu user xác nhận/chọn parent.
- Bảng role vẫn chi phối worker; nâng parent không tự nâng worker.

Lời gọi skill cho phép parent giao subagent theo bảng. Đọc schema tool hiện có và truyền rõ model + reasoning; dùng context mới (với collaboration.spawn_agent: fork_turns="none", model=ID, reasoning_effort=effort). Gói task phải tự đủ dữ kiện. Không chạy subagent không chỉ định model rồi mặc định nó đúng profile. Không yêu cầu worker sinh đội con.

## Tài liệu bắt buộc

Trước làm việc, parent đọc [workflow](references/workflow.md) và [hợp đồng vai trò](references/roles.md). Hai profile dùng cùng quy trình/tiêu chí; không giảm việc vì đổi model. Khi dispatch, chỉ gửi phần role và dữ liệu liên quan, không gửi mọi reference cho mọi worker.

## Luồng chính

S1/S6 → S2 → S3 → S4/S5 song song → parent tích hợp và kiểm lại phần ảnh hưởng → parent viết prompt → S7 độc lập → sửa → giao một prompt. W hỗ trợ kiểm kê, không thay S6/S7. Giới hạn đồng thời theo tool và budget user; không cắt gate để tiết kiệm.

Đầu ra worker là thiết kế/bằng chứng/các vấn đề, không phải mỗi người một prompt. Prompt cuối chứa bối cảnh, phạm vi, diện tích/layout, từng cụm nội thất, mỹ thuật, cách dựng và nghiệm thu. Số chưa biết có bước xác minh/fallback cụ thể; lỗi bắt buộc chưa giải quyết phải ghi BLOCKED.

## Ví dụ gọi

`$writing-prompts-map-sol Dựa vào description và file prompt/map/map-1 của khu được giao, viết prompt hoàn thiện map đủ công năng và nội thất, giữ kiến trúc, tính diện tích có căn cứ và có tiêu chí nghiệm thu.`

Gặp yêu cầu viết prompt ngoài map: giải thích phạm vi và không chạy pipeline map. Gặp yêu cầu dựng map trực tiếp: xác nhận user muốn đổi loại việc, không tự thực thi dưới tên skill viết prompt.
