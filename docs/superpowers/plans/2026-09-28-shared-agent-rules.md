# Đồng bộ rules Codex và Claude Code Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

[Thiết kế](../specs/2026-09-28-shared-agent-rules-design.md)

**Goal:** Tách rules chung thành `rules/common.md` và để `install.sh` dựng block common + overlay đúng cho Codex và Claude Code, bảo toàn rules cũ ngoài marker.

**Architecture:** Source common nằm trong `rules/common.md`; `codex/AGENTS.md` và `claude/CLAUDE.md` chỉ là overlay nền tảng. Installer dựng nội dung tạm, truyền một source hoàn chỉnh vào `merge_rules`, rồi dùng marker hiện có để thay block do dotagents quản lý. Preflight báo migration và conflict nhưng không tự xóa nội dung cũ.

**Tech Stack:** Bash, Markdown, Git worktree-independent installer regression trong `tests/install.sh`.

## Global Constraints

- Không đổi đường dẫn runtime: project dùng `<TARGET>/AGENTS.md` và `<TARGET>/CLAUDE.md`; global dùng `$CODEX_HOME/AGENTS.md` và `$CLAUDE_CONFIG_DIR/CLAUDE.md`.
- Không tự xóa hoặc tự hợp nhất rules cũ nằm ngoài marker dotagents.
- Common xuất hiện trước overlay trong block được quản lý.
- `--check` không được tạo, sửa hoặc xóa file đích, rules, skills hoặc config của project/global target; file tạm nội bộ phải được dọn.
- Không sửa skill, metadata skill hoặc thay đổi dirty ngoài phạm vi task.
- Trước commit phải kiểm tra Git identity, `git diff --cached --check` và đọc toàn bộ staged diff.

---

- [x] Task 1: Phân loại và tách source rules

**Files:**

- Create: `rules/common.md`
- Modify: `codex/AGENTS.md`
- Modify: `claude/CLAUDE.md`
- Test: `tests/install.sh`

**Interfaces:**

- Consumes: hai source rules hiện tại và spec `docs/superpowers/specs/2026-09-28-shared-agent-rules-design.md`.
- Produces: một common source không chứa nội dung platform-only và hai overlay có tiêu đề rõ ràng.

- [x] **Step 1: Lập bảng phân loại section hiện tại**

Đối chiếu từng heading của `codex/AGENTS.md` và `claude/CLAUDE.md`; ghi common khi semantics và hành động giống nhau, ghi overlay khi khác tool, path, lifecycle hoặc enforcement. Không chuyển section chỉ vì câu chữ tương tự.

- [x] **Step 2: Tạo `rules/common.md`**

Đưa các section common đã xác định vào file mới, giữ nguyên nội dung kỹ thuật và tiêu đề ổn định để installer có thể cảnh báo heading trùng. Không đưa marker `dotagents:begin` hoặc `dotagents:end` vào source.

- [x] **Step 3: Rút common khỏi hai overlay**

Giữ trong `codex/AGENTS.md` và `claude/CLAUDE.md` các rule nền tảng riêng; thêm heading overlay rõ ràng; không để cùng một common section xuất hiện lại trong overlay.

- [x] **Step 4: Rà semantic diff**

Dùng `diff` và đọc thủ công từng source để xác nhận mọi rule cũ hoặc nằm trong common hoặc nằm đúng một overlay. Sửa các câu bị mất chủ thể, sai tên tool hoặc thay đổi mức bảo toàn hành vi.

- [x] **Step 5: Chạy kiểm tra Markdown cơ bản**

Run: `git diff --check -- rules/common.md codex/AGENTS.md claude/CLAUDE.md`

Expected: không có whitespace error, marker quản lý hoặc section common trùng trong overlay.

- [x] Task 2: Dựng common + overlay trong installer

**Files:**

- Modify: `install.sh:61-93` (`merge_rules`) và phần gọi source ở các mode global/project.
- Test: `tests/install.sh`

**Interfaces:**

- Consumes: `rules/common.md`, một overlay nền tảng, file đích hiện tại và marker hiện tại.
- Produces: `build_rules_source <agent> <output-file>` hoặc helper tương đương tạo source tạm đã ghép; `merge_rules` nhận source hoàn chỉnh như trước.

- [x] **Step 1: Thêm resolver source an toàn**

Tạo helper nhận `claude` hoặc `codex`, resolve `rules/common.md` và overlay tương ứng dưới `KIT_DIR`, kiểm tra file tồn tại/đọc được/không rỗng, rồi ghi source ghép vào file tạm. Helper phải trả lỗi trước khi gọi `merge_rules` nếu thiếu source.

