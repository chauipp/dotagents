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
proposal_id: model-update-<target-name>-<YYYYMMDD>-<12-ký-tự-đầu-source_digest>
target_path: <canonical path>
research_date: YYYY-MM-DD
source_digest: <sha256>
source_ledger:
  <relative path>: <sha256>
host_capability_evidence: <metadata/tool và thời điểm xác minh>
```

Proposal ID định danh snapshot và ngày research. Không tái sử dụng ID sau khi audit lại.

## Rows

| row_id | profile | role/task | current model/effort | proposed model/effort | status | confidence | evidence | coupled edits |
|---|---|---|---|---|---|---|---|---|

`row_id` ổn định trong proposal, dạng `<profile-or-default>:<role-id>`. Status:

- `KEEP`: giữ cấu hình; không được chọn để APPLY.
- `CHANGE`: đổi model và/hoặc reasoning.
- `UNASSIGNED`: slot trống có đề xuất mới.
- `BLOCKED`: chưa đủ capability/evidence; không được APPLY.

`evidence` trỏ claim/source gần nhất và nêu giới hạn. `coupled edits` liệt kê parent gate, profile status, thông báo block, example, reference hoặc test phải đổi cùng row.

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
