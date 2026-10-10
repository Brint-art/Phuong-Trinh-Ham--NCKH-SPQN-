# Hàm số — Nền tảng tự học phương trình hàm

Website tự học phương trình hàm dành cho học sinh THPT khá giỏi và đội tuyển Olympic.
Không thi trực tuyến, không chấm điểm. Lộ trình học: **Lý thuyết → Ví dụ → Bài tập → Lời giải → Hỏi AI**.

## Công nghệ

- **Frontend**: HTML + CSS + JavaScript thuần (thân thiện với người mới)
- **API AI**: Vercel Serverless Functions (thư mục `api/`, Node.js)
- **AI**: Mistral API (`ministral-14b-latest` mặc định)
- **Database**: Supabase PostgreSQL (đọc trực tiếp từ trình duyệt qua Supabase JS + Row Level Security)
- **Hosting**: Vercel

## Cấu trúc thư mục

```
ham-so-website/
├── index.html                  → cấu trúc trang
├── styles.css                  → giao diện + responsive
├── app.js                      → logic trang (lý thuyết, bài tập, AI) + nạp dữ liệu Supabase
├── data.js                     → dữ liệu tĩnh dự phòng (dùng khi Supabase chưa có dữ liệu)
├── supabase-config.js          → cấu hình URL + anon key Supabase
├── supabase/
│   ├── schema.sql              → bảng, cột bổ sung, RLS (chạy trong SQL Editor)
│   ├── schema-v2-roles.sql     → tài khoản + vai trò + hàng đợi kiểm duyệt (Giai đoạn 4)
│   └── examples.sql            → mẫu INSERT nạp chuyên đề/bài học/bài tập
├── api/
│   ├── generate-exercises.js   → AI tạo bộ bài tập
│   └── ask-solution.js         → hỏi AI về từng bước giải
├── vercel.json                 → cấu hình Vercel
└── package.json                → script dev
```

## Chạy trên máy

**Cách 1 — test AI tại chỗ, KHÔNG cần cài Node.js và KHÔNG cần đẩy lên Vercel (khuyến nghị khi viết luận văn/bảo vệ):**

```
powershell -ExecutionPolicy Bypass -File dev-server.ps1
```

Mở http://localhost:8899. Script này vừa phục vụ file tĩnh vừa **tự chạy hai endpoint AI** (`/api/ask-solution`, `/api/generate-exercises`) bằng cách gọi thẳng Mistral API — chỉ dùng PowerShell, không cần Node.js/Python/Vercel CLI.

- Key đọc từ biến môi trường `MISTRAL_API_KEY` hoặc file `.env.local` đặt cạnh script (xem mẫu trong `.env.example`).
- Chưa có key → AI vẫn trả về bộ bài mẫu / câu trả lời minh họa (không báo lỗi).
- Đổi cổng: `dev-server.ps1 -Port 5000`.
- Truyền key tạm thời mà không cần file: `dev-server.ps1 -MistralKey sk-...`.
- Đây là bản mô phỏng để test; code thật để deploy vẫn là `api/*.js` (script bỏ qua rate-limit).

**Cách 2 — mở file trực tiếp (chỉ xem giao diện):**

Mở `index.html` bằng trình duyệt, hoặc server tĩnh bất kỳ (Sublime Server, Live Server...). Server tĩnh không chạy được code trong `api/` nên khu AI sẽ báo không tìm thấy endpoint — muốn AI chạy khi đó thì điền `apiBase` trong `supabase-config.js` trỏ về bản đã deploy.

**Cách 3 — chạy đầy đủ bằng Node.js (dùng đúng code `api/*.js` như trên Vercel):**

Chỉ cần cài Node.js 18+ (nodejs.org), rồi trong thư mục dự án chạy:

```
node server.js
```

Mở http://localhost:3000 — AI hoạt động đầy đủ, không cần cài thêm gì (kể cả Vercel CLI). Muốn AI tạo bài thật, tạo file `.env.local`:

```
MISTRAL_API_KEY=sk-...
MISTRAL_MODEL=ministral-14b-latest
```

