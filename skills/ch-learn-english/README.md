# ch-learn-english

Học tiếng Anh trong các chat bạn chọn. Bật bằng `$ch-learn-english on`, tắt bằng `$ch-learn-english off`; các từ, cụm và cấu trúc bạn xác nhận đã biết được lưu lại. Tắt chế độ vẫn giữ dữ liệu học.

## Dữ liệu cá nhân và mã nguồn skill

Mỗi máy cài skill bằng `./install.sh --codex` từ repo dotagents. Dữ liệu học mặc định ở `~/.local/state/dotagents/ch-learn-english/knowledge.json`. File này lưu các mục đã biết, chưa phải nhật ký toàn bộ bài học hay hệ thống ôn tập.

Để dùng chung giữa các máy, dùng một Git repository **public hoặc private**, theo lựa chọn của bạn. Có thể dùng repo riêng hoặc một thư mục profile trong repo hiện có. Skill hỗ trợ cả hai mức truy cập. Không lưu token hay SSH key trong profile.

## Thiết lập máy đầu tiên

Tạo repo public/private trên dịch vụ Git bạn dùng, clone vào một thư mục riêng, ví dụ `~/dotagents-learning/ch-learn-english`. Hoặc chọn thư mục profile trong repo đang có. Dùng đường dẫn thực tế của bạn khi chạy các lệnh. Đảm bảo repo có nhánh và upstream; với repo trống, cần commit/push đầu tiên và thiết lập upstream trước khi gọi sync.

Tạo `.gitignore` trong profile với nội dung sau để chỉ theo dõi các file cần thiết:

```gitignore
/*
!/.gitignore
!/README.md
!/knowledge.json
```

Các file `sessions/`, `turns/`, `.lock` và file tạm vẫn nằm trong thư mục này nhưng chỉ ở local từng máy. Ignore không gỡ file đã được track: kiểm tra `git ls-files` trước khi commit.

Đóng hoặc tạm dừng các chat đang ghi dữ liệu học. Nếu profile chưa có knowledge.json, sao chép file hiện tại vào đó:

```bash
cp -n "$HOME/.local/state/dotagents/ch-learn-english/knowledge.json" \
  "$HOME/dotagents-learning/ch-learn-english/knowledge.json"
```

Giữ bản gốc làm backup. Nếu đích đã có dữ liệu, so sánh trước khi chuyển; không ghi đè. Nếu chưa từng lưu mục nào, helper có thể tạo file sau lần học đầu tiên.

Đặt biến môi trường trước khi mở Codex:

```bash
export DOTAGENTS_ENGLISH_STATE_DIR="$HOME/dotagents-learning/ch-learn-english"
python3 "$HOME/.codex/skills/ch-learn-english/scripts/english_state.py" list
```

Biến phải có mặt cả trong môi trường Codex/hook lẫn helper. Export ở terminal không cập nhật ứng dụng desktop đang mở; khởi động Codex từ môi trường đã cấu hình và kiểm tra lại bằng helper. Trạng thái ON/OFF cũ không được sao chép: bật lại cho chat bạn muốn khi chuyển thư mục.

Commit `.gitignore` và knowledge.json, rồi push đầu tiên lên nhánh được chọn và thiết lập upstream, chẳng hạn `git push -u origin main` nếu nhánh thực tế là main. Dùng identity Git của bạn; kiểm tra đầy đủ staged diff trước commit/push.

## Học và đồng bộ

Khi bạn nói đã biết một mục, skill lưu ngay vào bản local. Không tự commit hoặc chạy mạng sau mỗi câu chat.

Mục đã biết sẽ xuất hiện như văn bản bình thường. Skill không thêm chữ `known`, `(known)` hoặc `đã biết` sau mục đó.

```text
$ch-learn-english sync
$ch-learn-english sync --push
```

Đây là lệnh gọi skill để **agent thực hiện Git**, không phải subcommand của english_state.py. `sync` fetch, commit thay đổi knowledge.json và merge upstream vào local. `sync --push` làm cùng quy trình rồi push lên upstream đã kiểm tra. Hai lệnh giữ nguyên chế độ ngôn ngữ của chat.

Trước khi đổi máy, dùng `sync --push`; khi bắt đầu ở máy còn lại, dùng `sync`. Bạn vẫn học được offline; nếu fetch thất bại, dữ liệu local được giữ để đồng bộ sau. Trong lúc sync, tạm dừng các chat khác trên cùng máy đang cập nhật profile để tránh Git và helper cùng sửa file.

## Máy mới

Clone cùng repo public/private vào thư mục bạn chọn, cài skill, cấu hình DOTAGENTS_ENGLISH_STATE_DIR trỏ tới thư mục profile và khởi động Codex trong môi trường đó. Kiểm tra helper `list`: các mục đã push phải xuất hiện. Bật học cho từng chat bằng `on`; không đồng bộ trạng thái chat.

## Profile trong repo dotagents

Profile học hiện được lưu tại `learning/ch-learn-english/knowledge.json` trong repo này, ngoài thư mục mã nguồn skill. `.gitignore` trong profile giữ session, lock và file tạm ở local. Các mục đã biết hiện có được sao chép từ từ điển local; file gốc vẫn được giữ lại.

Sau khi clone repo trên mỗi máy, từ root repo chạy:

```bash
export DOTAGENTS_ENGLISH_STATE_DIR="$PWD/learning/ch-learn-english"
python3 "$HOME/.codex/skills/ch-learn-english/scripts/english_state.py" list
```

Khởi động Codex trong môi trường có biến này để helper và hook ghi trực tiếp vào profile trong repo. Việc push một bản knowledge.json không tự đổi thư mục dữ liệu của ứng dụng đang chạy: trước khi cấu hình, ứng dụng vẫn ghi vào vị trí mặc định. Nếu đã học thêm ở vị trí mặc định sau lần sao chép, đối chiếu dữ liệu trước khi chuyển.

Git merge áp dụng cho cả nhánh của repo dùng chung, có thể mang theo cập nhật mã nguồn. Skill chỉ stage/commit knowledge.json trong profile. Nếu nhánh còn commit mã nguồn chưa push, riêng sync --push sẽ báo để bạn quyết định; nó không tự coi lệnh đồng bộ dữ liệu là quyền push mọi thay đổi mã nguồn.

## Khi Git báo conflict

Máy A thêm 5 từ và máy B thêm 10 từ khác nhau vẫn có thể conflict vì cùng sửa knowledge.json. Git merge theo văn bản; skill chưa có semantic merge.

Nếu merge báo conflict, skill dừng và giữ local commit. Dùng `git status`, sửa knowledge.json để giữ các mục bạn muốn từ cả hai phía, xóa conflict markers, rồi kiểm tra `python3 <đường-dẫn-skill>/scripts/english_state.py list`. Sau khi kiểm tra identity và staged diff, stage knowledge.json và chạy `git merge --continue`; sau đó gọi lại sync --push. Đừng dùng helper learn/forget trên file còn conflict: helper sẽ báo JSON không hợp lệ.

Nếu push bị từ chối vì máy kia vừa push, sync lại để lấy thay đổi mới rồi thử push. Không force-push. Một lần lưu local thành công chưa có nghĩa dữ liệu đã lên remote.
