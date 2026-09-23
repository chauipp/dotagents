# Map Subagent Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Đưa skill `map-subagent-workflow` vào bộ skill shared để installer cung cấp cho các agent như những skill shared khác.

**Architecture:** Giữ nguyên `SKILL.md` nguồn và đặt nó trong `shared/skills/map-subagent-workflow/`. Cập nhật README theo cách thống kê hiện có; installer đã lấy mọi thư mục shared tự động nên không cần sửa script hay thêm metadata riêng.

**Tech Stack:** Markdown, PowerShell, Git.

## Global Constraints

- Giữ nguyên nội dung `C:\Users\royal\.agents\skills\map-subagent-workflow\SKILL.md`.
- Đặt skill mới trong `shared/skills/map-subagent-workflow/` và không thêm metadata giới hạn invocation.
- Cập nhật README lên 27 skill shared và 28 skill tổng cộng cho mỗi agent.
- Không sửa logic installer hoặc các file cài đặt cá nhân ngoài repository.

---

- [ ] Task 1: Add the map subagent workflow as a shared skill

**Files:**
- Create: `shared/skills/map-subagent-workflow/SKILL.md`
- Modify: `README.md`
- Modify: `docs/superpowers/specs/2026-09-23-map-subagent-workflow-design.md`
- Modify: this plan and create `docs/superpowers/summaries/2026-09-23-map-subagent-workflow-summary.md` after completion.

**Interfaces:**
- Consumes: the user's existing map-subagent-workflow `SKILL.md`.
- Produces: a shared skill directory auto-discovered by `install.sh`, and README counts/descriptions matching the source directories.

- [x] **Step 1: Copy the source skill unchanged** to `shared/skills/map-subagent-workflow/SKILL.md`.
- [x] **Step 2: Update README counts and skill list** from 26 to 27 shared skills, 27 to 28 total skills, and 12 to 13 highlighted skills; include the Unreal map workflow in the self-written skills list.
- [x] **Step 3: Verify the copied file matches its source** using SHA-256 comparison, confirm the shared directory count and README figures agree, and inspect the final diff. Do not run the test suite unless requested.
- [x] **Step 4: Write the required four-section summary and keep all completed steps ticked; tick the task heading after its review passes.**

## Kết quả

`../summaries/2026-09-23-map-subagent-workflow-summary.md`
