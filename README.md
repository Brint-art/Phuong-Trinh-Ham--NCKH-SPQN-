# Hàm số — Nền tảng tự học phương trình hàm

Website tự học phương trình hàm dành cho học sinh THPT khá giỏi và đội tuyển Olympic.
Không thi trực tuyến, không chấm điểm. Lộ trình học: **Lý thuyết → Ví dụ → Bài tập → Lời giải → Hỏi AI**.

## Công nghệ

- **Frontend**: HTML + CSS + JavaScript thuần (thân thiện với người mới)
- **API AI**: Vercel Serverless Functions (thư mục `api/`, Node.js)
- **AI**: Mistral API (`ministral-14b-latest` mặc định)
- **Database**: Supabase PostgreSQL (đọc trực tiếp từ trình duyệt qua Supabase JS + Row Level Security)
- **Hosting**: Vercel

## Kiến trúc dữ liệu & Tính năng chính

Website được thiết kế dựa trên mô hình **2 luồng, 3 lớp, 2 vai trò**:

1. **Mô hình 2 luồng dữ liệu**:
   - **Luồng Lý thuyết (`lessons`)**: Gồm 3 khung nội dung: *Kiến thức bổ trợ*, *Kiến thức nền tảng*, và *Bài tập đặc trưng* (ví dụ mẫu).
   - **Luồng Bài tập (`exercises`)**: Gồm 2 khung nội dung: *Đề bài* và *Đáp án chi tiết*.

2. **Mô hình 2 vai trò (`profiles`)**:
   - `student` (Học sinh): Đọc nội dung công khai, tạo bài bằng AI lưu vào "Bộ bài của tôi", hỏi AI về từng bước giải.
   - `admin` (Quản trị): Có thêm quyền sửa nội dung lý thuyết/bài tập, xem trước (Preview LaTeX), tự động tạo slug, ẩn/xuất bản bài, đổi vai trò người dùng khác.

3. **Quy trình sinh bài tập bằng AI 3 lớp**:
   - **Lớp 1**: Trích xuất dữ liệu gốc (ngữ cảnh từ chuyên đề, kiến thức nền tảng, dạng bài liên quan).
   - **Lớp 2**: Gọi Mistral API sinh đề bài và đáp án từng bước dựa trên Prompt kỹ thuật số.
   - **Lớp 3 (Lớp an toàn)**: Dùng Math.js (trên frontend) kiểm chứng nghiệm và hằng số của phương trình hàm trước khi cho phép học sinh thêm vào thư viện.

4. **Thư viện AI cá nhân**:
   - Bài do AI sinh ra sẽ được lưu vào bảng `ai_library` thay vì chèn vào luồng bài tập chính. Nội dung sinh ra mang tính tham khảo và được cô lập theo từng học sinh.

## Cấu trúc thư mục

```
ham-so-website/
├── index.html                  → Cấu trúc trang và UI Admin
├── styles.css                  → Giao diện (CSS thuần)
├── app.js                      → Logic trang (Router, Load data, Auth, AI Math.js verification)
├── supabase-config.js          → Cấu hình URL + anon key Supabase
├── supabase/
│   ├── schema-v3.sql           → Cấu trúc bảng (Luồng lý thuyết/bài tập mới, roles, trigger auth, policies)
│   └── content-import-v3.sql   → Dữ liệu mẫu ban đầu (Idempotent: chạy lại thoải mái)
├── api/
│   ├── generate-exercises.js   → AI tạo bộ bài tập 
│   ├── ask-solution.js         → Hỏi AI về từng bước giải
│   └── _lib.js                 → Chống Spam (Rate Limiter), JWT Check, CORS
├── .env.example                → Mẫu biến môi trường
├── vercel.json                 → Cấu hình hosting Vercel
└── package.json                → Script chạy dev local
```

## Cách thiết lập Database (Supabase)

Website đọc dữ liệu trực tiếp từ Supabase bằng Supabase JS client + Row Level Security. 

