---
name: verifying-ui-with-playwright
description: Dùng khi một task có đụng tới thứ người dùng nhìn thấy trên trình duyệt — component, trang, CSS, form, luồng bấm — TRƯỚC khi báo là xong. Bắt mở trình duyệt thật bằng Playwright và xem tận mắt, thay vì suy ra từ việc code đã sửa đúng.
---

# Kiểm UI bằng Playwright trước khi báo xong

## Luật sắt

```
CODE ĐÚNG KHÔNG CHỨNG MINH ĐƯỢC UI ĐÚNG.
Chưa mở trình duyệt xem thì chưa được nói là xong.
```

Đây là bản chuyên cho UI của `verification-before-completion`. Test unit xanh, build sạch,
lint sạch — không cái nào chứng minh cái nút bấm được, cái modal đóng được, hay chữ không
bị tràn ra ngoài khung.

**Thông báo khi bắt đầu:** "Tôi dùng skill verifying-ui-with-playwright để kiểm giao diện."

## Khi nào bắt buộc chạy

Task có đụng vào bất kỳ thứ nào dưới đây thì bắt buộc:

- File component, template, trang
- CSS / style / class Tailwind
- Form, validation phía client, thông báo lỗi
- Luồng tương tác: bấm, kéo thả, mở/đóng, điều hướng
- State hiển thị: loading, empty, error
- Bất cứ chuỗi văn bản nào người dùng đọc được

**Không bắt buộc khi:** chỉ sửa backend/API không đổi hình dạng dữ liệu, sửa script build,
sửa tài liệu, sửa test.

## Các bước

### 1. Dựng app lên

Chạy dev server. Ghi lại URL và **cổng thật** — đừng đoán là 3000 hay 5173.

Server chạy nền, đừng để nó chặn phiên làm việc.

### 2. Mở trang bằng Playwright

Dùng công cụ Playwright có sẵn trong môi trường:

| Việc | Công cụ |
|---|---|
| Mở trang | `browser_navigate` |
| Đọc cấu trúc trang | `browser_snapshot` |
| Bấm / gõ / chọn | `browser_click`, `browser_type`, `browser_select_option`, `browser_fill_form` |
| Chờ một thứ hiện ra | `browser_wait_for` |
| Đọc lỗi console | `browser_console_messages` |
| Xem request thất bại | `browser_network_requests` |
| Đổi kích thước màn hình | `browser_resize` |
| Chụp ảnh | `browser_take_screenshot` |

Không có Playwright MCP thì viết một file `.spec.ts` rồi chạy `npx playwright test`. Máy chưa
cài thì `npx playwright install chromium`.

**Ưu tiên `browser_snapshot` hơn `browser_take_screenshot`.** Snapshot là cây accessibility ở
dạng văn bản — đọc được chính xác, tìm được phần tử theo tên. Ảnh chụp chỉ để xác nhận bố cục
và cho người dùng xem.

### 3. Đi đúng luồng người dùng sẽ đi

Không dừng ở "trang có tải được". Diễn lại đúng việc mà thay đổi này phục vụ.

Sửa form thì: bỏ trống rồi submit (phải hiện lỗi) → điền sai kiểu (phải hiện lỗi) → điền đúng
(phải thành công). Sửa modal thì: mở → bấm ra ngoài → bấm Esc → bấm nút đóng.

### 4. Bốn thứ luôn phải kiểm

1. **Console sạch.** `browser_console_messages`. Có `error` là chưa xong, kể cả trang trông vẫn ổn.
2. **Network sạch.** `browser_network_requests`. Không có 4xx/5xx nào ngoài dự tính.
3. **Hẹp màn hình.** `browser_resize` về 375×667. Rất nhiều lỗi tràn chữ và vỡ layout chỉ hiện ở đây.
4. **Trạng thái rỗng và trạng thái lỗi**, nếu thay đổi có liên quan. Chúng gần như luôn bị bỏ quên.

### 5. Báo cáo kèm bằng chứng

Nói rõ đã đi những bước nào, và dán ảnh chụp hoặc trích snapshot. Không được viết "đã kiểm,
chạy tốt" trống không.

## Những cái cớ hay gặp — không cái nào được chấp nhận

| Cớ | Vì sao không |
|---|---|
| "Sửa có mỗi CSS" | CSS là thứ vỡ nhiều nhất, và unit test không bao giờ bắt được |
| "Test unit xanh hết rồi" | Test unit không dựng trình duyệt, không có layout engine |
| "Code y hệt chỗ kia đang chạy" | Chỗ kia có context khác: CSS cha, state khác, dữ liệu khác |
| "Dựng server lâu quá" | Lâu hơn nhiều so với việc người dùng phát hiện lỗi rồi báo lại |
| "Người dùng bảo gấp" | Gấp là lý do để không phải làm lại lần hai |
| "Nhìn đoạn diff là biết đúng rồi" | Nhìn diff không chỉ ra được z-index sai, overflow, hay lỗi console |

## Khi không dựng được app

Có lúc thật sự không dựng được: thiếu biến môi trường, thiếu database, sandbox chặn mạng.

Lúc đó **nói thẳng ra**:

> Chưa kiểm được UI vì `<lý do cụ thể>`. Thay đổi nằm ở `<file:dòng>`. Nhờ bạn tự xem giúp
> `<đúng những bước nào>`.

Đó là báo cáo trung thực. Còn viết "xong rồi" là nói dối.
