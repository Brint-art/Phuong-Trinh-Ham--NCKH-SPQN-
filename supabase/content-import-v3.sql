-- ============================================================
-- Hàm số — Nạp nội dung chính (4 chuyên đề, 9 bài học, 15 bài tập + lời giải)
-- Nguồn: luận văn "Phương trình hàm" (file bài xong mục lục.docx)
--
-- Cách chạy: Supabase Dashboard → SQL Editor → mở file này → Run.
-- Lưu ý:
--   * File này XÓA toàn bộ nội dung cũ (bài học, bài tập, lời giải) rồi nhập mới.
--   * Công thức toán viết bằng LaTeX $...$ (MathJax).
--   * Một số lời giải đã được HIỆU CHỈNH so với luận văn (xem ghi chú trong từng bài):
--       - Bài 1:  luận văn thiếu họ nghiệm (x²+x+1)ⁿ.
--       - Bài 7:  luận văn thiếu họ nghiệm f(x) = x + c (thêm giả thiết f liên tục).
--       - Bài 8, 11: thêm giả thiết f liên tục để lời giải chặt chẽ.
--       - Bài 11: luận văn thiếu nghiệm f(x) = −2x.
--   * Ghi chú nguồn gốc "IMO 2002/2004" trong luận văn có thể không chính xác.
-- ============================================================

-- ---------- 0) Xóa dữ liệu cũ (theo thứ tự tránh lỗi khóa ngoại) ----------
delete from exercise_solutions;
delete from exercises;
delete from lessons;
delete from topics;

-- ---------- 1) Chuyên đề ----------
insert into topics (slug, title, description, display_order) values
('nen-tang', 'Kiến thức nền tảng',
 'Ánh xạ, hàm số, đơn ánh — toàn ánh — song ánh; nền tảng cho mọi dạng phương trình hàm.',
 1),
('pth-da-thuc', 'Phương trình hàm đa thức',
 'Phương trình hàm với nghiệm là đa thức: nghiệm, bậc, đồng nhất thức, đánh giá module.',
 2),
('pth-tren-r', 'Phương trình hàm trên tập số thực',
 'Kỹ thuật thay biến, khảo sát tập giá trị, phương trình Cauchy và các dạng mở rộng.',
 3),
('pth-roi-rac', 'Phương trình hàm rời rạc',
 'Phương trình hàm trên tập số nguyên: quỹ đạo, nguyên lý cực hạn, phân hoạch quỹ đạo.',
 4);

-- ---------- 2) Bài học ----------
-- sections là mảng JSON: type: definition | theorem | technique | example
-- Trong JSON, LaTeX dùng \\ (thoát), xuống dòng dùng \n.

-- ============ Chuyên đề: Kiến thức nền tảng ============
insert into lessons (topic_id, slug, title, objective, sections, display_order, is_published) values
(
  (select id from topics where slug = 'nen-tang'),
  'lich-su-phuong-trinh-ham',
  'Lịch sử phương trình hàm',
  'Hiểu nguồn gốc của phương trình hàm, từ phương trình Cauchy đến các bài toán Olympic hiện đại.',
  '[
    {"type": "definition", "title": "Phương trình hàm là gì",
     "body": "Phương trình hàm là phương trình mà ẩn số là một hàm số. Người giải cần tìm tất cả các hàm số thỏa mãn một (hoặc nhiều) đẳng thức cho trước trên một miền xác định.\nVí dụ: tìm mọi hàm $f: \\mathbb{R} \\to \\mathbb{R}$ thỏa mãn $f(x+y) = f(x) + f(y)$ với mọi $x, y \\in \\mathbb{R}$."},
    {"type": "example", "title": "Phương trình Cauchy",
     "body": "Phương trình $f(x+y) = f(x) + f(y)$ được nghiên cứu bởi nhà toán học Augustin-Louis Cauchy. Phương trình này đặt nền tảng cho nhiều nghiên cứu về tính chất của hàm số và mối liên hệ giữa các điều kiện đại số với các tính chất như liên tục, đơn điệu.\nNghiệm liên tục của phương trình này là $f(x) = ax$ với $a = f(1)$."},
    {"type": "theorem", "title": "Phương trình hàm trong Olympic",
     "body": "Phương trình hàm được sử dụng rộng rãi trong các bài toán Olympic và các kỳ thi học sinh giỏi, góp phần rèn luyện khả năng suy luận, phát hiện cấu trúc và xây dựng chiến lược giải toán."},
    {"type": "technique", "title": "Cách tiếp cận một bài phương trình hàm",
     "body": "Quy trình chung gồm các bước:\n1. Xác định rõ tập nguồn và tập đích của hàm số.\n2. Thay các giá trị đặc biệt ($0$, $1$, $-1$, nghiệm của biểu thức...) để thu thập thông tin.\n3. Khai thác các tính chất: đơn ánh, toàn ánh, chẵn/lẻ, chu kỳ, đơn điệu.\n4. Dự đoán nghiệm, chứng minh và thử lại."}
  ]'::jsonb,
  1,
  true
);

insert into lessons (topic_id, slug, title, objective, sections, display_order, is_published) values
(
  (select id from topics where slug = 'nen-tang'),
  'anh-xa-ham-so',
  'Ánh xạ và hàm số',
  'Nắm vững khái niệm ánh xạ, hàm số; phân biệt tập nguồn, tập đích, tập xác định, tập giá trị.',
  '[
    {"type": "definition", "title": "Ánh xạ và hàm số",
     "body": "Ánh xạ từ tập $X$ vào tập $Y$ là quy tắc cho tương ứng mỗi phần tử $x \\in X$ với đúng một phần tử $y \\in Y$, ký hiệu $f: X \\to Y$.\nHàm số là ánh xạ mà tập nguồn và tập đích là các tập hợp số. Tập nguồn gọi là tập xác định $D_f$; các tập số thường gặp: $\\mathbb{N}$ (tự nhiên), $\\mathbb{Z}$ (nguyên), $\\mathbb{Q}$ (hữu tỉ), $\\mathbb{R}$ (thực), $\\mathbb{C}$ (phức)."},
    {"type": "technique", "title": "Đọc kỹ tập nguồn và tập đích",
     "body": "Khi đọc đề phương trình hàm, việc đầu tiên là xác định rõ ba yếu tố: tập nguồn $X$, tập đích $Y$ và dạng điều kiện.\nNhiều sai lầm bắt nguồn từ việc thay các giá trị không thuộc tập nguồn, hoặc quên điều kiện giá trị $f(x)$ phải thuộc tập đích."},
    {"type": "example", "title": "Ví dụ minh họa",
     "body": "Quy tắc $f: \\mathbb{R} \\to \\mathbb{R}$, $f(x) = 2x + 1$ là một hàm số.\nQuy tắc $f: \\mathbb{N} \\to \\mathbb{N}$, $f(n) = n - 5$ không phải là ánh xạ vì $f(1) = -4 \\notin \\mathbb{N}$.\nTrong bài toán rời rạc $f: \\mathbb{N}^* \\to \\mathbb{N}^*$, giá trị $f(n)$ bắt buộc là số nguyên dương — đây là một ràng buộc quan trọng khi giải."}
  ]'::jsonb,
  2,
  true
);

insert into lessons (topic_id, slug, title, objective, sections, display_order, is_published) values
(
  (select id from topics where slug = 'nen-tang'),
  'don-anh-toan-anh-song-anh',
  'Đơn ánh, toàn ánh, song ánh',
  'Nhận biết và chứng minh đơn ánh, toàn ánh, song ánh — công cụ cốt lõi của phương trình hàm.',
  '[
    {"type": "definition", "title": "Ba khái niệm cơ bản",
     "body": "$f$ đơn ánh nếu $f(x_1) = f(x_2) \\Rightarrow x_1 = x_2$.\n$f$ toàn ánh nếu với mọi $y \\in Y$ tồn tại $x \\in X$ sao cho $f(x) = y$.\n$f$ song ánh nếu vừa đơn ánh vừa toàn ánh; khi đó tồn tại hàm ngược $f^{-1}$ thỏa mãn $f^{-1}(f(x)) = x$ và $f(f^{-1}(y)) = y$."},
    {"type": "technique", "title": "Kỹ thuật chứng minh",
     "body": "Chứng minh đơn ánh: giả sử $f(x_1) = f(x_2)$, dùng phương trình hàm với các phép thay biến khéo léo để ép ra $x_1 = x_2$.\nChứng minh toàn ánh: chỉ ra rằng vế phải (hoặc một biểu thức chứa $f$) nhận mọi giá trị khi biến chạy trên tập nguồn."},
    {"type": "theorem", "title": "Tính đơn ánh và toàn ánh của hàm hợp",
     "body": "Nếu $f \\circ g$ là đơn ánh thì $g$ là đơn ánh.\nNếu $f \\circ g$ là toàn ánh thì $f$ là toàn ánh.\nNếu $f \\circ g$ là song ánh thì phương trình $f(g(x)) = y$ có nghiệm duy nhất với mọi $y$."},
    {"type": "example", "title": "Ví dụ minh họa",
     "body": "$f: \\mathbb{R} \\to \\mathbb{R}$, $f(x) = 2x + 1$ là song ánh:\n• Đơn ánh: $2a + 1 = 2b + 1 \\Rightarrow a = b$.\n• Toàn ánh: với mọi $y$, chọn $x = \\frac{y-1}{2}$ thì $f(x) = y$.\nHàm ngược: $f^{-1}(x) = \\frac{x-1}{2}$."}
  ]'::jsonb,
  3,
  true
);

