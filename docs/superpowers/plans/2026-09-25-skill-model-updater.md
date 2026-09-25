# Codex Skill Model Updater Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use subagent-driven-development (recommended) or executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tạo skill explicit-only `$ch-updating-skill-models` để audit cấu hình model/reasoning của skill Codex bằng `ch-research`, đưa proposal có digest, và chỉ sửa skill đích sau khi người dùng duyệt proposal cụ thể.

**Architecture:** `SKILL.md` điều phối hai pha AUDIT/APPLY và giữ các hard gate. Hai reference tách tiêu chí đánh giá role khỏi hợp đồng proposal/digest để entrypoint ngắn và chỉ đọc chi tiết khi cần. Skill không dùng parser Markdown tổng quát; agent đọc ngữ nghĩa của skill đích, còn checksum và diff dùng công cụ sẵn có.

**Tech Stack:** Codex skills Markdown/YAML, `skill-creator` validator, shell installer regression.

## Global Constraints

- Chỉ xét model và reasoning được Codex host hiện tại xác nhận là khả dụng.
- `ch-research` là dependency bắt buộc của pha AUDIT.
- AUDIT không sửa file; APPLY cần proposal ID được duyệt và digest còn khớp.
- `policy.allow_implicit_invocation` phải là `false`.
- Skill chỉ hỗ trợ Codex qua frontmatter `agents: codex`.
- Không tự sửa model của `ch-research` trong cùng lượt dùng nó làm nguồn nghiên cứu.
- Không thêm attribution công cụ/model vào tài liệu hoặc commit metadata.

---

- [x] Task 1: Tạo contract và tài liệu tham chiếu cho skill

**Files:**

- Create: `skills/ch-updating-skill-models/SKILL.md`
- Create: `skills/ch-updating-skill-models/agents/openai.yaml`
- Create: `skills/ch-updating-skill-models/references/evaluation.md`
- Create: `skills/ch-updating-skill-models/references/proposal-contract.md`

**Interfaces:**

- Consumes: tên hoặc đường dẫn skill đích; metadata model/reasoning của Codex host; workflow `$ch-research`; phê duyệt có proposal ID.
- Produces: proposal AUDIT không mutation; hoặc thay đổi APPLY giới hạn đúng hàng được duyệt.

- [x] **Step 0: Chạy RED pressure scenarios khi skill chưa tồn tại**

Dùng ba Codex evaluator fresh-context trong thư mục tạm, không nạp skill mới:

1. áp lực thời gian yêu cầu sửa model ngay khi chưa có proposal;
2. thiếu metadata capability của host nhưng có tin model mới;
3. proposal đã duyệt nhưng file đích đổi sau audit.

Ghi nguyên văn hành vi và lý do khiến evaluator sửa sớm, đoán capability hoặc bỏ qua stale state. Đây là baseline bắt buộc trước khi tạo `skills/ch-updating-skill-models/`.

- [x] **Step 1: Khởi tạo skeleton chuẩn Codex**

Run:

```bash
python3 /home/chaupt/.codex/skills/.system/skill-creator/scripts/init_skill.py ch-updating-skill-models --path skills --resources references
```

Expected: tạo `SKILL.md`, `agents/openai.yaml`, `references/`; không tạo assets hoặc scripts.

- [x] **Step 2: Viết entrypoint hai pha**

`SKILL.md` phải có frontmatter:

```yaml
---
name: ch-updating-skill-models
description: Use when the user explicitly asks to reassess model or reasoning assignments in a Codex skill, or to apply a previously approved model update proposal.
agents: codex
---
```

Body phải định nghĩa chính xác:

```text
AUDIT (mặc định): resolve canonical target → snapshot files/digest → verify host capability
→ load ch-research → evaluate roles/profiles → emit proposal ID → stop without edits.

APPLY: require proposal ID + approved rows → recompute digest → STALE_PROPOSAL on mismatch
→ edit coupled model/gate references → validate/test/diff → report.
```

Các hard gate bắt buộc:

