# Kế hoạch triển khai bảo toàn danh tính Git của người dùng

> **Cho agent thực thi:** BẮT BUỘC dùng `executing-plans` để làm từng task, cập nhật checkbox khi task hoàn tất và kiểm tra kỹ identity Git trước mỗi commit.

**Mục tiêu:** Phân phối một skill và rule bắt buộc giúp giữ nguyên danh tính Git hiện tại của người dùng, đồng thời ngăn attribution agent/AI tự sinh trong code và metadata.

**Kiến trúc:** Skill dùng chung chứa quy trình kiểm tra có điều kiện trước commit/push. Hai file rule nạp yêu cầu này ở cấp runtime. Regression test xác minh skill/rule có mặt sau khi installer chạy theo dự án.

**Công nghệ:** Markdown, Bash, Git.

## Ràng buộc toàn cục

- Không được sửa `user.name`, `user.email`, dùng `--author`, hay danh tính bot/agent.
- Không thêm attribution agent/AI vào code, commit, push metadata, PR hoặc changelog do agent tạo.
- Nếu không đọc được cả `git config user.name` và `git config user.email`, dừng trước commit/push để xin người dùng cấu hình/xác nhận.
- Không xóa copyright, license, hay attribution đã có sẵn nếu người dùng không yêu cầu.

---

- [x] Task 1: Viết regression test cho skill và rule mới

**Files:**
- Modify: `tests/install.sh`

**Consumes:** Cấu trúc installer hiện có: shared skills được copy vào cả `.claude/skills` và `.codex/skills`; rule được merge thành `CLAUDE.md` và `AGENTS.md`.

**Produces:** Kiểm tra tự động thất bại nếu skill nguồn/chuyển giao hoặc câu neo trong hai runtime rules bị thiếu.

- [x] Step 1: Viết failing test

Thêm các assertion sau sau `assert_skill_set`:

```bash
[ -f "$KIT_DIR/shared/skills/preserving-user-git-identity/SKILL.md" ] \
  || fail 'Missing shared Git identity skill'
assert_file_equal "$KIT_DIR/shared/skills/preserving-user-git-identity/SKILL.md" \
  "$project/.claude/skills/preserving-user-git-identity/SKILL.md"
assert_file_equal "$KIT_DIR/shared/skills/preserving-user-git-identity/SKILL.md" \
  "$project/.codex/skills/preserving-user-git-identity/SKILL.md"
grep -q 'preserving-user-git-identity' "$project/CLAUDE.md" \
  || fail 'Claude rules omit Git identity safeguard'
grep -q 'preserving-user-git-identity' "$project/AGENTS.md" \
  || fail 'Codex rules omit Git identity safeguard'
```

- [x] Step 2: Chạy để xác nhận RED

Run: `bash tests/install.sh`

Expected: FAIL với `Missing shared Git identity skill`.

- [x] Task 2: Tạo skill và nạp rule cho Claude/Codex

**Files:**
- Create: `shared/skills/preserving-user-git-identity/SKILL.md`
- Modify: `claude/CLAUDE.md`
- Modify: `codex/AGENTS.md`

**Consumes:** Yêu cầu đã duyệt trong spec và failure message từ Task 1.

**Produces:** Skill dùng chung, dễ tìm và hai rule trỏ rõ tới skill đó.

- [x] Step 1: Viết skill với frontmatter hợp lệ

Tạo skill có `name: preserving-user-git-identity`, description bắt đầu bằng `Use when`, và quy trình: xác minh `git config user.name`/`user.email`; kiểm tra staged diff + message/template + trailer; dừng khi identity thiếu; không dùng `--author`/bot/agent identity; kiểm tra lại trước push.

- [x] Step 2: Thêm rule vào hai runtime instructions

Thêm một mục tương đương vào `claude/CLAUDE.md` và `codex/AGENTS.md`, nêu bắt buộc dùng `preserving-user-git-identity` trước mọi commit/push và không tự thay đổi Git identity.

- [x] Step 3: Chạy để xác nhận GREEN

Run: `bash tests/install.sh`

Expected: PASS; test xác nhận cả hai bản cài theo dự án có skill đúng nội dung và cả hai rule có câu neo.

- [x] Task 3: Kiểm tra chất lượng và hoàn tất tài liệu

**Files:**
- Modify: `docs/superpowers/specs/2026-09-14-preserving-user-git-identity-design.md`
- Modify: `docs/superpowers/plans/2026-09-14-preserving-user-git-identity.md`
- Create: `docs/superpowers/summaries/2026-09-14-preserving-user-git-identity-summary.md`

**Consumes:** Diff hoàn thiện và kết quả regression test.

**Produces:** Plan được tick theo tiến độ, summary dựa trên thay đổi thực tế và liên kết tài liệu ba chiều.

- [x] Step 1: Chạy kiểm tra cuối

Run: `bash tests/install.sh && git diff --check`

Expected: PASS và không có lỗi whitespace.

- [x] Step 2: Tick các task hoàn tất và viết summary

Đổi cả ba dòng Task thành `- [x]`, rồi tạo summary gồm: Đã làm gì, File chính, Khác với plan, Còn dở / cần lưu ý. Summary phải trỏ về spec và plan; plan phải trỏ đến summary trong mục Kết quả.

- [x] Step 3: Commit

Trước khi commit, đọc `git config user.name` và `git config user.email`; dừng nếu thiếu. Rà staged diff, commit message và trailer để chắc chắn không có attribution agent/AI. Sau đó commit với message `feat: protect user git identity`.

## Kết quả

Summary sẽ nằm tại [2026-09-14-preserving-user-git-identity-summary.md](../summaries/2026-09-14-preserving-user-git-identity-summary.md).
