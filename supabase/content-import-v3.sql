-- ============================================================
-- Hàm số — Nạp nội dung chính v3 (Idempotent, Markdown)
-- ============================================================

-- ---------- 1) Chuyên đề ----------
INSERT INTO topics (slug, title, description, display_order) VALUES
('nen-tang', 'Kiến thức nền tảng', 'Ánh xạ, hàm số, đơn ánh — toàn ánh — song ánh; nền tảng cho mọi dạng phương trình hàm.', 1),
('pth-da-thuc', 'Phương trình hàm đa thức', 'Phương trình hàm với nghiệm là đa thức: nghiệm, bậc, đồng nhất thức, đánh giá module.', 2),
('pth-tren-r', 'Phương trình hàm trên tập số thực', 'Kỹ thuật thay biến, khảo sát tập giá trị, phương trình Cauchy và các dạng mở rộng.', 3),
('pth-roi-rac', 'Phương trình hàm rời rạc', 'Phương trình hàm trên tập số nguyên: quỹ đạo, nguyên lý cực hạn, phân hoạch quỹ đạo.', 4)
ON CONFLICT (slug) DO UPDATE SET 
  title = EXCLUDED.title, 
  description = EXCLUDED.description, 
  display_order = EXCLUDED.display_order;

-- ---------- 2) Bài học ----------
INSERT INTO lessons (topic_id, slug, title, objective, display_order, is_published, foundational_knowledge, supplementary_knowledge, characteristic_exercises) VALUES
(
  (SELECT id FROM topics WHERE slug = 'nen-tang'), 'lich-su-phuong-trinh-ham', 'Lịch sử phương trình hàm', 'Hiểu nguồn gốc của phương trình hàm, từ phương trình Cauchy đến các bài toán Olympic hiện đại.', 1, true,
  '### Phương trình hàm là gì
Phương trình hàm là phương trình mà ẩn số là một hàm số. Người giải cần tìm tất cả các hàm số thỏa mãn một (hoặc nhiều) đẳng thức cho trước trên một miền xác định.
Ví dụ: tìm mọi hàm $f: \mathbb{R} \to \mathbb{R}$ thỏa mãn $f(x+y) = f(x) + f(y)$ với mọi $x, y \in \mathbb{R}$.

### Phương trình hàm trong Olympic
Phương trình hàm được sử dụng rộng rãi trong các bài toán Olympic và các kỳ thi học sinh giỏi, góp phần rèn luyện khả năng suy luận, phát hiện cấu trúc và xây dựng chiến lược giải toán.',
  '### Cách tiếp cận một bài phương trình hàm
Quy trình chung gồm các bước:
1. Xác định rõ tập nguồn và tập đích của hàm số.
2. Thay các giá trị đặc biệt ($0$, $1$, $-1$, nghiệm của biểu thức...) để thu thập thông tin.
3. Khai thác các tính chất: đơn ánh, toàn ánh, chẵn/lẻ, chu kỳ, đơn điệu.
4. Dự đoán nghiệm, chứng minh và thử lại.',
  '### Phương trình Cauchy
Phương trình $f(x+y) = f(x) + f(y)$ được nghiên cứu bởi nhà toán học Augustin-Louis Cauchy. Phương trình này đặt nền tảng cho nhiều nghiên cứu về tính chất của hàm số và mối liên hệ giữa các điều kiện đại số với các tính chất như liên tục, đơn điệu.
Nghiệm liên tục của phương trình này là $f(x) = ax$ với $a = f(1)$.'
),
(
  (SELECT id FROM topics WHERE slug = 'nen-tang'), 'anh-xa-ham-so', 'Ánh xạ và hàm số', 'Nắm vững khái niệm ánh xạ, hàm số; phân biệt tập nguồn, tập đích, tập xác định, tập giá trị.', 2, true,
  '### Ánh xạ và hàm số
Ánh xạ từ tập $X$ vào tập $Y$ là quy tắc cho tương ứng mỗi phần tử $x \in X$ với đúng một phần tử $y \in Y$, ký hiệu $f: X \to Y$.
Hàm số là ánh xạ mà tập nguồn và tập đích là các tập hợp số. Tập nguồn gọi là tập xác định $D_f$; các tập số thường gặp: $\mathbb{N}$ (tự nhiên), $\mathbb{Z}$ (nguyên), $\mathbb{Q}$ (hữu tỉ), $\mathbb{R}$ (thực), $\mathbb{C}$ (phức).',
  '### Đọc kỹ tập nguồn và tập đích
Khi đọc đề phương trình hàm, việc đầu tiên là xác định rõ ba yếu tố: tập nguồn $X$, tập đích $Y$ và dạng điều kiện.
Nhiều sai lầm bắt nguồn từ việc thay các giá trị không thuộc tập nguồn, hoặc quên điều kiện giá trị $f(x)$ phải thuộc tập đích.',
  '### Ví dụ minh họa
Quy tắc $f: \mathbb{R} \to \mathbb{R}$, $f(x) = 2x + 1$ là một hàm số.
Quy tắc $f: \mathbb{N} \to \mathbb{N}$, $f(n) = n - 5$ không phải là ánh xạ vì $f(1) = -4 \notin \mathbb{N}$.
Trong bài toán rời rạc $f: \mathbb{N}^* \to \mathbb{N}^*$, giá trị $f(n)$ bắt buộc là số nguyên dương — đây là một ràng buộc quan trọng khi giải.'
),
(
  (SELECT id FROM topics WHERE slug = 'nen-tang'), 'don-anh-toan-anh-song-anh', 'Đơn ánh, toàn ánh, song ánh', 'Nhận biết và chứng minh đơn ánh, toàn ánh, song ánh — công cụ cốt lõi của phương trình hàm.', 3, true,
  '### Ba khái niệm cơ bản
$f$ đơn ánh nếu $f(x_1) = f(x_2) \Rightarrow x_1 = x_2$.
$f$ toàn ánh nếu với mọi $y \in Y$ tồn tại $x \in X$ sao cho $f(x) = y$.
$f$ song ánh nếu vừa đơn ánh vừa toàn ánh; khi đó tồn tại hàm ngược $f^{-1}$ thỏa mãn $f^{-1}(f(x)) = x$ và $f(f^{-1}(y)) = y$.

### Tính đơn ánh và toàn ánh của hàm hợp
Nếu $f \circ g$ là đơn ánh thì $g$ là đơn ánh.
Nếu $f \circ g$ là toàn ánh thì $f$ là toàn ánh.
Nếu $f \circ g$ là song ánh thì phương trình $f(g(x)) = y$ có nghiệm duy nhất với mọi $y$.',
  '### Kỹ thuật chứng minh
Chứng minh đơn ánh: giả sử $f(x_1) = f(x_2)$, dùng phương trình hàm với các phép thay biến khéo léo để ép ra $x_1 = x_2$.
Chứng minh toàn ánh: chỉ ra rằng vế phải (hoặc một biểu thức chứa $f$) nhận mọi giá trị khi biến chạy trên tập nguồn.',
  '### Ví dụ minh họa
$f: \mathbb{R} \to \mathbb{R}$, $f(x) = 2x + 1$ là song ánh:
• Đơn ánh: $2a + 1 = 2b + 1 \Rightarrow a = b$.
• Toàn ánh: với mọi $y$, chọn $x = \frac{y-1}{2}$ thì $f(x) = y$.
Hàm ngược: $f^{-1}(x) = \frac{x-1}{2}$.'
),
(
  (SELECT id FROM topics WHERE slug = 'nen-tang'), 'ham-so-tap-gia-tri', 'Hàm số: tập xác định và tập giá trị', 'Phân biệt tập xác định và tập giá trị; biết khai thác tập giá trị trong bài toán phương trình hàm.', 4, true,
  '### Tập giá trị
Tập giá trị của $f$ là $f(X) = \{ f(x) : x \in X \}$ — tập tất cả các giá trị mà $f$ nhận được.
Ví dụ: $f(x) = x^2$ trên $\mathbb{R}$ có tập giá trị $[0; +\infty)$; $f(x) = x^3$ trên $\mathbb{R}$ có tập giá trị $\mathbb{R}$.',
  '### Kỹ thuật khảo sát tập giá trị
Nếu $t \in f(X)$ thì tồn tại $x$ sao cho $f(x) = t$, ta được quyền thay $t$ vào các vị trí thuận lợi của phương trình.
Nếu một đẳng thức đúng với mọi $t$ thuộc tập giá trị vô hạn của một đa thức $P$, thì hai đa thức tương ứng phải đồng nhất (Định lý đồng nhất đa thức).',
  '### Ví dụ minh họa
Trong bài toán $P(P(x)) = (P(x))^{2026}$: với mọi $y$ thuộc tập giá trị của $P$, tồn tại $x$ để $P(x) = y$. Thay $x$ vào phương trình: $P(y) = y^{2026}$. Vì tập giá trị của đa thức bậc dương là vô hạn, hai đa thức $P(t)$ và $t^{2026}$ đồng nhất, suy ra $P(x) = x^{2026}$.'
),
(
  (SELECT id FROM topics WHERE slug = 'pth-da-thuc'), 'so-phuc-module', 'Số phức và module', 'Nhắc lại số phức và module; biết dùng đánh giá module để chặn nghiệm của đa thức.', 1, true,
  '### Số phức và module
Số phức có dạng $z = a + bi$ với $a, b \in \mathbb{R}$ và $i^2 = -1$. Module của $z$ là $|z| = \sqrt{a^2 + b^2}$.
Số liên hợp $\overline{z} = a - bi$; ta có $z \cdot \overline{z} = |z|^2$.

### Bất đẳng thức tam giác
Với mọi số phức $z_1, z_2$: $|z_1 + z_2| \le |z_1| + |z_2|$.
Chứng minh: $|z_1 + z_2|^2 = (z_1 + z_2)(\overline{z_1} + \overline{z_2}) = |z_1|^2 + |z_2|^2 + 2\operatorname{Re}(z_1 \overline{z_2}) \le |z_1|^2 + |z_2|^2 + 2|z_1||z_2| = (|z_1| + |z_2|)^2$. Lấy căn hai vế ta được điều phải chứng minh.

### Định lý cơ bản của đại số
Mọi đa thức bậc $n \ge 1$ với hệ số thực (hoặc phức) đều có đúng $n$ nghiệm trên tập số phức $\mathbb{C}$ (tính cả nghiệm bội).
Vì vậy, một đa thức bậc $n$ không thể có quá $n$ nghiệm phân biệt — cơ sở cho kỹ thuật tạo ra vô số nghiệm để suy ra điều vô lý.',
  '### Kỹ thuật đánh giá module
Giả sử đa thức $P$ có nghiệm $\alpha$. Dùng phương trình để sinh ra các nghiệm mới (ví dụ $\alpha^2$, $\alpha(\alpha+1)$...). Nếu các nghiệm này có module tăng dần, $P$ sẽ có vô số nghiệm — mâu thuẫn. Vì vậy phải có $|\alpha| \le 1$ (hoặc một chặn tương tự), rồi kết hợp với một chặn khác để thu hẹp tập nghiệm khả dĩ.',
  ''
),
(
  (SELECT id FROM topics WHERE slug = 'pth-da-thuc'), 'da-thuc-nghiem-bac', 'Đa thức: nghiệm và bậc', 'Nắm định lý Bézout, định lý đồng nhất đa thức và quy tắc tính bậc — công cụ cơ bản của phương trình hàm đa thức.', 2, true,
  '### Định lý Bézout
$a$ là nghiệm của đa thức $P(x)$ khi và chỉ khi $P(x)$ chia hết cho $x - a$, tức là $P(x) = (x-a)Q(x)$.
Tổng quát: nếu $P$ có các nghiệm phân biệt $a_1, a_2, \dots, a_k$ thì $P(x) = (x-a_1)(x-a_2)\cdots(x-a_k)Q(x)$.

### Định lý đồng nhất đa thức
Nếu hai đa thức có bậc không vượt quá $n$ và nhận cùng giá trị tại $n+1$ điểm phân biệt thì chúng đồng nhất bằng nhau.
Hệ quả: đa thức nhận giá trị bằng không tại vô số điểm phân biệt phải là đa thức không.

### Bậc của đa thức
Cho $\deg P = n$, $\deg Q = m$:
• $\deg(PQ) = n + m$;
• Nếu $m \ge 1$ thì $\deg(P \circ Q) = n \cdot m$.
Ví dụ: $\deg P(x^2) = 2n$, $\deg P(x)^2 = 2n$, $\deg P(P(x)) = n^2$.',
  '### Kỹ thuật chặn bậc và so sánh hệ số
So sánh bậc hai vế để tìm $\deg P$, sau đó so sánh hệ số của lũy thừa cao nhất để tìm hệ số dẫn đầu.
Giả sử có hệ số khác 0 ở bậc thấp hơn: so sánh hệ số của số hạng tương ứng ở hai vế để dẫn đến mâu thuẫn, từ đó suy ra $P$ chỉ gồm một số hạng.',
  ''
),
(
  (SELECT id FROM topics WHERE slug = 'pth-tren-r'), 'tru-mat-lien-tuc', 'Tính trù mật và liên tục', 'Hiểu tính trù mật của tập số hữu tỉ và tiêu chuẩn liên tục qua dãy (Heine) — cầu nối từ kết quả trên ℚ ra toàn ℝ.', 1, true,
  '### Tính trù mật của ℚ trong ℝ
Tập số hữu tỉ $\mathbb{Q}$ trù mật trong $\mathbb{R}$: giữa hai số thực bất kỳ luôn tồn tại ít nhất một số hữu tỉ.
Hệ quả: với mọi số thực $x$, luôn tồn tại một dãy số hữu tỉ $(x_n)$ sao cho $x_n \to x$.

### Tiêu chuẩn Heine (liên tục qua dãy)
Hàm $f$ liên tục tại $x_0$ khi và chỉ khi với mọi dãy $(x_n)$ hội tụ về $x_0$, ta đều có $f(x_n) \to f(x_0)$.
Tính chất này cho phép chuyển giới hạn vào bên trong hàm số: $f(\lim x_n) = \lim f(x_n)$.',
  '### Chiến lược hai bước
Bước 1: chứng minh tính chất cần thiết trên tập $\mathbb{Q}$ (hoặc $\mathbb{Z}$) bằng quy nạp và các phép thay biến.
Bước 2: dùng tính trù mật và tiêu chuẩn Heine để mở rộng kết quả ra toàn $\mathbb{R}$.',
  ''
),
(
  (SELECT id FROM topics WHERE slug = 'pth-tren-r'), 'phuong-trinh-cauchy', 'Phương trình Cauchy', 'Nắm phương trình Cauchy, nghiệm của nó khi có thêm giả thiết liên tục, và các dạng mở rộng cơ bản.', 2, true,
  '### Phương trình Cauchy
Phương trình Cauchy có dạng: $f(x+y) = f(x) + f(y)$ với mọi $x, y \in \mathbb{R}$.
Trên tập số hữu tỉ, mọi nghiệm đều có dạng $f(x) = ax$ với $a = f(1)$. Để mở rộng lên $\mathbb{R}$, cần thêm điều kiện phụ như liên tục, đơn điệu hoặc bị chặn.

### Định lý 2.2.2 — Nghiệm liên tục của phương trình Cauchy
Nếu $f$ thỏa mãn phương trình Cauchy và liên tục tại ít nhất một điểm (hoặc bị chặn trên một khoảng), thì $f(x) = ax$ với $a$ là hằng số thực.
Chứng minh:
• Bước 1: thay $y = 0$ ta có $f(0) = 0$; thay $y = -x$ ta có $f(-x) = -f(x)$ (hàm lẻ).
• Bằng quy nạp: $f(nx) = nf(x)$ với mọi $n \in \mathbb{Z}$, $x \in \mathbb{R}$. Đặt $a = f(1)$ ta có $f(n) = an$ với mọi $n \in \mathbb{Z}$.
• Với số hữu tỉ $r = \frac{p}{q}$: $qf(\frac{p}{q}) = f(p) = ap$, suy ra $f(r) = ar$ với mọi $r \in \mathbb{Q}$.
• Bước 2: với $x \in \mathbb{R}$ bất kỳ, chọn dãy hữu tỉ $x_n \to x$. Do tính liên tục và kết quả trên $\mathbb{Q}$: $f(x) = \lim f(x_n) = \lim (a x_n) = ax$.

### Các dạng mở rộng thường gặp
• Dạng nhân: $f(xy) = f(x) + f(y)$ trên $\mathbb{R}^+$ — đặt $g(t) = f(e^t)$ đưa về Cauchy, nghiệm liên tục là $f(x) = a\ln x$.
• Dạng lũy thừa: $f(x+y) = f(x)f(y)$ với $f$ không đồng nhất 0 — nghiệm liên tục là $f(x) = a^x$.
• Dạng Cauchy mở rộng: $f(x+y) + f(x-y) = 2f(x)f(y)$ — liên hệ với công thức cộng của hàm $\cos$.',
  '### Kỹ thuật đưa về Cauchy
Khi gặp một phương trình hàm lạ, hãy tìm cách biến đổi để xuất hiện dạng cộng tính $f(u+v) = f(u) + f(v)$ (bằng cách đặt ẩn phụ, đổi biến, khai thác song ánh...), rồi áp dụng Định lý 2.2.2.',
  ''
),
(
  (SELECT id FROM topics WHERE slug = 'pth-roi-rac'), 'quy-dao-nguyen-ly-cuc-han', 'Quỹ đạo và nguyên lý cực hạn', 'Hiểu khái niệm quỹ đạo của hàm số; vận dụng nguyên lý cực hạn và phân hoạch quỹ đạo trong bài toán rời rạc.', 1, true,
  '### Quỹ đạo của hàm số
Cho $f: X \to X$ và phần tử $x \in X$. Quỹ đạo của $x$ dưới tác động của $f$ là dãy: $x,\ f(x),\ f(f(x)),\ f(f(f(x))),\ \dots$
Nếu tồn tại số nguyên dương $k$ sao cho $f^k(x) = x$ thì quỹ đạo gọi là tuần hoàn với chu kỳ $k$; khi đó $f$ thực hiện một phép hoán vị trên các phần tử của quỹ đạo.

### Định lý 2.3.1 — Nguyên lý cực hạn trong đánh giá đơn điệu
Cho $f: \mathbb{N} \to \mathbb{N}$. Nếu $f(f(n)) < f(n+1)$ với mọi $n$ thì $f$ là hàm đồng nhất: $f(n) = n$.
Chứng minh:
• Với mỗi $n$, xét tập $A_n = \{ f(n), f(n+1), \dots \}$. Theo nguyên lý cực hạn, $A_n$ có phần tử nhỏ nhất, đạt tại chỉ số $i_n$.
• Chứng minh $i_n = n$ bằng quy nạp: nếu $i_n > n$ thì theo giả thiết $f(f(i_n - 1)) < f(i_n)$. Vì $f(i_n - 1) \ge n$ nên $f(f(i_n - 1))$ là một phần tử của $A_n$, nhỏ hơn phần tử nhỏ nhất — mâu thuẫn.
• Vậy $f(0) < f(1) < f(2) < \dots$: $f$ tăng ngặt, do đó $f(n) \ge n$.
• Từ giả thiết và tính tăng ngặt: $f(f(n)) < f(n+1) \Rightarrow f(n) < n+1 \Rightarrow f(n) \le n$.
• Kết hợp lại: $f(n) = n$ với mọi $n$.

### Định lý 2.3.2 — Tính giải được của phương trình tịnh tiến tuần hoàn
Cho $c$ là số nguyên dương. Phương trình $f(f(n)) = n + c$ có nghiệm $f: \mathbb{N} \to \mathbb{N}$ khi và chỉ khi $c$ chẵn.
• Nếu $c$ chẵn: hàm $f(n) = n + \frac{c}{2}$ thỏa mãn vì $f(f(n)) = n + c$.
• Nếu tồn tại $f$: vì $f(f(f(n))) = f(n) + c = f(n + c)$ nên $f(n + c) = f(n) + c$ với mọi $n$. Do đó $f$ bảo toàn các lớp đồng dư modulo $c$ và cảm sinh một phép đổi chỗ không có điểm bất động trên $c$ lớp đồng dư; $c$ lớp bị ghép thành từng cặp nên $c$ phải chẵn.',
  '',
  ''
)
ON CONFLICT (slug) DO UPDATE SET 
  title = EXCLUDED.title,
  objective = EXCLUDED.objective,
  foundational_knowledge = EXCLUDED.foundational_knowledge,
  supplementary_knowledge = EXCLUDED.supplementary_knowledge,
  characteristic_exercises = EXCLUDED.characteristic_exercises;
