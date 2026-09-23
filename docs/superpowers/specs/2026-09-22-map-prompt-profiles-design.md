# Hai profile viết prompt map

User đã duyệt phạm vi vai trò và yêu cầu tạo writing-prompts-map-sol + writing-prompts-map-astra thay skill generic writing-prompts. Chỉ local, cùng trách nhiệm/chất lượng, khác bảng model. Sol tối đa xhigh, không Astra kể cả fallback. Astra dùng cấu hình đã đề xuất. Việc xây dựng/kiểm thử lần này dùng Sol/Terra/Luna để tiết kiệm quota.

Nguồn ở local/skills/, ngoài vòng quét shared/skills và codex/skills của installer global. Mỗi skill tự đủ SKILL.md + agents/openai.yaml + references/{workflow,roles}.md; hai reference giống hệt, kiểm parity. Metadata opt-in để user tự chọn. Copy cục bộ vào dotagents và indie-game-lab (cả worktree ue-game hiện dùng); không cài global, không chạy installer lên dự án thật vì có rules người dùng sửa.

Hợp đồng mỗi role: input, quyền/giới hạn, nhiệm vụ, output, gate, dependencies. Workflow S1/S6 → S2 → S3 → S4/S5 → parent integration/S2/S3/S5/S6 recheck → draft → S7 → focused fixes. W chỉ hỗ trợ cơ học, không thay S6 hoặc S7.

Kiểm: baseline với skill generic; application cases rectangle/annular sector/missing data; profile mismatch/model fallback; parity/schema/local vs global install. Bản Astra chỉ kiểm routing bằng model tiết kiệm, không chạy đội Astra và không tuyên bố benchmark chất lượng Astra.

## Plan thực thi
[Plan](../plans/2026-09-22-map-prompt-profiles.md)
## Kết quả
[Summary](../summaries/2026-09-22-map-prompt-profiles-summary.md)
