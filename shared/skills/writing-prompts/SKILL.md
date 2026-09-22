---
name: writing-prompts
description: Use when the user asks to create, rewrite, or improve a reusable prompt for another agent, including prompts grounded in project files or examples. Not for directly executing the task described inside that prompt.
---

# Writing Prompts

Biến ý tưởng hoặc prompt hiện có thành **một prompt hoàn chỉnh, có thể giao cho agent khác**. Giữ đúng mục tiêu, phạm vi và mức chi tiết người dùng muốn; mặc định viết cùng ngôn ngữ của họ.

## Xác định đúng tầng công việc

Phân biệt ba thứ trước khi viết:

- **Việc hiện tại:** tạo/cải thiện prompt; có thể đọc nguồn nhưng chưa thực hiện nhiệm vụ bên trong.
- **Việc agent nhận prompt phải làm:** sản phẩm, hành động và bằng chứng người dùng muốn nhận sau này.
- **Điều kiện của mỗi lượt:** thiếu công cụ hoặc file ở lượt viết prompt không có nghĩa agent nhận prompt cũng thiếu. Đưa điều kiện chưa biết thành bước kiểm tra của agent nhận việc.

Ví dụ: “viết prompt dựng map, lượt này không có UE” vẫn phải tạo prompt yêu cầu dựng map khi agent đích có UE. Trong prompt, nêu cách xử lý khi môi trường đích thiếu UE; không đổi sản phẩm thành bản kế hoạch chỉ vì người viết chưa có engine.

## Quy trình

1. **Rút yêu cầu:** kết quả, người nhận, đầu vào, phạm vi được làm, điều giữ nguyên, dạng bàn giao và mức chi tiết. Khi sửa prompt, giữ yêu cầu hợp lệ; sửa mâu thuẫn, phần thiếu hoặc khó thực hiện.
2. **Đọc nguồn:** đọc file/ảnh người dùng chỉ định khi truy cập được. Phân biệt dữ kiện đã xác minh, giả định thiết kế và dữ liệu cần khảo sát. Nếu nguồn không truy cập được, nói rõ; chỉ hỏi nội dung đó khi thiết yếu, không nhận đã đọc.
3. **Lấp khoảng trống đúng chỗ:** chỉ hỏi những câu làm thay đổi căn bản mục tiêu. Dữ liệu agent đích có thể tự khảo sát thì viết thành bước khảo sát. Với giả định ít rủi ro, chọn mặc định rõ ràng. Không bịa đường dẫn, kích thước, API hoặc kết quả kiểm tra.
4. **Viết prompt theo hợp đồng đầu ra bên dưới.** Chọn độ dài theo công việc; yêu cầu ngắn không cần quy trình nhiều mục. Chi tiết phải giúp thực hiện hoặc kiểm chứng, không chỉ làm văn bản dài.
5. **Tự rà:** thử đọc như một agent chưa thấy cuộc trò chuyện. Có biết làm gì, được sửa gì, bắt đầu từ đâu, gặp thiếu dữ liệu xử lý thế nào và khi nào đạt không? Sửa xung đột trước khi bàn giao.

**Nếu viết prompt dựng map/level/môi trường game:** đọc [references/map-building.md](references/map-building.md). Những lĩnh vực khác không cần đọc file đó. Không chuyển dữ kiện trạm biển sâu hoặc một dự án cụ thể thành mặc định cho mọi nhiệm vụ.

## Hợp đồng đầu ra

Trả **một prompt sẵn dùng** trong một khối code hoặc file Markdown theo yêu cầu. Lời dẫn ngắn nếu cần; không trả dàn ý bắt người dùng tự ghép. Prompt gồm những phần có ích cho nhiệm vụ:

| Thành phần | Nội dung cần chốt |
|---|---|
| Mục tiêu và sản phẩm | Agent đích thực hiện việc gì; kết quả cụ thể cho ai |
| Bối cảnh và đầu vào | Dữ kiện thiết yếu từ nguồn; đầu vào sẽ cung cấp sau; giả định và điều chưa biết |
| Phạm vi | Được làm gì, phải giữ gì; thao tác ngoài phạm vi cần quyết định thêm |
| Yêu cầu cụ thể | Nội dung/chức năng, ưu tiên và cách xử lý xung đột |
| Cách thực hiện | Các bước và cổng kiểm tra cần thiết; công cụ chỉ định hoặc điều kiện xác minh công cụ |
| Bàn giao và nghiệm thu | Định dạng, tiêu chí quan sát/đo được, bằng chứng; cách báo chưa kiểm hoặc bị chặn |

Prompt riêng cho một task phải chứa quyết định cụ thể từ đầu vào, không còn các ô trống có thể điền ngay. Khi người dùng yêu cầu **template tái sử dụng**, dùng ô điền có tên rõ ràng và chỉ dẫn mặc định. Khi yêu cầu **prompt tạo prompt**, nêu rõ sản phẩm là prompt cho agent thứ ba, không phải thực thi công việc cuối.

Nội dung thiết yếu phải có ngay trong prompt; đường dẫn nguồn chỉ hỗ trợ tra cứu. Agent nhận việc thiếu quyền đọc nguồn phải yêu cầu tài liệu hoặc báo giới hạn, không đoán. Không đưa câu “như đã bàn”, “làm tương tự” thay cho yêu cầu quan trọng.

## Ví dụ gọi

`$writing-prompts Dựa vào các file prompt/map/map-1, viết prompt hoàn thiện phòng quan sát hiện có: đủ nội thất, đi lại được, giữ kiến trúc và không thêm gameplay.`

Kết quả là prompt giao việc hoàn thiện phòng, có khảo sát, thiết kế cụm nội thất, trình tự dựng và QA. Không dựng phòng trong lượt viết; không chỉ trả danh sách đề mục.

## Lỗi thường gặp

- **Lẫn viết với làm:** bắt đầu sửa project hoặc phân tích file chưa được gửi. Tách rõ tác vụ hiện tại và tác vụ tương lai.
- **Chi tiết giả:** tọa độ/API/nguồn không xác minh. Nêu dữ liệu cần đo hoặc tra ở bước thực hiện.
- **Prompt phình to:** sao chép mọi luật từ mẫu. Chỉ giữ điều kiện phục vụ nhiệm vụ đích.
- **Tuyên bố đạt trước kiểm tra:** tiêu chí và bảng nghiệm thu là yêu cầu tương lai; trạng thái thật do agent thực hiện điền theo bằng chứng.
