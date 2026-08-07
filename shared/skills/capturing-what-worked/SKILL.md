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

## Bước 1: Chọn một trong ba chỗ ghi

Hai câu hỏi, theo đúng thứ tự này.

### Câu 1: cách làm này có đúng ở một dự án khác không?

**CÓ** → skill chung: `~/dotagents/shared/skills/<tên>/SKILL.md`, rồi chạy
`~/dotagents/install.sh`. Từ đó mọi dự án trên mọi máy đều có.

Ví dụ: "cách bắt lỗi hydration mismatch của React", "cách dò rò rỉ bộ nhớ trong test Node".

**Không chắc → coi như KHÔNG.** Nâng lên skill chung sau, khi gặp lại lần thứ hai ở dự án
khác — lần thứ hai đó mới là bằng chứng nó dùng chung được. Đẩy vội là biến quy ước riêng
của một dự án thành luật cho mọi dự án.

### Câu 2: đây là QUY TRÌNH agent phải tự làm theo, hay là KIẾN THỨC để tra?

Chỉ hỏi khi câu 1 trả lời KHÔNG.

**Quy trình** — có các bước phải tuân theo, và tuân sai thì hỏng → **skill riêng của dự án**:
`<dự án>/.claude/skills/<tên>/SKILL.md`, có frontmatter `name` + `description` như mọi skill khác.

Ví dụ: "trước khi sửa schema phải chạy `npm run db:check` rồi mới generate migration",
"deploy staging phải qua `scripts/deploy.sh`, gọi thẳng `vercel` là hỏng biến môi trường".

Chọn skill vì agent **tự thấy nó** trong danh sách skill nhờ dòng `description` — không cần ai
nhắc mới biết là có.

**Kiến thức** — một sự thật cần biết, không có bước nào phải làm theo → `docs/recipes/<slug>.md`.

Ví dụ: "cột `status` trong bảng `orders` còn hai giá trị cũ từ 2023, đừng tưởng chỉ có ba",
"CI chậm 8 phút là do bước cache, không phải do test".

Chọn recipe vì đây là thứ để **tra khi cần**, biến nó thành skill chỉ làm rác danh sách skill.

**Không chắc quy trình hay kiến thức → chọn skill.** Skill thì agent tự thấy; recipe thì phải
chủ động đi tìm mới ra.

### Bảng tóm

| Chỗ | Khi nào | Agent tìm ra bằng cách nào |
|---|---|---|
| `~/dotagents/shared/skills/` | Đúng ở mọi dự án | Tự thấy, mọi máy mọi dự án |
| `<dự án>/.claude/skills/` | Quy trình riêng của dự án này | Tự thấy khi mở dự án này |
| `<dự án>/docs/recipes/` | Kiến thức riêng của dự án này | Phải chủ động `ls` thư mục |

Hai chỗ đầu đi theo git của chính dự án hoặc của dotagents, nên đồng đội clone về là có sẵn.

## Bước 2: Tìm file đã có trước khi viết mới

```bash
ls docs/recipes/ .claude/skills/ 2>/dev/null
grep -ril "<từ khoá>" docs/recipes/ .claude/skills/ ~/dotagents/shared/skills/ 2>/dev/null
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
| `docs/recipes/` + `.claude/skills/` ← skill này | Lần sau gặp lại thì làm thế nào | Việc sau |

Summary kể lại **một lần**. Recipe dạy cho **mọi lần sau**. Đừng nhét recipe vào summary —
summary viết xong là hết đọc lại, còn recipe phải tra được.

## Bước 5: Nói cho người dùng biết

Ghi xong thì báo một dòng, kèm đường dẫn. Đừng lặng lẽ đẻ file trong repo của người ta.

Xét thấy **không** đáng ghi thì cũng không cần nói gì — im lặng đi tiếp.