- [x] **Step 2: Kiểm tra marker trong source**

Đếm marker begin/end trong common và overlay. Nếu source chứa marker hoặc số marker không cân bằng, dừng trước khi ghi file đích với thông báo nêu source lỗi.

- [x] **Step 3: Giữ nguyên hành vi merge an toàn**

Truyền source ghép vào `merge_rules`; giữ nguyên nhánh thay block có marker và nhánh bảo toàn file cũ chưa có marker. Không dùng `cat >>` trực tiếp ở caller và không sửa rules ngoài marker.

- [x] **Step 4: Mở rộng migration warning**

Tính heading trùng giữa file đích cũ và source ghép như hiện tại; output phải nêu file đích, số heading trùng và hướng dẫn review. `--check` phải dùng cùng resolver nhưng không gọi thao tác ghi.

- [x] **Step 5: Chạy kiểm tra shell**

Run: `bash -n install.sh`

Expected: exit 0.

- [x] Task 3: Bổ sung regression cho các trạng thái cài đặt

**Files:**

- Modify: `tests/install.sh`

**Interfaces:**

- Consumes: installer và source common/overlay từ Task 1–2.
- Produces: regression assertions cho output, preservation và safety gates.

- [x] **Step 1: Kiểm tra common/overlay trong file mới**

Sau project install, assert common marker/heading xuất hiện ở cả `CLAUDE.md` và `AGENTS.md`, assert heading Codex-only chỉ ở AGENTS và Claude-only chỉ ở CLAUDE.

- [x] **Step 2: Kiểm tra file cũ không marker**

Tạo project tạm có `CLAUDE.md` và `AGENTS.md` chứa rule riêng, chạy installer, assert nội dung cũ vẫn còn, block mới xuất hiện một lần ở cuối và output có migration warning khi có heading trùng.

- [x] **Step 3: Kiểm tra thay block và idempotency**

Chạy installer hai lần, lưu hash hai file runtime sau mỗi lần, assert hash lần hai không đổi và common không nhân đôi. Sửa một dòng ngoài marker giữa hai lần rồi assert dòng đó vẫn còn sau lần cài tiếp.

- [x] **Step 4: Kiểm tra source lỗi và `--check`**

Trong thư mục kit tạm, lần lượt làm common rỗng, overlay thiếu và source có marker; assert installer dừng trước khi ghi. Chạy `--check` trên project mới và assert không tạo rules, skills hoặc config.

- [x] **Step 5: Chạy toàn bộ regression**

Run: `bash tests/install.sh`

Expected: `PASS: installer preserves custom skills, detects collisions, and supports dry-run checks`.

- [x] Task 4: Cập nhật tài liệu và liên kết spec/plan

**Files:**

- Modify: `README.md`
- Modify: `docs/superpowers/specs/2026-09-28-shared-agent-rules-design.md`
- Modify: `docs/superpowers/plans/2026-09-28-shared-agent-rules.md`
- Create: `docs/superpowers/summaries/2026-09-28-shared-agent-rules-summary.md`

**Interfaces:**

- Consumes: behavior đã pass từ Task 1–3.
- Produces: tài liệu source/runtime path, migration behavior và summary kết quả.

- [x] **Step 1: Cập nhật README**

Mô tả `rules/common.md` là source chung, hai overlay là source platform, installer ghép vào file runtime nào, và file cũ chưa marker được bảo toàn/cảnh báo.

- [x] **Step 2: Nối ba tài liệu**

Ở cuối spec thêm link tới plan; ở cuối plan giữ mục `## Kết quả` trỏ tới summary; đầu summary trỏ lại spec và plan.

- [x] **Step 3: Tick plan theo kết quả thực tế**

Chỉ đánh dấu task `[x]` sau khi test tương ứng pass và đọc diff. Không đánh dấu trước khi chạy regression.

- [x] **Step 4: Viết summary riêng**

Ghi bốn mục `Đã làm gì`, `File chính`, `Khác với plan`, `Còn dở / cần lưu ý` dựa trên diff và commit, không chép lại kế hoạch.

- [x] **Step 5: Chạy review cuối**

Run: `git diff --check`

Đọc các source, installer, test, README, spec, plan và summary; xác nhận commit không chứa file ngoài phạm vi.

## Kết quả

[Summary triển khai](../summaries/2026-09-28-shared-agent-rules-summary.md)
