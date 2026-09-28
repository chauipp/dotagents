# Danh mục skill thống nhất Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task. Thực hiện inline trong worktree hiện tại.

**Goal:** Chuyển toàn bộ nguồn skill của dotagents vào `skills/` và để installer cài từ danh mục này theo agent đã chọn ở chế độ global hoặc project.

**Architecture:** `skills/<name>/` là nguồn canonical. Installer quét danh mục, đọc metadata `agents` trong frontmatter (không có nghĩa là dùng được cho cả hai agent), lọc trước khi preflight/copy; Graphify giữ hướng dẫn riêng Claude/Codex bên trong cùng một thư mục skill và có SKILL.md điều phối. Các đích runtime và cơ chế manifest hiện tại được giữ nguyên.

**Tech Stack:** Bash, Python 3 chỉ nếu cần parse metadata có sẵn trong repository; Markdown.

## Global Constraints

- Không đọc, ghi hoặc xóa `~/.agents/skills/`.
- Giữ nguyên thư mục rules `claude/` và `codex/`.
- Giữ mọi nội dung skill, giấy phép và provenance đã có; không thêm attribution công cụ.
- Chạy `bash tests/install.sh` và kiểm tra cú pháp shell trước khi tích hợp.
- Chỉ cài profile `writing-prompts-map-sol` và `writing-prompts-map-astra` khi chọn Codex.

---

## File structure

- `skills/`: nguồn duy nhất cho 27 skill dùng chung, Graphify, và hai profile map Codex.
- `skills/graphify/`: SKILL.md điều phối cùng bản hướng dẫn Claude và Codex trong `references/`.
- `install.sh`: đọc danh mục mới, lọc `agents`, giữ preflight/manifest/remove semantics.
- `README.md`, `local/README.md`, `claude/CLAUDE.md`, `codex/AGENTS.md`: hướng dẫn dùng đường dẫn nguồn mới.
- `tests/install.sh`: cập nhật nguồn kiểm thử và bao phủ chọn agent, phạm vi cùng `--rules-only`.
- `docs/superpowers/specs/...`, plan này, summary: liên kết chéo theo quy định repo.

- [x] Task 1: Chuyển nguồn skill về danh mục `skills/` và khai báo agent đích

**Files:**
- Move: `shared/skills/*` → `skills/*`
- Move: `local/skills/writing-prompts-map-*` → `skills/writing-prompts-map-*`
- Move: `claude/skills/graphify/*` và `codex/skills/graphify/*` → `skills/graphify/references/{claude,codex}/`
- Create: `skills/graphify/SKILL.md`
- Create: `docs/recipes/checking-installer-modes.md`

- [x] Step 1: Chuyển thư mục skill dùng chung và hai profile map vào `skills/`, giữ nguyên nội dung/tài nguyên.
- [x] Step 2: Chuyển hai hướng dẫn Graphify vào thư mục cùng skill dưới `references/claude/` và `references/codex/`; tạo SKILL.md gốc nói rõ agent cần mở hướng dẫn tương ứng.
- [x] Step 3: Thêm metadata `agents: codex` vào frontmatter hai profile map; skill không có metadata tiếp tục dùng cho Claude và Codex.
- [x] Step 4: Xóa các thư mục nguồn cũ sau khi xác nhận mọi tệp đã được di chuyển.

- [x] Task 2: Cài đặt installer từ danh mục thống nhất

**Files:**
- Modify: `install.sh`, `tests/install.sh`

- [x] Step 1: Thay `kit_skill_names` bằng phép quét `skills/*/` và chọn nguồn duy nhất.
- [x] Step 2: Thêm hàm lọc theo `agents` frontmatter và dùng cùng kết quả lọc cho preflight, copy, manifest và dọn skill cũ.
- [x] Step 3: Giữ nguyên tên skill trong manifest; nhận vào manifest bản cài cũ chỉ khi diff chính xác với nguồn, còn nội dung khác tiếp tục báo collision; giữ các cờ agent/scope/`--check`/`--rules-only` hiện có.
- [x] Step 4: Rà soát mọi thao tác installer để xác nhận không tham chiếu `~/.agents/skills/`.
- [x] Step 5: Tái hiện và sửa lỗi `--rules-only` ở global; chỉ cập nhật rules, không copy skills hoặc chạm config. Kiểm tra hồi quy trong `tests/install.sh`.

- [x] Task 3: Đồng bộ tài liệu và tham chiếu nguồn

**Files:**
- Modify: `README.md`, `local/README.md`, `claude/CLAUDE.md`, `codex/AGENTS.md`, `tests/install.sh`

- [x] Step 1: Sửa sơ đồ repo, số liệu, mô tả Graphify, hướng dẫn cập nhật skill và ví dụ profile map theo `skills/`.
- [x] Step 2: Cập nhật khối rules tự quản lý có trỏ nguồn skill chung sang `~/dotagents/skills/`.
- [x] Step 3: Chuyển tham chiếu test fixture từ `shared/skills`/`local/skills`/thư mục graphify cũ sang danh mục mới, giữ nguyên phạm vi assertion.
- [x] Step 4: Tìm các tham chiếu còn hiệu lực tới nguồn cũ, phân biệt tài liệu lịch sử, và sửa mọi hướng dẫn hiện hành.

- [x] Task 4: Rà soát kết quả và ghi summary

**Files:**
- Modify: `docs/superpowers/specs/2026-09-23-single-skills-catalog-design.md`, plan này
- Create: `docs/superpowers/summaries/2026-09-23-single-skills-catalog-summary.md`

- [x] Step 1: Liên kết spec tới plan và plan tới summary; thêm liên kết ngược trong summary.
- [x] Step 2: Chạy `bash tests/install.sh`, `bash -n install.sh tests/install.sh`, `git diff --check`; rà soát danh sách nguồn/đích và xác nhận installer không dùng `~/.agents/skills/`.
- [x] Step 3: Tick task trong plan ngay sau khi hoàn tất; viết summary bốn mục theo trạng thái thực tế.
- [x] Step 4: Dùng `capturing-what-worked` ghi lại bài học riêng của repo về kiểm tra cờ ở cả global và project.

## Kết quả

Summary: [2026-09-23-single-skills-catalog-summary.md](../summaries/2026-09-23-single-skills-catalog-summary.md).