> Lưu ý chọn model: không phải model nào cũng dùng được — tùy gói của tài khoản Mistral. Với key free-tier đã kiểm tra thực tế ngày 26/09/2026, các model `mistral-small-*`, `mistral-medium-*`, `magistral-*` trả **429** còn `ministral-14b-latest`, `ministral-8b-latest`, `ministral-3b-latest`, `codestral-latest` trả **200**. Nếu AI báo 429, đổi `MISTRAL_MODEL` sang một model trong nhóm 200 (xem `GET /v1/models` bằng key để biết danh sách khả dụng).

**Cách 4 — chạy bằng Vercel CLI:**

```
npm i -g vercel
vercel dev
```

**Cách 5 — server tĩnh + AI từ bản đã deploy:**

Nếu đã deploy trang lên Vercel (xem mục dưới) nhưng vẫn muốn xem giao diện bằng server tĩnh: điền `apiBase` trong `supabase-config.js` trỏ về URL bản deploy — các nút AI sẽ gọi API của bản deploy.

## Deploy lên Vercel

**Cách không cần Vercel CLI — deploy qua GitHub (khuyến nghị):**

1. Tạo repository trên GitHub rồi đẩy code trong thư mục `ham-so-website` lên (`.gitignore` đã loại trừ `.env.local` và `.vercel`).
2. Vào vercel.com → **Add New → Project** → chọn repository vừa tạo.
3. Framework Preset: **Other**; không cần cấu hình build.
4. **Environment Variables**: thêm `MISTRAL_API_KEY` (và `MISTRAL_MODEL` tùy chọn).
5. Nhấn **Deploy** — từ nay mỗi lần `git push`, Vercel tự deploy lại.

**Cách dùng Vercel CLI:**

1. Đăng ký tài khoản tại vercel.com, cài CLI và đăng nhập: `vercel login`.
2. Trong thư mục dự án chạy: `vercel` (theo hướng dẫn), rồi `vercel --prod`.
3. Thêm biến môi trường trên dashboard Vercel: **Project → Settings → Environment Variables**:
   - `MISTRAL_API_KEY`
   - `MISTRAL_MODEL` (tùy chọn)
4. Deploy lại (mỗi lần thay đổi env cần redeploy).

> API key chỉ nằm ở phía máy chủ (Vercel Environment Variables) — không bao giờ xuất hiện trong `index.html` hay `app.js`.

## Kết nối Supabase (Giai đoạn 2)

Website đọc dữ liệu trực tiếp từ Supabase bằng Supabase JS client + Row Level Security. Khi Supabase chưa được cấu hình — hoặc mới chỉ có chuyên đề mà chưa có bài học/bài tập nào — website tự dùng dữ liệu tĩnh trong `data.js`. Supabase chỉ "kích hoạt" khi đã có ít nhất một bài học hoặc bài tập; từ lúc đó, bảng nào có dữ liệu thì bảng đó chuyển sang dùng Supabase.

### Thiết lập lần đầu (Thứ tự chạy SQL)

