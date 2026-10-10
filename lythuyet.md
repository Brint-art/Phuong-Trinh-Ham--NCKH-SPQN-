# CHƯƠNG 1: KIẾN THỨC NỀN TẢNG VỀ HÀM SỐ VÀ ÁNH XẠ

## 1.2 Kiến thức nền tảng về hàm số và ánh xạ

### 1.2.1 Ánh xạ
* **Định nghĩa:** Giả sử $X$ và $Y$ là hai tập hợp cho trước. Một ánh xạ $f$ từ $X$ vào $Y$ là một quy tắc tương ứng với mỗi phần tử $x \in X$ tương ứng với đúng một phần tử $y \in Y$.  
  Ký hiệu: $f: X \to Y$. Phần tử $y$ được gọi là ảnh của $x$ và được viết là $y = f(x)$.
* **Lưu ý:** Giả sử $f: X \to Y$ là một ánh xạ, $A \subset X$ và $B \subset Y$ tùy ý:
  * $\forall x \in X$, $f(x)$ được gọi là ảnh của $x$ bởi $f$ hay giá trị của ánh xạ $f$ tại điểm $x$.
  * $f(A) = \{y \in Y \mid \exists x \in A: f(x) = y\}$, được gọi là ảnh của tập hợp $A$ bởi ánh xạ $f$.
  * $f^{-1}(B) = \{x \in X \mid f(x) \in B\}$ được gọi là tạo ảnh của tập hợp $B$ bởi $f$.

### 1.2.2 Đơn ánh, toàn ánh, song ánh
* **Đơn ánh:** Ánh xạ $f: X \to Y$ là một đơn ánh nếu với mọi $x_1, x_2 \in X$:
  $$x_1 \ne x_2 \implies f(x_1) \ne f(x_2) \iff f(x_1) = f(x_2) \implies x_1 = x_2$$
* **Toàn ánh:** Ánh xạ $f: X \to Y$ là một toàn ánh nếu với mọi $y \in Y$, luôn tồn tại $x \in X$ sao cho $f(x) = y$. Tức là $f(X) = Y$.
* **Song ánh:** Ánh xạ $f: X \to Y$ là một song ánh nếu với mọi $y \in Y$ luôn tồn tại duy nhất một phần tử $x \in X$ sao cho $f(x) = y$. Một ánh xạ là song ánh khi và chỉ khi nó vừa là đơn ánh, vừa là toàn ánh (ánh xạ một - một).

### 1.2.3 Hàm số
* **Định nghĩa:** Cho $X \subset \mathbb{R}$ và $Y \subset \mathbb{R}$. Khi đó ánh xạ $f: X \to Y$ được gọi là một hàm số từ tập $X$ đến tập $Y$.
* **Một số chú ý:**
  * Tập $X$ gọi là tập xác định của hàm số $f$.
  * Nếu $x_0 \in X$ thì $f(x_0)$ gọi là giá trị của hàm số $f$ tại điểm $x_0$.
  * Tập hợp $f(X)$ gọi là tập giá trị của hàm số $f$.
  * $y_0$ thuộc tập giá trị của hàm số $f$ khi và chỉ khi phương trình $f(x) = y_0$ có nghiệm thuộc $X$.
  * $f$ là toàn ánh $\iff$ Phương trình ẩn $x$: $f(x) = y$ có nghiệm với mọi $y \in Y$.
  * $f$ là song ánh $\iff$ Phương trình ẩn $x$: $f(x) = y$ có nghiệm duy nhất với mọi $y \in Y$.

---

# CHƯƠNG 2: PHƯƠNG TRÌNH HÀM

## 2.1 Phương trình hàm đa thức và kỹ thuật phân tích nghiệm

### 2.1.1 Kiến thức bổ trợ
* **Số phức và Mô-đun:**  
  Mỗi số phức $z \in \mathbb{C}$ có dạng $z = a + bi$ với $a, b \in \mathbb{R}$ và $i^2 = -1$. Đại lượng $a$ là phần thực, $b$ là phần ảo.  
  Mô-đun của số phức $z$, ký hiệu là $|z|$, là khoảng cách từ điểm biểu diễn $z$ đến gốc tọa độ trên mặt phẳng phức:
  $$|z| = \sqrt{a^2 + b^2}$$
* **Định lý 2.1.1 (Bất đẳng thức tam giác cho số phức):**  
  Với mọi số phức $z_1, z_2 \in \mathbb{C}$, ta luôn có:
  $$|z_1 + z_2| \le |z_1| + |z_2|$$
  *Chứng minh:*  
  Xét bình phương vế trái:
  $$|z_1 + z_2|^2 = (z_1 + z_2)(\overline{z_1} + \overline{z_2}) = |z_1|^2 + |z_2|^2 + 2\operatorname{Re}(z_1\overline{z_2})$$
  Vì $\operatorname{Re}(w) \le |w|$, ta có:
  $$2\operatorname{Re}(z_1\overline{z_2}) \le 2|z_1\overline{z_2}| = 2|z_1||z_2|$$
  Suy ra:
  $$|z_1 + z_2|^2 \le (|z_1| + |z_2|)^2 \implies |z_1 + z_2| \le |z_1| + |z_2|$$
