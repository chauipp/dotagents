# Gỡ dotagents có backup và ledger

## Phạm vi

Thêm uninstall.sh cho global/project, Claude/Codex/all, rules-only, check và restore.
Gỡ theo marker và manifest; không đoán ownership theo danh mục skill hiện tại.
Giữ rules ngoài marker, skill riêng, .system và Git index.
Trước mutation, kiểm tất cả marker, manifest, path, config và tạo backup.
Backup riêng mỗi lần gỡ gồm dữ liệu trước gỡ và journal; restore không ghi đè dữ liệu đã sửa tiếp.

## Ledger

Installer ghi .dotagents-state.json trong đích cài, version 1, theo agent.
Ghi ownership file rules mới và từng key config thực sự thay đổi: trước/ sau.
Snapshot ở temp; chỉ cập nhật ledger sau cài. Reinstall giữ giá trị gốc nếu key vẫn do installer quản lý.
Global: Claude enabledPlugins.superpowers, includeCoAuthoredBy, MCP playwright; Codex features.multi_agent, MCP playwright.
Project/rules-only không sửa config. Bản cài cũ thiếu ledger giữ config và báo rõ.
Nếu current khác applied, giữ key và ghi trạng thái còn dở. Không restore toàn bộ config cũ đè dữ liệu mới.
TOML sửa có mục tiêu, giữ các section không liên quan; cấu trúc không hỗ trợ thì dừng.

## Uninstall

Rules: một cặp marker hợp lệ; remove block; xóa file rỗng chỉ khi ledger chứng minh installer tạo.
Manifest: tên skill một segment an toàn, cấm .system; symlink không được dẫn ra ngoài đích.
Ignore: remove entry agent được chọn, giữ phần agent khác và ngoài block.
Không xóa backup cũ; không thao tác Git index. Missing target là no-op.
--check không ghi file/target/backup. Lỗi giữa chừng báo journal và cách restore.
Chạy lại no-op nếu đã gỡ; key bị user sửa vẫn được báo unresolved.

## Kiểm chứng

Regression đích tạm: legacy, rules riêng, modified kit, custom skill, selector, rules-only,
invalid marker/manifest/symlink, global config restored/changed/reinstall, check snapshot, restore và conflict.
Python 3.11+ (tomllib) cho helper; không thêm dependency.

## Plan thực thi

[Plan](../plans/2026-09-28-safe-uninstall.md) · [Summary](../summaries/2026-09-28-safe-uninstall-summary.md)