1. Tạo dự án tại [supabase.com](https://supabase.com) → **New project**.
2. Mở **SQL Editor** → chạy lần lượt các file SQL sau theo **đúng thứ tự**:
   - **Bước 1**: `supabase/schema-v2-roles.sql` — tạo enum `user_role`, bảng `profiles`, và hàm `app_is_admin()`. Hàm `app_is_admin()` được chuẩn hóa làm nguồn chân lý duy nhất (source of truth) để kiểm tra quyền quản trị cho mọi policies và logic bảo mật. Hàm được gán `set search_path = ''` (hoặc public) để bảo vệ các hàm `SECURITY DEFINER`.
   - **Bước 2**: `supabase/schema-v3.sql` — cập nhật cấu trúc bảng (`is_published`, `foundational_knowledge`...), sửa logic kiểm tra admin để tái sử dụng `app_is_admin()`, và cập nhật các chính sách RLS.
   - **Bước 3**: `supabase/content-import-v3.sql` — nạp nội dung lý thuyết 3 khung và bài tập đặc trưng. File dùng cấu trúc `ON CONFLICT (slug)` nên có thể chạy lại nhiều lần (idempotent) mà không sợ sinh bản sao. Không còn sử dụng `examples.sql` hay JSON.

3. Vào **Project Settings → API**, sao chép:
   - `Project URL` (dạng `https://xxxx.supabase.co`)
   - khóa `anon public` (bắt đầu bằng `eyJ...`)
4. Dán vào file `supabase-config.js`:

   ```js
   window.SUPABASE_CONFIG = {
     url: 'https://xxxx.supabase.co',
     anonKey: 'eyJ...'
   };
   ```

5. Chạy lại website — dữ liệu sẽ tự nạp từ Supabase.

Lưu ý khi nạp dữ liệu:
- Dữ liệu hiện tại chỉ viết bằng Markdown (công thức LaTeX `$ ... $`).
- Bài học chỉ hiển thị khi `is_published = true`.
- Bài tập chỉ hiển thị khi `is_published = true`.
- Admin có thể tạo bài viết/bài tập qua trang quản trị, hoặc chạy lại SQL.

### Bảo mật

- `anon key` trong `supabase-config.js` là công khai — an toàn vì Row Level Security chỉ cho đọc nội dung đã xuất bản.
- `service_role key` KHÔNG bao giờ đặt vào file chạy trên trình duyệt; dự án này cũng **không cần** tới nó: mọi thao tác ghi đều gửi từ trình duyệt bằng token của chính tài khoản đã đăng nhập, RLS tự quyết định vai trò được làm gì.

## Tài khoản và vai trò (Giai đoạn 4)

Dự án dùng **2 vai trò**, lưu trong `public.profiles.role`:

| Vai trò | Được làm gì |
|---|---|
| `student` (Học sinh) | Đọc nội dung đã xuất bản; tạo bài bằng AI và lưu vào **“Bộ bài của tôi”** (`status = 'draft'`, chỉ mình họ và quản trị viên thấy); hỏi AI. |
| `admin` (Quản trị = giáo viên phụ trách) | Toàn quyền `student` + **trang Quản trị**: duyệt / từ chối / xuất bản bài trong hàng đợi, sửa và ẩn/hiện bài học, xóa nội dung, xem log AI, xem danh sách tài khoản (kèm email) và đổi vai trò (`admin_set_user_role`). |

> Kế hoạch ban đầu đề ra 3 vai trò (thêm `editor` tách khỏi `admin`). Khi làm thật, phần hơn nhau giữa editor và admin chỉ còn “xóa nội dung + xem email + phân quyền” — không đủ để giữ một tầng trung gian, nên đã gộp lại. Nhãn `editor` **vẫn còn trong enum** `user_role` (PostgreSQL không cho xóa giá trị enum đã tạo) nhưng không còn chính sách nào dùng tới; script migration tự đưa hồ sơ `editor` cũ về `admin`.

Bài AI **không** tự xuất bản: luôn rơi vào hàng đợi để người lớn duyệt — đây là điểm then chốt của hướng nghiên cứu sư phạm (AI hỗ trợ tự luyện, con người kiểm duyệt nội dung). Hệ quả của việc còn một vai trò quản trị duy nhất: admin **có thể tự duyệt bài do chính mình tạo bằng AI** (không có quy tắc “người duyệt ≠ người tạo”). Nếu sau này có nhiều giáo viên cùng duyệt, phải tách lại quyền này.

### Bật tài khoản trên Supabase

1. Mở **SQL Editor** → dán toàn bộ `supabase/schema-v2-roles.sql` → **Run**.
   > ⚠️ Script này **xóa toàn bộ chính sách RLS hiện có trên các bảng `public.*` rồi tạo lại** theo mô hình vai trò (có `DROP POLICY` trong một khối `DO`). Nó an toàn với dữ liệu (không xóa bảng, không xóa dòng) và an toàn chạy lại nhiều lần, nhưng nếu bạn đã tự viết policy riêng thì hãy sao lưu trước: `select * from pg_policies where schemaname = 'public';`
2. Vào **Authentication → Providers → Email**: hoặc bật **Confirm email** kèm cấu hình SMTP (Supabase có SMTP mặc định giới hạn vài chục mail/ngày), hoặc **tắt** “Confirm email” để đăng ký là đăng nhập được ngay (tiện khi demo/bảo vệ).
   Nếu tắt confirm email mà tài khoản đăng ký trước đó vẫn ở trạng thái chưa xác minh, vào **Authentication → Users** bấm *Confirm user* cho tài khoản muốn dùng.
3. **Nâng tài khoản đầu tiên lên Quản trị** (bắt buộc làm thủ công vì trang web không cho ai đổi vai trò của chính mình): tạo tài khoản trên trang web, rồi chạy trong SQL Editor

   ```sql
   update public.profiles set role = 'admin'
   where id = (select id from auth.users where email = 'email-cua-ban@vidu.com');
   ```

   Sau đó tải lại trang — mục **Quản trị** sẽ xuất hiện trên header.
4. Từ tài khoản admin thứ hai trở đi có thể nâng/hạ vai trò ngay trong trang **Quản trị → Người dùng** (chỉ nhận `student` hoặc `admin`). Khi đăng xuất / đổi máy, mọi quyền lại dựa trên `profiles.role` — không có “quyền admin” cứng trong code.

### Luồng dữ liệu sau khi có tài khoản

- **Học sinh bấm “Tạo bộ bài”** → `api/generate-exercises.js` trả JSON → trình duyệt ghi vào `exercises` (`status = 'draft'`, `created_by = auth.uid()`, `is_ai_generated = true`), từng bước ghi vào `exercise_solutions`, thông tin request ghi vào `ai_generation_requests` để quản trị viên biết bài nào do AI tạo.
- **Quản trị vào trang Quản trị** → hàng đợi là `select` các bài `status in ('needs_review','draft')` → *Duyệt & xuất bản* (`published`) / *Từ chối* (`rejected`) / *Xóa*.
- **Học sinh** thấy bài đã xuất bản trong *Kho bài tập*; bài draft của mình thấy ở *Bộ bài của tôi*.

> Enum `exercise_status` ban đầu chỉ có `draft/published/approved`; `schema-v2-roles.sql` bổ sung `needs_review` và `rejected`. Nếu database chưa chạy migration, frontend bắt lỗi `22P02` và tự hỏi lại chỉ `status = 'draft'`, nên trang Quản trị vẫn chạy được.

## Kế hoạch các giai đoạn tiếp theo

- **Giai đoạn 2 — Supabase**: ✅ website đọc bài học/bài tập từ database (chạy `supabase/schema.sql` để bổ sung cột + RLS); ✅ nạp bài học/bài tập thật (15 bài đã xuất bản); ✅ lưu bài AI vào `exercises` + `ai_generation_requests`, câu hỏi vào `solution_questions`.
- **Giai đoạn 3 — AI**: ✅ sinh bài thật + hỏi AI theo bước (model `ministral-14b-latest`); ✅ kiểm tra JSON, sửa escape LaTeX bị JSON “ăn”, giới hạn 429; ⏳ log token/chi phí.
- **Giai đoạn 4 — Hoàn thiện**: ✅ đăng nhập/đăng ký + 2 vai trò Học sinh/Quản trị + hàng đợi kiểm duyệt bài AI (xem mục “Tài khoản và vai trò”); ⏳ bài yêu thích; ⏳ in/tải PDF; ⏳ tìm kiếm.
- **Giai đoạn 5 — Đợt chỉnh sửa lớn về trải nghiệm người dùng**: ⏳ không thêm tính năng mới, chỉ xử lý 25 lỗi UX đã đo trực tiếp (vỡ bố cục trên điện thoại khi mở lời giải, không điều hướng được bằng bàn phím, form Hỏi AI gửi trùng, lộ thuật ngữ kỹ thuật cho học sinh, modal/chương trình hỗ trợ, tương phản màu…). Danh sách đầy đủ kèm số đo và tiêu chí nghiệm thu nằm ở **mục 14** của `ke-hoach-du-an-website-ham-so.md`.

## Ghi chú bảo mật

- Không commit `.env.local` vào Git (đã có `.gitignore`).
- Thêm rate limit cho API tạo bài (đã có bộ đếm đơn giản trong `api/*.js`).
- Nội dung AI chỉ mang tính tham khảo — cần người có chuyên môn kiểm duyệt trước khi công bố chính thức.
