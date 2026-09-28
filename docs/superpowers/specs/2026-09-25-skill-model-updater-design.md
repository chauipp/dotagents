# Thiết kế skill cập nhật model cho skill Codex

## Mục tiêu

Tạo skill explicit-only `$ch-updating-skill-models` để đánh giá lại cấu hình model và reasoning của một skill Codex có parent/subagent, đưa ra đề xuất có bằng chứng, rồi chỉ áp dụng đề xuất sau khi người dùng duyệt rõ một phiên bản cụ thể.

Skill phân biệt capability đã được host xác nhận với capability chưa quan sát được. Khi host không expose metadata, AUDIT vẫn nghiên cứu và tạo proposal có nhãn `UNVERIFIED`, nhưng không được khẳng định ứng viên dispatch được; mọi thay đổi có điều kiện phải có preflight/fail-closed toàn profile cho parent và mọi worker trước dispatch đầu tiên; chỉ gate parent hoặc nhận lỗi dispatch sau khi pipeline chạy không đủ, nếu không thì row bị `BLOCKED`. Model chỉ mới được công bố không được trình bày như capability đã được host xác nhận.

## Cú pháp và phạm vi

Cú pháp audit mặc định:

```text
$ch-updating-skill-models <tên-skill-hoặc-đường-dẫn>
```

Ví dụ:

```text
$ch-updating-skill-models ch-writing-prompts-map
```

Skill đích phải có `SKILL.md` và phải mô tả đủ rõ vai trò, task hoặc profile đang dùng model. Nếu tên trùng nhiều nơi, skill dừng và yêu cầu chọn đúng đường dẫn. Không tự kích hoạt từ một cuộc trò chuyện chỉ nhắc đến model.

Skill mới có hai pha: `AUDIT` và `APPLY`. Một lượt audit không được sửa skill đích. Một lượt apply phải tham chiếu đúng proposal đã được người dùng duyệt.

## Pha AUDIT

### 1. Chụp trạng thái skill đích

Đọc `SKILL.md` cùng những reference được liên kết có chứa hợp đồng vai trò, model table, parent gate, fallback hoặc quy tắc dispatch. Ghi lại:

- đường dẫn skill đích;
- các file cấu hình model có liên quan;
- từng profile như `low`, `med`, `medium`, `high` nếu skill đích có dùng;
- từng role/task, trách nhiệm, phụ thuộc và vị trí trong pipeline;
- model, reasoning, parent gate và fallback hiện tại;
- digest của toàn bộ file liên quan để phát hiện skill bị thay đổi sau lúc audit.

Không ép `low/med/high` lên một skill không có khái niệm profile. Với skill có profile, giữ nguyên ý nghĩa chất lượng/phạm vi hiện tại của từng level.

### 2. Ghi nhận capability của Codex host

Lấy danh sách model và reasoning từ metadata/capability của Codex host nếu host expose. Ghi `capability_status: VERIFIED` hoặc `UNVERIFIED`; không dùng việc không đọc được model cha hiện tại để chặn AUDIT. `UNVERIFIED` không chứng minh ứng viên dispatch được. Proposal đổi cấu hình khi capability chưa xác minh phải có preflight/fail-closed toàn profile cho parent và mọi worker trước dispatch đầu tiên; nếu không thể bảo đảm thì row là `BLOCKED`.

### 3. Research bằng `ch-research`

Đọc và áp dụng workflow của `ch-research` để nghiên cứu thông tin mới nhất tại ngày audit. Câu hỏi trung tâm phải là: theo bằng chứng hiện tại, cấu hình nào phù hợp nhất với từng vai trò/profile và capability host đã được xác nhận hay chưa? Nếu capability chưa xác minh, phân biệt rõ ứng viên nghiên cứu với cấu hình đã biết là dispatch được.

Nghiên cứu phải đối chiếu:

- tài liệu chính thức về model, reasoning, tool use và giới hạn;
- dữ liệu đánh giá hoặc benchmark có cấu hình đủ tương đồng với task;
- bằng chứng thực tế về độ tin cậy, độ trễ và chi phí khi có dữ liệu so sánh được;
- bằng chứng phản bác hoặc trường hợp model mới hơn không phù hợp hơn.

Không dùng thứ hạng tổng quát để thay cho phân tích task. Benchmark khác harness, reasoning, tool access hoặc loại task phải được ghi là không so sánh trực tiếp.

`ch-research` là dependency cố định của pha audit. Skill không tự dùng kết luận của một lượt audit để sửa model của chính `ch-research` trong cùng lượt.

### 4. Đánh giá theo vai trò

Với mỗi role/task, đánh giá tối thiểu:

- độ khó suy luận và độ dài chuỗi phụ thuộc;
- nhu cầu đọc nhiều nguồn hoặc giữ nhiều ràng buộc;
- nhu cầu tool use, tính toán, code hoặc review độc lập;
- hậu quả nếu sai;
- yêu cầu tốc độ/chi phí của profile;
- lợi ích thực tế của reasoning cao hơn;
- khả năng role chạy song song hay nằm trên đường găng;
- yêu cầu model parent phải đủ năng lực điều phối và tích hợp kết quả worker.

Reasoning được chọn theo task, không mặc định mọi role ở level cao đều dùng mức reasoning cao nhất. Parent gate phải tương thích với cấu hình role của profile và không được tự hạ model khi parent hiện tại không đủ.

### 5. Proposal

Trả một proposal có ID duy nhất theo từng lượt audit, ngày research, trạng thái capability và digest skill đích. Proposal gồm:

| Profile | Role/task | Hiện tại → đề xuất | Billing surface hiện tại → đề xuất | Trạng thái | Hiệu năng & độ phù hợp | Chi phí/task | Đánh đổi & lựa chọn khác | Confidence | Bằng chứng | Coupled edits |
|---|---|---|---|---|---|---|---|---|---|---|

