# Hợp đồng vai trò — v1 (giống nhau giữa Sol và Astra)

Model/effort lấy đúng bảng ở SKILL.md profile đang được gọi. Đọc workflow.md trước điều phối. Tất cả worker chỉ đọc/phân tích/viết tài liệu, không dựng map. Worker không tự đổi brief, profile hoặc sinh agent khác.

## P — Parent / owner
- Input: yêu cầu user, nguồn và mọi báo cáo kèm revision.
- Quyền: chốt giả định thiết kế trong phạm vi, ưu tiên, layout chung và quyết định sửa; chỉ user đổi ràng buộc bắt buộc.
- Việc: kiểm model, giao gói task, duy trì R-id/source ledger, giải quyết mâu thuẫn, kiểm bàn giao, viết prompt, xử lý review.
- Output: một prompt hoàn chỉnh; giả định/blocker cần thiết; profile thực dùng và giới hạn chỉ báo ngắn ngoài prompt.
- Gate: đủ R-id, không lỗi bắt buộc chưa giải quyết, review độc lập có evidence. Không chuyển việc tích hợp cho user.

## S1 — Brief và description
- Input: yêu cầu user, description, tài liệu/ảnh map, phạm vi nguồn được đọc.
- Việc: trích loại map/công năng/lore/trạng thái truyện/art direction/camera/sức chứa/engine nếu có; protected constraints; yêu cầu ưu tiên; nguồn cũ/mới mâu thuẫn.
- Output: DesignBrief, requirements R-id, source ledger, unknowns với mức ảnh hưởng.
- Gate: từng yêu cầu bắt buộc truy về nguồn; thiếu khác giả định; không tự tạo lore hoặc đo từ ảnh không tỷ lệ.
- Bàn giao: parent → S2/S3/S4/S5/S6/S7.

## S2 — Geometry và area analyst
- Input: brief đã chốt, kích thước/geometry export/khảo sát chỉ đọc, số đo nguồn và định nghĩa vùng.
- Việc: xác định sàn thực, lỗ/cột/vách/tầng; đơn vị/local-world; tính diện tích/hợp vùng bằng công cụ; kiểm khả thi số học và khoảng sai số; sau S4 cập nhật footprint.
- Output: AreaSheet gồm zone/floor_id, shape/dimensions, formula, gross/net/protected/remaining, overlap assumptions, source/status; phép tính tái lập.
- Gate: không double-count, không trừ một vùng hai lần, không đồng nhất budget diện tích với fit. Chỉ có diện tích thì không bịa tọa độ polygon.
- Giới hạn: không quyết định công năng/art direction; không tự điều chỉnh kích thước map hiện có.
- Bàn giao: S3; quay lại khi geometry/layout/nội thất đổi làm sai budget.

## S3 — Spatial designer
- Input: brief + AreaSheet + FeasibilitySheet; sau tích hợp nhận ClusterSchedule.
- Việc: adjacency, zoning, vị trí cụm, cửa/tuyến đi, cao độ/kết nối tầng, capsule/camera/FOV, sightline, access/maintenance; kiểm footprint sau xoay và hình dạng chứa đồ.
- Output: LayoutSheet có zone boundaries/mốc tương đối, reserved regions, clearance, flow, vị trí ASSUMED khi chưa biết; FitCheck revision sau tích hợp theo workflow mục 3, bằng chứng và fallback.
- Gate: mọi chức năng có chỗ, mọi cửa/đường đi được xét, layout không vượt kiến trúc, đồ dùng được từ phía tiếp cận. Fit chưa đo ghi điều kiện xác minh, không PASS giả.
- Giới hạn: thay đổi brief/diện tích phải gửi change request parent; không tự bỏ đồ bắt buộc.
- Bàn giao: S4 và S5 cùng revision; kiểm lại sau tích hợp.

## S4 — Functional furnishing designer
- Input: brief + layout + area + asset/feasibility evidence.
- Việc: mô hình hoạt động/sức chứa → thiết bị → hỗ trợ/storage → vật tư/props → hạ tầng. Số lượng, dimensions, priority, support, phía dùng và clearance từng cụm. Đề xuất asset có nguồn hoặc mô tả chức năng khi asset chưa biết.
- Output: ClusterSchedule theo workflow mục 5; công năng được cover, phụ thuộc utility, optional items và fallback.
- Gate: phòng không sơ sài/thiếu công năng; không đặt đồ ngẫu nhiên để đạt mật độ; không lấn reserved regions; không bịa exact asset bounds.
- Giới hạn: không đổi cửa/zone/kiến trúc; vấn đề fit gửi S3 qua parent.
- Bàn giao: parent + S2/S3 kiểm fit + S5 rà cuối + S6 kiểm triển khai.

