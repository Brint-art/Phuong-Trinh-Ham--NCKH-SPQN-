# Hàm số — Nền tảng tự học phương trình hàm

Website tự học phương trình hàm dành cho học sinh THPT khá giỏi và đội tuyển Olympic.
Không thi trực tuyến, không chấm điểm. Lộ trình học: **Lý thuyết → Ví dụ → Bài tập → Lời giải → Hỏi AI**.

## Công nghệ

- **Frontend**: HTML + CSS + JavaScript thuần (thân thiện với người mới)
- **API AI**: Vercel Serverless Functions (thư mục `api/`, Node.js)
- **AI**: Mistral API (`mistral-small-2603` mặc định)
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
│   └── examples.sql            → mẫu INSERT nạp chuyên đề/bài học/bài tập
├── api/
│   ├── generate-exercises.js   → AI tạo bộ bài tập
│   └── ask-solution.js         → hỏi AI về từng bước giải
├── vercel.json                 → cấu hình Vercel
└── package.json                → script dev
```

## Chạy trên máy

**Cách 1 — server tĩnh (xem giao diện + dữ liệu):**

Mở `index.html` bằng trình duyệt, hoặc chạy server tĩnh bất kỳ (Sublime Server, Live Server...). Lưu ý: server tĩnh không chạy được code trong `api/` nên khu AI sẽ trả về bộ bài mẫu.

**Cách 2 — chạy đầy đủ cả API AI, không cần Vercel CLI (khuyến nghị):**

Chỉ cần cài Node.js 18+ (nodejs.org), rồi trong thư mục dự án chạy:

```
node server.js
```

Mở http://localhost:3000 — AI hoạt động đầy đủ, không cần cài thêm gì (kể cả Vercel CLI). Muốn AI tạo bài thật, tạo file `.env.local`:

```
MISTRAL_API_KEY=sk-...
MISTRAL_MODEL=mistral-small-2603
```

**Cách 3 — chạy bằng Vercel CLI (như trước):**

```
npm i -g vercel
vercel dev
```

**Cách 4 — server tĩnh + AI từ bản đã deploy:**

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

### Thiết lập lần đầu

1. Tạo dự án tại [supabase.com](https://supabase.com) → **New project**.
2. Mở **SQL Editor** → dán nội dung file `supabase/schema.sql` → **Run**. File này an toàn chạy lại nhiều lần; nó bổ sung các cột còn thiếu vào bảng đã có sẵn.
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

### Nạp nội dung bài học

Mở file `supabase/examples.sql` — bên trong có mẫu INSERT cho chuyên đề, bài học (kèm `sections` JSON), bài tập và lời giải theo bước. Sửa nội dung rồi chạy trong SQL Editor (hoặc nhập bằng Table Editor).

Lưu ý khi nạp dữ liệu:
- Bài học chỉ hiển thị khi `is_published = true`.
- Bài tập chỉ hiển thị khi `status = 'published'`.
- `sections` là JSON đúng cấu trúc `data.js`: mảng gồm `{ "type", "title", "body" }` với `type` là `definition | theorem | technique | example`.
- Công thức toán viết bằng LaTeX `$...$` như trong `data.js`.
- Mỗi dòng của `TOPICS`, `LESSONS`, `EXERCISES` nên điền `slug` (không dấu, không khoảng trắng) để website dùng làm id nội bộ; nếu bỏ trống, website tự dùng uuid.

### Bảo mật

- `anon key` trong `supabase-config.js` là công khai — an toàn vì Row Level Security chỉ cho đọc nội dung đã xuất bản.
- `service_role key` KHÔNG bao giờ đặt vào file chạy trên trình duyệt; sau này chỉ dùng trong các API function phía máy chủ (`api/*.js`).

## Kế hoạch các giai đoạn tiếp theo

- **Giai đoạn 2 — Supabase**: ✅ website đọc bài học/bài tập từ database (chạy `supabase/schema.sql` để bổ sung cột + RLS); ⏳ nạp bài học/bài tập thật; ⏳ lưu bài AI vào `ai_generation_requests`, câu hỏi vào `solution_questions`.
- **Giai đoạn 3 — AI**: bật sinh bài thật, hỏi AI theo bước, log token/chi phí, kiểm tra JSON + trạng thái duyệt.
- **Giai đoạn 4 — Hoàn thiện**: đăng nhập, bộ bài yêu thích, in/tải PDF, tìm kiếm.

## Ghi chú bảo mật

- Không commit `.env.local` vào Git (đã có `.gitignore`).
- Thêm rate limit cho API tạo bài (đã có bộ đếm đơn giản trong `api/*.js`).
- Nội dung AI chỉ mang tính tham khảo — cần giáo viên/chuyên gia kiểm duyệt trước khi công bố chính thức.