insert into lessons (topic_id, slug, title, objective, sections, display_order, is_published) values
(
  (select id from topics where slug = 'nen-tang'),
  'ham-so-tap-gia-tri',
  'Hàm số: tập xác định và tập giá trị',
  'Phân biệt tập xác định và tập giá trị; biết khai thác tập giá trị trong bài toán phương trình hàm.',
  '[
    {"type": "definition", "title": "Tập giá trị",
     "body": "Tập giá trị của $f$ là $f(X) = \\{ f(x) : x \\in X \\}$ — tập tất cả các giá trị mà $f$ nhận được.\nVí dụ: $f(x) = x^2$ trên $\\mathbb{R}$ có tập giá trị $[0; +\\infty)$; $f(x) = x^3$ trên $\\mathbb{R}$ có tập giá trị $\\mathbb{R}$."},
    {"type": "technique", "title": "Kỹ thuật khảo sát tập giá trị",
     "body": "Nếu $t \\in f(X)$ thì tồn tại $x$ sao cho $f(x) = t$, ta được quyền thay $t$ vào các vị trí thuận lợi của phương trình.\nNếu một đẳng thức đúng với mọi $t$ thuộc tập giá trị vô hạn của một đa thức $P$, thì hai đa thức tương ứng phải đồng nhất (Định lý đồng nhất đa thức)."},
    {"type": "example", "title": "Ví dụ minh họa",
     "body": "Trong bài toán $P(P(x)) = (P(x))^{2026}$: với mọi $y$ thuộc tập giá trị của $P$, tồn tại $x$ để $P(x) = y$. Thay $x$ vào phương trình: $P(y) = y^{2026}$. Vì tập giá trị của đa thức bậc dương là vô hạn, hai đa thức $P(t)$ và $t^{2026}$ đồng nhất, suy ra $P(x) = x^{2026}$."}
  ]'::jsonb,
  4,
  true
);

-- ============ Chuyên đề: Phương trình hàm đa thức ============
insert into lessons (topic_id, slug, title, objective, sections, display_order, is_published) values
(
  (select id from topics where slug = 'pth-da-thuc'),
  'so-phuc-module',
  'Số phức và module',
  'Nhắc lại số phức và module; biết dùng đánh giá module để chặn nghiệm của đa thức.',
  '[
    {"type": "definition", "title": "Số phức và module",
     "body": "Số phức có dạng $z = a + bi$ với $a, b \\in \\mathbb{R}$ và $i^2 = -1$. Module của $z$ là $|z| = \\sqrt{a^2 + b^2}$.\nSố liên hợp $\\overline{z} = a - bi$; ta có $z \\cdot \\overline{z} = |z|^2$."},
    {"type": "theorem", "title": "Bất đẳng thức tam giác",
     "body": "Với mọi số phức $z_1, z_2$: $|z_1 + z_2| \\le |z_1| + |z_2|$.\nChứng minh: $|z_1 + z_2|^2 = (z_1 + z_2)(\\overline{z_1} + \\overline{z_2}) = |z_1|^2 + |z_2|^2 + 2\\operatorname{Re}(z_1 \\overline{z_2}) \\le |z_1|^2 + |z_2|^2 + 2|z_1||z_2| = (|z_1| + |z_2|)^2$. Lấy căn hai vế ta được điều phải chứng minh."},
    {"type": "theorem", "title": "Định lý cơ bản của đại số",
     "body": "Mọi đa thức bậc $n \\ge 1$ với hệ số thực (hoặc phức) đều có đúng $n$ nghiệm trên tập số phức $\\mathbb{C}$ (tính cả nghiệm bội).\nVì vậy, một đa thức bậc $n$ không thể có quá $n$ nghiệm phân biệt — cơ sở cho kỹ thuật tạo ra vô số nghiệm để suy ra điều vô lý."},
    {"type": "technique", "title": "Kỹ thuật đánh giá module",
     "body": "Giả sử đa thức $P$ có nghiệm $\\alpha$. Dùng phương trình để sinh ra các nghiệm mới (ví dụ $\\alpha^2$, $\\alpha(\\alpha+1)$...). Nếu các nghiệm này có module tăng dần, $P$ sẽ có vô số nghiệm — mâu thuẫn. Vì vậy phải có $|\\alpha| \\le 1$ (hoặc một chặn tương tự), rồi kết hợp với một chặn khác để thu hẹp tập nghiệm khả dĩ."}
  ]'::jsonb,
  1,
  true
);

insert into lessons (topic_id, slug, title, objective, sections, display_order, is_published) values
(
  (select id from topics where slug = 'pth-da-thuc'),
  'da-thuc-nghiem-bac',
  'Đa thức: nghiệm và bậc',
  'Nắm định lý Bézout, định lý đồng nhất đa thức và quy tắc tính bậc — công cụ cơ bản của phương trình hàm đa thức.',
  '[
    {"type": "theorem", "title": "Định lý Bézout",
     "body": "$a$ là nghiệm của đa thức $P(x)$ khi và chỉ khi $P(x)$ chia hết cho $x - a$, tức là $P(x) = (x-a)Q(x)$.\nTổng quát: nếu $P$ có các nghiệm phân biệt $a_1, a_2, \\dots, a_k$ thì $P(x) = (x-a_1)(x-a_2)\\cdots(x-a_k)Q(x)$."},
    {"type": "theorem", "title": "Định lý đồng nhất đa thức",
     "body": "Nếu hai đa thức có bậc không vượt quá $n$ và nhận cùng giá trị tại $n+1$ điểm phân biệt thì chúng đồng nhất bằng nhau.\nHệ quả: đa thức nhận giá trị bằng không tại vô số điểm phân biệt phải là đa thức không."},
    {"type": "theorem", "title": "Bậc của đa thức",
     "body": "Cho $\\deg P = n$, $\\deg Q = m$:\n• $\\deg(PQ) = n + m$;\n• Nếu $m \\ge 1$ thì $\\deg(P \\circ Q) = n \\cdot m$.\nVí dụ: $\\deg P(x^2) = 2n$, $\\deg P(x)^2 = 2n$, $\\deg P(P(x)) = n^2$."},
    {"type": "technique", "title": "Kỹ thuật chặn bậc và so sánh hệ số",
     "body": "So sánh bậc hai vế để tìm $\\deg P$, sau đó so sánh hệ số của lũy thừa cao nhất để tìm hệ số dẫn đầu.\nGiả sử có hệ số khác 0 ở bậc thấp hơn: so sánh hệ số của số hạng tương ứng ở hai vế để dẫn đến mâu thuẫn, từ đó suy ra $P$ chỉ gồm một số hạng."}
  ]'::jsonb,
  2,
  true
);

-- ============ Chuyên đề: Phương trình hàm trên tập số thực ============
insert into lessons (topic_id, slug, title, objective, sections, display_order, is_published) values
(
  (select id from topics where slug = 'pth-tren-r'),
  'tru-mat-lien-tuc',
  'Tính trù mật và liên tục',
  'Hiểu tính trù mật của tập số hữu tỉ và tiêu chuẩn liên tục qua dãy (Heine) — cầu nối từ kết quả trên ℚ ra toàn ℝ.',
  '[
    {"type": "definition", "title": "Tính trù mật của ℚ trong ℝ",
     "body": "Tập số hữu tỉ $\\mathbb{Q}$ trù mật trong $\\mathbb{R}$: giữa hai số thực bất kỳ luôn tồn tại ít nhất một số hữu tỉ.\nHệ quả: với mọi số thực $x$, luôn tồn tại một dãy số hữu tỉ $(x_n)$ sao cho $x_n \\to x$."},
    {"type": "theorem", "title": "Tiêu chuẩn Heine (liên tục qua dãy)",
     "body": "Hàm $f$ liên tục tại $x_0$ khi và chỉ khi với mọi dãy $(x_n)$ hội tụ về $x_0$, ta đều có $f(x_n) \\to f(x_0)$.\nTính chất này cho phép chuyển giới hạn vào bên trong hàm số: $f(\\lim x_n) = \\lim f(x_n)$."},
    {"type": "technique", "title": "Chiến lược hai bước",
     "body": "Bước 1: chứng minh tính chất cần thiết trên tập $\\mathbb{Q}$ (hoặc $\\mathbb{Z}$) bằng quy nạp và các phép thay biến.\nBước 2: dùng tính trù mật và tiêu chuẩn Heine để mở rộng kết quả ra toàn $\\mathbb{R}$."}
  ]'::jsonb,
  1,
  true
);

insert into lessons (topic_id, slug, title, objective, sections, display_order, is_published) values
(
  (select id from topics where slug = 'pth-tren-r'),
  'phuong-trinh-cauchy',
  'Phương trình Cauchy',
  'Nắm phương trình Cauchy, nghiệm của nó khi có thêm giả thiết liên tục, và các dạng mở rộng cơ bản.',
  '[
    {"type": "definition", "title": "Phương trình Cauchy",
     "body": "Phương trình Cauchy có dạng: $f(x+y) = f(x) + f(y)$ với mọi $x, y \\in \\mathbb{R}$.\nTrên tập số hữu tỉ, mọi nghiệm đều có dạng $f(x) = ax$ với $a = f(1)$. Để mở rộng lên $\\mathbb{R}$, cần thêm điều kiện phụ như liên tục, đơn điệu hoặc bị chặn."},
    {"type": "theorem", "title": "Định lý 2.2.2 — Nghiệm liên tục của phương trình Cauchy",
     "body": "Nếu $f$ thỏa mãn phương trình Cauchy và liên tục tại ít nhất một điểm (hoặc bị chặn trên một khoảng), thì $f(x) = ax$ với $a$ là hằng số thực.\nChứng minh:\n• Bước 1: thay $y = 0$ ta có $f(0) = 0$; thay $y = -x$ ta có $f(-x) = -f(x)$ (hàm lẻ).\n• Bằng quy nạp: $f(nx) = nf(x)$ với mọi $n \\in \\mathbb{Z}$, $x \\in \\mathbb{R}$. Đặt $a = f(1)$ ta có $f(n) = an$ với mọi $n \\in \\mathbb{Z}$.\n• Với số hữu tỉ $r = \\frac{p}{q}$: $qf(\\frac{p}{q}) = f(p) = ap$, suy ra $f(r) = ar$ với mọi $r \\in \\mathbb{Q}$.\n• Bước 2: với $x \\in \\mathbb{R}$ bất kỳ, chọn dãy hữu tỉ $x_n \\to x$. Do tính liên tục và kết quả trên $\\mathbb{Q}$: $f(x) = \\lim f(x_n) = \\lim (a x_n) = ax$."},
    {"type": "theorem", "title": "Các dạng mở rộng thường gặp",
     "body": "• Dạng nhân: $f(xy) = f(x) + f(y)$ trên $\\mathbb{R}^+$ — đặt $g(t) = f(e^t)$ đưa về Cauchy, nghiệm liên tục là $f(x) = a\\ln x$.\n• Dạng lũy thừa: $f(x+y) = f(x)f(y)$ với $f$ không đồng nhất 0 — nghiệm liên tục là $f(x) = a^x$.\n• Dạng Cauchy mở rộng: $f(x+y) + f(x-y) = 2f(x)f(y)$ — liên hệ với công thức cộng của hàm $\\cos$."},
    {"type": "technique", "title": "Kỹ thuật đưa về Cauchy",
     "body": "Khi gặp một phương trình hàm lạ, hãy tìm cách biến đổi để xuất hiện dạng cộng tính $f(u+v) = f(u) + f(v)$ (bằng cách đặt ẩn phụ, đổi biến, khai thác song ánh...), rồi áp dụng Định lý 2.2.2."}
  ]'::jsonb,
  2,
  true
);

