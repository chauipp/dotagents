# Danh mục skill thống nhất

## Mục tiêu

Dotagents có một thư mục nguồn `skills/` làm danh mục canonical cho mọi skill được phân phối bởi installer. Người dùng chọn agent và phạm vi cài đặt bằng `install.sh`; installer lấy skill từ cùng danh mục thay vì dựa trên các thư mục nguồn riêng `shared/skills/`, `local/skills/`, `claude/skills/` và `codex/skills/`.

## Phạm vi hành vi

- Hỗ trợ chọn `codex`, `claude` hoặc `all` và chọn cài global hoặc vào một project cụ thể.
- Mỗi skill có một thư mục nguồn duy nhất dưới `skills/<name>/`.
- Skill chỉ dành cho một agent có thể khai báo metadata để installer chỉ cài nó cho agent tương thích. Hai profile `writing-prompts-map-sol` và `writing-prompts-map-astra` thuộc danh mục chung nhưng chỉ cài cho Codex.
- Graphify vẫn có thể chứa nội dung hoặc tham chiếu riêng theo agent bên trong cùng thư mục skill; không duy trì hai bản Graphify rời nhau.
- Các file rules `claude/CLAUDE.md` và `codex/AGENTS.md` giữ nguyên vị trí và mục đích.
- Đích runtime tiếp tục theo convention hiện tại của agent, như `.claude/skills/`, `.codex/skills/` hoặc thư mục skills global tương ứng. Installer không đọc, ghi hoặc xóa `~/.agents/skills/`.
- Cập nhật README và các chỉ dẫn/kiểm tra installer để mô tả nguồn danh mục mới và chọn agent/phạm vi.

## Cấu trúc và luồng cài đặt

`skills/` là nguồn duy nhất, với mỗi skill có `SKILL.md` và các tài nguyên cần thiết. Metadata trong skill thể hiện agent đích khi skill không áp dụng cho mọi agent; thiếu giới hạn agent nghĩa là dùng được cho cả Claude và Codex. Installer nhận lựa chọn agent/phạm vi, duyệt danh mục, lọc theo metadata rồi chép skill phù hợp vào đích runtime hiện hành. Nếu đích đã có bản skill không nằm trong manifest nhưng trùng nội dung hoàn toàn với nguồn canonical, installer có thể nhận bản đó vào manifest; skill cùng tên nhưng nội dung khác vẫn gây collision để bảo toàn chỉnh sửa riêng. Nội dung rules và các tùy chọn project/global hiện có không đổi ngoài việc dùng chung danh mục skill.

## Di chuyển và tương thích

- Chuyển các skill hiện có từ các thư mục nguồn phân tán vào `skills/`, giữ nội dung, giấy phép và provenance đã có.
- Gộp hai bản Graphify vào một skill có tài nguyên chung; phần hướng dẫn khác nhau theo agent được giữ dưới dạng file/nhánh nội dung trong skill đó.
- Bỏ cơ chế `local/skills/` riêng cho profile map; hai profile này trở thành các skill Codex trong danh mục mới và được cài khi chọn Codex.
- Dọn các tham chiếu đang hoạt động tới đường dẫn nguồn cũ trong installer, tài liệu, rules và hướng dẫn nội bộ. Tài liệu lịch sử có thể giữ nguyên.
- Giữ các lựa chọn cài đặt CLI hiện hành (global/project, Codex/Claude/all, check và rules-only nếu đang hỗ trợ); thay đổi nằm ở nguồn skill và quy tắc lọc agent.

## Kiểm chứng

Đối chiếu nội dung skill trước/sau di chuyển, rà soát hành vi installer cho từng agent và phạm vi, bảo đảm không có đường dẫn thao tác `~/.agents/skills/`, và rà soát README cùng các tham chiếu nguồn cũ. Không thay đổi quy tắc cài đặt rules.

## Plan thực thi

Kế hoạch thực thi: [2026-09-23-single-skills-catalog.md](../plans/2026-09-23-single-skills-catalog.md).
