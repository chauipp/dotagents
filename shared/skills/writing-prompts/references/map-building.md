# Viết prompt dựng map có thể triển khai

Đọc khi đầu ra là prompt tạo/hoàn thiện level hoặc môi trường game. Đây là checklist để viết yêu cầu cụ thể theo khu được giao, không phải văn bản chép nguyên vào mọi prompt.

## 1. Xác định loại việc và nguồn

Chốt tạo map mới, cải tạo hay hoàn thiện khu hiện có. Với khu hiện có, khảo sát trước placement; với map mới, nêu rõ phần kiến trúc được tạo. Lấy art direction, camera, chức năng và trạng thái truyện từ brief/project.

Đọc prompt khu đích và khu lân cận khi được cung cấp để tránh trùng chức năng. Học tiêu chuẩn từ mẫu, không tự chuyển kích thước hoặc lore mẫu sang map khác. Số liệu cũ là tham khảo cho đến khi đo được; không ép map hiện tại khớp bản cũ.

## 2. Khảo sát và phạm vi

Prompt cần giao agent đích:

- Xác định source/target level, checkpoint và actor cần bảo vệ; giữ thay đổi chưa lưu của người dùng.
- Đo geometry, mặt sàn/trần, vách, cửa, kính, kết nối và diện tích hữu dụng.
- Xác định capsule, camera/FOV, spawn, số người chơi và asset sẵn có.
- Chốt đơn vị, gốc/trục local, hướng quay và phép đổi sang world trước khi ghi transform.
- Khoanh phần được sửa: actor, asset, collision, material, đèn, cảnh ngoài và thiết lập shared.
- Không xóa asset nguồn chỉ vì bỏ instance; không sửa khu khác hoặc global lighting để cứu một góc chụp.

Ưu tiên phạm vi/kết nối → đi lại → tỷ lệ/công năng → bố cục → chi tiết. Thiếu chỗ thì giảm module/đồ phụ, không thu nhỏ đồ phi lý hoặc tự dời cửa.

## 3. Bố cục và từng cụm

Thiết kế mặt bằng trước chi tiết: Zone/Cluster ID, cửa, đường đi, vùng thao tác, điểm nhấn, mật độ và khoảng nghỉ. Các khu quan trọng cần mục riêng theo công năng, không chỉ liệt kê tên asset.

Mỗi cụm cần:

| Trường | Nội dung |
|---|---|
| Công năng | Hoạt động phục vụ và quan hệ với cụm kế bên |
| Vị trí | Mốc tương đối, hướng tiếp cận, quan hệ cửa/vách/kính |
| Thiết bị chính | Số lượng có lý do, kích thước tham khảo, silhouette/cấu tạo |
| Hỗ trợ | Bàn/ghế/storage, đế, housing, bracket, mặt đỡ |
| Dấu vết dùng | Props theo hành động, wear đúng nơi; phù hợp trạng thái truyện |
| Hạ tầng | Power/data/fluid nếu cần; đường đi, điểm đầu/cuối và giá đỡ |
| Clearance | Đi qua, sử dụng, mở cửa/tủ, bảo trì; đo theo collision/bounds |
| Kiểm tra | Biểu hiện đạt, lỗi dễ gặp và phương án thu gọn |

Viết những lựa chọn thiết kế cụ thể phù hợp brief; agent dựng xác nhận số đo trước placement. Không biến thiếu kích thước thành lý do chỉ viết “đặt nội thất phù hợp”.

## 4. Đủ lớp không gian và khả năng đi lại

“Đủ đầy” là sàn–chân vách–nội thất–mặt bàn–tường–trần đều có quyết định thiết kế. Có khối lớn, đồ hỗ trợ và chi tiết gần; vùng trống có lý do giao thông/thao tác/sightline/bảo trì. Không đo chất lượng bằng actor count.

Bảo vệ tuyến cửa–cửa và cửa–cụm, spawn, vùng tránh nhau nếu có nhiều người chơi. Đo thông thủy giữa bề mặt/collision, tính chân đế, tay vịn và ghế kéo ra. Không tắt collision vật lớn để làm tuyến có vẻ thông.

Thiết kế mặt bên/mặt sau và góc ngược với FOV gameplay; không chỉ một ảnh từ cửa. Props nằm đúng support surface, không dùng một Z cho mọi vật.

## 5. Material, ánh sáng, asset

Chỉ định palette, nhóm chất liệu, độ nhám/bóng tương đối và wear theo sử dụng. Đèn có fixture/nguồn hợp lý, giúp đọc chức năng; không dùng bloom che thiếu chi tiết.

Nếu có kính/cảnh ngoài trong phạm vi: kiểm cả chính diện và góc xiên, mép nối, back-face/parallax; backdrop và kính là hai lớp riêng. Không tự khoét vỏ để thêm view.

Ưu tiên asset sẵn có, module dùng lại; hero asset mới theo nhu cầu/budget. Primitive dùng blockout hoặc làm bộ phận model, không coi hộp trơn là thiết bị final. Ghi nguồn/license và quyền phân phối source asset ngoài.

Manifest gồm stable ID, Zone/Cluster ID, asset/source, transform, bounds/footprint, support, hướng tiếp cận và collision. Script chạy lại cập nhật đúng actor sở hữu, không nhân bản. Nếu có nhiều worker, chỉ một builder ghi target level tại một thời điểm.

## 6. Trình tự và bằng chứng

Khảo sát/checkpoint → thiết kế/manifest → blockout và kiểm đường đi → nội thất chính/hỗ trợ → hạ tầng/material/đèn → props/wear → QA/sửa/lưu/reload.

Mỗi chặng có đầu ra và điều kiện chuyển tiếp. Blockout chưa đi được thì sửa trước chi tiết.

Prompt giao kiểm:

- Inventory trước/sau, cửa/spawn/khu ngoài phạm vi được bảo toàn.
- Collision, clearance, support, xuyên mesh, z-fighting, thiếu mặt và nhãn.
- Walkthrough thực tế với pawn/camera phù hợp; trace/proxy không thay thế hoàn toàn chơi thử.
- Ảnh viewport/game: top-down, từ cửa, góc ngược/chéo, điểm hẹp, cận cụm và góc đặc thù.
- Map Check hoặc kiểm tương đương của engine; reference, save/reload và chạy lại placement nếu có.
- Hiệu năng trước/sau cùng máy/camera/cấu hình; báo số đo khi chưa có budget, không hứa FPS.

Bàn giao target/checkpoint, layout, manifest, file/asset đổi, ảnh, sai lệch và bảng PASS/FAIL/CHƯA KIỂM kèm bằng chứng. Nếu agent đích thiếu engine/công cụ, báo phần làm được và blocker; không dùng concept/ảnh sinh thay ảnh nghiệm thu.

Mặc định dựng tĩnh nếu brief không yêu cầu gameplay. Tách rõ hình dáng thiết bị/cửa khỏi tương tác, trigger, puzzle, animation hoặc mô phỏng vật lý.