-- ---------- 3) Bài tập và lời giải ----------
INSERT INTO exercises (lesson_id, slug, title, question, detailed_solution, display_order, is_published, tags) VALUES
(
  (SELECT id FROM lessons WHERE slug = 'so-phuc-module'), 'ex-imo-2001-da-thuc', 'Tìm đa thức thỏa mãn P(x²) = P(x)P(x−1)',
  'Tìm tất cả các đa thức $P(x)$ với hệ số thực thỏa mãn $P(x^2) = P(x)P(x-1)$ với mọi $x \in \mathbb{R}$.',
  '1. Trường hợp P là đa thức hằng: thay vào phương trình được c = c². $P(x) \equiv c \implies c = c^2 \implies c \in \{0, 1\}$
2. Mọi đa thức khác hằng đều có ít nhất một nghiệm phức. $P$ khác hằng. Gọi $\alpha \in \mathbb{C}$ là một nghiệm của $P$ (tồn tại theo Định lý cơ bản của Đại số).
3. Từ một nghiệm t bất kỳ, ta sinh ra hai nghiệm mới t² và (t+1)². Thay $x = \alpha$: $P(\alpha^2) = P(\alpha)P(\alpha-1) = 0$. Thay $x = \alpha+1$: $P((\alpha+1)^2) = P(\alpha+1)P(\alpha) = 0$.
4. Lặp lại: $\alpha^{2^k}$ là nghiệm với mọi $k \in \mathbb{N}$. Nếu $|\alpha| \ne 1$ thì có vô số nghiệm phân biệt (module tăng nếu $|\alpha| > 1$, giảm dần về 0 nếu $0 < |\alpha| < 1$); nếu $\alpha = 0$ thì $1, 4, 25, \dots$ cũng là nghiệm. Đều vô lý. Vậy $|\alpha| = 1$.
5. Tương tự với nghiệm $(\alpha+1)^2$: $(\alpha+1)^{2^k}$ là nghiệm với mọi $k \ge 1$, nên $|\alpha+1| = 1$ (trường hợp $\alpha+1 = 0$ lại dẫn tới $1, 4, 25, \dots$ là nghiệm — vô lý).
6. Trên đường tròn đơn vị, hai điểm cách đều 0 và −1 chính là hai căn bậc ba nguyên thủy của đơn vị. $|\alpha| = |\alpha+1| = 1 \implies \operatorname{Re}(\alpha) = -\frac{1}{2} \implies \alpha \in \{\omega, \omega^2\}$ với $\omega^2 + \omega + 1 = 0$.
7. Do hệ số thực, hai nghiệm liên hợp ω, ω² xuất hiện với cùng số bội. Mọi nghiệm của $P$ đều là $\omega$ hoặc $\omega^2$, nên $P(x) = C(x^2+x+1)^n$ với $C \in \mathbb{R}$.
8. Thay vào: $C(x^4+x^2+1)^n = C^2(x^2+x+1)^n(x^2-x+1)^n = C^2(x^4+x^2+1)^n \implies C \in \{0, 1\}$.
9. Kết luận: $P \equiv 0$ hoặc $P(x) = (x^2+x+1)^n$ với $n \in \mathbb{N}$ (trường hợp $n = 0$ chính là $P \equiv 1$).',
  1, true, array['đánh giá module', 'nghiệm phức']
),
(
  (SELECT id FROM lessons WHERE slug = 'da-thuc-nghiem-bac'), 'ex-vmo-2006', 'Tìm đa thức thỏa mãn xP(x−1) = (x−3)P(x)',
  'Tìm tất cả các đa thức $P(x)$ với hệ số thực thỏa mãn $xP(x-1) = (x-3)P(x)$ với mọi $x \in \mathbb{R}$.',
  '1. Thay $x = 0$: $0 \cdot P(-1) = -3P(0) \implies P(0) = 0$.
2. Thay $x = 1$: $1 \cdot P(0) = -2P(1) \implies P(1) = 0$.
3. Thay $x = 3$: $3P(2) = 0 \cdot P(3) \implies P(2) = 0$.
4. Theo Định lý Bézout: $P(x) = x(x-1)(x-2)Q(x)$ với $Q$ là đa thức.
5. Thay vào phương trình: $x(x-1)(x-2)(x-3)Q(x-1) = (x-3)x(x-1)(x-2)Q(x)$, suy ra $Q(x-1) = Q(x)$ với vô số $x$.
6. $Q(x-1) \equiv Q(x)$ nên $Q$ là hằng số $C$. Kết luận: $P(x) = Cx(x-1)(x-2)$, $C \in \mathbb{R}$ tùy ý.',
  2, true, array['tịnh tiến nghiệm', 'Bézout']
),
(
  (SELECT id FROM lessons WHERE slug = 'da-thuc-nghiem-bac'), 'ex-chan-bac', 'Tìm đa thức thỏa mãn P(x)² = P(x²)',
  'Tìm tất cả các đa thức $P(x)$ với hệ số thực thỏa mãn $P(x)^2 = P(x^2)$ với mọi $x \in \mathbb{R}$.',
  '1. Khảo sát bậc và hệ số cao nhất. Giả sử $P(x) = ax^n + \dots$. Ta có $(ax^n)^2 = a(x^2)^n \implies a^2 = a \implies a = 1$ (nếu P khác 0).
2. Vậy $P(x) = x^n + \dots$. Giả sử có hệ số khác 0 ở bậc thấp hơn: $P(x) = x^n + bx^k + \dots$ với $k < n, b \ne 0$.
3. Thay vào phương trình: vế trái là $(x^n + bx^k + \dots)^2 = x^{2n} + 2bx^{n+k} + \dots$, vế phải là $x^{2n} + bx^{2k} + \dots$.
4. So sánh hệ số của $x^{n+k}$: vế phải không có số hạng này (vì $2k < n+k$), nên $2b = 0 \implies b = 0$ — mâu thuẫn.
5. Do đó $P(x)$ không có số hạng nào khác ngoài $x^n$. Vậy $P(x) = x^n$ hoặc $P \equiv 0$.',
  3, true, array['chặn bậc', 'so sánh hệ số']
),
(
  (SELECT id FROM lessons WHERE slug = 'so-phuc-module'), 'ex-nga-1999', 'Tìm đa thức thỏa mãn P(x)P(x+1) = P(x²+x)',
  'Tìm tất cả các đa thức $P(x)$ với hệ số thực thỏa mãn $P(x)P(x+1) = P(x^2+x)$ với mọi $x \in \mathbb{R}$.',
  '1. Giả sử $P$ có nghiệm $\alpha \in \mathbb{C}$. Khi đó $\alpha^2+\alpha$ và $(\alpha-1)^2+(\alpha-1) = \alpha^2-\alpha$ cũng là nghiệm.
2. Theo bất đẳng thức tam giác: $|\alpha^2+\alpha| + |\alpha^2-\alpha| \ge |2\alpha^2| = 2|\alpha|^2$.
3. Gọi $\alpha$ là nghiệm có module lớn nhất. Khi đó $|\alpha^2+\alpha| \le |\alpha|$ và $|\alpha^2-\alpha| \le |\alpha|$.
4. Suy ra $2|\alpha|^2 \le |\alpha| + |\alpha| = 2|\alpha| \implies |\alpha| \le 1$.
5. Mặt khác $P(0)P(1) = P(0) \implies P(0)=0$ (hoặc P(1)=1). Dùng các nhận xét module để giới hạn tập nghiệm. Cuối cùng được $P(x) \equiv 0$ hoặc $P(x) \equiv 1$ hoặc $P(x) = x^n$.',
  4, true, array['đánh giá module', 'nghiệm phức']
),
(
  (SELECT id FROM lessons WHERE slug = 'ham-so-tap-gia-tri'), 'ex-tap-gia-tri', 'Tìm đa thức thỏa mãn P(P(x)) = (P(x))²⁰²⁶',
  'Tìm tất cả các đa thức $P(x)$ với hệ số thực thỏa mãn $P(P(x)) = (P(x))^{2026}$ với mọi $x \in \mathbb{R}$.',
  '1. Với mọi $y$ thuộc tập giá trị của đa thức $P$, tồn tại $x$ sao cho $P(x) = y$.
2. Thay $x$ vào phương trình, ta có: $P(y) = y^{2026}$.
3. Vì đa thức $P$ không phải là hằng số (nếu là hằng số thì dễ thấy nghiệm là 0 hoặc 1), tập giá trị của nó là vô hạn (chứa một tia).
4. Hai đa thức $P(t)$ và $t^{2026}$ bằng nhau trên một tập vô hạn nên chúng phải đồng nhất.
5. Vậy $P(x) = x^{2026}$. Thử lại thấy thỏa mãn.',
  5, true, array['tập giá trị', 'đồng nhất đa thức']
),
(
  (SELECT id FROM lessons WHERE slug = 'da-thuc-nghiem-bac'), 'ex-sai-phan', 'Tìm đa thức thỏa mãn P(x+1) + P(x−1) = 2P(x)',
  'Tìm tất cả các đa thức $P(x)$ với hệ số thực thỏa mãn $P(x+1) + P(x-1) = 2P(x)$ với mọi $x \in \mathbb{R}$.',
  '1. Phương trình có thể viết lại thành $P(x+1) - P(x) = P(x) - P(x-1)$.
2. Đặt $\Delta P(x) = P(x) - P(x-1)$. Ta có $\Delta P(x+1) = \Delta P(x)$ với mọi $x$.
3. Vậy đa thức $\Delta P(x)$ tuần hoàn với chu kỳ 1. Đa thức tuần hoàn thì phải là đa thức hằng.
4. Do $\Delta P(x) = c$, suy ra $P(x)$ là đa thức bậc nhất (hoặc bậc 0): $P(x) = cx + d$.
5. Thử lại: $c(x+1)+d + c(x-1)+d = 2cx + 2d = 2(cx+d)$ thỏa mãn. Kết luận: $P(x) = cx + d$.',
  6, true, array['sai phân', 'bậc']
),
(
  (SELECT id FROM lessons WHERE slug = 'don-anh-toan-anh-song-anh'), 'ex-don-anh-f0', 'Giải phương trình f(f(x)+y) = f(x+y) + f(0)',
  'Tìm tất cả các hàm số $f: \mathbb{R} \to \mathbb{R}$ liên tục thỏa mãn $f(f(x) + y) = f(x + y) + f(0)$ với mọi $x, y \in \mathbb{R}$.',
  '1. Đặt $c = f(0)$. Thay $x = 0$, ta có $f(f(0)+y) = f(y)+f(0) \implies f(y+c) = f(y)+c$.
2. Thay y bởi $y - x$ ta có $f(f(x) + y - x) = f(y) + c$.
3. Hàm $f$ có chu kỳ nếu $f(u) = f(v)$. Dựa vào tính liên tục, suy ra f là đơn ánh.
4. Vì f đơn ánh, phương trình $f(f(x)+y) = f(x+y+c)$ kẽo theo $f(x)+y = x+y+c \implies f(x) = x+c$.
5. Thử lại $f(x) = x+c$ vào phương trình ban đầu thấy thỏa mãn.',
  7, true, array['chu kỳ', 'đơn ánh']
),
(
  (SELECT id FROM lessons WHERE slug = 'phuong-trinh-cauchy'), 'ex-vmo-2005-cos', 'Giải phương trình f(x+y) + f(x−y) = 2f(x)f(y)',
  'Tìm tất cả các hàm số $f: \mathbb{R} \to \mathbb{R}$ liên tục, $f \not\equiv 0$, thỏa mãn $f(x+y) + f(x-y) = 2f(x)f(y)$ với mọi $x, y \in \mathbb{R}$ và $f(x) \le 1$ với mọi $x$.',
  '1. Thay $y=0$: $2f(x) = 2f(x)f(0) \implies f(0)=1$ (vì f không đồng nhất 0).
2. Thay $x=0$: $f(y)+f(-y) = 2f(0)f(y) = 2f(y) \implies f(-y)=f(y)$ (f là hàm chẵn).
3. Vì $f(x) \le 1$ và $f(0)=1$, nên f liên hệ với hàm cos.
4. Đặt $f(x) = \cos(ax)$. Thử lại bằng công thức $\cos(a(x+y)) + \cos(a(x-y)) = 2\cos(ax)\cos(ay)$ thấy thỏa mãn.',
  8, true, array['phương trình lượng giác', 'Cauchy']
),
(
  (SELECT id FROM lessons WHERE slug = 'ham-so-tap-gia-tri'), 'ex-f-x-f-y', 'Giải phương trình f(x+f(y)) = f(x) + yf(y)',
  'Tìm tất cả các hàm số $f: \mathbb{R} \to \mathbb{R}$ thỏa mãn $f(x + f(y)) = f(x) + yf(y)$ với mọi $x, y \in \mathbb{R}$.',
  '1. Thay $y = 0$: $f(x + f(0)) = f(x)$. Từ đây f có chu kỳ $c = f(0)$.
2. Giả sử $f(y_0) \ne 0$. Sử dụng chu kỳ suy ra mâu thuẫn nếu f(0) khác 0, do đó f(0) = 0.
3. Từ đó chứng minh $f(x) = cx$ không thỏa mãn trừ khi $c=1$ hoặc $c=-1$. Do $f(x+f(y)) = f(x)+y f(y)$.
4. Kết luận $f(x) = x$ hoặc $f(x) = -x$.',
  9, true, array['tập giá trị']
),
(
  (SELECT id FROM lessons WHERE slug = 'phuong-trinh-cauchy'), 'ex-binh-phuong-hieu', 'Giải phương trình f(x²−y²) = xf(x) − yf(y)',
  'Tìm tất cả các hàm số $f: \mathbb{R} \to \mathbb{R}$ thỏa mãn $f(x^2 - y^2) = xf(x) - yf(y)$ với mọi $x, y \in \mathbb{R}$.',
  '1. Thay $y=0$: $f(x^2) = xf(x) - 0 = xf(x)$.
2. Thay $x=0$: $f(-y^2) = -yf(y)$. Suy ra $f$ là hàm lẻ.
3. Với $a, b \ge 0$, ta có $f(a-b) = f(a) - f(b)$, suy ra $f$ cộng tính trên $\mathbb{R}$.
4. Viết $f((u+v)^2)$ theo 2 cách và dùng tính cộng tính để so sánh, ta được $f(2uv) = uf(v)+vf(u)$.
5. Chọn $v=1$, ta được $f(2u) = uf(1)+f(u) \implies 2f(u) = uf(1)+f(u) \implies f(u) = uf(1)$.
6. Kết luận $f(x) = cx$.',
  10, true, array['đưa về Cauchy', 'hàm chẵn lẻ']
),
(
  (SELECT id FROM lessons WHERE slug = 'phuong-trinh-cauchy'), 'ex-olympic-2001', 'Giải phương trình f(x+y+f(y)) = f(x) + 2y',
  'Tìm tất cả các hàm số $f: \mathbb{R} \to \mathbb{R}$ liên tục thỏa mãn $f(x + y + f(y)) = f(x) + 2y$ với mọi $x, y \in \mathbb{R}$.',
  '1. Chứng minh f toàn ánh: cố định x, khi y chạy thì vế phải quét qua toàn bộ $\mathbb{R}$.
2. Giả sử $f(u)=f(v)$, suy ra $u=v$ nên f đơn ánh. Do đó f là song ánh.
3. Vì f song ánh, ta thay biến khéo léo để rút ra tính cộng tính $f(u+v) = f(u)+f(v)$.
4. Kết hợp với tính liên tục, $f(x) = cx$. Thay vào phương trình tìm được $c=1$ hoặc $c=-2$.
5. Kết luận $f(x) = x$ hoặc $f(x) = -2x$.',
  11, true, array['Cauchy', 'song ánh']
),
(
  (SELECT id FROM lessons WHERE slug = 'quy-dao-nguyen-ly-cuc-han'), 'ex-imo-1977', 'Chứng minh f(n) = n từ f(f(n)) < f(n+1)',
  'Tìm tất cả các hàm số $f: \mathbb{N} \to \mathbb{N}$ thỏa mãn $f(f(n)) < f(n+1)$ với mọi $n \in \mathbb{N}$.',
  '1. Xét $A_n = \{f(n), f(n+1), \dots\}$. Theo nguyên lý cực hạn, tập này có phần tử nhỏ nhất đạt tại $i_n$.
2. Bằng quy nạp, chứng minh được $i_n = n$, nghĩa là $f(0) < f(1) < f(2) < \dots$
3. Suy ra $f$ tăng ngặt, do đó $f(n) \ge n$ với mọi $n$.
4. Kết hợp với giả thiết, $f(f(n)) < f(n+1) \implies f(n) < n+1 \implies f(n) \le n$.
5. Từ 3 và 4 suy ra $f(n) = n$.',
  12, true, array['nguyên lý cực hạn']
),
(
  (SELECT id FROM lessons WHERE slug = 'quy-dao-nguyen-ly-cuc-han'), 'ex-quy-dao-2025', 'Chứng minh vô nghiệm f(f(n)) = n + 2025',
  'Chứng minh rằng không tồn tại hàm số $f: \mathbb{N} \to \mathbb{N}$ thỏa mãn $f(f(n)) = n + 2025$ với mọi $n \in \mathbb{N}$.',
  '1. Từ phương trình suy ra $f(n+2025) = f(f(f(n))) = f(n)+2025$.
2. Do đó $f$ bảo toàn lớp đồng dư modulo $2025$.
3. Hàm $f$ cảm sinh một phép đổi chỗ không điểm bất động trên $2025$ lớp đồng dư.
4. Một phép đổi chỗ không điểm bất động chỉ có thể tồn tại trên một tập có số phần tử chẵn, nhưng $2025$ là số lẻ.
5. Mâu thuẫn. Vậy không tồn tại hàm số $f$.',
  13, true, array['quỹ đạo', 'đồng dư']
),
(
  (SELECT id FROM lessons WHERE slug = 'quy-dao-nguyen-ly-cuc-han'), 'ex-nhan-tinh', 'Chứng minh không tồn tại f nhân tính và cộng tính',
  'Tìm tất cả các hàm số $f: \mathbb{N}^* \to \mathbb{N}^*$ thỏa mãn đồng thời hai điều kiện với mọi $m, n \in \mathbb{N}^*$:
(1) $f(m \cdot f(n)) = n^2 f(m)$;
(2) $f(m + n) \le f(m) + f(n)$.',
  '1. Thay $m=1, n=1$ rút ra $f(f(n)) = n^2 f(1)$ và $f(1)=1$.
2. Từ đó $f(f(n)) = n^2$. Suy ra $f$ đơn ánh.
3. Từ điều kiện (2), ta có $f(n) = f(1+1+\dots+1) \le n f(1) = n$.
4. Từ $f(f(n)) = n^2$, nếu áp dụng $f(x) \le x$, ta có $n^2 = f(f(n)) \le f(n) \le n$.
5. $n^2 \le n$ là vô lý với mọi $n \ge 2$. Vậy không tồn tại hàm $f$.',
  14, true, array['nhân tính', 'bất đẳng thức']
),
(
  (SELECT id FROM lessons WHERE slug = 'phuong-trinh-cauchy'), 'ex-cauchy-z', 'Giải phương trình f(m+f(n)) = f(m) + n trên ℤ',
  'Tìm tất cả các hàm số $f: \mathbb{Z} \to \mathbb{Z}$ thỏa mãn $f(m + f(n)) = f(m) + n$ với mọi $m, n \in \mathbb{Z}$.',
  '1. Vế phải quét toàn bộ $\mathbb{Z}$ nên $f$ toàn ánh. Dễ thấy $f$ cũng đơn ánh nên $f$ song ánh.
2. Từ đó thay $m=0, n=0 \implies f(0)=0$.
3. Thay $m=0$, ta có $f(f(n)) = n$. 
4. Thay $n$ bằng $f(n)$ ta có $f(m+n) = f(m)+f(n)$, tức là f cộng tính trên $\mathbb{Z}$.
5. Do $f$ cộng tính trên $\mathbb{Z}$ nên $f(n) = cn$. Kết hợp $f(f(n))=n \implies c^2=1 \implies c = 1$ hoặc $c = -1$.
6. Nghiệm: $f(n) = n$ hoặc $f(n) = -n$.',
  15, true, array['song ánh', 'Cauchy trên Z']
)
ON CONFLICT (slug) DO UPDATE SET 
  lesson_id = EXCLUDED.lesson_id,
  title = EXCLUDED.title,
  question = EXCLUDED.question,
  detailed_solution = EXCLUDED.detailed_solution,
  tags = EXCLUDED.tags;

