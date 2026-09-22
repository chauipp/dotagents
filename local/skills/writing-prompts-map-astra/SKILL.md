---
name: writing-prompts-map-astra
description: Use when the user explicitly invokes writing-prompts-map-astra to create or improve a prompt for building a game map, level, or environment. Not for general prompts or directly building the map.
---

# Writing Prompts Map — Astra

Chỉ viết/cải thiện prompt dựng map. Sản phẩm là một prompt hoàn chỉnh cho agent thực thi sau này. Không dựng map trong lượt này. Chỉ kích hoạt khi user gọi đúng profile; không tự kích hoạt cả hai skill. Cài project-local, không cài global.

## Model bắt buộc

P yêu cầu gpt-6-astra xhigh. S2/S3 dùng Astra high, S7 Astra xhigh; phần còn lại theo bảng. Không tự dùng max/ultra. Nếu thiếu Astra, báo và đề nghị user chọn writing-prompts-map-sol; không âm thầm đổi profile.

| Role | Model ID | Reasoning |
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

Kiểm model/effort đang chạy bằng metadata môi trường nếu được cung cấp. Skill không tự đổi parent. Nếu parent sai cấu hình, dừng trước pipeline và hướng dẫn user chọn đúng model/effort; không nhận đang dùng model mong muốn chỉ vì file ghi vậy. Nếu không xác minh được parent, yêu cầu user xác nhận cấu hình. Không đổi config global. Model/effort role không được tool hỗ trợ thì báo giới hạn, xin chọn cấu hình tương thích trong profile; không tự thay thế ngoài allowlist. Nếu không có cấu hình tương thích và user chưa chọn phương án khác, ghi BLOCKED_MODEL với role/model thiếu rồi dừng pipeline, không hỏi lặp hoặc giả đã chạy.

Lời gọi skill cho phép parent giao subagent theo bảng. Đọc schema tool hiện có và truyền rõ model + reasoning; dùng context mới (với collaboration.spawn_agent: fork_turns="none", model=ID, reasoning_effort=effort). Gói task phải tự đủ dữ kiện. Không chạy subagent không chỉ định model rồi mặc định nó đúng profile. Không yêu cầu worker sinh đội con.

## Tài liệu bắt buộc

Trước làm việc, parent đọc [workflow](references/workflow.md) và [hợp đồng vai trò](references/roles.md). Hai profile dùng cùng quy trình/tiêu chí; không giảm việc vì đổi model. Khi dispatch, chỉ gửi phần role và dữ liệu liên quan, không gửi mọi reference cho mọi worker.

## Luồng chính

S1/S6 → S2 → S3 → S4/S5 song song → parent tích hợp và kiểm lại phần ảnh hưởng → parent viết prompt → S7 độc lập → sửa → giao một prompt. W hỗ trợ kiểm kê, không thay S6/S7. Giới hạn đồng thời theo tool và budget user; không cắt gate để tiết kiệm.

Đầu ra worker là thiết kế/bằng chứng/các vấn đề, không phải mỗi người một prompt. Prompt cuối chứa bối cảnh, phạm vi, diện tích/layout, từng cụm nội thất, mỹ thuật, cách dựng và nghiệm thu. Số chưa biết có bước xác minh/fallback cụ thể; lỗi bắt buộc chưa giải quyết phải ghi BLOCKED.

## Ví dụ gọi

`$writing-prompts-map-astra Dựa vào description và file prompt/map/map-1 của khu được giao, viết prompt hoàn thiện map đủ công năng và nội thất, giữ kiến trúc, tính diện tích có căn cứ và có tiêu chí nghiệm thu.`

Gặp yêu cầu viết prompt ngoài map: giải thích phạm vi và không chạy pipeline map. Gặp yêu cầu dựng map trực tiếp: xác nhận user muốn đổi loại việc, không tự thực thi dưới tên skill viết prompt.
