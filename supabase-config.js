/* ============================================================
   Hàm số — cấu hình kết nối Supabase (Giai đoạn 2)
   Điền URL và anon key từ Supabase Dashboard:
   Project Settings → API → Project URL / anon public key.
   Anon key được phép công khai vì Row Level Security (RLS) chỉ
   cho phép đọc nội dung đã xuất bản.
   KHÔNG BAO GIỜ đặt service_role key vào file này.
   ============================================================ */

window.SUPABASE_CONFIG = {
  url: 'https://uywpxiqchksbwbfdbqnd.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV5d3B4aXFjaGtzYndiZmRicW5kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA4MzY0MzcsImV4cCI6MjEwNjQxMjQzN30.HXugCDeJI5BJNPmODAqDo9vvaQGXebcxl1UgqQ45KSM',
  // Khi chạy website bằng server tĩnh (Sublime Server, Live Server...)
  // thì AI không thể chạy trên server đó. Nếu đã deploy trang lên Vercel,
  // điền URL bản deploy vào đây để các nút AI gọi về API của bản deploy:
  //   apiBase: 'https://ham-so-xxx.vercel.app'
  apiBase: ''  // để trống khi chạy bằng server.js / vercel dev (API cùng máy chủ)
};