`Trạng thái` dùng một trong các giá trị:

- `KEEP`: bằng chứng chưa đủ để thay;
- `CHANGE`: đề xuất đổi model hoặc reasoning;
- `UNASSIGNED`: có thể đề xuất cấu hình mới cho slot đang trống;
- `BLOCKED`: chưa đủ capability hoặc bằng chứng để đưa cấu hình chạy.

Proposal phải ghi rõ:

- `target_mode` là `default` hoặc `profiled`, và chỉ các profile thực sự có trong target;
- capability host là `VERIFIED`/`UNVERIFIED`, không khẳng định dispatch khi chưa xác minh;
- billing surface của target và riêng từng lựa chọn model; giá API chỉ là proxy có nhãn, không phải phí Codex subscription;
- chi phí trên một đầu ra đạt chuẩn hoặc `UNKNOWN`, giả định workload, retries/review, và nguồn;
- thay đổi parent gate tương ứng;
- file/đoạn nào sẽ bị sửa nếu được duyệt;
- khác biệt về chất lượng, tốc độ và chi phí nếu có bằng chứng;
- mức độ tin cậy theo từng thay đổi;
- giới hạn và dữ liệu có thể làm kết luận thay đổi;
- câu lệnh duyệt chứa proposal ID.

Không sửa file trong pha này.

## Cổng phê duyệt

Chỉ chuyển sang APPLY khi người dùng duyệt proposal ID cụ thể. Người dùng có thể duyệt toàn bộ hoặc chọn một tập hàng `CHANGE`/`UNASSIGNED`.

Trước khi sửa, tính lại digest các file nguồn. Nếu khác digest trong proposal, trả `STALE_PROPOSAL`, nêu file đã đổi và yêu cầu audit lại. Không tự ghép một proposal cũ vào nội dung mới.

## Pha APPLY

Áp dụng đúng các hàng đã duyệt và cập nhật mọi vị trí liên quan:

- model/reasoning table;
- parent model gate;
- alias/profile và trạng thái khả dụng;
- ví dụ hoặc thông báo block có nhắc model cũ;
- reference mô tả dispatch nếu có;
- test hoặc tài liệu kiểm tra đúng cấu hình đó.

Không thay đổi workflow chuyên môn, trách nhiệm role hoặc phạm vi skill đích nếu proposal không yêu cầu. Không tự cập nhật một skill thứ hai.

Sau khi sửa:

1. chạy validator cấu trúc cho skill đích nếu có;
2. tìm tham chiếu model/reasoning cũ trong toàn bộ thư mục skill;
3. chạy test riêng của skill hoặc installer có liên quan;
4. đọc diff để xác nhận chỉ các hàng đã duyệt được áp dụng;
5. báo file đã sửa, kiểm tra đã chạy và giới hạn còn lại.

Nếu validation thất bại, sửa lỗi do thay đổi vừa áp dụng. Nếu lỗi nằm ngoài phạm vi hoặc cần đổi thiết kế chuyên môn, dừng và báo rõ thay vì mở rộng proposal.

## Cấu trúc file

```text
skills/ch-updating-skill-models/
├── SKILL.md
├── agents/
│   └── openai.yaml
└── references/
    ├── evaluation.md
    └── proposal-contract.md
```

- `SKILL.md`: routing, hai pha, capability gate, approval gate và quy tắc dừng.
- `evaluation.md`: tiêu chí phân tích role/task và kỷ luật bằng chứng.
- `proposal-contract.md`: schema proposal, digest, trạng thái, cú pháp duyệt và stale check.
- `agents/openai.yaml`: metadata hiển thị và `allow_implicit_invocation: false`.

Không thêm script parser vì cấu trúc Markdown của các skill không đồng nhất; đọc ngữ nghĩa đáng tin hơn một parser bảng tổng quát. Digest dùng công cụ checksum sẵn có trong môi trường.

## Kiểm thử

Kiểm tra tối thiểu bằng các tình huống:

1. Audit `ch-writing-prompts-map` tạo proposal nhưng không sửa file.
2. Host không expose capability thì ghi `UNVERIFIED` và tiếp tục AUDIT; không claim dispatch. Nếu không có target-wide preflight/fail-closed cho parent và worker models trước dispatch đầu tiên, candidate row phải `BLOCKED`.
3. Duyệt proposal đúng digest thì chỉ sửa các hàng được chọn và các gate phụ thuộc.
4. Skill đích đổi sau audit thì trả `STALE_PROPOSAL`.
5. Tên skill mơ hồ hoặc thiếu model contract thì dừng với hướng dẫn cụ thể.
6. Skill không tự audit và sửa `ch-research` trong cùng lượt.
7. Không dùng giá API để kết luận phí/tiết kiệm Codex subscription; giá và chi phí task thiếu dữ liệu được ghi `UNKNOWN` hoặc `ESTIMATE`.
8. Target không có profile được đánh giá ở mode `default`; target có một hay hai profile chỉ đánh giá các profile hiện có.

Validator của `skill-creator` được chạy cho skill mới. Installer regression phải xác nhận skill được cài cho Codex và không tự kích hoạt.

## Ngoài phạm vi

- Tự động chạy audit theo lịch.
- Thay model dựa riêng vào tên phiên bản mới hơn.
- Benchmark model trực tiếp bằng workload tốn phí trong lượt tạo skill.
- Tự sửa workflow chuyên môn hoặc số lượng subagent của skill đích.
- Tự sửa model nội bộ của `ch-research` trong chính lượt research đó.

## Plan thực thi

[Plan triển khai](../plans/2026-09-25-skill-model-updater.md)
