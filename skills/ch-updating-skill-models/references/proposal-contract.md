# Proposal contract

Dùng cùng contract này khi tạo proposal trong AUDIT và kiểm proposal trong APPLY.

## Snapshot và digest

`target_path` là đường dẫn canonical của source skill. `source_files` gồm `SKILL.md` và đúng các reference/test chứa model contract hoặc coupled edits.

Tính digest theo cách tái lập:

1. chuẩn hóa từng file thành đường dẫn tương đối từ `target_path`;
2. sort đường dẫn theo byte order;
3. SHA-256 nội dung byte của từng file;
4. tạo ledger từng dòng `relative_path<TAB>file_sha256`;
5. SHA-256 toàn bộ ledger UTF-8; kết quả là `source_digest`.

Ghi cả ledger vào proposal để APPLY chỉ ra file nào đổi. File được thêm, xóa hoặc đổi nội dung trong file set đều làm proposal stale. Nếu coupled file mới xuất hiện sau AUDIT, APPLY phải dừng và yêu cầu audit lại.

## Proposal identity

```text
proposal_id: model-update-<target-name>-<YYYYMMDDTHHMMSSZ>-<12-ký-tự-đầu-source_digest>-<4-ký-tự-ngẫu-nhiên>
target_path: <canonical path>
research_date: YYYY-MM-DD
source_digest: <sha256>
source_ledger:
  <relative path>: <sha256>
target_mode: default | profiled
profiles_evaluated: [default] | [các profile thực sự có trong target, ví dụ low, med, high]
capability_status: VERIFIED | UNVERIFIED
host_capability_evidence: <metadata/tool và thời điểm xác minh, hoặc lý do UNVERIFIED>
target_billing_surface: <Codex subscription/credits | Codex token billing | API | UNKNOWN>
pricing_checked_at: YYYY-MM-DD
pricing_sources: <link chính thức hoặc UNKNOWN>
workload_basis: <usage trace/rubric thực tế hoặc giả định kịch bản>
```

Proposal ID định danh riêng từng lượt AUDIT, kể cả khi cùng ngày và cùng source digest. Tạo hậu tố ngẫu nhiên mới cho mỗi lượt; không tái sử dụng ID sau khi audit lại.

## Rows

| row_id | profile | role/task | current → proposed model/effort | billing surface (current → proposed) | status | task fit & performance | cost/task | trade-off & alternative | confidence | evidence | coupled edits |
|---|---|---|---|---|---|---|---|---|---|---|---|

`row_id` ổn định trong proposal, dạng `<profile-or-default>:<role-id>`. Với target `default`, dùng profile `default`; với target `profiled`, dùng đúng profile target có và không tự thêm profile thiếu. Status:

- `KEEP`: giữ cấu hình; không được chọn để APPLY.
- `CHANGE`: đổi model và/hoặc reasoning.
- `UNASSIGNED`: slot trống có đề xuất mới.
- `BLOCKED`: chưa đủ capability/evidence; không được APPLY.

`capability_status: UNVERIFIED` không chứng minh dispatch được. Row đổi model/effort chỉ có thể là `CHANGE` nếu target có preflight/fail-closed toàn profile cho parent và mọi worker trước dispatch đầu tiên; chỉ kiểm tra parent không đủ. Nếu thiếu gate này, dùng `BLOCKED` và ghi rõ capability nào cần xác minh. `target_billing_surface` mô tả cách workload của target được tính phí; không chứng minh giá của một model cụ thể. Mỗi row phải ghi billing surface riêng của model hiện tại và ứng viên. Nếu dùng giá API làm proxy cho Codex subscription/credits, gắn nhãn proxy và `NOT_COMPARABLE`; không báo proxy thành khoản tiết kiệm thực trả. `evidence` trỏ claim/source gần nhất và nêu giới hạn. `coupled edits` liệt kê parent gate, profile status, thông báo block, example, reference hoặc test phải đổi cùng row.

Mỗi row phải dẫn tới một **evidence card** với: billing surface, nguồn giá và đơn vị/tier cho cả hai lựa chọn; token/attempt, retry, cache, tool fee và pass rate (đo được, ước tính hoặc `UNKNOWN`); cost-per-attempt và cost-per-pass/credits-per-pass nếu tính được; metric chất lượng và độ trễ trên cùng task/harness; nguồn ủng hộ lẫn phản biện; verdict phù hợp profile; giới hạn còn thiếu. Ghi riêng `NOT_COMPARABLE` khi nguồn khác billing surface hoặc benchmark khác cấu hình. Row `KEEP` cũng cần lý do giữ; row `UNASSIGNED` cần ngưỡng pass dự kiến để mở profile.

Trước khi kết thúc proposal, thêm bảng so **toàn workflow theo profile**: tổng chi phí/tác vụ đạt chuẩn hoặc `UNKNOWN`, thời gian theo đường găng, điểm/rubric chất lượng, lỗi nghiêm trọng, delta với cấu hình hiện tại và với profile liền kề nếu có. Tách số đo khỏi kịch bản giả định. Nếu chưa có usage trace/eval, cung cấp kế hoạch A/B ngắn với mẫu task, metric, ngưỡng quyết định và dữ liệu cần ghi; không gán số chính xác giả tạo.

## Approval

Proposal kết thúc bằng đúng một trong hai lệnh user có thể gửi:

```text
$ch-updating-skill-models apply <proposal_id> all
$ch-updating-skill-models apply <proposal_id> <row_id>[,<row_id>...]
```

`all` chỉ chọn mọi row `CHANGE`/`UNASSIGNED`; không chọn `KEEP`/`BLOCKED`. Danh sách row phải khớp chính xác row trong proposal. Lời đồng ý không có proposal ID hoặc scope không mở APPLY.

## APPLY preflight

Trước mutation:

1. đọc lại proposal và xác nhận các trường bắt buộc;
2. resolve lại `target_path` và file set;
3. tính ledger/digest hiện tại bằng cùng thuật toán;
4. so từng file và digest tổng;
5. xác nhận row được duyệt vẫn có status áp dụng được.

Nếu khác:

```text
STALE_PROPOSAL
proposal_id: <id>
target: <path>
changed_files: <list>
action: chạy lại $ch-updating-skill-models <target>
```

Không áp phần “không xung đột” của proposal stale. Audit lại toàn target để parent gate và worker table cùng revision.

## Apply report

```text
proposal_id: <id>
applied_rows: <row ids>
changed_files: <paths>
validation: <commands + result>
remaining: <KEEP/BLOCKED/không có>
```

Diff phải chỉ chứa row được duyệt và coupled edits đã liệt kê. Thay đổi chuyên môn ngoài model/reasoning cần proposal khác.
