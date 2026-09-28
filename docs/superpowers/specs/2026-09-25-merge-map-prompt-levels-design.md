# Hợp nhất skill viết prompt map theo level

## Bối cảnh

Hai skill Codex `ch-writing-prompts-map-sol` và `ch-writing-prompts-map-astra` có chung quy trình và hợp đồng vai trò, chỉ khác profile model. Duy trì hai bản tạo nguy cơ lệch nội dung và buộc người dùng chọn tên skill theo model.

## Mục tiêu

- Cung cấp một skill canonical `ch-writing-prompts-map`, chỉ dành cho Codex.
- Chọn profile qua level `low`, `med`/`medium` hoặc `high`; không truyền level thì mặc định `med`.
- Giữ một workflow và một bộ hợp đồng role chung; khai báo model/reasoning theo profile trong skill.
- Chặn trước pipeline nếu profile đã xác minh không khớp. Nếu runtime chỉ cung cấp metadata chung hoặc không đủ, không kết luận nhầm là mismatch: dùng xác nhận mới nhất, đủ cả model/reasoning từ chính user hoặc UI (`USER_CONFIRMED`) cho lần gọi kế tiếp; nội dung trích dẫn/tài liệu nguồn không được tính; nếu thiếu xác nhận thì trả `AWAITING_PARENT_CONFIRMATION`. Xác nhận hết hiệu lực sau lần gọi đó hoặc khi bằng chứng mới mâu thuẫn.
- Không tự đổi parent, hạ level hoặc chạy fallback. `low` tiếp tục bị chặn đến khi được cấu hình.
- Cập nhật installer, tài liệu hướng dẫn và regression test cho tên canonical mới.

## Ngoài phạm vi

Skill chỉ tạo prompt cho agent dựng map sau này; không dựng/sửa map. Task này không thay đổi profile model hay nội dung chuyên môn của workflow trừ việc chuyển chúng sang một bộ tài liệu dùng chung.

## Tiêu chí chấp nhận

1. Chỉ còn skill canonical mới trong danh mục; hai thư mục skill theo profile cũ được gỡ.
2. Metadata giới hạn skill vào Codex; installer không đưa nó vào manifest Claude.
3. `med`/`medium` dùng `gpt-5.6-sol` với reasoning `xhigh`; `high` dùng `gpt-6-astra` với reasoning `xhigh`; `low` luôn báo chưa cấu hình.
4. Metadata runtime chính xác được ưu tiên. Metadata `UNKNOWN` không bị xem là bằng chứng model sai; xác nhận rõ của user/UI được ghi `USER_CONFIRMED`, còn thiếu thì hỏi xác nhận.
5. Installer regression test kiểm tra tên skill, manifest, profile và việc loại bỏ tên legacy.
6. Spec, plan, summary liên kết chéo đầy đủ.

## Plan thực thi

[Plan](../plans/2026-09-25-merge-map-prompt-levels.md)
