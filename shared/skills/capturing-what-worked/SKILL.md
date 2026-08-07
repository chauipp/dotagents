---
name: capturing-what-worked
description: Dùng ngay sau khi một task đã làm xong VÀ đã kiểm chứng là đúng, để cân nhắc ghi lại cách làm cho lần sau. Chỉ ghi khi cách làm đúng KHÔNG phải là cách hiển nhiên — mục đích là chặn lần sau đi lại đúng cái ngõ cụt vừa đi.
---

# Ghi lại cách làm đúng

## Vấn đề nó giải

Bạn vừa mất một giờ mò ra cách đúng. Ba tuần sau gặp lại đúng loại việc đó, phiên làm việc
mới không có ký ức gì — nó lại đi đúng cái ngõ cụt cũ, lại mất một giờ, và lần này có thể
dừng ở chỗ sai mà tưởng là đúng.

Thứ đáng cứu **không phải cách làm đúng**. Cách làm đúng, đọc code là suy ra được. Thứ đáng
cứu là **cái bẫy** — lý do cách hiển nhiên lại sai.

**Thông báo khi bắt đầu:** "Tôi dùng skill capturing-what-worked để xem việc này có đáng ghi lại không."

## Cổng chặn — hầu hết task KHÔNG đáng ghi

Ghi bừa thì ba tháng sau có ba chục file rác, không ai đọc, và những file thật sự quý bị chôn
trong đó. Nên phải qua cổng.

**Chỉ ghi khi có ít nhất một điều sau đúng:**

- Cách làm đầu tiên tôi chọn đã **sai**, và phải quay lại làm cách khác
- Phải đọc từ ba file trở lên hoặc phải tra tài liệu ngoài mới hiểu được cách làm
- Có một **cái bẫy im lặng**: làm sai mà không có lỗi, không có test đỏ, chỉ sai âm thầm
- Có một quy ước riêng của dự án này mà nhìn code không tự suy ra được

**Không ghi khi:**

- Làm đúng ngay từ lần đầu bằng cách hiển nhiên
- Chỉ là kiến thức phổ thông về framework, tra Google ra ngay
- Chỉ đúng một lần này, không lặp lại (sửa một typo, đổi một con số)
- Đã có file ghi rồi — lúc đó **sửa file cũ**, không đẻ file mới

## Bước 1: Xác định phạm vi — quyết định chỗ ghi

Tự hỏi: *cách làm này có đúng ở một dự án khác không?*

**KHÔNG — chỉ đúng trong repo này** → ghi thành `docs/recipes/<slug>.md` ngay trong repo đó.

Ví dụ: "migration trong dự án này phải chạy qua script bọc riêng chứ không gọi thẳng",
"component trong `admin/` bắt buộc đăng ký ở registry, quên là im lặng không render".

Để trong repo vì: đi cùng code, review được qua PR, ai clone về cũng có, và khi code đổi thì
sửa cùng một lần.

**CÓ — đúng ở mọi dự án** → viết thành skill trong `~/dotagents/shared/skills/`, rồi
`~/dotagents/install.sh`.

Ví dụ: "cách bắt lỗi hydration mismatch của React", "cách dò rò rỉ bộ nhớ trong test Node".

**Không chắc → cứ để trong repo.** Nâng lên thành skill sau, khi gặp lại lần thứ hai ở dự án
khác. Lần thứ hai đó mới là bằng chứng nó dùng chung được. Đẩy vội lên thành skill là biến
một quy ước riêng thành luật chung cho mọi dự án.

## Bước 2: Tìm file đã có trước khi viết mới

```bash
ls docs/recipes/ 2>/dev/null
grep -ril "<từ khoá>" docs/recipes/ ~/dotagents/shared/skills/ 2>/dev/null
```

Có file gần đúng thì **sửa nó**. Hai file cùng chủ đề mà lệch nhau còn tệ hơn không có file nào.

## Bước 3: Viết — đúng bốn mục, ngắn

```markdown
# <Việc gì>

## Khi nào gặp lại
<Dấu hiệu nhận ra đúng tình huống này. Viết sao cho lần sau ĐỌC LƯỚT là nhận ra.>

## Cách làm đúng
<Các bước. Có lệnh thì dán lệnh. Có file thì ghi đường dẫn kèm số dòng.>

## Cái bẫy
<PHẦN QUAN TRỌNG NHẤT. Cách hiển nhiên là gì, vì sao nó sai, và sai thì
biểu hiện ra sao. Không có mục này thì cả file gần như vô dụng.>

## Kiểm thế nào là đúng
<Lệnh cụ thể, hoặc thứ phải quan sát thấy. Không viết "chạy thử xem".>
```

Nhắm dưới 40 dòng. Dài hơn thường là đang chép lại code chứ không phải ghi lại bài học.

## Bước 4: Ghi ngay, đừng dồn

Viết **ngay khi vừa xác nhận task đúng**, lúc còn nhớ mình đã sai ở đâu. Dồn tới cuối phiên
thì cái bẫy — thứ đáng giá nhất — là cái bị quên đầu tiên.

## Phân biệt với những thứ đang có

| Tài liệu | Trả lời câu hỏi | Nhìn về |
|---|---|---|
| `docs/superpowers/plans/` | Định làm gì | Trước khi làm |
| `docs/superpowers/summaries/` | Cuối cùng đã làm ra cái gì | Việc cụ thể đó |
| `docs/recipes/` ← skill này | Lần sau gặp lại thì làm thế nào | Việc sau |

Summary kể lại **một lần**. Recipe dạy cho **mọi lần sau**. Đừng nhét recipe vào summary —
summary viết xong là hết đọc lại, còn recipe phải tra được.

## Bước 5: Nói cho người dùng biết

Ghi xong thì báo một dòng, kèm đường dẫn. Đừng lặng lẽ đẻ file trong repo của người ta.

Xét thấy **không** đáng ghi thì cũng không cần nói gì — im lặng đi tiếp.
