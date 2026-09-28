# Evaluation guide

Đọc file này trong pha AUDIT sau khi target mode đã được xác định và `ch-research` đã thu thập evidence. Capability host, nếu không expose được, phải ghi là `UNVERIFIED`; không được biến thiếu metadata parent thành lý do chặn toàn bộ proposal.

## Thứ tự bằng chứng

1. Metadata/capability trực tiếp của Codex host quyết định model và reasoning nào có thể chạy.
2. Bảng giá chính thức theo đúng billing surface và tài liệu model OpenAI mô tả giá, capability, giới hạn, tool use và reasoning; xác nhận ngày truy cập, model ID, đơn vị, tier và điều kiện giá.
3. Benchmark hoặc đánh giá độc lập chỉ dùng khi task, model version, harness, prompt, reasoning, tool access và metric đủ tương đồng.
4. Provider benchmark được ghi là provider-reported khi thiếu kiểm chứng độc lập.
5. Kinh nghiệm cộng đồng là tín hiệu yếu; inference phải ghi nhãn.

Không gộp các kết quả không so sánh trực tiếp. Ngày research phải xuất hiện trong proposal.

## Bằng chứng giá và chi phí thực tế

Với **mỗi model/effort hiện tại và ứng viên** trong từng profile/role, ghi riêng billing surface (Codex gói thuê bao/credits, Codex token billing, hoặc API), nguồn giá chính thức và ngày kiểm tra. Trường `target_billing_surface` cấp proposal mô tả cách workload target được tính phí; nó không thay cho billing surface riêng của từng model. Kiểm tra [giá API chính thức](https://developers.openai.com/api/docs/pricing) và [cách tính usage Codex](https://help.openai.com/en/articles/11369540-using-codex-with-your-chatgpt-plan) theo đúng account/kênh sử dụng. Giá API không tự động là giá mà người dùng trả trong Codex. Nếu gói thuê bao chỉ có quota/credits mà không có quy đổi USD đáng tin, báo đơn vị quota/credits; USD là `UNKNOWN`. Không suy giá Codex từ API nếu chưa xác minh chính sách quy đổi.

Khi có giá theo token, ghi riêng input, cached input/cache write, output, long-context/tier surcharge và tool-call fee nếu áp dụng. Reasoning token và output dài hơn ở effort cao phải được tính vào kịch bản. Giá khuyến mại và điều kiện hết hạn phải được nêu. Nếu nguồn không cho giá của đúng model/tier, ghi `UNKNOWN`; không thay bằng giá của model gần giống.

Ước tính **chi phí cho một task đạt chuẩn**, không chỉ giá/1M token. Dùng usage trace thực của target nếu có: số lượt parent, số worker song song, token theo loại, retry, review, tool call, thời gian và tỷ lệ pass. Nếu chưa có trace, đưa kịch bản thấp/cơ sở/cao với giả định token, retry và cache minh bạch; ghi `ESTIMATE`, không trình bày như chi phí đo được. Công thức cho từng kịch bản: tổng chi phí các lượt model + tool + retry/review, chia cho số đầu ra đạt rubric; nếu tỷ lệ pass chưa biết, cost-per-pass là `UNKNOWN` và chỉ báo cost-per-attempt. Với worker chạy song song, cộng chi phí tất cả worker nhưng đo wall-clock theo đường găng.

So hiện trạng và ứng viên trên **cùng workload, cùng billing surface, cùng điều kiện giá**. Nêu mức chênh tuyệt đối và phần trăm, ngưỡng cải thiện chất lượng/giảm retry cần đạt để bù chi phí, cùng độ nhạy khi token hoặc pass rate thay đổi. Nếu không thể so cùng điều kiện, trình bày hai kịch bản riêng và ghi `NOT_COMPARABLE`.

## Bằng chứng hiệu năng theo đúng nhiệm vụ

Ưu tiên eval nội bộ trên các task đại diện của target và rubric của từng role: độ đúng ràng buộc, lỗi nghiêm trọng, chất lượng đầu ra cuối, phát hiện lỗi của reviewer, số vòng sửa và thời gian tới PASS. Với target map, đo thêm hình học/fit và khả năng thực thi prompt. Ghi số mẫu, độ khó, cùng input/tool/harness, model version, reasoning, cách chấm và khoảng biến thiên nếu có. Không dùng một điểm benchmark coding hoặc sáng tạo tổng quát để kết luận trực tiếp cho role chuyên biệt của target.

Nếu chưa có eval nội bộ, tìm benchmark gần nhiệm vụ nhất, nêu khoảng cách giữa benchmark và role, và xem đó là evidence gián tiếp. Với role quyết định chất lượng cuối hoặc parent gate, chỉ đưa khuyến nghị đổi khi lợi ích có bằng chứng đủ mạnh hoặc rủi ro hiện trạng đã được quan sát; trường hợp còn mơ hồ dùng `KEEP`/`BLOCKED` và đề nghị A/B nhỏ trên cùng tập task. Không cộng điểm từ các benchmark khác harness thành một thứ hạng duy nhất.

## Quyết định theo profile

Mỗi profile giữ mục tiêu riêng từ target. `low` ưu tiên chi phí/thời gian nhưng phải đạt ngưỡng đúng bắt buộc; `med` tối ưu cân bằng chất lượng, chi phí và tốc độ; `high` ưu tiên chất lượng và độ tin cậy, nhưng vẫn phải giải thích lợi ích tăng thêm so với `med`. Đây là tiêu chí đánh giá, không phải lệnh tự tạo hay kích hoạt profile thiếu. Với slot `UNASSIGNED`, chỉ đề xuất khi nêu được ngưỡng chất lượng tối thiểu và cách kiểm chứng.

Với từng row, đưa verdict theo thứ tự: ràng buộc task → hiệu năng hiện trạng/ứng viên → chi phí cho task đạt chuẩn → đánh đổi theo profile → lựa chọn `KEEP`/`CHANGE`/`UNASSIGNED`/`BLOCKED`. Nêu ít nhất một lựa chọn cạnh tranh hợp lệ và lý do không chọn. Nếu giá hoặc hiệu năng cần thiết còn `UNKNOWN`, ghi câu hỏi/eval cần làm; không biến suy luận thành kết quả đo.

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

Giữ nghĩa profile trong target. Nếu target có `low/med/high`, đánh giá riêng từng profile theo mục tiêu chất lượng, tốc độ và chi phí đã ghi trong target. Nếu target có `medium`, báo cáo cùng profile chuẩn hóa `med`. Nếu target không có profile, đánh giá mode `default` theo các role/model/reasoning hiện có và không tự tạo ba level.

Mỗi profile phải có cấu hình parent khả thi. Nếu parent gate yêu cầu model/effort cao hơn parent row, proposal phải đánh dấu `BLOCKED` thay vì thêm fallback. Nếu chỉ thiếu capability metadata của host, không chặn AUDIT: ghi `capability_status: UNVERIFIED` và không khẳng định model/effort dispatch được. Row `CHANGE` chỉ hợp lệ nếu skill đích preflight/fail-closed toàn bộ model và reasoning của parent lẫn mọi worker trong profile trước dispatch đầu tiên; gate chỉ kiểm tra parent chưa đủ và lỗi dispatch sau khi pipeline bắt đầu không phải preflight. Nếu target chưa có gate toàn profile, dùng `BLOCKED` cho rows phụ thuộc dispatch.

## Confidence

- `high`: host capability rõ, nguồn chính thức và evidence task-specific độc lập cùng hướng.
- `medium`: capability rõ, giá đúng billing surface và evidence task-specific còn hạn chế hoặc chủ yếu provider-reported.
- `low`: inference từ task gần giống, dữ liệu ít hoặc có bất đồng đáng kể.

Chỉ `CHANGE`/`UNASSIGNED` khi evidence đủ để giải thích lợi ích, chi phí và trade-off theo profile. Nếu không, dùng `KEEP` hoặc `BLOCKED`. Confidence của chất lượng, chi phí và khả dụng host phải được nêu riêng; một nguồn giá chính xác không làm tăng confidence của hiệu năng.