-- ============ Chuyên đề: Phương trình hàm rời rạc ============
insert into lessons (topic_id, slug, title, objective, sections, display_order, is_published) values
(
  (select id from topics where slug = 'pth-roi-rac'),
  'quy-dao-nguyen-ly-cuc-han',
  'Quỹ đạo và nguyên lý cực hạn',
  'Hiểu khái niệm quỹ đạo của hàm số; vận dụng nguyên lý cực hạn và phân hoạch quỹ đạo trong bài toán rời rạc.',
  '[
    {"type": "definition", "title": "Quỹ đạo của hàm số",
     "body": "Cho $f: X \\to X$ và phần tử $x \\in X$. Quỹ đạo của $x$ dưới tác động của $f$ là dãy: $x,\\ f(x),\\ f(f(x)),\\ f(f(f(x))),\\ \\dots$\nNếu tồn tại số nguyên dương $k$ sao cho $f^k(x) = x$ thì quỹ đạo gọi là tuần hoàn với chu kỳ $k$; khi đó $f$ thực hiện một phép hoán vị trên các phần tử của quỹ đạo."},
    {"type": "theorem", "title": "Định lý 2.3.1 — Nguyên lý cực hạn trong đánh giá đơn điệu",
     "body": "Cho $f: \\mathbb{N} \\to \\mathbb{N}$. Nếu $f(f(n)) < f(n+1)$ với mọi $n$ thì $f$ là hàm đồng nhất: $f(n) = n$.\nChứng minh:\n• Với mỗi $n$, xét tập $A_n = \\{ f(n), f(n+1), \\dots \\}$. Theo nguyên lý cực hạn, $A_n$ có phần tử nhỏ nhất, đạt tại chỉ số $i_n$.\n• Chứng minh $i_n = n$ bằng quy nạp: nếu $i_n > n$ thì theo giả thiết $f(f(i_n - 1)) < f(i_n)$. Vì $f(i_n - 1) \\ge n$ nên $f(f(i_n - 1))$ là một phần tử của $A_n$, nhỏ hơn phần tử nhỏ nhất — mâu thuẫn.\n• Vậy $f(0) < f(1) < f(2) < \\dots$: $f$ tăng ngặt, do đó $f(n) \\ge n$.\n• Từ giả thiết và tính tăng ngặt: $f(f(n)) < f(n+1) \\Rightarrow f(n) < n+1 \\Rightarrow f(n) \\le n$.\n• Kết hợp lại: $f(n) = n$ với mọi $n$."},
    {"type": "theorem", "title": "Định lý 2.3.2 — Tính giải được của phương trình tịnh tiến tuần hoàn",
     "body": "Cho $c$ là số nguyên dương. Phương trình $f(f(n)) = n + c$ có nghiệm $f: \\mathbb{N} \\to \\mathbb{N}$ khi và chỉ khi $c$ chẵn.\n• Nếu $c$ chẵn: hàm $f(n) = n + \\frac{c}{2}$ thỏa mãn vì $f(f(n)) = n + c$.\n• Nếu tồn tại $f$: vì $f(f(f(n))) = f(n) + c = f(n + c)$ nên $f(n + c) = f(n) + c$ với mọi $n$. Do đó $f$ bảo toàn các lớp đồng dư modulo $c$ và cảm sinh một phép đổi chỗ không có điểm bất động trên $c$ lớp đồng dư; $c$ lớp bị ghép thành từng cặp nên $c$ phải chẵn."}
  ]'::jsonb,
  1,
  true
);

-- ---------- 3) Bài tập ----------
-- Lưu ý: problem_latex là cột văn bản thường → LaTeX dùng dấu gạch chéo ĐƠN (\).

-- ============ Chuyên đề: Phương trình hàm đa thức (6 bài) ============
insert into exercises (topic_id, slug, title, problem_latex, difficulty, type, techniques, related, hint, source, status) values
(
  (select id from topics where slug = 'pth-da-thuc'),
  'ex-imo-2001-da-thuc',
  'Tìm đa thức thỏa mãn P(x²) = P(x)P(x−1)',
  'Tìm tất cả các đa thức $P(x)$ với hệ số thực thỏa mãn $P(x^2) = P(x)P(x-1)$ với mọi $x \in \mathbb{R}$.',
  3,
  'Tìm đa thức',
  array['thay biến', 'đánh giá module', 'nghiệm phức'],
  array['Nghiệm của đa thức', 'Module số phức'],
  'Nếu α là nghiệm thì α² và (α+1)² cũng là nghiệm. Dùng module để thu hẹp tập nghiệm khả dĩ.',
  'IMO 2001 (theo luận văn)',
  'published'
),
(
  (select id from topics where slug = 'pth-da-thuc'),
  'ex-vmo-2006',
  'Tìm đa thức thỏa mãn xP(x−1) = (x−3)P(x)',
  'Tìm tất cả các đa thức $P(x)$ với hệ số thực thỏa mãn $xP(x-1) = (x-3)P(x)$ với mọi $x \in \mathbb{R}$.',
  2,
  'Tìm đa thức',
  array['thay biến', 'tịnh tiến nghiệm'],
  array['Nghiệm của đa thức', 'Định lý Bézout'],
  'Thay các giá trị x = 0, 1, 3 để tìm nghiệm của P.',
  'VMO 2006',
  'published'
),
(
  (select id from topics where slug = 'pth-da-thuc'),
  'ex-chan-bac',
  'Tìm đa thức thỏa mãn P(x)² = P(x²)',
  'Tìm tất cả các đa thức $P(x)$ với hệ số thực thỏa mãn $P(x)^2 = P(x^2)$ với mọi $x \in \mathbb{R}$.',
  2,
  'Tìm đa thức',
  array['chặn bậc', 'so sánh hệ số'],
  array['Bậc của đa thức', 'Đồng nhất đa thức'],
  'So sánh hệ số cao nhất; giả sử có hệ số khác 0 ở bậc thấp hơn rồi so sánh hệ số tương ứng ở hai vế.',
  'Luận văn — Kỹ thuật chặn bậc',
  'published'
),
(
  (select id from topics where slug = 'pth-da-thuc'),
  'ex-nga-1999',
  'Tìm đa thức thỏa mãn P(x)P(x+1) = P(x²+x)',
  'Tìm tất cả các đa thức $P(x)$ với hệ số thực thỏa mãn $P(x)P(x+1) = P(x^2+x)$ với mọi $x \in \mathbb{R}$.',
  3,
  'Tìm đa thức',
  array['đánh giá module', 'bất đẳng thức tam giác'],
  array['Nghiệm của đa thức', 'Module số phức'],
  'Nếu α là nghiệm thì α(α+1) và α(α−1) cũng là nghiệm; chọn nghiệm có module lớn nhất.',
  'Olympic Nga 1999',
  'published'
),
(
  (select id from topics where slug = 'pth-da-thuc'),
  'ex-tap-gia-tri',
  'Tìm đa thức thỏa mãn P(P(x)) = (P(x))²⁰²⁶',
  'Tìm tất cả các đa thức $P(x)$ với hệ số thực thỏa mãn $P(P(x)) = (P(x))^{2026}$ với mọi $x \in \mathbb{R}$.',
  2,
  'Tìm đa thức',
  array['khảo sát tập giá trị', 'đồng nhất đa thức'],
  array['Tập giá trị của hàm số', 'Định lý đồng nhất đa thức'],
  'Với mọi y thuộc tập giá trị của P, tồn tại x để P(x) = y; thay x vào phương trình.',
  'Luận văn — Khảo sát tập giá trị',
  'published'
),
(
  (select id from topics where slug = 'pth-da-thuc'),
  'ex-sai-phan',
  'Tìm đa thức thỏa mãn P(x+1) + P(x−1) = 2P(x)',
  'Tìm tất cả các đa thức $P(x)$ với hệ số thực thỏa mãn $P(x+1) + P(x-1) = 2P(x)$ với mọi $x \in \mathbb{R}$.',
  1,
  'Tìm đa thức',
  array['sai phân'],
  array['Bậc của đa thức', 'Đa thức tuần hoàn'],
  'Đặt ΔP(x) = P(x+1) − P(x) và chứng minh ΔP là hằng số.',
  'Luận văn — Phương pháp sai phân',
  'published'
);

