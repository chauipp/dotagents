# Evaluation guide

Đọc file này trong pha AUDIT sau khi host capability đã được xác minh và `ch-research` đã thu thập evidence.

## Thứ tự bằng chứng

1. Metadata/capability trực tiếp của Codex host quyết định model và reasoning nào có thể chạy.
2. Tài liệu OpenAI chính thức mô tả capability, giới hạn, tool use và reasoning.
3. Benchmark hoặc đánh giá độc lập chỉ dùng khi task, model version, harness, prompt, reasoning, tool access và metric đủ tương đồng.
4. Provider benchmark được ghi là provider-reported khi thiếu kiểm chứng độc lập.
5. Kinh nghiệm cộng đồng là tín hiệu yếu; inference phải ghi nhãn.

Không gộp các kết quả không so sánh trực tiếp. Ngày research phải xuất hiện trong proposal.

## Ma trận role/task

Với mỗi role, ghi ngắn gọn:

| Tiêu chí | Câu hỏi |
|---|---|
| Reasoning complexity | Có nhiều bước phụ thuộc, tối ưu hoặc mâu thuẫn phải giải quyết không? |
| Context burden | Role phải giữ bao nhiêu nguồn, constraint và revision? |
| Tool use | Có browse, code, tính toán, file hoặc API cần độ tin cậy cao không? |
| Error impact | Sai sót chỉ làm chậm hay phá kết quả tích hợp/gate cuối? |
| Critical path | Role nằm trên đường găng hay chạy song song số lượng lớn? |
| Review independence | Reviewer có cần model mạnh/context mới để tìm lỗi của parent không? |
| Latency/cost | Profile có ưu tiên tốc độ/chi phí và có evidence định lượng không? |
| Effort gain | Reasoning cao hơn có cải thiện task này theo evidence hay chỉ kéo dài output? |

## Chọn model và effort

Chọn model theo yêu cầu role, sau đó chọn reasoning thấp nhất vẫn đáp ứng độ tin cậy cần thiết. Không ánh xạ máy móc `low → low reasoning`, `high → max reasoning`.

- Parent: đủ năng lực điều phối, xử lý mâu thuẫn và tích hợp mọi worker trong profile.
- Reviewer độc lập: ưu tiên khả năng phát hiện lỗi và giữ riêng context; không mặc định cùng model với writer.
- Task cơ học/kiểm kê: ưu tiên model nhanh hơn nếu schema rõ và hậu quả lỗi được gate sau bắt lại.
- Task hình học, code hoặc logic nhiều bước: tăng reasoning khi evidence cho thấy task hưởng lợi.
- Worker song song số lượng lớn: cân nhắc latency/cost nhưng không hạ dưới ngưỡng chất lượng của role.

Model mới hơn không mặc định tốt hơn. Khi evidence không phân biệt được hai lựa chọn, dùng `KEEP`. Khi slot hiện tại trống và đủ evidence, dùng `UNASSIGNED` cùng đề xuất; slot vẫn chưa chạy cho tới APPLY.

## Profile

Giữ nghĩa profile trong target. Nếu target có `low/med/high`, đánh giá từng profile theo mục tiêu chất lượng, tốc độ và chi phí đã ghi trong target. Nếu target không có profile, không tự tạo ba level.

Mỗi profile phải có cấu hình parent khả thi. Nếu parent gate yêu cầu model/effort cao hơn parent row hoặc host không hỗ trợ, proposal phải đánh dấu `BLOCKED` thay vì thêm fallback.

## Confidence

- `high`: host capability rõ, nguồn chính thức và evidence task-specific độc lập cùng hướng.
- `medium`: capability rõ nhưng evidence task-specific còn hạn chế hoặc chủ yếu provider-reported.
- `low`: inference từ task gần giống, dữ liệu ít hoặc có bất đồng đáng kể.

Chỉ `CHANGE`/`UNASSIGNED` khi evidence đủ để giải thích lợi ích và trade-off. Nếu không, dùng `KEEP` hoặc `BLOCKED`.