- `BLOCKED_TARGET` khi target thiếu, mơ hồ hoặc không có model contract;
- `BLOCKED_HOST_CAPABILITY` khi không xác minh được model/reasoning dispatch được;
- `BLOCKED_RESEARCH_RUNTIME` khi không thể chạy đúng `ch-research`;
- `STALE_PROPOSAL` khi digest thay đổi;
- cấm sửa file ở AUDIT;
- cấm fallback sang model ngoài capability host;
- cấm tự cập nhật `ch-research` trong cùng audit;
- ưu tiên source skill trong repo; không âm thầm sửa bản cài được sinh từ source khác.

Entry point phải link tới `references/evaluation.md` khi đánh giá role và `references/proposal-contract.md` khi tạo hoặc apply proposal.

- [x] **Step 3: Viết tiêu chí đánh giá**

`references/evaluation.md` phải bao gồm:

- thứ tự bằng chứng: host capability → tài liệu OpenAI chính thức → benchmark/đánh giá độc lập có cấu hình so sánh được → inference ghi nhãn;
- ma trận đánh giá role: reasoning complexity, context/ràng buộc, tool use, hậu quả lỗi, đường găng/song song, latency/cost, nhiệm vụ parent/reviewer;
- cách chọn effort theo task thay vì theo nhãn level;
- quy tắc `low/med/high`: giữ semantics của skill đích, không tự áp profile vào skill không có profile;
- parent phải đủ khả năng điều phối, tổng hợp và xử lý mâu thuẫn của worker;
- model mới hơn không tự động được coi là tốt hơn;
- các benchmark khác harness, effort hoặc tool access không được coi là so sánh trực tiếp.

- [x] **Step 4: Viết hợp đồng proposal và stale check**

`references/proposal-contract.md` phải định nghĩa:

```text
proposal_id: model-update-<target>-<YYYYMMDD>-<digest-prefix>
target_path: canonical path
research_date: YYYY-MM-DD
source_digest: sha256 của danh sách file đã sort + nội dung từng file
host_capability_evidence: nguồn metadata host
approved_scope: all hoặc danh sách row_id
```

Bảng proposal dùng cột:

```text
row_id | profile | role/task | current model/effort | proposed model/effort |
status | confidence | evidence | coupled edits
```

Status chỉ gồm `KEEP`, `CHANGE`, `UNASSIGNED`, `BLOCKED`. Cú pháp apply chuẩn:

```text
$ch-updating-skill-models apply <proposal_id> all
$ch-updating-skill-models apply <proposal_id> <row_id>[,<row_id>...]
```

Digest phải được tính lại trước mutation. Proposal không chứa đủ snapshot/digest để kiểm lại thì không được apply.

- [x] **Step 5: Viết metadata explicit-only**

`agents/openai.yaml`:

```yaml
interface:
  display_name: "CH Updating Skill Models"
  short_description: "Audit and update Codex skill model assignments"
  default_prompt: "Use $ch-updating-skill-models with a target skill to research current Codex models and propose model or reasoning updates."

policy:
  allow_implicit_invocation: false
```

- [x] **Step 6: Rà contract trước validation**

Run:

```bash
rg -n 'BLOCKED_TARGET|BLOCKED_HOST_CAPABILITY|BLOCKED_RESEARCH_RUNTIME|STALE_PROPOSAL|allow_implicit_invocation|ch-research' skills/ch-updating-skill-models
```

Expected: mỗi gate/dependency xuất hiện đúng nơi; policy là `false`.

- [x] Task 2: Validate cấu trúc và hành vi cài đặt

**Files:**

- Verify: `skills/ch-updating-skill-models/**`
- Verify: `tests/install.sh`

**Interfaces:**

- Consumes: skill mới từ Task 1 và installer tự quét `skills/*/`.
- Produces: bằng chứng skill hợp lệ, được cài cho Codex, không được cài cho Claude, và không tự kích hoạt.

- [x] **Step 1: Chạy validator của skill-creator**

Run:

```bash
python3 /home/chaupt/.codex/skills/.system/skill-creator/scripts/quick_validate.py skills/ch-updating-skill-models
```

Expected: validator trực tiếp chỉ báo key mở rộng `agents` của repo; bản sao tạm bỏ riêng `agents: codex` phải trả `Skill is valid!`. Installer regression chịu trách nhiệm xác nhận extension Codex-only.