-- ============ Chuyên đề: Phương trình hàm trên tập số thực (5 bài) ============
insert into exercises (topic_id, slug, title, problem_latex, difficulty, type, techniques, related, hint, source, status) values
(
  (select id from topics where slug = 'pth-tren-r'),
  'ex-don-anh-f0',
  'Giải phương trình f(f(x)+y) = f(x+y) + f(0)',
  'Tìm tất cả các hàm số $f: \mathbb{R} \to \mathbb{R}$ liên tục thỏa mãn $f(f(x) + y) = f(x + y) + f(0)$ với mọi $x, y \in \mathbb{R}$.',
  3,
  'Tìm hàm số',
  array['thay biến', 'chu kỳ', 'đơn ánh', 'tính liên tục'],
  array['Hàm tuần hoàn', 'Đơn ánh'],
  'Đặt c = f(0). Thay x = 0 để có f(x+c) = f(x)+c. Nếu f có chu kỳ khác 0 và liên tục thì f bị chặn — dùng điều này để chứng minh f đơn ánh.',
  'Luận văn Bài toán 7 (ghi nguồn IMO 2002 chưa chính xác)',
  'published'
),
(
  (select id from topics where slug = 'pth-tren-r'),
  'ex-vmo-2005-cos',
  'Giải phương trình f(x+y) + f(x−y) = 2f(x)f(y)',
  'Tìm tất cả các hàm số $f: \mathbb{R} \to \mathbb{R}$ liên tục, $f \not\equiv 0$, thỏa mãn $f(x+y) + f(x-y) = 2f(x)f(y)$ với mọi $x, y \in \mathbb{R}$ và $f(x) \le 1$ với mọi $x$.',
  2,
  'Tìm hàm số',
  array['thay biến', 'công thức lượng giác'],
  array['Phương trình Cauchy', 'Hàm cos'],
  'Thay y = x để có f(2x) = 2f(x)² − f(0); chứng minh f(0) = 1 và f chẵn, rồi liên hệ với công thức nhân đôi của cos.',
  'VMO 2005',
  'published'
),
(
  (select id from topics where slug = 'pth-tren-r'),
  'ex-f-x-f-y',
  'Giải phương trình f(x+f(y)) = f(x) + yf(y)',
  'Tìm tất cả các hàm số $f: \mathbb{R} \to \mathbb{R}$ thỏa mãn $f(x + f(y)) = f(x) + yf(y)$ với mọi $x, y \in \mathbb{R}$.',
  3,
  'Tìm hàm số',
  array['thay biến', 'quy nạp', 'đánh giá tăng trưởng'],
  array['Tập giá trị của hàm số', 'Chu kỳ'],
  'Chứng minh f(0) = 0 bằng cách thay y = 0 và y = c = f(0). Sau đó giả sử tồn tại y₀ với f(y₀) ≠ 0 và xây dựng mâu thuẫn.',
  'Luận văn Bài toán 9 (ghi nguồn IMO 2004 chưa chính xác)',
  'published'
),
(
  (select id from topics where slug = 'pth-tren-r'),
  'ex-binh-phuong-hieu',
  'Giải phương trình f(x²−y²) = xf(x) − yf(y)',
  'Tìm tất cả các hàm số $f: \mathbb{R} \to \mathbb{R}$ thỏa mãn $f(x^2 - y^2) = xf(x) - yf(y)$ với mọi $x, y \in \mathbb{R}$.',
  2,
  'Tìm hàm số',
  array['đặt ẩn phụ', 'đưa về Cauchy'],
  array['Phương trình Cauchy', 'Hàm chẵn lẻ'],
  'Thay y = x để có f(0) = 0; thay y = 0 để có f(x²) = xf(x); đặt x = √a, y = √b để đưa về dạng cộng tính.',
  'Luận văn — Phương trình đa biến',
  'published'
),
(
  (select id from topics where slug = 'pth-tren-r'),
  'ex-olympic-2001',
  'Giải phương trình f(x+y+f(y)) = f(x) + 2y',
  'Tìm tất cả các hàm số $f: \mathbb{R} \to \mathbb{R}$ liên tục thỏa mãn $f(x + y + f(y)) = f(x) + 2y$ với mọi $x, y \in \mathbb{R}$.',
  3,
  'Tìm hàm số',
  array['song ánh', 'đưa về Cauchy'],
  array['Đơn ánh, toàn ánh, song ánh', 'Phương trình Cauchy'],
  'Chứng minh f song ánh: toàn ánh do vế phải quét hết ℝ; đơn ánh bằng cách so sánh hai cách tính f(3d) khi f(u) = f(v).',
  'Olympic 2001 (theo luận văn)',
  'published'
);

-- ============ Chuyên đề: Phương trình hàm rời rạc (4 bài) ============
insert into exercises (topic_id, slug, title, problem_latex, difficulty, type, techniques, related, hint, source, status) values
(
  (select id from topics where slug = 'pth-roi-rac'),
  'ex-imo-1977',
  'Chứng minh f(n) = n từ bất đẳng thức f(f(n)) < f(n+1)',
  'Tìm tất cả các hàm số $f: \mathbb{N} \to \mathbb{N}$ thỏa mãn $f(f(n)) < f(n+1)$ với mọi $n \in \mathbb{N}$.',
  2,
  'Tìm hàm số',
  array['nguyên lý cực hạn', 'đánh giá đơn điệu'],
  array['Nguyên lý cực hạn', 'Hàm tăng ngặt'],
  'Dùng nguyên lý cực hạn để chứng minh f tăng ngặt, sau đó kết hợp với giả thiết.',
  'IMO 1977',
  'published'
),
(
  (select id from topics where slug = 'pth-roi-rac'),
  'ex-quy-dao-2025',
  'Chứng minh không tồn tại f thỏa f(f(n)) = n + 2025',
  'Chứng minh rằng không tồn tại hàm số $f: \mathbb{N} \to \mathbb{N}$ thỏa mãn $f(f(n)) = n + 2025$ với mọi $n \in \mathbb{N}$.',
  3,
  'Chứng minh vô nghiệm',
  array['quỹ đạo', 'đồng dư', 'phép đổi chỗ'],
  array['Quỹ đạo của hàm số', 'Đồng dư'],
  'Chứng minh f(n + 2025) = f(n) + 2025, từ đó xét phép hoán vị trên các lớp đồng dư modulo 2025.',
  'Luận văn — Phân hoạch quỹ đạo',
  'published'
),
(
  (select id from topics where slug = 'pth-roi-rac'),
  'ex-nhan-tinh',
  'Chứng minh không tồn tại f thỏa hai điều kiện nhân tính và cộng tính',
  'Tìm tất cả các hàm số $f: \mathbb{N}^* \to \mathbb{N}^*$ thỏa mãn đồng thời hai điều kiện với mọi $m, n \in \mathbb{N}^*$:\n(1) $f(m \cdot f(n)) = n^2 f(m)$;\n(2) $f(m + n) \le f(m) + f(n)$.',
  3,
  'Chứng minh vô nghiệm',
  array['nhân tính', 'quy nạp', 'bất đẳng thức'],
  array['Đơn ánh', 'Nguyên lý quy nạp'],
  'Thay m = 1 và n = 1 để có f(f(n)) = n²f(1); chứng minh f(1) = 1 và f đơn ánh, rồi dùng điều kiện (2) để có f(n) ≤ n và dẫn đến n² ≤ n.',
  'Luận văn — Phương trình nhân tính',
  'published'
),
(
  (select id from topics where slug = 'pth-roi-rac'),
  'ex-cauchy-z',
  'Giải phương trình f(m+f(n)) = f(m) + n trên ℤ',
  'Tìm tất cả các hàm số $f: \mathbb{Z} \to \mathbb{Z}$ thỏa mãn $f(m + f(n)) = f(m) + n$ với mọi $m, n \in \mathbb{Z}$.',
  2,
  'Tìm hàm số',
  array['song ánh', 'Cauchy trên ℤ'],
  array['Đơn ánh, toàn ánh, song ánh', 'Phương trình Cauchy'],
  'Chứng minh f song ánh, f(0) = 0, f(f(n)) = n, rồi chứng minh tính cộng tính và đưa về nghiệm Cauchy trên ℤ.',
  'Luận văn — Cauchy trên ℤ',
  'published'
);

-- ---------- 4) Lời giải ----------
-- Lưu ý: content_latex là cột văn bản thường → LaTeX dùng dấu gạch chéo ĐƠN (\).
-- Mỗi dòng là một bước giải; explanation là diễn giải bằng lời tiếng Việt.

-- ============ Bài 1: ex-imo-2001-da-thuc ============
insert into exercise_solutions (exercise_id, step_number, content_latex, explanation) values
((select id from exercises where slug = 'ex-imo-2001-da-thuc'), 1, '$P(x) \equiv c \implies c = c^2 \implies c \in \{0, 1\}$', 'Trường hợp P là đa thức hằng: thay vào phương trình được c = c².'),
((select id from exercises where slug = 'ex-imo-2001-da-thuc'), 2, '$P$ khác hằng. Gọi $\alpha \in \mathbb{C}$ là một nghiệm của $P$ (tồn tại theo Định lý cơ bản của Đại số).', 'Mọi đa thức khác hằng đều có ít nhất một nghiệm phức.'),
((select id from exercises where slug = 'ex-imo-2001-da-thuc'), 3, 'Thay $x = \alpha$: $P(\alpha^2) = P(\alpha)P(\alpha-1) = 0$. Thay $x = \alpha+1$: $P((\alpha+1)^2) = P(\alpha+1)P(\alpha) = 0$.', 'Từ một nghiệm t bất kỳ, ta sinh ra hai nghiệm mới t² và (t+1)².'),
((select id from exercises where slug = 'ex-imo-2001-da-thuc'), 4, 'Lặp lại: $\alpha^{2^k}$ là nghiệm với mọi $k \in \mathbb{N}$. Nếu $|\alpha| \ne 1$ thì có vô số nghiệm phân biệt (module tăng nếu $|\alpha| > 1$, giảm dần về 0 nếu $0 < |\alpha| < 1$); nếu $\alpha = 0$ thì $1, 4, 25, \dots$ cũng là nghiệm. Đều vô lý. Vậy $|\alpha| = 1$.', 'Đa thức khác hằng chỉ có hữu hạn nghiệm nên mọi dãy nghiệm vô hạn phân biệt đều không thể xảy ra.'),
((select id from exercises where slug = 'ex-imo-2001-da-thuc'), 5, 'Tương tự với nghiệm $(\alpha+1)^2$: $(\alpha+1)^{2^k}$ là nghiệm với mọi $k \ge 1$, nên $|\alpha+1| = 1$ (trường hợp $\alpha+1 = 0$ lại dẫn tới $1, 4, 25, \dots$ là nghiệm — vô lý).', 'Áp dụng đúng lập luận của bước trước cho nghiệm mới.'),
((select id from exercises where slug = 'ex-imo-2001-da-thuc'), 6, '$|\alpha| = |\alpha+1| = 1 \implies \operatorname{Re}(\alpha) = -\frac{1}{2} \implies \alpha \in \{\omega, \omega^2\}$ với $\omega^2 + \omega + 1 = 0$.', 'Trên đường tròn đơn vị, hai điểm cách đều 0 và −1 chính là hai căn bậc ba nguyên thủy của đơn vị.'),
((select id from exercises where slug = 'ex-imo-2001-da-thuc'), 7, 'Mọi nghiệm của $P$ đều là $\omega$ hoặc $\omega^2$, nên $P(x) = C(x^2+x+1)^n$ với $C \in \mathbb{R}$.', 'Do hệ số thực, hai nghiệm liên hợp ω, ω² xuất hiện với cùng số bội.'),
((select id from exercises where slug = 'ex-imo-2001-da-thuc'), 8, 'Thay vào: $C(x^4+x^2+1)^n = C^2(x^2+x+1)^n(x^2-x+1)^n = C^2(x^4+x^2+1)^n \implies C \in \{0, 1\}$.', 'Dùng hằng đẳng thức (x²+x+1)(x²−x+1) = x⁴+x²+1. C = 0 cho lại P ≡ 0.'),
((select id from exercises where slug = 'ex-imo-2001-da-thuc'), 9, 'Kết luận: $P \equiv 0$ hoặc $P(x) = (x^2+x+1)^n$ với $n \in \mathbb{N}$ (trường hợp $n = 0$ chính là $P \equiv 1$).', 'Lưu ý: luận văn kết luận {0, 1} là thiếu — họ (x²+x+1)ⁿ thỏa mãn vì ω, ω² vẫn thỏa |α| = |α+1| = 1 nên bước kết luận "mọi nghiệm bằng 0" trong luận văn chưa chính xác.');

