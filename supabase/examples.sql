-- ============================================================
-- Hàm số — Mẫu nạp dữ liệu vào Supabase
-- Cách dùng: sửa nội dung theo ý bạn rồi chạy trong SQL Editor.
-- (Bạn cũng có thể nhập liệu bằng Table Editor thay vì SQL.)
--
-- Lưu ý quan trọng:
--   * Bài học chỉ hiển thị trên website khi is_published = true.
--   * Bài tập chỉ hiển thị khi status = 'published'.
--   * Công thức toán viết bằng LaTeX $...$, xuống dòng dùng \n
--     (trong SQL viết xuống dòng thật cũng được).
-- ============================================================

-- ---------- 1) Thêm chuyên đề ----------
insert into topics (slug, title, description, display_order) values
('nen-tang', 'Kiến thức nền tảng',
 'Ánh xạ, hàm số, tập xác định — tập giá trị, đơn ánh — toàn ánh — song ánh...',
 1);

-- ---------- 2) Thêm bài học ----------
-- sections là mảng JSON, mỗi phần tử gồm:
--   type: definition | theorem | technique | example
--   title: tiêu đề khối
--   body: nội dung (LaTeX $...$, \n để xuống dòng)
insert into lessons (topic_id, slug, title, objective, sections, display_order, is_published) values
(
  (select id from topics where slug = 'nen-tang'),
  'anh-xa-ham-so',
  'Ánh xạ và hàm số',
  'Nắm vững khái niệm ánh xạ và hàm số; phân biệt tập nguồn, tập đích.',
  '[
    {"type": "definition", "title": "Định nghĩa",
     "body": "Ánh xạ từ tập $X$ vào tập $Y$ là quy tắc cho tương ứng mỗi phần tử $x \\in X$ với đúng một phần tử $y \\in Y$, ký hiệu $f: X \\to Y$.\nHàm số là ánh xạ mà tập nguồn và tập đích là các tập hợp số."},
    {"type": "technique", "title": "Kỹ thuật giải",
     "body": "Khi đọc đề phương trình hàm, việc đầu tiên là xác định rõ ba yếu tố: tập nguồn $X$, tập đích $Y$ và dạng điều kiện."},
    {"type": "example", "title": "Ví dụ minh họa",
     "body": "Quy tắc $f: \\mathbb{R} \\to \\mathbb{R}$, $f(x) = 2x + 1$ là một hàm số."}
  ]'::jsonb,
  1,
  true
);

-- ---------- 3) Thêm bài tập ----------
-- techniques và related là mảng văn bản (array[...])
insert into exercises
  (topic_id, slug, title, problem_latex, difficulty, type, techniques, related, hint, source, status)
values
(
  (select id from topics where slug = 'nen-tang'),
  'ex-song-anh-1',
  'Chứng minh f(x) = 2x + 1 là song ánh',
  'Cho $f: \\mathbb{R} \\to \\mathbb{R}$ xác định bởi $f(x) = 2x + 1$. Chứng minh $f$ là song ánh và tìm hàm ngược.',
  1,
  'Chứng minh song ánh',
  array['song ánh'],
  array['Đơn ánh, toàn ánh, song ánh'],
  'Giải phương trình $f(x) = y$ theo $x$ với $y$ bất kỳ.',
  'Ví dụ cơ bản',
  'published'
);

-- ---------- 4) Thêm lời giải theo từng bước ----------
insert into exercise_solutions (exercise_id, step_number, content_latex, explanation) values
(
  (select id from exercises where slug = 'ex-song-anh-1'),
  1,
  'Giả sử $f(a) = f(b)$. Khi đó $2a + 1 = 2b + 1 \\Rightarrow a = b$. Vậy $f$ đơn ánh.',
  'Dùng định nghĩa: $f(a) = f(b) \\Rightarrow a = b$.'
),
(
  (select id from exercises where slug = 'ex-song-anh-1'),
  2,
  'Với $y \\in \\mathbb{R}$ tùy ý, chọn $x = \\frac{y - 1}{2}$ thì $f(x) = y$. Vậy $f$ toàn ánh.',
  'Với mọi $y$ ở tập đích, luôn tìm được $x$ ở tập nguồn.'
),
(
  (select id from exercises where slug = 'ex-song-anh-1'),
  3,
  '$f$ vừa đơn ánh vừa toàn ánh nên song ánh. Hàm ngược: $f^{-1}(x) = \\frac{x - 1}{2}$.',
  'Hàm ngược chính là biểu thức $x$ theo $y$ tìm được ở bước 2.'
);
