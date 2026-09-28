# Skill viết prompt map theo level cho Codex

Skill canonical nằm trong danh mục `skills/` và có metadata `agents: codex`. Installer cài nó ở cả global và project khi chọn Codex; không cài vào Claude.

| Level | Parent bắt buộc | Cách gọi |
|---|---|---|
| `low` | Chưa cấu hình; luôn block | `$ch-writing-prompts-map low <yêu cầu map>` |
| `med` hoặc `medium` | `gpt-5.6-sol / xhigh` | `$ch-writing-prompts-map med <yêu cầu map>` |
| `high` | `gpt-6-astra / xhigh` | `$ch-writing-prompts-map high <yêu cầu map>` |

Không truyền level thì mặc định là `med`. Parent phải khớp model/reasoning của level trước khi chạy pipeline. Metadata runtime chính xác được ưu tiên; nếu chỉ hiện nhãn tổng quát hoặc `UNKNOWN`, skill hỏi xác nhận thay vì kết luận model sai. Khi user xác nhận rõ model và reasoning từ bộ chọn, skill tiếp tục ở lần gọi kế tiếp với bằng chứng `USER_CONFIRMED`; xác nhận hết hiệu lực sau lần đó hoặc khi có bằng chứng đổi model. Nếu metadata runtime chính xác cho thấy profile không khớp thì vẫn `BLOCKED_MODEL`. Skill không tự đổi parent hoặc fallback.

Skill chỉ viết prompt cho map; không dựng map hoặc viết prompt lĩnh vực khác. Hai alias `med` và `medium` dùng cùng profile Sol.