-- ============ Bài 2: ex-vmo-2006 ============
insert into exercise_solutions (exercise_id, step_number, content_latex, explanation) values
((select id from exercises where slug = 'ex-vmo-2006'), 1, 'Thay $x = 0$: $0 \cdot P(-1) = -3P(0) \implies P(0) = 0$.', 'Chọn x sao cho một vế bị triệt tiêu.'),
((select id from exercises where slug = 'ex-vmo-2006'), 2, 'Thay $x = 1$: $1 \cdot P(0) = -2P(1) \implies P(1) = 0$.', 'Dùng kết quả P(0) = 0 ở bước trên.'),
((select id from exercises where slug = 'ex-vmo-2006'), 3, 'Thay $x = 3$: $3P(2) = 0 \cdot P(3) \implies P(2) = 0$.', 'Đây chính là kỹ thuật tịnh tiến nghiệm: tìm được ba nghiệm 0, 1, 2.'),
((select id from exercises where slug = 'ex-vmo-2006'), 4, 'Theo Định lý Bézout: $P(x) = x(x-1)(x-2)Q(x)$ với $Q$ là đa thức.', '0, 1, 2 là ba nghiệm phân biệt của P.'),
((select id from exercises where slug = 'ex-vmo-2006'), 5, 'Thay vào phương trình: $x(x-1)(x-2)(x-3)Q(x-1) = (x-3)x(x-1)(x-2)Q(x)$, suy ra $Q(x-1) = Q(x)$ với vô số $x$.', 'Đẳng thức đúng với mọi x ngoài 0, 1, 2, 3; vì là các đa thức liên tục nên đúng với mọi x.'),
((select id from exercises where slug = 'ex-vmo-2006'), 6, '$Q(x-1) \equiv Q(x)$ nên $Q$ là hằng số $C$ (đa thức bất biến với phép tịnh tiến phải hằng). Kết luận: $P(x) = Cx(x-1)(x-2)$, $C \in \mathbb{R}$ tùy ý.', 'Nếu Q có bậc m ≥ 1 thì hệ số cao nhất hai vế là ax^m và a(x−1)^m, không thể bằng nhau. Thử lại thỏa mãn.');

-- ============ Bài 3: ex-chan-bac ============
insert into exercise_solutions (exercise_id, step_number, content_latex, explanation) values
((select id from exercises where slug = 'ex-chan-bac'), 1, '$P \equiv c \implies c = c^2 \implies c \in \{0, 1\}$.', 'Trường hợp đa thức hằng.'),
((select id from exercises where slug = 'ex-chan-bac'), 2, 'Với $\deg P = n \ge 1$: so sánh hệ số bậc $2n$ ở hai vế, $a_n^2 = a_n \implies a_n = 1$.', 'Hệ số cao nhất của P² là a_n², của P(x²) là a_n.'),
((select id from exercises where slug = 'ex-chan-bac'), 3, 'Giả sử $P(x) = x^n + Q(x)$ với $\deg Q = m < n$, $Q \ne 0$.', 'Giả sử còn hệ số khác 0 ở bậc thấp hơn để tìm mâu thuẫn.'),
((select id from exercises where slug = 'ex-chan-bac'), 4, 'Thay vào: $(x^n + Q(x))^2 = x^{2n} + Q(x^2) \implies 2x^nQ(x) + Q(x)^2 = Q(x^2)$.', 'Khai triển và giản ước x²ⁿ ở hai vế.'),
((select id from exercises where slug = 'ex-chan-bac'), 5, 'Bậc vế trái là $n + m$ (hệ số của $x^{n+m}$ là $2a_m \ne 0$), bậc vế phải là $2m$. Vì $m < n$ nên $n + m > 2m$: mâu thuẫn.', 'Vậy Q ≡ 0, tức P(x) = xⁿ (n ≥ 1). Kết luận: P ≡ 0, P ≡ 1 hoặc P(x) = xⁿ.');

-- ============ Bài 4: ex-nga-1999 ============
insert into exercise_solutions (exercise_id, step_number, content_latex, explanation) values
((select id from exercises where slug = 'ex-nga-1999'), 1, '$P \equiv c \implies c = c^2 \implies c \in \{0, 1\}$.', 'Trường hợp đa thức hằng.'),
((select id from exercises where slug = 'ex-nga-1999'), 2, '$P$ khác hằng: đặt $P(x) = x^m Q(x)$ với $Q(0) \ne 0$, $m \ge 0$.', 'Tách toàn bộ nghiệm 0 ra khỏi P.'),
((select id from exercises where slug = 'ex-nga-1999'), 3, 'Từ $P(x)P(x+1) = P(x^2+x)$ suy ra $Q(x)Q(x+1) = Q(x^2+x)$.', 'Vì x^m(x+1)^m = (x²+x)^m nên giản ước được.'),
((select id from exercises where slug = 'ex-nga-1999'), 4, 'Thay $x = 0$: $Q(0)Q(1) = Q(0) \implies Q(1) = 1$ (vì $Q(0) \ne 0$).', 'Điều kiện ban đầu cho Q.'),
((select id from exercises where slug = 'ex-nga-1999'), 5, 'Nếu $Q$ khác hằng, gọi $\alpha \ne 0$ là nghiệm của $Q$ có module lớn nhất. Thay $x = \alpha$: $Q(\alpha^2+\alpha) = 0$; thay $x = \alpha-1$: $Q(\alpha^2-\alpha) = 0$.', 'Vậy α(α+1) và α(α−1) đều là nghiệm của Q.'),
((select id from exercises where slug = 'ex-nga-1999'), 6, 'Tính cực đại của $|\alpha|$: $|\alpha(\alpha+1)| \le |\alpha| \implies |\alpha+1| \le 1$; tương tự $|\alpha-1| \le 1$.', 'Chia được cho |α| > 0 vì α ≠ 0.'),
((select id from exercises where slug = 'ex-nga-1999'), 7, 'Bất đẳng thức tam giác: $2 = |(\alpha+1) - (\alpha-1)| \le |\alpha+1| + |\alpha-1| \le 2$. Đẳng thức xảy ra nên $\alpha+1$ và $1-\alpha$ cùng hướng, mà $|\alpha+1| = |\alpha-1| = 1$ nên $\alpha + 1 = 1 - \alpha \implies \alpha = 0$: mâu thuẫn với $\alpha \ne 0$.', 'Vậy Q không có nghiệm khác 0, tức Q hằng; do Q(1) = 1 nên Q ≡ 1. Kết luận: P(x) = xᵐ (m ≥ 0) hoặc P ≡ 0.');

-- ============ Bài 5: ex-tap-gia-tri ============
insert into exercise_solutions (exercise_id, step_number, content_latex, explanation) values
((select id from exercises where slug = 'ex-tap-gia-tri'), 1, '$P \equiv c \implies c = c^{2026} \implies c \in \{0, 1\}$.', 'Trên ℝ, c(c²⁰²⁵ − 1) = 0 chỉ có nghiệm c = 0 hoặc c = 1.'),
((select id from exercises where slug = 'ex-tap-gia-tri'), 2, '$P$ khác hằng: tập giá trị $T = P(\mathbb{R})$ chứa vô số phần tử.', 'Đa thức bậc ≥ 1 có tập giá trị vô hạn (bậc lẻ phủ ℝ, bậc chẵn phủ một tia).'),
((select id from exercises where slug = 'ex-tap-gia-tri'), 3, 'Với mỗi $y \in T$, tồn tại $x$ sao cho $P(x) = y$: $P(y) = P(P(x)) = (P(x))^{2026} = y^{2026}$.', 'Mỗi giá trị y trong tập giá trị đều thỏa P(y) = y²⁰²⁶.'),
((select id from exercises where slug = 'ex-tap-gia-tri'), 4, 'Hai đa thức $P(y)$ và $y^{2026}$ bằng nhau tại vô số điểm $y \in T$ nên đồng nhất: $P(y) \equiv y^{2026}$.', 'Định lý đồng nhất đa thức.'),
((select id from exercises where slug = 'ex-tap-gia-tri'), 5, 'Thử lại: $P(P(x)) = (x^{2026})^{2026} = x^{2026^2} = (P(x))^{2026}$ — thỏa mãn. Kết luận: $P \equiv 0$, $P \equiv 1$ hoặc $P(x) = x^{2026}$.', 'Ba đa thức tìm được đều thỏa mãn phương trình.');