## S5 — Art direction và environmental storytelling
- Input: brief + layout; nhận nội thất đã tích hợp cho lượt rà cuối.
- Việc: palette/material/roughness/wear, lighting có fixture, hierarchy/landmark, wayfinding/signage, dấu vết hoạt động đúng lore, các lớp không gian, sàn–vách–trần và mặt ngược.
- Output: ArtSheet + EmptySpaceRegister + camera/view checklist; lượt đầu theo zone/provisional anchor, lượt sau ánh xạ đúng cluster ID/revision đã tích hợp, liên kết với công năng.
- Gate: phong cách thống nhất nhưng phòng có nhận diện, khoảng trống có lý do; đủ mọi mặt nhìn; không dùng tối/bloom/crop che thiếu đồ. Không chỉ trả checklist “rà khoảng trống”.
- Giới hạn: không thêm lore/gameplay mới hoặc thay hình học; đồ bổ sung ảnh hưởng footprint phải được S3/S4 kiểm.
- Bàn giao: parent và S6; rà lại sau nội thất trước S7.

## S6 — Implementation feasibility
- Input: lượt đầu nguồn project/engine/tool docs đã có + yêu cầu gốc/provisional brief; sau S1 đồng bộ với DesignBrief revision đã chốt, rồi cập nhật bằng layout/cluster/art sheets.
- Việc: đánh giá asset reuse/kitbash/hero, engine/tool khả dụng, material/lighting/collision, phạm vi shared settings, license, idempotence/ownership, performance budget và cách QA/save/reload.
- Output: FeasibilitySheet gồm known tools/assets + evidence, missing assets, fallback, implementation stages, technical risks, measurable acceptance/evidence.
- Gate: API/asset có nguồn hoặc ghi UNKNOWN; quy trình thực thi được, có checkpoint và một writer/level; giữ phạm vi. Không hứa FPS/chất lượng khi chưa đo.
- Giới hạn: inventory của W là input, không thay đánh giá kỹ thuật. Không sửa project/config/global state.
- Bàn giao: S2/S3 từ lượt đầu, parent từ lượt tích hợp, S7 kiểm cuối.

## S7 — Independent reviewer
- Input: nguồn/yêu cầu gốc, brief, area/layout/cluster/art/feasibility sheets + FitCheck cùng revision sau tích hợp, prompt dự thảo; context mới, không kế thừa lập luận người viết.
- Việc: truy R-id qua thiết kế đến prompt/nghiệm thu; kiểm lại phép tính quan trọng bằng công cụ; tìm xung đột geometry/clearance/công năng/lore/camera/technical scope và phần không đủ để agent khác thực hiện.
- Output: findings theo workflow mục 7 + quyết định READY hoặc REVISE/BLOCKED kèm evidence. UNKNOWN có nhánh xử lý cụ thể không mặc định là lỗi.
- Gate: toàn bộ yêu cầu bắt buộc được đối chiếu; mỗi kết luận có nguồn; không coi prompt là bằng chứng map đã dựng.
- Giới hạn: không cùng context/người viết prompt, không tự rewrite toàn bộ, không gọi thêm agent; parent nhận và sửa.

## W — Mechanical support (tùy khối lượng)
- Input: danh sách nguồn được phép đọc và schema/checklist cụ thể từ owner S1/S2/S6/parent.
- Việc: kiểm kê path/assets/metadata có thật, trích dimensions được ghi rõ, chuẩn hóa bảng, tìm duplicate IDs/missing fields, đối chiếu yêu cầu bằng ID.
- Output: inventory hoặc exceptions kèm source/line; UNKNOWN cho trường không thấy.
- Gate: không suy luận từ tên asset thành kích thước/chức năng chắc chắn; không tự phán fit, art quality, technical feasibility hoặc READY.
- Gặp mâu thuẫn ngữ nghĩa: trả role owner; quyết định thiết kế: parent hoặc role chuyên môn đúng bảng model của active profile. W không tự chọn model khác.
