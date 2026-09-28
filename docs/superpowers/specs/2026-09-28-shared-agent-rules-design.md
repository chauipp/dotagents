# Thiết kế đồng bộ rules dùng chung cho Codex và Claude Code

## Mục tiêu

Tách các quy tắc dùng chung của bộ kit dotagents thành một nguồn duy nhất, sau đó để `install.sh` dựng block rules hoàn chỉnh cho Codex và Claude Code. Mỗi agent vẫn nhận đúng tên file và đường dẫn runtime mà công cụ của nó tự nạp, trong khi phần nội dung chung không còn phải duy trì thủ công ở hai bản sao.

## Phạm vi

Task này chỉ thay đổi source rules của dotagents, `install.sh` và regression tests liên quan đến việc ghép rules.

Bao gồm:

- phân loại nội dung hiện có thành common, Codex-only và Claude-only;
- tạo source common;
- biến `codex/AGENTS.md` và `claude/CLAUDE.md` thành overlay nền tảng;
- ghép common + overlay vào block được installer quản lý;
- bảo toàn nội dung đã có trong file đích;
- cảnh báo migration khi file đích có rules cũ chưa được đánh dấu;
- kiểm tra idempotency, thiếu source, trùng section và phạm vi file.

Không bao gồm:

- đổi tên hoặc đổi đường dẫn runtime chuẩn của Codex/Claude;
- tự xóa rules cũ của user hoặc project;
- tự hợp nhất hai section có nội dung mâu thuẫn;
- sửa các skill, metadata skill hoặc thay đổi dirty không liên quan;
- dùng cơ chế `CLAUDE.md` import `AGENTS.md` làm đường chính;
- thay đổi model, reasoning, plugin hoặc MCP configuration.

## Bối cảnh runtime

Source trong kit và file runtime là hai lớp khác nhau:

| Lớp | Codex | Claude Code |
|---|---|---|
| Source của kit | `rules/common.md` + `codex/AGENTS.md` | `rules/common.md` + `claude/CLAUDE.md` |
| Project runtime | `<TARGET>/AGENTS.md` | `<TARGET>/CLAUDE.md` |
| Global runtime | `$CODEX_HOME/AGENTS.md` | `$CLAUDE_CONFIG_DIR/CLAUDE.md` |
| Mặc định global | `~/.codex/AGENTS.md` | `~/.claude/CLAUDE.md` |

`install.sh` hiện dùng `$CODEX_HOME` và `$CLAUDE_CONFIG_DIR`, sau đó gọi `merge_rules` cho từng file đích. Thiết kế mới giữ nguyên các đích này; chỉ thay source đơn lẻ bằng nội dung đã dựng từ common và overlay.

## Kiến trúc source

Tạo file `rules/common.md`. File này chứa các section áp dụng như nhau cho hai agent, ví dụ ngôn ngữ, bảo toàn Git identity, phạm vi commit/push, kiểm UI, quy tắc tài liệu plan/spec/summary và lưu conversation.

Giữ hai overlay:

```text
codex/AGENTS.md       # Codex overlay
claude/CLAUDE.md      # Claude overlay
```

Sau refactor, mỗi overlay chỉ chứa cách gọi skill/subagent, khác biệt worktree/tool/lifecycle và hướng dẫn chỉ có ý nghĩa trong runtime của agent đó. Không để overlay lặp lại nguyên văn common. Nếu một rule gần giống nhưng khác semantics, giữ nó ở overlay.

## Hợp đồng dựng block

Installer dựng source tạm theo thứ tự:

```text
BEGIN_MARK
common.md
platform overlay
END_MARK
```

Trong file runtime, block có dạng:

```markdown
<!-- dotagents:begin — KHÔNG sửa tay, chạy lại install.sh để cập nhật -->

[nội dung rules/common.md]

[nội dung codex/AGENTS.md hoặc claude/CLAUDE.md]

<!-- dotagents:end -->
```

Common đứng trước overlay để phần riêng của agent giải thích cách áp dụng rule chung trên nền tảng đó. Marker hiện tại vẫn là ranh giới sở hữu của installer; không tạo marker riêng cho common và overlay.

## Hành vi merge và migration

### File đích chưa tồn tại hoặc rỗng

Installer tạo file và ghi một block hoàn chỉnh common + overlay.

### File đích có block dotagents

