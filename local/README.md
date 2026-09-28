# Hai profile viết prompt map cho Codex

Hai skill nằm trong danh mục canonical `skills/` và có metadata `agents: codex`. Vì thế installer tự cài chúng cùng các skill còn lại ở cả global và project khi chọn Codex; chúng không được cài vào Claude.

| Skill | Parent cần chọn | Cách gọi |
|---|---|---|
| ch-writing-prompts-map-sol | gpt-5.6-sol / xhigh | `$ch-writing-prompts-map-sol <yêu cầu map>` |
| ch-writing-prompts-map-astra | gpt-6-astra / xhigh | `$ch-writing-prompts-map-astra <yêu cầu map>` |

Chọn parent Sol xhigh hoặc Astra xhigh, rồi gọi profile tương ứng. Skill chỉ viết prompt cho map; không dựng map hoặc viết prompt lĩnh vực khác. Metadata opt-in giúp user tự chọn profile. Skill không tự đổi model parent; thiếu model/công cụ phải báo đúng giới hạn. Bản Sol không gọi Astra, kể cả fallback. Không dùng max/ultra mặc định.

Hai profile giữ chung nội dung trong `references/workflow.md` và `references/roles.md`; cập nhật phần dùng chung ở cả hai nơi và kiểm tra parity bằng so sánh file. Bảng model/policy riêng nằm trong từng `SKILL.md`.
