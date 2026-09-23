# Hai skill viết prompt map

[Spec](../specs/2026-09-22-map-prompt-profiles-design.md) · [Plan](../plans/2026-09-22-map-prompt-profiles.md)

## Đã làm gì
- Tách writing-prompts thành writing-prompts-map-sol và writing-prompts-map-astra; cả hai chỉ viết prompt map, opt-in, cùng hợp đồng và gate chất lượng.
- Giữ đủ parent + S1–S7; W Luna chỉ kiểm kê/đối chiếu. Sol cấm Astra; profile Astra dùng Astra ở parent/S2/S3/S7 như đã chốt.
- Chuẩn hóa PROVIDED/VERIFIED/DERIVED/ASSUMED/UNKNOWN, phép tính hợp diện tích, footprint/clearance, FitCheck theo revision, nội thất theo công năng, mỹ thuật và kiểm khả thi kỹ thuật.
- Nguồn ở local/skills, ngoài bộ cài global; README có cách chọn model, gọi skill và cài local. Đã cài vào .codex/skills của dotagents, indie-game-lab và worktree ue-game; mọi bản copy khớp checksum, global không có hai profile. Bản copy được bỏ qua qua .git/info/exclude, không ignore skill riêng khác.
- Thêm regression bảo vệ không cài global, local copies còn sau cập nhật kit, hai bộ reference không lệch.

## File chính
- local/skills/writing-prompts-map-sol/SKILL.md: model Sol/Terra/Luna, giới hạn xhigh và guard parent/dispatch.
- local/skills/writing-prompts-map-astra/SKILL.md: model profile Astra, chung nhiệm vụ và tiêu chí với Sol.
- references/workflow.md + references/roles.md trong mỗi package: trình tự, hợp đồng vai trò, FitCheck và yêu cầu prompt hoàn chỉnh.
- agents/openai.yaml trong mỗi package: metadata opt-in và lời gọi đúng tên; không giả cấu hình model parent.
- tests/install.sh: regression scope cài đặt và parity.
- README.md và local/README.md: cách dùng và quản lý nguồn/bản copy.

## Khác với plan
- Không chạy đội Astra thật: user đang hạn chế quota; kiểm bảng model/routing bằng Terra, đối chiếu metadata runtime. Không thay đổi thiết kế profile Astra.
- Bổ sung FitCheck revision, PROVIDED và S6 provisional/rebase sau review để khép dependency.

## Còn dở / cần lưu ý
- Chưa benchmark hai đội model end-to-end, chưa dựng/kiểm map trong engine. Kết quả dưới đây là thử hành vi có giới hạn và kiểm tài liệu, không chứng minh chất lượng tốt nhất tuyệt đối.
- Skill không tự đổi model parent; chọn Sol xhigh hoặc Astra xhigh tương ứng trước khi gọi, mở task mới/reload skill nếu chưa thấy tên.

## Bằng chứng kiểm thử
- Baseline với generic skill: Terra tính đúng 67.020643m² và union16m² nhưng tự đổi gợi ý 80% phủ sàn sang phủ thị giác: “Hãy coi ‘80%’ là mục tiêu phủ thị giác”. Đây là lỗi đổi nghĩa metric cần chặn.
- Application Terra high: sector R12/r4/60° → floor67.020643, remaining51.020643, 80%=53.616515; xác định xung đột, không tự đổi metric; chưa có cửa không kết luận fit.
- Application rectangle: 10×8, cột4, tuyến12, lỗ4 không giao → còn60 trước bàn8, còn52 sau bàn; props trên bàn không trừ sàn lần nữa. Python kiểm độc lập khớp.
- Missing-scale: ảnh perspective không có scale không cho diện tích chính xác; giữ cửa/kiến trúc và nêu bước đo/fallback.
- Prompt mẫu Sol high: có layout cụ thể, cụm công năng, mỹ thuật, engineering và QA; lần đầu nhầm VERIFIED theo brief, sửa theo PROVIDED và bổ sung FitCheck, không gọi số dự toán là fit trong engine.
- Review Sol high: phát hiện thiếu gate sau tích hợp, S5 cluster chưa tồn tại, S6 brief dependency, S7 input thiếu FitCheck; đã sửa và đối chiếu source.
- Routing Terra high: Sol chặn parent Astra; Astra thiếu model không fallback âm thầm; S2/S3 Astra high, S7 Astra xhigh; không giả review độc lập. Reviewer từng nhầm S2 Astra là Terra ở câu gộp role, đã đọc bảng và sửa kết luận: Sol chỉ gộp S2/S6, Astra không gộp S1/S2/S6.
- quick_validate.py: cả hai package hợp lệ; metadata YAML opt-in, default prompt đúng tên; mọi model/effort có trong metadata runtime; references byte-identical.
- Installer regression RED: “Map prompt skill leaked into global install: writing-prompts”; sau gỡ generic khỏi shared/skills → GREEN. Test chạy trong thư mục tạm, không cài global thật.

Review cuối: không còn finding quan trọng; reviewer độc lập chạy lại installer regression GREEN và kiểm diff/parity.
