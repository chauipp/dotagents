# Skill viết prompt map chỉ dùng local

Nguồn được version-control ở `local/skills/`, không thuộc vòng quét `shared/skills/` hay `codex/skills/` của installer. Vì vậy chạy lại installer global không cài chúng lên toàn máy. Hai profile thay thế skill generic `writing-prompts`.

| Skill | Parent cần chọn | Cách gọi |
|---|---|---|
| writing-prompts-map-sol | gpt-5.6-sol / xhigh | `$writing-prompts-map-sol <yêu cầu map>` |
| writing-prompts-map-astra | gpt-6-astra / xhigh | `$writing-prompts-map-astra <yêu cầu map>` |

## Cài vào một project Codex

Copy nguyên thư mục từng profile vào `<project>/.codex/skills/`. Trước khi copy, kiểm tra đích: nếu là skill riêng cùng tên hoặc có chỉnh sửa cục bộ, so diff/backup trước, không ghi đè mù. Chỉ cập nhật bản copy do lần cài này sở hữu. Không copy vào `~/.codex/skills`, `~/.agents/skills` hay `~/.claude/skills`.

Ví dụ cài mới, chạy từ root dotagents, thay đường dẫn project thật:

```bash
mkdir -p '/path/to/project/.codex/skills'
cp -R local/skills/writing-prompts-map-sol '/path/to/project/.codex/skills/'
cp -R local/skills/writing-prompts-map-astra '/path/to/project/.codex/skills/'
```

Mỗi worktree có thư mục skill riêng; cài tại worktree đang mở nếu cần. Mở task/phiên mới hoặc reload danh sách skill để nhận tên mới. `agents/openai.yaml` chỉ khai discovery/default prompt; không có trường giả để đổi model parent. User chọn model trước khi gọi. Các role subagent dùng tham số model/reasoning của tool hiện hành; nếu host không hỗ trợ, skill báo BLOCKED_MODEL hoặc đề nghị chọn profile tương thích.

Bản copy kit không commit vào project: thêm hai đường dẫn cụ thể `.codex/skills/writing-prompts-map-sol/` và `.codex/skills/writing-prompts-map-astra/` vào `.git/info/exclude` của repo, hoặc cấu hình ignore riêng theo quy ước project. Không ignore cả thư mục skills vì còn skill riêng của dự án. Nguồn được commit ở repo dotagents này.

## Giữ hai bản không lệch

`references/workflow.md` và `references/roles.md` phải giống hệt giữa hai profile. Sửa tài liệu chung thì cập nhật cả hai; `bash tests/install.sh` kiểm parity và việc không cài global. Bảng model/policy riêng nằm trong mỗi `SKILL.md`. Tài liệu tự đủ trong từng package, không symlink sang skill còn lại.

Sản phẩm chỉ là prompt dựng map. Không coi review prompt là nghiệm thu map trong engine. Báo cáo kiểm thử tại `docs/superpowers/summaries/2026-09-22-map-prompt-profiles-summary.md` ghi phạm vi đã kiểm và giới hạn.