* **Định lý 2.1.2 (Định lý cơ bản của Đại số):**  
  Mọi đa thức bậc $n \ge 1$ với hệ số thực (hoặc phức) đều có đúng $n$ nghiệm trên tập số phức $\mathbb{C}$ (tính cả nghiệm bội).

### 2.1.2 Kiến thức nền tảng
Mọi đa thức $P(x)$ với hệ số thực đều biểu diễn dưới dạng:
$$P(x) = \sum_{i=0}^n a_i x^i = a_n x^n + \dots + a_1 x + a_0$$
Nếu $a_n \ne 0$ thì $n = \deg P$. Đa thức hằng $P(x) = C \ne 0$ có bậc là $0$, còn đa thức không $P(x) \equiv 0$ quy ước có $\deg = -\infty$.

* **Định lý 2.1.3 (Định lý Bézout):**  
  Số $\alpha$ là nghiệm của đa thức $P(x)$ khi và chỉ khi $P(x)$ chia hết cho $(x - \alpha)$.
* **Định lý 2.1.4 (Định lý đồng nhất đa thức):**  
  Nếu hai đa thức $P(x)$ và $Q(x)$ có bậc không vượt quá $n$ và nhận cùng giá trị tại $n+1$ điểm phân biệt thì $P(x) \equiv Q(x)$.  
  *Hệ quả:* Nếu một đa thức nhận giá trị bằng $0$ tại vô số điểm phân biệt thì nó phải là đa thức không ($P(x) \equiv 0$).
* **Định lý 2.1.5 (Bậc của đa thức):**  
  Với hai đa thức khác không có $\deg P = n$ và $\deg Q = m$:
  1. $\deg(P \cdot Q) = n + m$
  2. Nếu $m \ge 1$ thì $\deg(P(Q(x))) = n \cdot m$

---

## 2.2 Phương trình hàm trên $\mathbb{R}$ - Kỹ thuật Cauchy và điểm bất động

### 2.2.1 Kiến thức bổ trợ
* **Tính trù mật của $\mathbb{Q}$ trong $\mathbb{R}$:** Giữa hai số thực bất kỳ luôn tồn tại ít nhất một số hữu tỉ.  
  *Hệ quả:* Với mọi số thực $x \in \mathbb{R}$, luôn tồn tại một dãy số hữu tỉ $(r_n)$ sao cho $\lim_{n \to \infty} r_n = x$.
* **Định lý 2.2.1 (Tiêu chuẩn Heine về tính liên tục):**  
  Hàm số $f(x)$ liên tục tại điểm $x_0$ khi và chỉ khi với mọi dãy số $(x_n)$ hội tụ về $x_0$, ta luôn có:
  $$\lim_{n \to \infty} f(x_n) = f(x_0)$$

### 2.2.2 Kiến thức nền tảng
* **Phương trình hàm Cauchy:** $f(x+y) = f(x) + f(y), \quad \forall x, y \in \mathbb{R}$
* **Định lý 2.2.2:**  
  Nếu hàm số $f: \mathbb{R} \to \mathbb{R}$ thỏa mãn phương trình Cauchy và liên tục tại ít nhất một điểm (hoặc bị chặn trên một khoảng bất kỳ), thì:
  $$f(x) = cx, \quad \forall x \in \mathbb{R} \quad (c = f(1))$$
* **Định lý 2.2.3 (Tính đơn ánh và toàn ánh của hàm hợp):**
  Cho $f: X \to Y$ và $g: Y \to Z$:
  1. Nếu $g \circ f$ là đơn ánh thì $f$ là đơn ánh.
  2. Nếu $g \circ f$ là toàn ánh thì $g$ là toàn ánh.
  3. Nếu $f$ là song ánh thì phương trình $f(x) = y$ có nghiệm duy nhất với mọi $y \in Y$.

---

## 2.3 Phương trình hàm trên tập rời rạc

### 2.3.1 Kiến thức nền tảng
* **Quỹ đạo của phần tử:** Quỹ đạo của $x \in X$ dưới tác động của hàm $f: X \to X$ là dãy:
  $$\mathcal{O}(x) = \{x, f(x), f(f(x)), \dots, f^{(k)}(x), \dots\}$$
* **Định lý 2.3.1 (Nguyên lý cực hạn):**  
  Cho $f: \mathbb{N}^* \to \mathbb{N}^*$. Nếu $f(f(n)) < f(n+1)$ với mọi $n \in \mathbb{N}^*$, thì:
  $$f(n) = n, \quad \forall n \in \mathbb{N}^*$$
* **Định lý 2.3.2:**  
  Cho $c \in \mathbb{Z}^+$. Phương trình $f(f(n)) = n + c$ có nghiệm $f: \mathbb{Z} \to \mathbb{Z}$ khi và chỉ khi $c$ là một số chẵn.