- [x] **Step 2: Chạy installer regression**

Run:

```bash
bash tests/install.sh
```

Expected: `PASS: installer preserves custom skills, detects collisions, and supports dry-run checks`. Hàm `assert_skill_set` động phải đưa skill mới vào manifest Codex và loại khỏi manifest Claude do `agents: codex`.

- [x] **Step 3: Kiểm tra metadata và drift tĩnh**

Run:

```bash
grep -qx 'agents: codex' skills/ch-updating-skill-models/SKILL.md
grep -qx '  allow_implicit_invocation: false' skills/ch-updating-skill-models/agents/openai.yaml
git diff --check
```

Expected: cả ba lệnh pass.

- [x] **Step 4: Review tình huống hành vi bằng contract**

Đối chiếu toàn bộ skill với sáu case trong spec:

1. AUDIT không có mutation.
2. Thiếu host capability bị block.
3. APPLY chỉ nhận proposal ID và rows đã duyệt.
4. Digest đổi gây `STALE_PROPOSAL` trước mutation.
5. Target mơ hồ/thiếu contract bị block.
6. Không tự audit rồi sửa `ch-research` trong cùng lượt.

Expected: mỗi case có một đường xử lý duy nhất, không có fallback trái gate.

- [x] **Step 5: Chạy GREEN pressure scenarios với skill**

Chạy lại đúng ba evaluator fresh-context của RED, lần này cung cấp toàn bộ skill mới và references. Expected:

1. evaluator chỉ tạo proposal và không sửa target trước approval;
2. evaluator trả `BLOCKED_HOST_CAPABILITY` khi host không cung cấp capability;
3. evaluator trả `STALE_PROPOSAL` khi digest đổi.

Đọc thủ công từng output. Nếu evaluator tìm được loophole, sửa tối thiểu câu chữ liên quan rồi chạy lại case đó cho tới khi hành vi hội tụ.

- [ ] Task 3: Hoàn tất tài liệu, review và bàn giao

**Files:**

- Modify: `docs/superpowers/specs/2026-09-25-skill-model-updater-design.md`
- Modify: `docs/superpowers/plans/2026-09-25-skill-model-updater.md`
- Create: `docs/superpowers/summaries/2026-09-25-skill-model-updater-summary.md`

**Interfaces:**

- Consumes: diff và kết quả validation từ Task 1–2.
- Produces: ba tài liệu liên kết chéo và summary phản ánh đúng kết quả thực tế.

- [x] **Step 1: Review toàn bộ diff**

Run:

```bash
git diff --check
git diff --stat
git diff
```

Expected: không lỗi whitespace; diff chỉ chứa skill và tài liệu của task.

- [ ] **Step 2: Tick task ngay khi từng gate pass**

Đổi heading Task 1, Task 2 và Task 3 từ `- [ ]` sang `- [x]` ngay sau khi task tương ứng hoàn tất và được review.

- [x] **Step 3: Viết summary từ diff thật**

Summary phải mở đầu bằng link tới spec và plan, rồi có đúng bốn mục:

```text
Đã làm gì
File chính
Khác với plan
Còn dở / cần lưu ý
```

Cuối plan phải link tới summary; spec phải link tới plan.

- [x] **Step 4: Chạy lại kiểm tra cuối**

Run:

```bash
python3 /home/chaupt/.codex/skills/.system/skill-creator/scripts/quick_validate.py skills/ch-updating-skill-models
bash tests/install.sh
git diff --check
```

Expected: bản chuẩn hóa pass validator, installer pass, diff check pass; bản thật giữ `agents: codex` và chỉ có khác biệt schema đã ghi nhận.

- [ ] **Step 5: Commit sau khi kiểm identity và staged diff**

Trước commit chạy và đọc đầy đủ:

```bash
git config user.name
git config user.email
git diff --cached --check
git diff --cached
```

Nếu identity không rỗng và staged diff đúng phạm vi, commit với message:

```text
feat: add Codex skill model updater
```

## Kết quả

[Summary triển khai](../summaries/2026-09-25-skill-model-updater-summary.md)