Installer giữ nguyên mọi nội dung bên ngoài marker, thay toàn bộ block cũ bằng block mới. Đây là đường cập nhật chính thức và phải idempotent.

### File đích có nội dung nhưng chưa có marker

Installer giữ nguyên toàn bộ nội dung cũ, nối block mới xuống cuối và cảnh báo rằng rules cũ chưa được dotagents quản lý. Không được tự suy đoán phần cũ là bản kit để xóa.

Nếu có heading Markdown cấp một trùng giữa nội dung cũ và block mới, installer cảnh báo khả năng tồn tại bản cũ gây conflict. Cảnh báo phải nêu file đích, số heading trùng và hướng dẫn user review; installer vẫn không xóa hoặc tự merge nội dung.

### `--check`

`--check` dựng cùng block như cài thật nhưng không ghi file đích, rules, skills hoặc config của project/global target; file tạm nội bộ được phép dùng và phải được dọn trước khi kết thúc. Output phải cho biết source common và overlay, file đích, trạng thái marker, số heading trùng, hành động dự kiến và lỗi khiến cài thật phải dừng.

## Lỗi và safety gates

Installer dừng trước khi ghi nếu:

- `rules/common.md` không tồn tại, không đọc được hoặc rỗng;
- overlay của agent không tồn tại, không đọc được hoặc rỗng;
- source không thuộc kit hiện tại hoặc đường dẫn bị resolve ra ngoài kit;
- hai source chứa marker quản lý lồng nhau hoặc marker không cân bằng;
- thao tác tạo file tạm hoặc ghi file đích thất bại.

Installer không dừng chỉ vì file đích có rules cũ; trường hợp đó là migration warning. Nội dung cũ ngoài marker phải được bảo toàn.

## Phân loại nội dung

Trước khi tách file, rà từng section hiện tại:

| Loại | Tiêu chí | Nơi sau refactor |
|---|---|---|
| Common | Cùng ý nghĩa và cùng hành động ở cả hai agent | `rules/common.md` |
| Codex-only | Tên file, tool, lifecycle hoặc behavior riêng Codex | `codex/AGENTS.md` |
| Claude-only | Tên file, tool, lifecycle hoặc behavior riêng Claude | `claude/CLAUDE.md` |
| Không chắc | Khác biệt chưa chứng minh là nền tảng bắt buộc | Giữ ở overlay và ghi chú review |

Không chuyển một rule sang common chỉ vì câu chữ giống nhau. Phải kiểm tra semantics runtime, đặc biệt với worktree, subagent, skill invocation, conversation storage và approval.

## Kiểm thử và nghiệm thu

Regression test phải bao phủ:

1. File đích mới nhận đúng common và đúng overlay.
2. File đích có rules riêng không marker giữ nguyên toàn bộ và nhận thêm một block.
3. File đích có marker thay đúng block, giữ nguyên nội dung trước và sau marker.
4. Chạy installer hai lần cho cùng đích không nhân đôi common hoặc overlay.
5. Codex không nhận section Claude-only; Claude không nhận section Codex-only.
6. Thiếu common hoặc overlay dừng trước khi sửa file.
7. Heading trùng tạo cảnh báo nhưng không xóa file cũ.
8. `--check` không tạo, sửa hoặc xóa file đích, rules, skills hoặc config của project/global target; file tạm nội bộ phải được dọn.
9. Source marker lồng hoặc không cân bằng dừng trước khi ghi.
10. Các test installer hiện có vẫn pass, gồm collision skill, manifest và rules-only.

Kiểm tra thủ công sau cài đặt phải xác nhận common xuất hiện đúng một lần, overlay đúng agent đứng sau common, rules cũ ngoài marker còn nguyên, không có section chung bị lặp và đường dẫn runtime không đổi.

## Tiêu chí hoàn tất

Task chỉ được coi là hoàn tất khi source common và hai overlay đã được phân loại, tách và rà semantic diff; `install.sh` dựng block chung + overlay cho cả global và project mode; migration warning bảo toàn rules cũ; regression test và `git diff --check` pass; README mô tả source/runtime path và hành vi file đích đã có rules; commit không chứa thay đổi ngoài phạm vi task.

## Plan thực thi

[Implementation plan](../plans/2026-09-28-shared-agent-rules.md) · [Kết quả triển khai](../summaries/2026-09-28-shared-agent-rules-summary.md)
