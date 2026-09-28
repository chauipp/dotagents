# Danh mục skill thống nhất — Summary

Spec: [2026-09-23-single-skills-catalog-design.md](../specs/2026-09-23-single-skills-catalog-design.md)

Plan: [2026-09-23-single-skills-catalog.md](../plans/2026-09-23-single-skills-catalog.md)

## Đã làm gì

- Gom 30 skill vào nguồn `skills/`; hai profile viết prompt map giờ được cài tự động cho Codex ở cả global và project.
- Chỉnh installer lọc `agents: codex` nhất quán ở bước collision, copy và manifest; bản copy cũ chỉ được nhận khi trùng chính xác nguồn kit.
- Gom Graphify vào một skill: hướng dẫn Claude/Codex và extraction specs riêng nằm cùng cây, reference giống nhau chỉ lưu một bản.
- Sửa `--rules-only` để ở cả global và project đều chỉ cập nhật rules, không chép skills hay sửa config.
- Ghi recipe kiểm tra khác biệt giữa nhánh global và project để tránh lỗi cùng loại.
- Cập nhật README, hướng dẫn profile, rules và tham chiếu trong script kiểm tra theo cấu trúc mới.

## File chính

- `install.sh` — quét danh mục canonical, lọc theo agent, bảo toàn collision tùy chỉnh và thực thi đúng `--rules-only` ở cả hai phạm vi.
- `skills/` — chứa toàn bộ nguồn skill; Graphify đặt các workflow riêng theo agent bên trong cùng thư mục.
- `README.md`, `local/README.md`, `claude/CLAUDE.md`, `codex/AGENTS.md` — mô tả cấu trúc và cách cài mới.
- `tests/install.sh` — cập nhật các tham chiếu nguồn cũ và kỳ vọng profile map tự cài cho Codex.
- `docs/recipes/checking-installer-modes.md` — ghi lại cách rà các cờ theo từng nhánh cài đặt.

## Khác với plan

Bổ sung xử lý bản skill cũ chép thủ công nếu nội dung trùng chính xác nguồn; bản đã chỉnh khác vẫn được báo collision. Sửa lỗi global `--rules-only` phát hiện trong lúc rà các kiểu cài và ghi lại bài học này thành recipe.

## Còn dở / cần lưu ý

`bash tests/install.sh`, kiểm tra cú pháp shell và `git diff --check` đều đạt. Các chỉnh sửa local có sẵn trên `main` được bảo toàn khi tích hợp.