-- ============ Bài 6: ex-sai-phan ============
insert into exercise_solutions (exercise_id, step_number, content_latex, explanation) values
((select id from exercises where slug = 'ex-sai-phan'), 1, 'Viết lại phương trình: $P(x+1) - P(x) = P(x) - P(x-1)$ với mọi $x$.', 'Đưa về dạng sai phân đối xứng.'),
((select id from exercises where slug = 'ex-sai-phan'), 2, 'Đặt $\Delta P(x) = P(x+1) - P(x)$: phương trình trở thành $\Delta P(x) = \Delta P(x-1)$ với mọi $x$.', 'Toán tử sai phân tiến một bước.'),
((select id from exercises where slug = 'ex-sai-phan'), 3, '$\Delta P$ là đa thức tuần hoàn chu kỳ 1 nên phải là hằng số: $\Delta P(x) \equiv c$.', 'Đa thức tuần hoàn bắt buộc hằng vì đa thức bậc ≥ 1 không bị chặn.'),
((select id from exercises where slug = 'ex-sai-phan'), 4, 'Nếu $\deg P = n \ge 2$ thì $\deg \Delta P = n - 1 \ge 1$, mâu thuẫn với việc $\Delta P$ hằng. Vậy $P(x) = ax + b$.', 'Bậc của sai phân bằng bậc trừ 1.'),
((select id from exercises where slug = 'ex-sai-phan'), 5, 'Thử lại: $a(x+1)+b + a(x-1)+b = 2ax+2b = 2P(x)$ — thỏa mãn với mọi $a, b \in \mathbb{R}$.', 'Kết luận: mọi đa thức bậc nhất (và hằng số, khi a = 0) đều thỏa mãn.');

-- ============ Bài 7: ex-don-anh-f0 ============
insert into exercise_solutions (exercise_id, step_number, content_latex, explanation) values
((select id from exercises where slug = 'ex-don-anh-f0'), 1, 'Đặt $c = f(0)$. Phương trình trở thành $f(f(x) + y) = f(x + y) + c$ (1).', 'Ký hiệu cho gọn.'),
((select id from exercises where slug = 'ex-don-anh-f0'), 2, 'Thay $x = 0$ vào (1): $f(y + c) = f(y) + c$ với mọi $y$.', 'Suy ra f(x + nc) = f(x) + nc với mọi n ∈ ℤ (quy nạp).'),
((select id from exercises where slug = 'ex-don-anh-f0'), 3, 'Thay $y = 0$ vào (1): $f(f(x)) = f(x) + c$ với mọi $x$.', 'Hệ thức liên hệ f(f(x)) với f(x).'),
((select id from exercises where slug = 'ex-don-anh-f0'), 4, 'Giả sử $f(a) = f(b)$ với $a \ne b$: so sánh (1) cho $x = a$ và $x = b$ được $f(y + a) = f(y + b)$ với mọi $y$, tức $d = b - a$ là một chu kỳ khác 0 của f.', 'Hai giá trị bằng nhau sinh ra một chu kỳ.'),
((select id from exercises where slug = 'ex-don-anh-f0'), 5, 'Nếu $c \ne 0$: f liên tục và tuần hoàn nên bị chặn trên ℝ (đạt max, min trên một chu kỳ), nhưng $f(x + nc) = f(x) + nc$ không bị chặn — mâu thuẫn.', 'Vậy khi c ≠ 0, f không thể có hai giá trị bằng nhau.'),
((select id from exercises where slug = 'ex-don-anh-f0'), 6, 'Vậy với $c \ne 0$: f đơn ánh. Từ bước 2 và 3: $f(f(x)) = f(x) + c = f(x + c)$ nên $f(x) = x + c$ với mọi $x$.', 'Thử lại: f(f(x)+y) = x+y+2c = f(x+y)+c — thỏa mãn với mọi c ∈ ℝ.'),
((select id from exercises where slug = 'ex-don-anh-f0'), 7, 'Nếu $c = 0$: (1) thành $f(f(x) + y) = f(x + y)$. Đặt $h(x) = x - f(x)$ và thay $y = t - f(x)$: $f(t) = f(t + h(x))$ với mọi $x, t$ — mọi giá trị của h đều là chu kỳ của f.', 'Chuyển bài toán về tập các chu kỳ.'),
((select id from exercises where slug = 'ex-don-anh-f0'), 8, 'h liên tục và $h(0) = 0$. Nếu $h \equiv 0$ thì $f(x) = x$. Ngược lại, nếu $h(x_0) \ne 0$ thì (do tính liên tục) cả đoạn $[0, h(x_0)]$ gồm toàn chu kỳ; tập chu kỳ là nhóm con đóng của ℝ chứa một đoạn nên là toàn bộ ℝ: f hằng, và $f \equiv 0$ (vì c = 0).', 'Kết luận: f ≡ 0 hoặc f(x) = x + c với c ∈ ℝ tùy ý.'),
((select id from exercises where slug = 'ex-don-anh-f0'), 9, 'Lưu ý về luận văn: kết luận {0, id} là thiếu họ nghiệm $f(x) = x + c$; và bước suy ra c = 0 từ tính tuần hoàn trong luận văn không chặt chẽ. Giả thiết f liên tục là cần thiết để loại các nghiệm hoang dã (như $f(x) = x - \lfloor x \rfloor$ khi c = 0).', 'Ví dụ f(x) = x − ⌊x⌋ thỏa mãn phương trình với c = 0 nhưng không liên tục.');

-- ============ Bài 8: ex-vmo-2005-cos ============
insert into exercise_solutions (exercise_id, step_number, content_latex, explanation) values
((select id from exercises where slug = 'ex-vmo-2005-cos'), 1, 'Thay $y = 0$: $2f(x) = 2f(x)f(0)$ với mọi $x$. Vì $f \not\equiv 0$ nên $f(0) = 1$.', 'Nếu f ≡ 0 thì bị loại theo giả thiết.'),
((select id from exercises where slug = 'ex-vmo-2005-cos'), 2, 'Thay $x = 0$: $f(y) + f(-y) = 2f(0)f(y) = 2f(y) \implies f(-y) = f(y)$: f là hàm chẵn.', 'Tính đối xứng của phương trình cho thấy f chẵn.'),
((select id from exercises where slug = 'ex-vmo-2005-cos'), 3, 'Thay $y = x$: $f(2x) + f(0) = 2f(x)^2 \implies f(2x) = 2f(x)^2 - 1$.', 'Công thức nhân đôi quen thuộc.'),
((select id from exercises where slug = 'ex-vmo-2005-cos'), 4, 'Vì $f(2x) \le 1$ nên $f(x)^2 \le 1$, tức $-1 \le f(x) \le 1$ với mọi $x$.', 'Giả thiết f ≤ 1 kết hợp công thức nhân đôi cho chặn dưới.'),
((select id from exercises where slug = 'ex-vmo-2005-cos'), 5, 'Do f liên tục, $f(0) = 1$ và $-1 \le f \le 1$, tồn tại hàm liên tục $g$ với $g(0) = 0$ sao cho $f(x) = \cos g(x)$ với mọi $x$.', 'Phép nâng giá trị f lên đối số của cos (chọn nhánh arccos liên tục qua 0).'),
((select id from exercises where slug = 'ex-vmo-2005-cos'), 6, 'Phương trình trở thành $\cos g(x+y) + \cos g(x-y) = 2\cos g(x)\cos g(y) = \cos(g(x)+g(y)) + \cos(g(x)-g(y))$. Nhờ tính liên tục và $g(0) = 0$, mọi nhánh đều quy về $g(x+y) = g(x) + g(y)$ với mọi $x, y$.', 'Bước chọn nhánh là phần tinh tế của bài VMO 2005; kết quả cuối không phụ thuộc cách chọn.'),
((select id from exercises where slug = 'ex-vmo-2005-cos'), 7, 'g liên tục và cộng tính nên $g(x) = cx$ (Định lý 2.2.2) $\implies f(x) = \cos(cx)$ với $c \in \mathbb{R}$ tùy ý.', 'Thử lại: cos(cx+cy) + cos(cx−cy) = 2cos(cx)cos(cy) — thỏa mãn. Khi c = 0 ta có f ≡ 1.');

-- ============ Bài 9: ex-f-x-f-y ============
insert into exercise_solutions (exercise_id, step_number, content_latex, explanation) values
((select id from exercises where slug = 'ex-f-x-f-y'), 1, 'Thay $x = 0$: $f(f(y)) = f(0) + yf(y)$ (1).', 'Hệ thức cho f(f(y)).'),
((select id from exercises where slug = 'ex-f-x-f-y'), 2, 'Thay $y = 0$: $f(x + f(0)) = f(x)$ với mọi $x$ — vậy $c = f(0)$ là một chu kỳ của f.', 'f tuần hoàn với chu kỳ c.'),
((select id from exercises where slug = 'ex-f-x-f-y'), 3, 'Thay $y = c$: $f(x + f(c)) = f(x) + cf(c)$. Vì $f(c) = f(0) = c$ (tuần hoàn) nên $f(x + c) = f(x) + c^2$; kết hợp bước 2: $f(x) = f(x) + c^2 \implies c = 0$.', 'Vậy f(0) = 0 và (1) trở thành f(f(y)) = yf(y) (2).'),
((select id from exercises where slug = 'ex-f-x-f-y'), 4, 'Quy nạp từ phương trình gốc: $f(x + nf(y)) = f(x) + nyf(y)$ với mọi $n \in \mathbb{N}$ (3).', 'Bước chuyển: f(x + (n+1)f(y)) = f((x + f(y)) + nf(y)) = f(x + f(y)) + nyf(y).'),
((select id from exercises where slug = 'ex-f-x-f-y'), 5, 'Giả sử tồn tại $y_0$ sao cho $f(y_0) = a \ne 0$. Từ (2): $f(a) = f(f(y_0)) = y_0 f(y_0) = y_0 a$.', 'Mục tiêu: chỉ ra giả sử này dẫn tới mâu thuẫn.'),
((select id from exercises where slug = 'ex-f-x-f-y'), 6, 'Áp dụng (3) với $x = 0, y = y_0$: $f(na) = ny_0a$ với mọi $n$ (4).', 'Giá trị f tại các bội của a.'),
((select id from exercises where slug = 'ex-f-x-f-y'), 7, 'Tính $f(ny_0a)$ theo hai cách. Cách 1 — (3) với $x = 0, y = a$: $f(nf(a)) = naf(a) \implies f(ny_0a) = ny_0a^2$. Cách 2 — (4) với $n \to ny_0$: $f(ny_0a) = ny_0^2a$. So sánh: $a = y_0$.', 'Hai cách tính cùng một giá trị phải cho cùng kết quả.'),
((select id from exercises where slug = 'ex-f-x-f-y'), 8, 'Kết hợp (2): $f(f(y_0)) = y_0 f(y_0) \implies f(y_0) = y_0^2$; mà $f(y_0) = y_0$ nên $y_0 = y_0^2 \implies y_0 = 1$ (vì $y_0 \ne 0$).', 'Điểm duy nhất có thể mang giá trị khác 0 là y = 1.'),
((select id from exercises where slug = 'ex-f-x-f-y'), 9, 'Như vậy nếu $f \not\equiv 0$ thì $f(y) = 0$ với mọi $y \ne 1$ và $f(1) = 1$. Thay $y = 1$ vào phương trình: $f(x + 1) = f(x) + 1$; cho $x = -1$: $f(0) = f(-1) + 1 = 0 + 1 = 1$, vô lý.', 'Mâu thuẫn chứng tỏ không tồn tại y₀ với f(y₀) ≠ 0. Kết luận: f ≡ 0 (thử lại thỏa mãn).');

