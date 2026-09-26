/* ============================================================
   Hàm số — dữ liệu tĩnh dự phòng (Giai đoạn 1)
   Chứa: chuyên đề (topics), bài học (lessons), bài tập (exercises)
   Từ Giai đoạn 2, website ưu tiên đọc dữ liệu từ Supabase (xem app.js);
   dữ liệu này chỉ dùng khi Supabase chưa cấu hình hoặc bảng trống.
   ============================================================ */

const TOPICS = [
  {
    id: 'nen-tang',
    title: 'Kiến thức nền tảng',
    slug: 'nen-tang',
    description: 'Ánh xạ, hàm số, tập xác định — tập giá trị, đơn ánh — toàn ánh — song ánh và các nhận xét cơ bản về nghiệm phương trình hàm.',
    displayOrder: 1
  },
  {
    id: 'da-thuc',
    title: 'Chuyên đề 1 — Phương trình hàm đa thức',
    slug: 'da-thuc',
    description: 'Số phức, định lý cơ bản của đại số, Bézout, đồng nhất đa thức, bậc, kỹ thuật phân tích — tịnh tiến nghiệm, chặn bậc, tập giá trị và sai phân.',
    displayOrder: 2
  },
  {
    id: 'r-thuc',
    title: 'Chuyên đề 2 — Phương trình hàm trên ℝ',
    slug: 'r-thuc',
    description: 'Tính trù mật của ℚ, tiêu chuẩn Heine, phương trình Cauchy, thay biến, đối xứng, điểm bất động và phương trình hàm nhiều biến.',
    displayOrder: 3
  },
  {
    id: 'roi-rac',
    title: 'Chuyên đề 3 — Phương trình hàm trên tập rời rạc',
    slug: 'roi-rac',
    description: 'Quỹ đạo, chu kỳ và điểm bất động, nguyên lý cực hạn, đánh giá đơn điệu, phân hoạch lớp đồng dư và Cauchy trên ℤ, ℕ.',
    displayOrder: 4
  }
];

const TECHNIQUES = [
  'song ánh', 'thay biến', 'đối xứng', 'cauchy', 'trù mật', 'phân tích nghiệm',
  'tịnh tiến nghiệm', 'chặn bậc', 'sai phân', 'điểm bất động', 'cực hạn',
  'đơn điệu', 'lớp đồng dư', 'quỹ đạo', 'quy nạp'
];

