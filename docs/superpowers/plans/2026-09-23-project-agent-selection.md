# Chọn agent khi cài vào một project — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Cho phép cài rules và skills cho riêng Codex hoặc Claude Code trong một project.

**Architecture:** Tái sử dụng hai cờ `WANT_CLAUDE` và `WANT_CODEX` hiện có. Chỉ riêng nhánh `MODE=project`, khi người dùng không chọn agent thì bật cả hai để giữ tương thích; khi đã chọn thì lọc preflight, rules, skills và thông báo theo các cờ đó. Cập nhật README để nêu cú pháp chọn từng agent và hành vi mặc định.

**Tech Stack:** Bash installer, Markdown documentation.

## Global Constraints

- Không đổi hành vi cài global.
- Không thao tác `~/.agents/skills/`.
- Không truyền cờ agent trong chế độ project thì tiếp tục cài cả Claude và Codex.

---

- [x] Task 1: Thêm lựa chọn agent cho chế độ project

**Files:**
- Modify: `install.sh`
- Modify: `README.md`

**Interfaces:**
- Dùng các biến parse sẵn `WANT_CLAUDE` và `WANT_CODEX`.
- `--project [DIR] --claude` chọn rules `CLAUDE.md` và skill đích `.claude/skills/`.
- `--project [DIR] --codex` chọn rules `AGENTS.md` và skill đích `.codex/skills/`.
- Không có selector hoặc có cả hai selector (`--all`) chọn cả hai như trước.

- [x] Step 1: Trong nhánh project, nếu cả hai biến chọn agent vẫn bằng 0 thì đặt cả hai thành 1; không thay logic tự phát hiện agent của nhánh global.
- [x] Step 2: Tạo danh sách target skills project từ các biến được chọn; chỉ gọi preflight trên danh sách đó khi chưa bật `--rules-only`.
- [x] Step 3: Gọi `merge_rules` và `copy_skills` có điều kiện theo agent đã chọn; chỉ chạy ignore manifest trên các đích đã được cài.
- [x] Step 4: Chỉ hiển thị cảnh báo plugin/MCP dành cho Claude khi Claude được chọn.
- [x] Step 5: Cập nhật help đầu `install.sh` và phần README về cài project để mô tả `--claude`, `--codex`, `--all`, selector kết hợp với `--check`/`--rules-only`, và mặc định cài cả hai.
- [x] Step 6: Đọc lại diff của `install.sh` và README; xác nhận nhánh global không đổi và các đích chỉ được chọn mới bị nhắc đến trong luồng project.

## Kết quả

../summaries/2026-09-23-project-agent-selection-summary.md