-- ============ Bài 10: ex-binh-phuong-hieu ============
insert into exercise_solutions (exercise_id, step_number, content_latex, explanation) values
((select id from exercises where slug = 'ex-binh-phuong-hieu'), 1, 'Thay $y = 0$: $f(x^2) = xf(x)$ với mọi $x$.', 'Chú ý f(0) = 0 (cho x = 0, y = 0).'),
((select id from exercises where slug = 'ex-binh-phuong-hieu'), 2, 'Thay $x = 0$: $f(-y^2) = -yf(y)$. Kết hợp bước 1: $f(-t) = -f(t)$ — f là hàm lẻ.', 'Với t ≥ 0: f(−t) = −f(t) theo đúng hai công thức trên.'),
((select id from exercises where slug = 'ex-binh-phuong-hieu'), 3, 'Với $a, b \ge 0$, đặt $x = \sqrt{a}, y = \sqrt{b}$: $f(a - b) = \sqrt{a}\,f(\sqrt{a}) - \sqrt{b}\,f(\sqrt{b}) = f(a) - f(b)$.', 'Dùng f(x²) = xf(x) cho x = √a và x = √b.'),
((select id from exercises where slug = 'ex-binh-phuong-hieu'), 4, 'Mở rộng cho mọi $u, v$: chọn $N$ đủ lớn để $u + N, v + N \ge 0$. Khi đó $f(u - v) = f((u+N) - (v+N)) = f(u+N) - f(v+N) = f(u) - f(v)$.', 'Trong đó f(u+N) = f(u) + f(N) suy từ bước 3 với cặp (u+N, N).'),
((select id from exercises where slug = 'ex-binh-phuong-hieu'), 5, 'Suy ra f cộng tính: $f(u + v) = f(u - (-v)) = f(u) - f(-v) = f(u) + f(v)$ với mọi $u, v$.', 'Dùng bước 4 và tính lẻ.'),
((select id from exercises where slug = 'ex-binh-phuong-hieu'), 6, 'Khai triển $f((u+v)^2)$ theo hai cách. Cách 1 (bước 1): $(u+v)f(u+v) = (u+v)(f(u) + f(v))$. Cách 2 (bước 5 + bước 1): $f(u^2 + 2uv + v^2) = f(u^2) + f(2uv) + f(v^2) = uf(u) + f(2uv) + vf(v)$. So sánh: $f(2uv) = uf(v) + vf(u)$.', 'Kỹ thuật khai triển hai cách kinh điển.'),
((select id from exercises where slug = 'ex-binh-phuong-hieu'), 7, 'Cho $v = 1$: $f(2u) = uf(1) + f(u)$. Vì f cộng tính nên $f(2u) = 2f(u)$, suy ra $f(u) = uf(1)$. Đặt $c = f(1)$: $f(x) = cx$ với $c \in \mathbb{R}$ tùy ý.', 'Thử lại: f(x²−y²) = c(x²−y²) = x·cx − y·cy — thỏa mãn.');

-- ============ Bài 11: ex-olympic-2001 ============
insert into exercise_solutions (exercise_id, step_number, content_latex, explanation) values
((select id from exercises where slug = 'ex-olympic-2001'), 1, 'f toàn ánh: cố định $x_0$, khi $y$ chạy thì $f(x_0 + y + f(y)) = f(x_0) + 2y$ nhận mọi giá trị thực.', 'Vế phải quét khắp ℝ nên mọi số thực đều thuộc tập giá trị của f.'),
((select id from exercises where slug = 'ex-olympic-2001'), 2, 'Giả sử $f(u) = f(v)$, đặt $d = v - u$. So sánh phương trình với $x = u$ và $x = v$: $f(t + u + f(u)) = f(t) + 2u$ và $f(t + v + f(v)) = f(t) + 2v$; vì $f(u) = f(v)$ nên $f(s + d) = f(s) + 2d$ với mọi $s$ (A).', 'Từ f(u) = f(v) rút ra hệ thức tịnh tiến quan trọng.'),
((select id from exercises where slug = 'ex-olympic-2001'), 3, 'Đặt $p = f(0)$. Thay $x = y = 0$: $f(p) = p$.', 'Giá trị tại điểm bất động.'),
((select id from exercises where slug = 'ex-olympic-2001'), 4, 'Từ (A) với $s = 0$: $f(d) = p + 2d$. Thay $x = 0, y = d$ vào phương trình: $f(d + f(d)) = p + 2d$. Mặt khác, áp dụng (A) ba lần: $f(d + f(d)) = f(3d + p) = p + 6d$. So sánh: $p + 6d = p + 2d \implies d = 0$.', 'Vậy f(u) = f(v) kéo theo u = v: f đơn ánh.'),
((select id from exercises where slug = 'ex-olympic-2001'), 5, 'f vừa đơn ánh vừa toàn ánh nên là song ánh. Từ $f(f(0)) = f(0)$ và tính đơn ánh: $f(0) = 0$.', 'Hệ quả của tính song ánh.'),
((select id from exercises where slug = 'ex-olympic-2001'), 6, 'Thay $x = 0$: $f(y + f(y)) = 2y$ với mọi $y$ (B). Đặt $g(y) = y + f(y)$ thì $f(g(y)) = 2y$, tức $g = f^{-1} \circ (y \mapsto 2y)$ nên g song ánh. Với $t$ bất kỳ, đặt $y = g^{-1}(t)$: $f(x + t) = f(x) + 2g^{-1}(t)$. Cho $x = 0$: $f(t) = 2g^{-1}(t) \implies g^{-1}(t) = \frac{f(t)}{2}$. Vậy $f(x + t) = f(x) + f(t)$: f cộng tính.', 'Dùng tính song ánh để thay biến g(y) bằng t tùy ý.'),
((select id from exercises where slug = 'ex-olympic-2001'), 7, 'f liên tục và cộng tính nên $f(x) = cx$ (Định lý 2.2.2). Thay vào phương trình: $c(x + y + cy) = cx + 2y \implies c^2 + c - 2 = 0 \implies c \in \{1, -2\}$.', 'Kết luận: f(x) = x hoặc f(x) = −2x.'),
((select id from exercises where slug = 'ex-olympic-2001'), 8, 'Thử lại. $f(x) = x$: $f(x + y + y) = x + 2y$ — thỏa mãn. $f(x) = -2x$: $f(x + y - 2y) = f(x - y) = -2x + 2y = f(x) + 2y$ — thỏa mãn.', 'Lưu ý: luận văn chỉ kết luận f(x) = x là thiếu nghiệm f(x) = −2x.');

-- ============ Bài 12: ex-imo-1977 ============
insert into exercise_solutions (exercise_id, step_number, content_latex, explanation) values
((select id from exercises where slug = 'ex-imo-1977'), 1, 'Với mỗi $n$, tập $A_n = \{f(n), f(n+1), \dots\} \subset \mathbb{N}$ khác rỗng nên có phần tử nhỏ nhất; gọi $i_n \ge n$ là chỉ số thỏa $f(i_n) = \min A_n$.', 'Nguyên lý cực hạn: mọi tập con khác rỗng của ℕ đều có phần tử nhỏ nhất.'),
((select id from exercises where slug = 'ex-imo-1977'), 2, 'Với $n = 0$: nếu $i_0 > 0$ thì theo giả thiết $f(f(i_0 - 1)) < f(i_0)$. Vì $f(i_0 - 1) \in \mathbb{N}$ nên $f(f(i_0 - 1)) \in A_0$ — mâu thuẫn với $f(i_0) = \min A_0$. Vậy $i_0 = 0$, tức $f(0) = \min A_0$.', 'Bước cơ sở của quy nạp: f(0) nhỏ hơn hoặc bằng mọi f(m).'),
((select id from exercises where slug = 'ex-imo-1977'), 3, 'Giả sử $i_k = k$ với mọi $k < n$ (f tăng ngặt trên đoạn đầu). Nếu $i_n > n$ thì $f(f(i_n - 1)) < f(i_n)$; do $i_n - 1 \ge n$ nên $f(i_n - 1) \in A_n$, kéo theo $f(f(i_n - 1)) \in A_n$ và nhỏ hơn $\min A_n$: mâu thuẫn. Vậy $i_n = n$.', 'Bước chuyển quy nạp; đồng thời f(n−1) = min A_{n−1} nên f(n−1) < f(n).'),
((select id from exercises where slug = 'ex-imo-1977'), 4, 'Suy ra f tăng ngặt trên ℕ, do đó $f(n) \ge n$ với mọi $n$.', 'Hàm tăng ngặt từ ℕ vào ℕ không thể nhảy lùi.'),
((select id from exercises where slug = 'ex-imo-1977'), 5, 'Từ giả thiết $f(f(n)) < f(n+1)$ và f tăng ngặt: $f(n) < n + 1$, tức $f(n) \le n$.', 'Tăng ngặt cho phép khử f ở hai vế bất đẳng thức.'),
((select id from exercises where slug = 'ex-imo-1977'), 6, 'Kết hợp $n \le f(n) \le n$: $f(n) = n$ với mọi $n$. Thử lại: $f(f(n)) = n < n + 1 = f(n+1)$ — thỏa mãn.', 'Nghiệm duy nhất là hàm đồng nhất.');