const LESSONS = [
  /* ---------- Kiến thức nền tảng ---------- */
  {
    id: 'anh-xa-ham-so',
    topicId: 'nen-tang',
    title: 'Ánh xạ và hàm số',
    displayOrder: 1,
    objective: 'Nắm vững khái niệm ánh xạ và hàm số; phân biệt tập nguồn, tập đích và hiểu cách một phương trình hàm đặt ra bài toán tìm hàm.',
    sections: [
      { type: 'definition', title: 'Định nghĩa', body: 'Ánh xạ từ tập $X$ vào tập $Y$ là quy tắc cho tương ứng mỗi phần tử $x \\in X$ với đúng một phần tử $y \\in Y$, ký hiệu $f: X \\to Y$, $y = f(x)$.\nHàm số là ánh xạ mà tập nguồn và tập đích là các tập hợp số (thường là tập con của $\\mathbb{R}$, $\\mathbb{Z}$, $\\mathbb{N}$).\nTrong phương trình hàm, hàm số được mô tả gián tiếp qua một điều kiện chứa biến; nhiệm vụ là tìm tất cả các hàm thỏa mãn điều kiện đó.' },
      { type: 'technique', title: 'Kỹ thuật giải', body: 'Khi đọc đề phương trình hàm, việc đầu tiên là xác định rõ ba yếu tố: tập nguồn $X$, tập đích $Y$ và dạng điều kiện.\nTập nguồn quyết định phép thế nào được phép: trên $\\mathbb{R}$ ta thế số thực tùy ý; trên $\\mathbb{N}$ chỉ thế số tự nhiên; trên $\\mathbb{Z}$ thế được cả số âm.' },
      { type: 'example', title: 'Ví dụ minh họa', body: 'Quy tắc $f: \\mathbb{R} \\to \\mathbb{R}$, $f(x) = 2x + 1$ là một hàm số.\nQuy tắc “$x \\mapsto \\pm\\sqrt{x}$” không là ánh xạ từ $\\mathbb{R}$ vào $\\mathbb{R}$ vì một $x$ có thể cho hai ảnh (và $\\sqrt{x}$ không xác định khi $x < 0$).' }
    ]
  },
  {
    id: 'don-anh-toan-anh-song-anh',
    topicId: 'nen-tang',
    title: 'Đơn ánh, toàn ánh, song ánh',
    displayOrder: 2,
    objective: 'Nhận biết và chứng minh tính đơn ánh, toàn ánh, song ánh của hàm số — công cụ thế biến mạnh nhất trong phương trình hàm.',
    sections: [
      { type: 'definition', title: 'Định nghĩa', body: '$f: X \\to Y$ là đơn ánh nếu $x_1 \\neq x_2 \\Rightarrow f(x_1) \\neq f(x_2)$.\n$f$ là toàn ánh nếu với mọi $y \\in Y$, tồn tại $x \\in X$ sao cho $f(x) = y$.\n$f$ là song ánh nếu vừa đơn ánh vừa toàn ánh; khi đó tồn tại hàm ngược $f^{-1}: Y \\to X$.' },
      { type: 'technique', title: 'Kỹ thuật giải', body: 'Chứng minh đơn ánh: giả sử $f(a) = f(b)$ rồi biến đổi để suy ra $a = b$.\nChứng minh toàn ánh: lấy $y$ bất kỳ thuộc tập đích, chỉ ra $x$ sao cho $f(x) = y$.\nMẹo: nếu $f(f(x)) = x + c$ với $c \\neq 0$ thì $f$ song ánh (vì $x \\mapsto x + c$ là song ánh).\nNếu $f$ song ánh, ta được quyền thế biến bằng $f(t)$ với $t$ tùy ý.' },
      { type: 'example', title: 'Ví dụ minh họa', body: '$f(x) = 2x + 1$ trên $\\mathbb{R}$ là song ánh, hàm ngược $f^{-1}(y) = \\frac{y - 1}{2}$.\n$f(x) = x^2$ trên $\\mathbb{R}$ không đơn ánh ($1$ và $-1$ cùng ảnh) và không toàn ánh (không có $x$ để $x^2 = -1$).' }
    ]
  },
  {
    id: 'txd-tgt',
    topicId: 'nen-tang',
    title: 'Tập xác định và tập giá trị',
    displayOrder: 3,
    objective: 'Phân biệt tập xác định và tập giá trị; biết dùng thông tin về tập giá trị để tìm điểm tựa cho phép thế biến.',
    sections: [
      { type: 'definition', title: 'Định nghĩa', body: 'Tập xác định (miền) của $f$ là tập các giá trị mà $f$ được định nghĩa; tập giá trị của $f$ là $f(X) = \\{f(x) : x \\in X\\}$.\n$f$ toàn ánh khi và chỉ khi tập giá trị bằng đúng tập đích.' },
      { type: 'technique', title: 'Kỹ thuật giải', body: 'Nhiều bài phương trình hàm yêu cầu chứng minh $0$ thuộc tập giá trị hoặc $f(0) = 0$ — đó là điểm tựa để thế biến.\nNếu chứng minh được $f$ toàn ánh, có thể thế biến bằng $f(t)$ với $t$ tùy ý để “thoát” lớp ngoài của $f$.\nNếu tập giá trị bị chặn (chẳng hạn $f(x) \\in \\mathbb{N}$), phối hợp với đánh giá để thu hẹp miền giá trị.' },
      { type: 'example', title: 'Ví dụ minh họa', body: '$f(x) = x^3$ trên $\\mathbb{R}$ có tập giá trị là $\\mathbb{R}$ (toàn ánh).\n$f(x) = x^2 + 1$ trên $\\mathbb{R}$ có tập giá trị $[1, +\\infty)$ — không toàn ánh trên $\\mathbb{R}$.' }
    ]
  },
  {
    id: 'nhan-xet-nghiem',
    topicId: 'nen-tang',
    title: 'Nhận xét cơ bản về nghiệm phương trình hàm',
    displayOrder: 4,
    objective: 'Nắm quy trình mở đầu chuẩn khi giải một phương trình hàm và thói quen thử lại nghiệm.',
    sections: [
      { type: 'technique', title: 'Ba bước mở đầu chuẩn', body: '1. Thế các giá trị đặc biệt: $x = 0$, $y = 0$, $x = y$, $x = f(y)$, hoán vị biến…\n2. Tìm $f(0)$ nếu có thể — rất nhiều bài quy về $f(0) = 0$.\n3. Kiểm tra tính đơn ánh, toàn ánh để có quyền thế biến mạnh hơn.' },
      { type: 'technique', title: 'Thử lại nghiệm', body: 'Sau khi tìm được nghiệm dự đoán, luôn thay ngược vào điều kiện ban đầu để kiểm tra.\nMột số bài có nghiệm “lạ” (hàm hằng, hàm phụ thuộc tham số) — bỏ quên thử lại là mất điểm.' },
      { type: 'example', title: 'Ví dụ minh họa', body: 'Xét $f(x + y) = f(x) + f(y)$. Thế $x = y = 0$ được $f(0) = 2f(0) \\Rightarrow f(0) = 0$.\nThế $y = -x$ được $f(-x) = -f(x)$ — hàm lẻ.' }
    ]
  },

  /* ---------- Chuyên đề 1: Đa thức ---------- */
  {
    id: 'so-phuc-fda',
    topicId: 'da-thuc',
    title: 'Số phức và định lý cơ bản của đại số',
    displayOrder: 1,
    objective: 'Ôn tập số phức, module, bất đẳng thức tam giác và định lý cơ bản của đại số — nền tảng để khảo sát nghiệm đa thức.',
    sections: [
      { type: 'definition', title: 'Định nghĩa', body: 'Số phức $z = a + bi$ với $a, b \\in \\mathbb{R}$, $i^2 = -1$; module $|z| = \\sqrt{a^2 + b^2}$.\nBất đẳng thức tam giác: $|z_1 + z_2| \\le |z_1| + |z_2|$ và $|z_1 - z_2| \\ge \\big||z_1| - |z_2|\\big|$.' },
      { type: 'theorem', title: 'Định lý cơ bản của đại số', body: 'Mọi đa thức bậc $n \\ge 1$ hệ số phức có đúng $n$ nghiệm phức (kể cả bội).\nHệ quả: mọi đa thức hệ số thực phân tích được thành tích các nhân tử bậc nhất và bậc hai (vô nghiệm thực).' },
      { type: 'technique', title: 'Kỹ thuật giải', body: 'Đa thức hệ số thực bậc lẻ luôn có nghiệm thực.\nNếu $P(z) = 0$ và $P$ hệ số thực thì $P(\\overline{z}) = 0$ — nghiệm phức đi theo cặp liên hợp.\nKhi bài toán không nhắc gì thêm, vẫn có thể khảo sát nghiệm phức để chặn nghiệm thực.' },
      { type: 'example', title: 'Ví dụ minh họa', body: '$P(x) = x^2 + 1$ không có nghiệm thực nhưng có nghiệm phức $\\pm i$.\n$P(x) = x^3 - 1$ có nghiệm $1, \\omega, \\omega^2$ với $\\omega = e^{2\\pi i/3}$.' }
    ]
  },
  {
    id: 'bezout-dong-nhat',
    topicId: 'da-thuc',
    title: 'Định lý Bézout và đồng nhất đa thức',
    displayOrder: 2,
    objective: 'Sử dụng định lý Bézout và định lý đồng nhất để so sánh hệ số và tìm dạng nghiệm đa thức.',
    sections: [
      { type: 'theorem', title: 'Định lý', body: 'Bézout: $P(a) = 0$ khi và chỉ khi $(x - a)$ là nhân tử của $P(x)$.\nĐồng nhất: nếu hai đa thức nhận giá trị bằng nhau tại vô hạn điểm (hoặc với mọi $x$) thì mọi hệ số tương ứng của chúng bằng nhau.' },
      { type: 'technique', title: 'Kỹ thuật giải', body: '“Đa thức có vô hạn nghiệm thì đồng nhất bằng 0” — đòn bẩy chính của mọi bài phương trình hàm đa thức.\nSo sánh hệ số bậc cao nhất và hệ số tự do là cách nhanh nhất để chặn dạng nghiệm.\nĐẳng thức đúng với mọi $x$ có thể đạo hàm hai vế (nếu đang khảo sát trên $\\mathbb{R}$).' },
      { type: 'example', title: 'Ví dụ minh họa', body: 'Nếu $P(x)^2 = P(x^2)$ và $P \\neq 0$: so sánh hệ số bậc cao nhất hai vế, với $\\deg P = n$, hệ số đầu $a_n$ thỏa $a_n^2 = a_n \\Rightarrow a_n = 1$.' }
    ]
  },
  {
    id: 'bac-da-thuc-hop',
    topicId: 'da-thuc',
    title: 'Bậc của đa thức và đa thức hợp',
    displayOrder: 3,
    objective: 'Dùng bậc của đa thức hợp để tìm bậc của nghiệm, từ đó so sánh hệ số và chốt dạng đa thức.',
    sections: [
      { type: 'definition', title: 'Định nghĩa', body: 'Bậc của đa thức $P$, ký hiệu $\\deg P$, là số mũ lớn nhất của $x$ xuất hiện với hệ số khác 0.\nQuy ước $\\deg 0 = -\\infty$.' },
      { type: 'theorem', title: 'Định lý', body: '$\\deg(P \\circ Q) = \\deg P \\cdot \\deg Q$ khi $P, Q$ khác hằng.\nHệ quả: nếu $\\deg P = n \\ge 1$ thì $\\deg(P \\circ P) = n^2$.' },
      { type: 'technique', title: 'Kỹ thuật giải', body: 'Từ điều kiện đề cho, tính bậc hai vế để tìm $n$; sau đó so sánh hệ số đầu để tìm hệ số bậc cao nhất.\nNếu hai vế có bậc khác nhau một cách mâu thuẫn thì chỉ còn nghiệm tầm thường.' },
      { type: 'example', title: 'Ví dụ minh họa', body: 'Từ $P(P(x)) = (x^2 + x + 1)P(x)$: nếu $\\deg P = n \\ge 1$ thì $n^2 = n + 2 \\Rightarrow n = 2$. So sánh hệ số đầu được hệ số bậc 2 bằng 1.' }
    ]
  },
  {
    id: 'phan-tich-nghiem',
    topicId: 'da-thuc',
    title: 'Kỹ thuật phân tích nghiệm',
    displayOrder: 4,
    objective: 'Sinh dãy nghiệm từ một nghiệm để chứng tỏ đa thức đồng nhất 0 hoặc chặn tập nghiệm.',
    sections: [
      { type: 'technique', title: 'Kỹ thuật giải', body: 'Nếu $\\alpha$ là nghiệm của $P$ thì $P(x) = (x - \\alpha)Q(x)$.\nTừ $P(\\alpha) = 0$, thế biến để suy ra $f(\\alpha)$ cũng là nghiệm: mỗi điều kiện của đề là một “cỗ máy sinh nghiệm”.\nNếu sinh được vô hạn nghiệm phân biệt thì $P \\equiv 0$ (định lý đồng nhất).\nNgược lại, nếu tập nghiệm bị chặn trong tập hữu hạn $\\{\\alpha_1, \\ldots, \\alpha_k\\}$ thì $P(x) = c\\prod (x - \\alpha_i)^{m_i}$.' },
      { type: 'example', title: 'Ví dụ minh họa', body: 'Từ $P(x^2) = P(x)P(x+1)$: nếu $P(\\alpha) = 0$ thì $P(\\alpha^2) = 0$ và $P((\\alpha - 1)^2) = 0$.\nVới $|\\alpha| \\notin \\{0, 1\\}$, dãy $\\alpha, \\alpha^2, \\alpha^4, \\ldots$ là vô hạn nghiệm phân biệt $\\Rightarrow P \\equiv 0$.' }
    ]
  },
  {
    id: 'tinh-tien-nghiem-chan-bac',
    topicId: 'da-thuc',
    title: 'Tịnh tiến nghiệm và chặn bậc',
    displayOrder: 5,
    objective: 'Dùng phép tịnh tiến biến số và kỹ thuật so sánh bậc để xác định hoàn toàn đa thức nghiệm.',
    sections: [
      { type: 'technique', title: 'Kỹ thuật giải', body: 'Tịnh tiến nghiệm: đặt $Q(x) = P(x + a)$ để chuyển nghiệm về gốc tọa độ, làm gọn tính toán.\nChặn bậc: khi đã biết tập nghiệm hữu hạn, viết $P(x) = c\\prod (x - \\alpha_i)^{m_i}$ rồi thay vào điều kiện gốc để tìm số mũ và hằng số.\nSo sánh bội của nghiệm ở hai vế là công cụ tinh để loại nghiệm “thừa”.' },
      { type: 'example', title: 'Ví dụ minh họa', body: 'Bài $P(x^2) = P(x)P(x+1)$: chứng minh được nghiệm chỉ có thể là $0$ hoặc $1$.\nSuy ra $P(x) = x^m(x - 1)^n$; thay vào điều kiện được $m = n$.\nKết quả: $P(x) = x^n(x - 1)^n$, cùng hai nghiệm tầm thường $P \\equiv 0$ và $P \\equiv 1$.' }
    ]
  },
  {
    id: 'tap-gia-tri-sai-phan',
    topicId: 'da-thuc',
    title: 'Khảo sát tập giá trị và phương pháp sai phân',
    displayOrder: 6,
    objective: 'Biết dùng sai phân và phép nội suy để xác định đa thức từ các giá trị hoặc hiệu của giá trị.',
    sections: [
      { type: 'definition', title: 'Định nghĩa', body: 'Sai phân của dãy: $\\Delta a_n = a_{n+1} - a_n$; sai phân cấp 2: $\\Delta^2 a_n = \\Delta a_{n+1} - \\Delta a_n$.\nĐa thức bậc $n$ có sai phân cấp $n$ là hằng số.' },
      { type: 'technique', title: 'Kỹ thuật giải', body: 'Nếu $f(x + 1) - f(x) = g(x)$ với $g$ là đa thức bậc $k$ thì $\\deg f = k + 1$ (khi $f$ là đa thức) — từ đó đặt dạng và so sánh hệ số.\nNội suy: biết giá trị đa thức bậc $n$ tại $n + 1$ điểm phân biệt thì xác định duy nhất đa thức đó.' },
      { type: 'example', title: 'Ví dụ minh họa', body: 'Tìm $P$ với $P(x + 1) - P(x) = 2x$: vế phải bậc 1 nên $\\deg P = 2$.\nĐặt $P(x) = ax^2 + bx + c$, thay vào được $a = 1$, $b = -1$.\nVậy $P(x) = x^2 - x + c$ với $c$ tùy ý.' }
    ]
  },

  /* ---------- Chuyên đề 2: Trên ℝ ---------- */
  {
    id: 'trum-mat-heine',
    topicId: 'r-thuc',
    title: 'Tính trù mật của ℚ và tiêu chuẩn Heine',
    displayOrder: 1,
    objective: 'Hiểu tính trù mật của ℚ trong ℝ và tiêu chuẩn Heine — cầu nối từ kết quả trên tập hữu tỉ sang toàn ℝ.',
    sections: [
      { type: 'theorem', title: 'Định lý', body: '$\\mathbb{Q}$ trù mật trong $\\mathbb{R}$: với mọi $a < b$, tồn tại $q \\in \\mathbb{Q}$ sao cho $a < q < b$.\nTiêu chuẩn Heine: $f$ liên tục tại $x_0$ khi và chỉ khi với mọi dãy $x_n \\to x_0$ thì $f(x_n) \\to f(x_0)$.' },
      { type: 'technique', title: 'Kỹ thuật giải', body: 'Chiến lược trù mật: chứng minh đẳng thức mong muốn trên $\\mathbb{Q}$, rồi dùng tính liên tục (qua Heine) mở rộng ra $\\mathbb{R}$.\nĐây là công cụ chính để giải phương trình Cauchy khi có điều kiện liên tục.' },
      { type: 'example', title: 'Ví dụ minh họa', body: 'Nếu $f(x + y) = f(x) + f(y)$ và $f$ liên tục: với $q \\in \\mathbb{Q}$ chứng minh được $f(q) = qf(1)$.\nVới $x$ bất kỳ, chọn $q_n \\to x$ ($q_n \\in \\mathbb{Q}$): $f(x) = \\lim f(q_n) = \\lim q_n f(1) = xf(1)$.' }
    ]
  },
  {
    id: 'cauchy',
    topicId: 'r-thuc',
    title: 'Phương trình hàm Cauchy',
    displayOrder: 2,
    objective: 'Giải phương trình Cauchy $f(x + y) = f(x) + f(y)$ và hiểu vai trò của điều kiện bổ sung.',
    sections: [
      { type: 'definition', title: 'Định nghĩa', body: 'Phương trình hàm Cauchy (cộng tính): $f(x + y) = f(x) + f(y)$ với mọi $x, y \\in \\mathbb{R}$.' },
      { type: 'theorem', title: 'Định lý', body: 'Nếu $f$ cộng tính và liên tục (hoặc đơn điệu, hoặc bị chặn trên một khoảng) thì $f(x) = cx$ với $c = f(1)$.\nKhông có điều kiện bổ sung thì tồn tại nghiệm “bệnh hoạn” không tuyến tính, xây dựng qua cơ sở Hamel.' },
      { type: 'technique', title: 'Kỹ thuật giải', body: 'Chứng minh theo bậc thang: $\\mathbb{N} \\to \\mathbb{Z} \\to \\mathbb{Q} \\to \\mathbb{R}$ (bước cuối cần liên tục hoặc đơn điệu).' },
      { type: 'example', title: 'Ví dụ minh họa', body: '$f(x + y) = f(x) + f(y)$ với $f$ liên tục $\\Rightarrow f(x) = cx$.\nThử lại: $c(x + y) = cx + cy$ đúng với mọi $c \\in \\mathbb{R}$.' }
    ]
  },
  {
    id: 'dieu-kien-lien-tuc-don-dieu',
    topicId: 'r-thuc',
    title: 'Điều kiện liên tục, đơn điệu hoặc bị chặn',
    displayOrder: 3,
    objective: 'Nắm ba điều kiện đủ để kết luận nghiệm Cauchy là tuyến tính và biết khai thác chúng trong đề bài.',
    sections: [
      { type: 'theorem', title: 'Định lý', body: 'Đối với phương trình Cauchy, ba điều kiện sau đều đủ để kết luận $f(x) = cx$:\n(1) $f$ liên tục tại một điểm;\n(2) $f$ đơn điệu trên một khoảng;\n(3) $f$ bị chặn (trên hoặc dưới) trên một khoảng.' },
      { type: 'technique', title: 'Kỹ thuật giải', body: 'Chứng minh nhanh với đơn điệu: kẹp $x$ giữa hai dãy hữu tỉ rồi so sánh.\nTrong đề thi, điều kiện liên tục/đơn điệu thường được cho kèm — đừng bỏ sót khi đọc đề.' },
      { type: 'example', title: 'Ví dụ minh họa', body: '$f$ cộng tính và $f(x) \\ge 0$ với mọi $x \\ge 0$.\nKhi đó $x \\ge y \\Rightarrow f(x) - f(y) = f(x - y) \\ge 0$ nên $f$ tăng.\nSuy ra $f(x) = cx$ với $c = f(1) \\ge 0$.' }
    ]
  },
  {
    id: 'thay-bien-doi-xung',
    topicId: 'r-thuc',
    title: 'Kỹ thuật thay biến và đối xứng',
    displayOrder: 4,
    objective: 'Thành thạo các phép thế thông minh và khai thác tính đối xứng của điều kiện để đưa về dạng quen thuộc.',
    sections: [
      { type: 'technique', title: 'Kỹ thuật giải', body: 'Các phép thế kinh điển: $x = 0$, $y = f(x)$, $x = y$, hoán vị hai biến, thay $x$ bằng $f(x)$…\nKỹ thuật đối xứng: nếu điều kiện đối xứng theo $x, y$, hoán đổi hai biến rồi trừ (hoặc cộng) hai phương trình để khử phần đối xứng.\nMục tiêu chung: cô lập $f(x)$ hoặc đưa về dạng Cauchy.' },
      { type: 'example', title: 'Ví dụ minh họa', body: 'Với $f(x) - f(y) = (x - y)g(x + y)$: hoán vị $x, y$ rồi trừ vế theo vế, đặt $t = x + y$ để khảo sát $g$.' }
    ]
  },
  {
    id: 'diem-bat-dong',
    topicId: 'r-thuc',
    title: 'Điểm bất động',
    displayOrder: 5,
    objective: 'Sử dụng điểm bất động như điểm tựa để thế biến và chặn nghiệm của phương trình hàm.',
    sections: [
      { type: 'definition', title: 'Định nghĩa', body: '$x_0$ là điểm bất động của $f$ nếu $f(x_0) = x_0$.\nTập các điểm bất động ký hiệu $\\operatorname{Fix}(f)$.' },
      { type: 'technique', title: 'Kỹ thuật giải', body: 'Nhiều bài chứng minh $\\operatorname{Fix}(f)$ “đóng” với một phép toán (cộng, nhân) rồi dùng trù mật hoặc cực hạn để suy ra nó là cả tập nguồn.\nThế $x = f(x)$ hoặc $x = f(y)$ để sinh điểm bất động mới từ điểm đã có.\nNếu $f(f(x)) = g(x)$ với $g$ không có điểm bất động thì $f$ cũng không có điểm bất động.' },
      { type: 'example', title: 'Ví dụ minh họa', body: '$f(f(x)) = x^2 + 2$: nếu $a$ là điểm bất động thì $a = a^2 + 2$ — vô nghiệm.\nVậy $f$ không có điểm bất động nào.' }
    ]
  },
  {
    id: 'nhieu-bien',
    topicId: 'r-thuc',
    title: 'Phương trình hàm nhiều biến',
    displayOrder: 6,
    objective: 'Xử lý điều kiện ba biến trở lên bằng cách cố định biến và quy về các dạng đã biết.',
    sections: [
      { type: 'technique', title: 'Kỹ thuật giải', body: 'Cố định các biến khác, khảo sát theo từng biến một.\nHoán vị các biến để tìm tính đối xứng của $f$.\nThường đưa về dạng $f(x) + f(y) = f(x + y)$ (cộng tính) hoặc $f(x)f(y) = f(x + y)$ (hàm mũ).' },
      { type: 'example', title: 'Ví dụ minh họa', body: '$f(x + y + z) = f(x) + f(y) + f(z)$: đặt $y = z = 0$ được $f(x) = f(x) + 2f(0) \\Rightarrow f(0) = 0$.\nĐặt $z = 0$ được phương trình Cauchy hai biến.' }
    ]
  },

  /* ---------- Chuyên đề 3: Rời rạc ---------- */
  {
    id: 'quy-dao-chu-ky',
    topicId: 'roi-rac',
    title: 'Quỹ đạo, chu kỳ và điểm bất động',
    displayOrder: 1,
    objective: 'Phân tích cấu trúc của hàm trên tập rời rạc qua quỹ đạo, chu kỳ và điểm bất động.',
    sections: [
      { type: 'definition', title: 'Định nghĩa', body: 'Quỹ đạo của $a$ dưới $f$ là dãy $a, f(a), f(f(a)), \\ldots$\nNếu $f^p(a) = a$ với $p$ dương nhỏ nhất thì $a$ có chu kỳ $p$; $p = 1$ tức là điểm bất động.' },
      { type: 'technique', title: 'Kỹ thuật giải', body: 'Vẽ quỹ đạo để hình dung cấu trúc của $f$ trên tập rời rạc.\nNếu $f(f(x)) = x$ với mọi $x$ thì mọi quỹ đạo có độ dài 1 hoặc 2: $f$ là đối hợp, gồm điểm bất động và các cặp hoán vị.' },
      { type: 'example', title: 'Ví dụ minh họa', body: '$f: \\mathbb{N} \\to \\mathbb{N}$, $f(f(n)) = n + 2$: vì $f \\circ f$ là “tịnh tiến” nên $f$ phải gần như là tịnh tiến — bài tập mẫu sẽ chứng minh $f(n) = n + 1$ hoặc $f$ hoán đổi chẵn lẻ.' }
    ]
  },
  {
    id: 'nguyen-ly-cuc-han',
    topicId: 'roi-rac',
    title: 'Nguyên lý cực hạn',
    displayOrder: 2,
    objective: 'Dùng tính sắp thứ tự tốt của ℕ, ℤ để phản chứng qua phần tử nhỏ nhất vi phạm.',
    sections: [
      { type: 'technique', title: 'Kỹ thuật giải', body: 'Trên $\\mathbb{N}$ (hoặc $\\mathbb{Z}$), mọi tập con khác rỗng đều có phần tử nhỏ nhất.\nChiến lược: giả sử tồn tại phần tử vi phạm điều cần chứng minh, chọn phần tử nhỏ nhất vi phạm, rồi từ điều kiện sinh ra phần tử nhỏ hơn vẫn vi phạm — mâu thuẫn.' },
      { type: 'example', title: 'Ví dụ minh họa', body: 'IMO 1977: $f(n + 1) > f(f(n))$ trên $\\mathbb{N}$. Lấy $m$ là giá trị nhỏ nhất của $f$; chỉ ra giá trị đó đạt tại $n = 0$, từ đó $m = 0$, rồi quy nạp được $f(n) = n$.' }
    ]
  },
  {
    id: 'danh-gia-don-dieu',
    topicId: 'roi-rac',
    title: 'Đánh giá đơn điệu',
    displayOrder: 3,
    objective: 'Chứng minh hàm tăng/giảm trên tập rời rạc rồi so sánh f(n) với n để chốt nghiệm.',
    sections: [
      { type: 'technique', title: 'Kỹ thuật giải', body: 'Với $f: \\mathbb{N} \\to \\mathbb{N}$, thường chứng minh $f$ tăng rồi so sánh $f(n)$ với $n$.\nNếu $f$ tăng và $f(f(n)) = n$ thì $f(n) = n$: vì $f(n) < n \\Rightarrow f(f(n)) < f(n) < n$ (mâu thuẫn), tương tự với $f(n) > n$.\nNếu $f$ tăng và $f(f(n)) \\le n + 1$ thì $f(n) \\in \\{n, n + 1\\}$ — tiếp tục xét tính chẵn lẻ để loại bớt.' },
      { type: 'example', title: 'Ví dụ minh họa', body: '$f$ tăng ngặt và $f(f(n)) = n + 1$: so sánh $f(n)$ với $n$ theo các trường hợp $f(n) < n$, $f(n) = n$, $f(n) > n$ rồi đối chiếu chẵn lẻ để loại nghiệm.' }
    ]
  },
  {
    id: 'lop-dong-du-tinh-tien',
    topicId: 'roi-rac',
    title: 'Phân hoạch lớp đồng dư và tịnh tiến tuần hoàn',
    displayOrder: 4,
    objective: 'Giải phương trình dạng f(n + m) = f(n) + m bằng cách xét riêng từng lớp đồng dư modulo m.',
    sections: [
      { type: 'technique', title: 'Kỹ thuật giải', body: 'Phân hoạch tập nguồn theo các lớp đồng dư modulo $m$: $n \\equiv 0, 1, \\ldots, m - 1 \\pmod m$.\nPhương trình tịnh tiến $f(n + m) = f(n) + m$: từng lớp đồng dư độc lập, $f$ được xác định hoàn toàn bởi giá trị trên mỗi lớp.\nKết hợp với điều kiện ban đầu (ví dụ $f(0)$, $f(1)$) để chốt hằng số trên từng lớp.' },
      { type: 'example', title: 'Ví dụ minh họa', body: '$f: \\mathbb{Z} \\to \\mathbb{Z}$, $f(n + 2) = f(n) + 2$. Đặt $n = 2k$ và $n = 2k + 1$:\n$f(2k) = 2k + a$, $f(2k + 1) = 2k + 1 + b$ với $a = f(0)$, $b = f(1) - 1$.' }
    ]
  },
  {
    id: 'cauchy-z-n',
    topicId: 'roi-rac',
    title: 'Phương trình Cauchy trên ℤ và ℕ',
    displayOrder: 5,
    objective: 'Giải phương trình Cauchy trên tập rời rạc — nơi không cần điều kiện liên tục.',
    sections: [
      { type: 'theorem', title: 'Định lý', body: 'Cauchy trên $\\mathbb{Z}$: $f(m + n) = f(m) + f(n) \\Rightarrow f(n) = nf(1)$ — không cần điều kiện liên tục vì $\\mathbb{Z}$ không có vấn đề trù mật.\nTrên $\\mathbb{N}$: kết quả tương tự $f(n) = nf(1)$, với lưu ý $f(1) \\ge 0$ nếu $f: \\mathbb{N} \\to \\mathbb{N}$.' },
      { type: 'technique', title: 'Kỹ thuật giải', body: 'Chứng minh quy nạp trên $\\mathbb{N}$, mở rộng sang $\\mathbb{Z}$ nhờ $f(-n) = -f(n)$ (suy từ $f(0) = 0$).\nVới $f: \\mathbb{N} \\to \\mathbb{N}$, kiểm tra thêm điều kiện $c = f(1) \\in \\mathbb{N}$.' },
      { type: 'example', title: 'Ví dụ minh họa', body: '$f: \\mathbb{Z} \\to \\mathbb{Z}$, $f(m + n) = f(m) + f(n)$ $\\Rightarrow f(n) = cn$ với $c = f(1) \\in \\mathbb{Z}$.\nMọi $c \\in \\mathbb{Z}$ đều cho nghiệm.' }
    ]
  }
];