1. Tạo dự án tại [supabase.com](https://supabase.com) → **New project**.
2. Mở **SQL Editor** → chạy lần lượt các file SQL sau theo **đúng thứ tự**:
   - **Bước 1**: `supabase/schema-v3.sql` — tạo toàn bộ cấu trúc bảng, RLS (Row Level Security), hàm `app_is_admin()`, bảng `profiles`, và trigger cho auth. (Đã dọn dẹp các bảng hàng đợi duyệt bài cũ).
   - **Bước 2**: `supabase/content-import-v3.sql` — nạp nội dung lý thuyết (3 khung) và bài tập vận dụng (2 khung). File dùng cấu trúc `ON CONFLICT (slug)` nên có thể chạy lại nhiều lần (idempotent) mà không sợ sinh bản sao.

3. Vào **Authentication → Providers → Email**: 
   - Tắt **Confirm email** nếu muốn đăng ký là đăng nhập được ngay để test. 

4. Vào **Project Settings → API**, sao chép:
   - `Project URL`
   - Khóa `anon public` (bắt đầu bằng `eyJ...`)
5. Dán vào file `supabase-config.js`:
   ```js
   window.SUPABASE_CONFIG = {
     url: 'https://xxxx.supabase.co',
     anonKey: 'eyJ...',
     apiBase: '' // Trỏ đến Vercel URL nếu muốn chạy UI local nhưng AI trên cloud
   };
   ```

### Cách tạo tài khoản Admin đầu tiên
Vì lý do bảo mật, người dùng không thể tự cấp quyền Admin cho chính mình qua giao diện.
Sau khi bạn đăng ký tài khoản trên web, hãy vào Supabase **SQL Editor** và chạy lệnh sau để biến mình thành Admin:
```sql
UPDATE public.profiles SET role = 'admin'
WHERE id = (SELECT id FROM auth.users WHERE email = 'email-cua-ban@vidu.com');
```
Sau đó tải lại trang — mục **Quản trị** sẽ xuất hiện trên thanh điều hướng. Từ tài khoản Admin này, bạn có thể phân quyền cho người khác trên giao diện.

## Chạy trên máy cá nhân (Local Development)

**Cách 1 — Chạy bằng Node.js (Mô phỏng giống Vercel):**
Chỉ cần cài Node.js 18+ (nodejs.org), rồi trong thư mục dự án chạy:
```bash
npm install
node server.js
```
Mở `http://localhost:3000`. API của AI sẽ tự động hoạt động đúng với môi trường local.
Để AI hoạt động, hãy copy `.env.example` thành `.env.local` và điền key Mistral:
```env
MISTRAL_API_KEY=sk-...
MISTRAL_MODEL=ministral-14b-latest
ALLOWED_ORIGINS=http://localhost:3000
```

**Cách 2 — Mở HTML tĩnh (Chỉ test giao diện):**
Mở `index.html` bằng Live Server. Nếu bạn muốn gọi AI, bạn cần cấu hình URL Vercel đã deploy vào `apiBase` trong `supabase-config.js`.

**Cách 3 — Chạy bằng PowerShell (Script cũ, không cần cài Node):**
Mở PowerShell: `powershell -ExecutionPolicy Bypass -File dev-server.ps1`
Tuy nhiên, dùng `server.js` (Cách 1) vẫn ổn định và mô phỏng sát nhất với server Vercel.

## Deploy lên Vercel

1. Đẩy code lên GitHub (file `.env.local` đã bị loại trừ trong `.gitignore`).
2. Vào [vercel.com](https://vercel.com) → **Add New → Project** → Chọn repository.
3. Framework Preset: **Other**.
4. **Environment Variables**: thêm `MISTRAL_API_KEY` và `ALLOWED_ORIGINS` (ví dụ: `https://ham-so.vercel.app`).
5. Nhấn **Deploy**. Mỗi lần `git push`, Vercel sẽ tự cập nhật.

## Ghi chú bảo mật
- **JWT & Rate Limit**: Các serverless function (`api/*.js`) tự động kiểm tra token JWT (lấy từ Supabase auth) thông qua header `Authorization`. IP / User sẽ bị rate-limit nếu gửi quá số lượng request (cấu hình trong `_lib.js`).
- **CORS**: Được quản lý bởi `ALLOWED_ORIGINS` trong `.env`.
- **An toàn XSS**: Toàn bộ nội dung hiển thị ra Markdown/HTML từ người dùng hay DB đều được làm sạch qua `DOMPurify` trên frontend.
- API Key của AI tuyệt đối chỉ cấu hình trên Vercel, không đưa vào mã nguồn Client.