-- ============ Bài 13: ex-quy-dao-2025 ============
insert into exercise_solutions (exercise_id, step_number, content_latex, explanation) values
((select id from exercises where slug = 'ex-quy-dao-2025'), 1, 'Giả sử tồn tại f thỏa $f(f(n)) = n + 2025$. Áp dụng f vào hai vế: $f(f(f(n))) = f(n + 2025)$; mặt khác $f(f(f(n))) = f(n) + 2025$. Vậy $f(n + 2025) = f(n) + 2025$ với mọi $n$.', 'Hệ thức tịnh tiến theo chu kỳ 2025.'),
((select id from exercises where slug = 'ex-quy-dao-2025'), 2, 'Nếu $m \equiv n \pmod{2025}$ thì $f(m) \equiv f(n) \pmod{2025}$. Vậy f cảm sinh một ánh xạ $\sigma$ trên $\mathbb{Z}_{2025}$: $\sigma([n]) = [f(n)]$.', 'f bảo toàn lớp đồng dư modulo 2025.'),
((select id from exercises where slug = 'ex-quy-dao-2025'), 3, 'Vì $f(f(n)) = n + 2025 \equiv n \pmod{2025}$ nên $\sigma(\sigma([n])) = [n]$: $\sigma$ là một phép đổi chỗ (involution).', 'Áp dụng σ hai lần trở về chính mình.'),
((select id from exercises where slug = 'ex-quy-dao-2025'), 4, 'σ không có điểm bất động: nếu $\sigma([n]) = [n]$ thì $f(n) = n + 2025k$; khi đó $f(f(n)) = f(n + 2025k) = f(n) + 2025k = n + 4045k$, nhưng $f(f(n)) = n + 2025$ nên $k = \frac{1}{2}$ — vô lý.', 'Bước f(n + 2025k) = f(n) + 2025k lặp lại từ hệ thức ở bước 1.'),
((select id from exercises where slug = 'ex-quy-dao-2025'), 5, 'Một phép đổi chỗ không có điểm bất động phải ghép các phần tử thành từng cặp rời nhau, nhưng $\mathbb{Z}_{2025}$ có 2025 phần tử (một số lẻ) — không thể ghép cặp. Mâu thuẫn.', 'Kết luận: không tồn tại hàm f thỏa mãn bài toán.');

-- ============ Bài 14: ex-nhan-tinh ============
insert into exercise_solutions (exercise_id, step_number, content_latex, explanation) values
((select id from exercises where slug = 'ex-nhan-tinh'), 1, 'Thay $m = 1$ vào (1): $f(f(n)) = n^2 f(1)$ (A). Thay $n = 1$: $f(mf(1)) = f(m)$ (B).', 'Hai hệ thức xuất phát từ điều kiện nhân tính.'),
((select id from exercises where slug = 'ex-nhan-tinh'), 2, 'Đặt $a = f(1)$. Từ (A) với $n = 1$: $f(f(1)) = f(1) \implies f(a) = a$.', 'a là điểm bất động của f.'),
((select id from exercises where slug = 'ex-nhan-tinh'), 3, 'f đơn ánh: nếu $f(u) = f(v)$ thì $f(f(u)) = f(f(v)) \implies u^2 a = v^2 a \implies u = v$ (vì $a \ge 1 > 0$ và $u, v \in \mathbb{N}^*$).', 'Dùng (A) để chuyển đẳng thức của f về đẳng thức của biến.'),
((select id from exercises where slug = 'ex-nhan-tinh'), 4, 'Từ (B): $f(am) = f(m)$ với mọi m; kết hợp tính đơn ánh: $am = m \implies a = 1$. Vậy $f(1) = 1$ và (A) trở thành $f(f(n)) = n^2$.', 'Bước then chốt: f(1) phải bằng 1.'),
((select id from exercises where slug = 'ex-nhan-tinh'), 5, 'Từ (2): $f(n) = f(1 + 1 + \dots + 1) \le n f(1) = n$ với mọi $n$.', 'Điều kiện cộng tính cho chặn trên f(n) ≤ n.'),
((select id from exercises where slug = 'ex-nhan-tinh'), 6, 'Kết hợp với (A): $n^2 = f(f(n)) \le f(n) \le n$ với mọi $n$.', 'Áp dụng bước 5 cho giá trị f(n).'),
((select id from exercises where slug = 'ex-nhan-tinh'), 7, '$n^2 \le n$ vô lý với mọi $n \ge 2$ (chẳng hạn $n = 2$: $4 \le 2$). Kết luận: không tồn tại hàm nào thỏa mãn đồng thời hai điều kiện.', 'Lưu ý: miền xác định là ℕ* (số nguyên dương); trên tập này bài toán vô nghiệm.');

-- ============ Bài 15: ex-cauchy-z ============
insert into exercise_solutions (exercise_id, step_number, content_latex, explanation) values
((select id from exercises where slug = 'ex-cauchy-z'), 1, 'f toàn ánh: cố định $m$, khi $n$ chạy khắp ℤ thì $f(m) + n$ nhận mọi giá trị nguyên, và giá trị đó đều nằm trong tập giá trị của f.', 'Vế phải quét khắp ℤ.'),
((select id from exercises where slug = 'ex-cauchy-z'), 2, 'f đơn ánh: nếu $f(a) = f(b)$ thì $f(m + f(a)) = f(m + f(b)) \implies f(m) + a = f(m) + b \implies a = b$.', 'So sánh phương trình tại n = a và n = b.'),
((select id from exercises where slug = 'ex-cauchy-z'), 3, 'f là song ánh. Thay $m = n = 0$: $f(f(0)) = f(0)$; do f đơn ánh: $f(0) = 0$.', 'Phần tử 0 được ghim tại 0.'),
((select id from exercises where slug = 'ex-cauchy-z'), 4, 'Thay $m = 0$: $f(f(n)) = n$ với mọi $n$ (C).', 'f là phép nghịch đảo của chính nó.'),
((select id from exercises where slug = 'ex-cauchy-z'), 5, 'Với $u$ bất kỳ, do f song ánh tồn tại $t$ sao cho $f(t) = u$; từ (C): $t = f(u)$. Thay $n = t$ vào phương trình: $f(m + u) = f(m) + t = f(m) + f(u)$ — f cộng tính trên ℤ.', 'Mọi u đều viết được dưới dạng f(t) nhờ tính song ánh.'),
((select id from exercises where slug = 'ex-cauchy-z'), 6, 'Nghiệm của phương trình Cauchy trên ℤ là $f(n) = cn$ với $c = f(1) \in \mathbb{Z}$.', 'Tính cộng tính kéo theo f(n) = nf(1) bằng quy nạp hai phía.'),
((select id from exercises where slug = 'ex-cauchy-z'), 7, 'Thay vào (C): $f(f(n)) = c^2 n = n \implies c^2 = 1 \implies c = \pm 1$.', 'Điều kiện nghịch đảo chọn ra hai hằng số.'),
((select id from exercises where slug = 'ex-cauchy-z'), 8, 'Thử lại. $f(n) = n$: $f(m + n) = m + n = f(m) + n$ — thỏa mãn. $f(n) = -n$: $f(m - n) = n - m = -m + n = f(m) + n$ — thỏa mãn. Kết luận: $f(n) = n$ hoặc $f(n) = -n$.', 'Hai nghiệm duy nhất của bài toán.');
-- ============================================================
-- Nạp dữ liệu vào cấu trúc V3 (3 khung lý thuyết, 2 khung bài tập)
-- ============================================================

DO $$
DECLARE
    lesson_record RECORD;
    section_json JSONB;
    v_supp TEXT;
    v_found TEXT;
    v_char TEXT;
BEGIN
    FOR lesson_record IN SELECT id, sections FROM lessons WHERE sections IS NOT NULL AND sections != '[]'::jsonb LOOP
        v_supp := '';
        v_found := '';
        v_char := '';
        
        FOR section_json IN SELECT * FROM jsonb_array_elements(lesson_record.sections) LOOP
            IF section_json->>'type' = 'definition' OR section_json->>'type' = 'theorem' THEN
                v_found := v_found || '<h4>' || COALESCE(section_json->>'title', '') || '</h4><p>' || COALESCE(section_json->>'body', '') || '</p>';
            ELSIF section_json->>'type' = 'technique' THEN
                v_supp := v_supp || '<h4>' || COALESCE(section_json->>'title', '') || '</h4><p>' || COALESCE(section_json->>'body', '') || '</p>';
            ELSIF section_json->>'type' = 'example' THEN
                v_char := v_char || '<h4>' || COALESCE(section_json->>'title', '') || '</h4><p>' || COALESCE(section_json->>'body', '') || '</p>';
            END IF;
        END LOOP;
        
        UPDATE lessons 
        SET 
            foundational_knowledge = v_found,
            supplementary_knowledge = v_supp,
            characteristic_exercises = v_char
        WHERE id = lesson_record.id;
    END LOOP;
END $$;

UPDATE exercises SET question = problem_latex WHERE (question = '' OR question IS NULL) AND problem_latex IS NOT NULL;

DO $$
DECLARE
    ex_record RECORD;
    v_solution TEXT;
BEGIN
    FOR ex_record IN SELECT id FROM exercises LOOP
        SELECT string_agg(content_latex || ' ' || explanation, e'\n' ORDER BY step_number)
        INTO v_solution
        FROM exercise_solutions
        WHERE exercise_id = ex_record.id;
        
        IF v_solution IS NOT NULL AND v_solution != '' THEN
            UPDATE exercises 
            SET detailed_solution = v_solution
            WHERE id = ex_record.id;
        END IF;
    END LOOP;
END $$;