const EXERCISES = [
  {
    id: 'ex-song-anh-1',
    topicId: 'nen-tang',
    title: 'Chứng minh f(x) = 2x + 1 là song ánh',
    difficulty: 1,
    techniques: ['song ánh'],
    type: 'Chứng minh song ánh',
    source: 'Ví dụ cơ bản',
    problem: 'Cho $f: \\mathbb{R} \\to \\mathbb{R}$ xác định bởi $f(x) = 2x + 1$. Chứng minh $f$ là song ánh và tìm hàm ngược.',
    related: ['Đơn ánh, toàn ánh, song ánh'],
    hint: 'Giải phương trình $f(x) = y$ theo $x$ với $y$ bất kỳ.',
    steps: [
      { content: 'Chứng minh đơn ánh: giả sử $f(a) = f(b)$. Khi đó $2a + 1 = 2b + 1 \\Rightarrow 2a = 2b \\Rightarrow a = b$. Vậy $f$ đơn ánh.', explanation: 'Dùng định nghĩa: $f(a) = f(b) \\Rightarrow a = b$.' },
      { content: 'Chứng minh toàn ánh: với $y \\in \\mathbb{R}$ tùy ý, chọn $x = \\frac{y - 1}{2} \\in \\mathbb{R}$. Ta có $f(x) = 2 \\cdot \\frac{y-1}{2} + 1 = y$. Vậy $f$ toàn ánh.', explanation: 'Với mọi $y$ ở tập đích, luôn tìm được $x$ ở tập nguồn.' },
      { content: '$f$ vừa đơn ánh vừa toàn ánh nên song ánh. Hàm ngược: $f^{-1}(x) = \\frac{x - 1}{2}$.', explanation: 'Hàm ngược chính là biểu thức $x$ theo $y$ tìm được ở bước 2.' }
    ]
  },
  {
    id: 'ex-cauchy-1',
    topicId: 'r-thuc',
    title: 'Phương trình hàm Cauchy với điều kiện liên tục',
    difficulty: 1,
    techniques: ['cauchy', 'trù mật'],
    type: 'Tìm hàm số',
    source: 'Kinh điển',
    problem: 'Tìm tất cả các hàm liên tục $f: \\mathbb{R} \\to \\mathbb{R}$ thỏa mãn $f(x + y) = f(x) + f(y)$ với mọi $x, y \\in \\mathbb{R}$.',
    related: ['Phương trình hàm Cauchy', 'Tính trù mật của ℚ trong ℝ'],
    hint: 'Tính $f(0)$, $f(-x)$, mở rộng từ ℕ lên ℚ, cuối cùng dùng tính liên tục.',
    steps: [
      { content: 'Thế $x = y = 0$: $f(0) = f(0) + f(0) \\Rightarrow f(0) = 0$.', explanation: 'Điểm tựa đầu tiên của mọi bài Cauchy.' },
      { content: 'Thế $y = -x$: $f(0) = f(x) + f(-x) \\Rightarrow f(-x) = -f(x)$.', explanation: 'Suy ra $f$ là hàm lẻ.' },
      { content: 'Quy nạp: $f(nx) = nf(x)$ với $n \\in \\mathbb{N}$. Từ tính lẻ mở rộng ra $\\mathbb{Z}$, rồi $f(q) = qf(1)$ với mọi $q \\in \\mathbb{Q}$.', explanation: 'Mở rộng theo bậc thang ℕ → ℤ → ℚ.' },
      { content: 'Với $x$ bất kỳ, chọn dãy hữu tỉ $q_n \\to x$. Do $f$ liên tục (tiêu chuẩn Heine): $f(x) = \\lim f(q_n) = \\lim q_n f(1) = xf(1)$.', explanation: 'Bước trù mật: ℚ trù mật trong ℝ.' },
      { content: 'Đặt $c = f(1)$: $f(x) = cx$. Thử lại: $c(x + y) = cx + cy$ đúng với mọi $c$. Vậy $f(x) = cx$, $c \\in \\mathbb{R}$.', explanation: 'Luôn thử lại nghiệm tìm được.' }
    ]
  },
  {
    id: 'ex-cauchy-2',
    topicId: 'r-thuc',
    title: 'Dùng tính song ánh từ f(x + f(y)) = f(x) + y',
    difficulty: 2,
    techniques: ['thay biến', 'song ánh', 'cauchy'],
    type: 'Tìm hàm số',
    source: 'Sưu tầm',
    problem: 'Tìm tất cả các hàm liên tục $f: \\mathbb{R} \\to \\mathbb{R}$ thỏa mãn $f(x + f(y)) = f(x) + y$ với mọi $x, y \\in \\mathbb{R}$.',
    related: ['Đơn ánh, toàn ánh, song ánh', 'Phương trình hàm Cauchy'],
    hint: 'Chứng minh f song ánh từ đẳng thức, tìm f(0) = 0, rồi đưa về phương trình Cauchy.',
    steps: [
      { content: 'Thế $x = 0$: $f(f(y)) = f(0) + y$ với mọi $y$.', explanation: 'Vế phải chạy khắp ℝ khi y chạy khắp ℝ.' },
      { content: 'Vì $y \\mapsto f(0) + y$ là song ánh trên $\\mathbb{R}$ và $f(f(y)) = f(0) + y$ nên $f$ toàn ánh. Nếu $f(a) = f(b)$ thì $f(f(a)) = f(f(b)) \\Rightarrow f(0) + a = f(0) + b \\Rightarrow a = b$, vậy $f$ đơn ánh. Do đó $f$ song ánh.', explanation: 'f∘f là một tịnh tiến nên f song ánh.' },
      { content: 'Vì $f$ song ánh, tồn tại $c$ với $f(c) = 0$. Thế $y = c$ vào $f(f(y)) = f(0) + y$: $f(f(c)) = f(0) + c \\Rightarrow f(0) = f(0) + c \\Rightarrow c = 0$. Vậy $f(0) = 0$.', explanation: 'Điểm tựa: f(0) = 0.' },
      { content: 'Thế $y = f(t)$ (được phép vì $f$ toàn ánh): $f(x + f(f(t))) = f(x) + f(t)$. Do $f(f(t)) = t$ (vì $f(0) = 0$), được $f(x + t) = f(x) + f(t)$.', explanation: 'Đưa về phương trình Cauchy.' },
      { content: 'Do $f$ liên tục và cộng tính nên $f(x) = cx$. Thay vào điều kiện gốc: $c(x + cy) = cx + y \\Rightarrow c^2 y = y$ với mọi $y \\Rightarrow c^2 = 1 \\Rightarrow c = \\pm 1$.', explanation: 'Dùng điều kiện gốc để chốt hằng số.' },
      { content: 'Vậy $f(x) = x$ hoặc $f(x) = -x$. Thử lại cả hai đều thỏa mãn.', explanation: 'Hai nghiệm.' }
    ]
  },
  {
    id: 'ex-r-2',
    topicId: 'r-thuc',
    title: 'Đưa về Cauchy bằng phép đổi hàm',
    difficulty: 2,
    techniques: ['thay biến', 'cauchy'],
    type: 'Tìm hàm số',
    source: 'Sưu tầm',
    problem: 'Tìm tất cả các hàm liên tục $f: \\mathbb{R} \\to \\mathbb{R}$ thỏa mãn $f(x - y) = f(x) + f(y) - 2xy$ với mọi $x, y \\in \\mathbb{R}$.',
    related: ['Phương trình hàm Cauchy', 'Kỹ thuật thay biến'],
    hint: 'Đặt $g(x) = f(x) - x^2$ để khử số hạng $2xy$.',
    steps: [
      { content: 'Đặt $g(x) = f(x) - x^2$, tức $f(x) = g(x) + x^2$.', explanation: 'Khử số hạng 2xy bằng hằng đẳng thức.' },
      { content: 'Thay vào điều kiện: $g(x - y) + (x - y)^2 = g(x) + x^2 + g(y) + y^2 - 2xy$. Khai triển $(x - y)^2 = x^2 - 2xy + y^2$, rút gọn được $g(x - y) = g(x) + g(y)$.', explanation: 'Phép đổi hàm đưa về dạng Cauchy.' },
      { content: 'Thế $y = -t$: $g(x + t) = g(x) + g(-t)$. Thế $x = y = 0$: $g(0) = 2g(0) \\Rightarrow g(0) = 0$; thế $x = 0$: $g(-t) = g(0) + g(t) = g(t)$. Vậy $g(x + t) = g(x) + g(t)$.', explanation: 'g cộng tính.' },
      { content: '$g$ liên tục (vì $f$ liên tục) và cộng tính nên $g(x) = cx$.', explanation: 'Áp dụng kết quả bài Cauchy.' },
      { content: 'Vậy $f(x) = x^2 + cx$ với $c \\in \\mathbb{R}$. Thử lại thỏa mãn.', explanation: 'Họ nghiệm một tham số.' }
    ]
  },
  {
    id: 'ex-da-thuc-1',
    topicId: 'da-thuc',
    title: 'Đa thức thỏa mãn P(x²) = P(x)P(x + 1)',
    difficulty: 2,
    techniques: ['phân tích nghiệm', 'chặn bậc'],
    type: 'Tìm đa thức',
    source: 'Sưu tầm',
    problem: 'Tìm tất cả các đa thức hệ số thực $P(x)$ thỏa mãn $P(x^2) = P(x)P(x + 1)$ với mọi $x \\in \\mathbb{R}$.',
    related: ['Định lý đồng nhất đa thức', 'Kỹ thuật phân tích nghiệm'],
    hint: 'Xét nghiệm α của P: nếu α ∉ {0, 1} thì sinh ra vô hạn nghiệm, mâu thuẫn định lý đồng nhất.',
    steps: [
      { content: '$P \\equiv 0$ và $P \\equiv 1$ thỏa mãn. Xét $P \\neq 0$, $P \\not\\equiv 1$.', explanation: 'Loại nghiệm tầm thường trước.' },
      { content: 'Đặt $\\deg P = n$. So sánh hệ số bậc cao nhất hai vế (cùng bậc $2n$): $a_n = a_n^2 \\Rightarrow a_n = 1$.', explanation: 'Hệ số đầu bằng 1.' },
      { content: 'Giả sử $P(\\alpha) = 0$. Thế $x = \\alpha$: $P(\\alpha^2) = P(\\alpha)P(\\alpha + 1) = 0 \\Rightarrow \\alpha^2$ là nghiệm. Thế $x = \\alpha - 1$: $P((\\alpha - 1)^2) = 0 \\Rightarrow (\\alpha - 1)^2$ là nghiệm.', explanation: 'Hai “cỗ máy sinh nghiệm”: α ↦ α² và α ↦ (α−1)².' },
      { content: 'Nếu $\\alpha \\notin \\{0, 1\\}$: khi $|\\alpha| \\neq 0, 1$, dãy $\\alpha, \\alpha^2, \\alpha^4, \\ldots$ (nếu $|\\alpha| \\neq 1$) hoặc dãy sinh bởi $\\alpha \\mapsto (\\alpha - 1)^2$ là vô hạn nghiệm phân biệt $\\Rightarrow P \\equiv 0$ (định lý đồng nhất), mâu thuẫn $P \\neq 0$. Vậy nghiệm của $P$ chỉ có thể là $0$ hoặc $1$.', explanation: 'Chặn tập nghiệm về {0, 1}.' },
      { content: 'Suy ra $P(x) = x^m(x - 1)^n$ (hệ số đầu bằng 1 theo bước 2). Thay vào điều kiện: $x^{2m}(x^2 - 1)^n = x^m(x - 1)^n \\cdot x^n(x + 1)^n$.', explanation: 'Dạng nghiệm tổng quát sau khi chặn nghiệm.' },
      { content: 'Rút gọn vế phải: $x^{m+n}(x - 1)^n(x + 1)^n$. So sánh bậc: $2m = m + n \\Rightarrow m = n$. Vậy $P(x) = x^n(x - 1)^n$, $n \\in \\mathbb{N}$.', explanation: 'So sánh số mũ để chốt kết quả.' },
      { content: 'Kết luận: $P \\equiv 0$, $P \\equiv 1$ hoặc $P(x) = x^n(x - 1)^n$. Thử lại đều thỏa mãn.', explanation: 'Ghi đủ ba họ nghiệm.' }
    ]
  },
  {
    id: 'ex-da-thuc-2',
    topicId: 'da-thuc',
    title: 'Tìm đa thức P với P(P(x)) = x⁴ − 2x²',
    difficulty: 3,
    techniques: ['chặn bậc'],
    type: 'Tìm đa thức',
    source: 'Sưu tầm',
    problem: 'Tìm tất cả các đa thức hệ số thực $P$ thỏa mãn $P(P(x)) = x^4 - 2x^2$ với mọi $x \\in \\mathbb{R}$.',
    related: ['Bậc của đa thức và đa thức hợp'],
    hint: 'deg(P∘P) = (deg P)² = 4 ⇒ deg P = 2.',
    steps: [
      { content: 'Nếu $P$ hằng thì $P(P(x))$ hằng, mâu thuẫn. Đặt $\\deg P = n \\ge 1$. Ta có $\\deg(P \\circ P) = n^2 = \\deg(x^4 - 2x^2) = 4 \\Rightarrow n = 2$.', explanation: 'Bậc của đa thức hợp bằng tích bậc.' },
      { content: 'Đặt $P(x) = ax^2 + bx + c$ với $a \\neq 0$. Hệ số của $x^4$ trong $P(P(x))$ là $a^3$. Vậy $a^3 = 1 \\Rightarrow a = 1$ (hệ số thực).', explanation: 'So sánh hệ số bậc cao nhất.' },
      { content: '$P(x) = x^2 + bx + c$. Khai triển $P(P(x))$: hệ số của $x^3$ là $2b$. So với vế phải: $2b = 0 \\Rightarrow b = 0$.', explanation: 'Khử số hạng bậc lẻ.' },
      { content: '$P(x) = x^2 + c$. Khi đó $P(P(x)) = (x^2 + c)^2 + c = x^4 + 2cx^2 + c^2 + c$. So sánh với $x^4 - 2x^2$: $2c = -2 \\Rightarrow c = -1$; kiểm tra $c^2 + c = 0$ đúng với $c = -1$.', explanation: 'Hai hệ số cùng cho c = −1.' },
      { content: 'Vậy $P(x) = x^2 - 1$. Thử lại: $P(P(x)) = (x^2 - 1)^2 - 1 = x^4 - 2x^2$. Đúng.', explanation: 'Nghiệm duy nhất.' }
    ]
  },
  {
    id: 'ex-roi-rac-1',
    topicId: 'roi-rac',
    title: 'Hàm trên ℕ với f(f(n)) = n + 2',
    difficulty: 3,
    techniques: ['quỹ đạo', 'song ánh', 'lớp đồng dư'],
    type: 'Tìm hàm số',
    source: 'Sưu tầm',
    problem: 'Tìm tất cả các hàm $f: \\mathbb{N} \\to \\mathbb{N}$ thỏa mãn $f(f(n)) = n + 2$ với mọi $n \\in \\mathbb{N}$.',
    related: ['Quỹ đạo của hàm số', 'Phân hoạch theo lớp đồng dư'],
    hint: 'Chứng minh f song ánh, rồi f(n + 2) = f(n) + 2, rồi xét riêng n chẵn và n lẻ.',
    steps: [
      { content: 'Vì $n \\mapsto n + 2$ là song ánh trên $\\mathbb{N}$ và $f \\circ f$ bằng chính ánh xạ đó nên $f$ song ánh.', explanation: 'f∘f song ánh ⇒ f song ánh.' },
      { content: 'Tính $f(f(f(n)))$ theo hai cách: dùng đẳng thức với biến $f(n)$ được $f(n) + 2$; áp $f$ vào đẳng thức gốc được $f(n + 2)$. Vậy $f(n + 2) = f(n) + 2$.', explanation: 'Tịnh tiến từng lớp chẵn/lẻ.' },
      { content: 'Suy ra $f(2k) = f(0) + 2k$ và $f(2k + 1) = f(1) + 2k$ với mọi $k$.', explanation: 'Phân hoạch theo lớp đồng dư mod 2.' },
      { content: 'Từ $f(f(0)) = 2$: nếu $f(0)$ chẵn, $f(0) = 2k \\Rightarrow f(f(0)) = f(2k) = f(0) + 2k = 4k = 2 \\Rightarrow k = \\frac{1}{2}$, vô lý. Vậy $f(0) = 2k + 1$ lẻ. Khi đó $f(f(0)) = f(2k + 1) = f(1) + 2k = 2 \\Rightarrow f(1) = 2 - 2k \\ge 0 \\Rightarrow k \\in \\{0, 1\\}$.', explanation: 'Chặn f(0), f(1) bằng tính nguyên.' },
      { content: 'Trường hợp $k = 0$: $f(0) = 1$, $f(1) = 2 \\Rightarrow f(n) = n + 1$. Trường hợp $k = 1$: $f(0) = 3$, $f(1) = 0 \\Rightarrow f(2k) = 2k + 3$, $f(2k + 1) = 2k$.', explanation: 'Hai nghiệm ứng với hai cách nối quỹ đạo.' },
      { content: 'Thử lại cả hai hàm đều thỏa mãn $f(f(n)) = n + 2$.', explanation: 'Kiểm tra trực tiếp.' }
    ]
  },
  {
    id: 'ex-roi-rac-2',
    topicId: 'roi-rac',
    title: 'Phương trình tịnh tiến trên ℤ',
    difficulty: 1,
    techniques: ['lớp đồng dư'],
    type: 'Tìm hàm số',
    source: 'Ví dụ cơ bản',
    problem: 'Tìm tất cả các hàm $f: \\mathbb{Z} \\to \\mathbb{Z}$ thỏa mãn $f(n + 2) = f(n) + 2$, $f(0) = 0$, $f(1) = 1$ với mọi $n \\in \\mathbb{Z}$.',
    related: ['Phân hoạch theo lớp đồng dư', 'Phương trình tịnh tiến tuần hoàn'],
    hint: 'Xét riêng n chẵn và n lẻ rồi quy nạp hai chiều.',
    steps: [
      { content: 'Với $n = 2k$: quy nạp theo $k \\ge 0$ được $f(2k) = f(0) + 2k = 2k$; với $k < 0$, viết $f(n) = f(n + 2) - 2$ và quy nạp ngược, vẫn được $f(2k) = 2k$.', explanation: 'Lớp chẵn xác định hoàn toàn bởi f(0).' },
      { content: 'Với $n = 2k + 1$: tương tự $f(2k + 1) = f(1) + 2k = 2k + 1$.', explanation: 'Lớp lẻ xác định bởi f(1).' },
      { content: 'Vậy $f(n) = n$ với mọi $n \\in \\mathbb{Z}$. Thử lại thỏa mãn.', explanation: 'Mỗi lớp đồng dư độc lập nên điều kiện ban đầu quyết định hàm.' }
    ]
  }
];
