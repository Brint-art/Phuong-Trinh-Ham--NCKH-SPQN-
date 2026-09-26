/* ============================================================
   Hàm số — cấu hình kết nối Supabase (Giai đoạn 2)
   Điền URL và anon key từ Supabase Dashboard:
   Project Settings → API → Project URL / anon public key.
   Anon key được phép công khai vì Row Level Security (RLS) chỉ
   cho phép đọc nội dung đã xuất bản.
   KHÔNG BAO GIỜ đặt service_role key vào file này.
   ============================================================ */

window.SUPABASE_CONFIG = {
  url: 'https://xgcocacjtsrsvhbguofa.supabase.co',
  anonKey: 'sb_publishable_ko42b9i0DtdpDAmp2MK2zw_wK6OluJa', // publishable key (dạng mới) — dùng như anon key
  useStaticFallback: true,  // true: dùng tạm data.js cho phần Supabase chưa có dữ liệu.
                             // Supabase chỉ "kích hoạt" khi đã có ít nhất 1 bài học hoặc bài tập.

  // Khi chạy website bằng server tĩnh (Sublime Server, Live Server...)
  // thì AI không thể chạy trên server đó. Nếu đã deploy trang lên Vercel,
  // điền URL bản deploy vào đây để các nút AI gọi về API của bản deploy:
  //   apiBase: 'https://ham-so-xxx.vercel.app'
  apiBase: ''  // để trống khi chạy bằng server.js / vercel dev (API cùng máy chủ)
};
