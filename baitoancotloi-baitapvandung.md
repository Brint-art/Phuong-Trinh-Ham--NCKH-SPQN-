# BÀI TOÁN CỐT LÕI VÀ BÀI TẬP VẬN DỤNG

## 2.1 Phương trình hàm đa thức

### 2.1.3 Bài toán cốt lõi

#### Bài toán 1 (IMO 2001)
Tìm tất cả các đa thức $P(x) \in \mathbb{R}[x]$ thỏa mãn:
$$P(x^2) = P(x)P(x-1), \quad \forall x \in \mathbb{R}$$

* **Lời giải:**
  * **Trường hợp 1:** $P(x) = C$ (hằng số). Thay vào phương trình: $C = C^2 \implies C = 0$ hoặc $C = 1$.
  * **Trường hợp 2:** $P(x)$ có bậc $n \ge 1$.  
    Giả sử $\alpha$ là một nghiệm phức của $P(x)$. Ta có:
    $$P(\alpha^2) = P(\alpha)P(\alpha-1) = 0 \implies \alpha^2 \text{ cũng là nghiệm}.$$
    Tiếp tục quá trình, dãy $(\alpha^{2^k})_{k \ge 1}$ đều là nghiệm của $P(x)$. Để đa thức có hữu hạn nghiệm, bắt buộc $|\alpha| \le 1$.  
    Mặt khác, thay $x = \alpha + 1$ vào phương trình:
    $$P((\alpha+1)^2) = P(\alpha+1)P(\alpha) = 0 \implies (\alpha+1)^2 \text{ là nghiệm}.$$
    Tương tự ta có $|\alpha + 1| \le 1$.  
    Đặt $\alpha = a + bi$. Kết hợp $|\alpha| \le 1$ và $|\alpha+1| \le 1$, suy ra $a \le 0$. Xét nghiệm $\alpha^2$, phần thực của $\alpha^2$ là $a^2 - b^2 \le 0 \implies a^2 \le b^2$. Dẫn đến nghiệm duy nhất có thể là $\alpha = 0$.  
    Theo định lý nghiệm, $P(x) = C x^n$. Thay vào phương trình ban đầu được:
    $$C x^{2n} = C^2 x^n (x-1)^n$$
    Đẳng thức không thể xảy ra với $n \ge 1$ vì vế phải có nghiệm $x = 1$ nhưng vế trái thì không.
  * **Kết luận:** $P(x) \equiv 0$ hoặc $P(x) \equiv 1$.

---

### 2.1.4 Các bài toán áp dụng

#### Bài toán 2 (VMO 2006 - Tịnh tiến nghiệm)
Tìm tất cả đa thức $P(x) \in \mathbb{R}[x]$ thỏa mãn:
$$xP(x-1) = (x-3)P(x), \quad \forall x \in \mathbb{R}$$

* **Lời giải:**
  * Cho $x = 0 \implies -3P(0) = 0 \implies P(0) = 0$.
  * Cho $x = 1 \implies P(0) = -2P(1) \implies P(1) = 0$.
  * Cho $x = 2 \implies 2P(1) = -P(2) \implies P(2) = 0$.
  * Vậy $P(x) = x(x-1)(x-2)Q(x)$. Thay vào phương trình ban đầu suy ra:
    $$Q(x-1) = Q(x), \quad \forall x \in \mathbb{R} \implies Q(x) \equiv C$$
  * **Kết luận:** $P(x) = C x(x-1)(x-2)$ với $C \in \mathbb{R}$.

#### Bài toán 3 (Chặn bậc)
Tìm tất cả đa thức $P(x) \in \mathbb{R}[x]$ thỏa mãn:
$$P(x)^2 = P(x^2), \quad \forall x \in \mathbb{R}$$
* **Kết luận:** $P(x) \equiv 0$, $P(x) \equiv 1$, hoặc $P(x) = x^n$ ($n \in \mathbb{N}^*$).

#### Bài toán 4 (Olympic Nga 1999 - Đánh giá Mô-đun)
Tìm tất cả đa thức $P(x) \in \mathbb{R}[x]$ thỏa mãn:
$$P(x)P(x+1) = P(x^2+x), \quad \forall x \in \mathbb{R}$$
* **Kết luận:** $P(x) \equiv 0$, $P(x) \equiv 1$, hoặc $P(x) = x^n$.

#### Bài toán 5 (Khảo sát tập giá trị)
Tìm tất cả đa thức $P(x) \in \mathbb{R}[x]$ thỏa mãn:
$$P(P(x)) = [P(x)]^{2026}, \quad \forall x \in \mathbb{R}$$
* **Kết luận:** $P(x) \equiv 0$, $P(x) \equiv 1$, hoặc $P(x) = x^{2026}$.

#### Bài toán 6 (Toán tử sai phân)
Tìm tất cả đa thức $P(x) \in \mathbb{R}[x]$ thỏa mãn:
$$P(x+1) + P(x-1) = 2P(x), \quad \forall x \in \mathbb{R}$$
* **Kết luận:** $P(x) = Cx + D$ với $C, D \in \mathbb{R}$.

---

## 2.2 Phương trình hàm trên $\mathbb{R}$

#### Bài toán 7 (IMO 2002 - Tính đơn ánh)
Tìm tất cả các hàm số $f: \mathbb{R} \to \mathbb{R}$ thỏa mãn:
$$f(f(x) + y) = f(x+y) + f(0), \quad \forall x, y \in \mathbb{R}$$
* **Kết luận:** $f(x) \equiv 0$ hoặc $f(x) = x$.

#### Bài toán 8 (VMO 2005 - Mở rộng Cauchy / Hàm lượng giác)
Tìm tất cả các hàm số $f: \mathbb{R} \to \mathbb{R}$ liên tục thỏa mãn $|f(x)| \le 1$ và:
$$f(x+y) + f(x-y) = 2f(x)f(y), \quad \forall x, y \in \mathbb{R}$$
* **Kết luận:** $f(x) = \cos(cx)$ với $c \in \mathbb{R}$.

#### Bài toán 9 (IMO 2004)
Tìm tất cả các hàm số $f: \mathbb{R} \to \mathbb{R}$ thỏa mãn:
$$f(x + f(y)) = f(x) + yf(y), \quad \forall x, y \in \mathbb{R}$$
* **Kết luận:** $f(x) \equiv 0$.

#### Bài toán 10 (Phương trình đa biến)
Tìm tất cả các hàm số $f: \mathbb{R} \to \mathbb{R}$ thỏa mãn:
$$f(x^2 - y^2) = xf(x) - yf(y), \quad \forall x, y \in \mathbb{R}$$
* **Kết luận:** $f(x) = cx$ với $c \in \mathbb{R}$.

#### Bài toán 11
Tìm tất cả các hàm số $f: \mathbb{R} \to \mathbb{R}$ thỏa mãn:
$$f(x+y+f(y)) = f(x) + 2y, \quad \forall x, y \in \mathbb{R}$$
* **Kết luận:** $f(x) = x$.

---

## 2.3 Phương trình hàm trên tập rời rạc

#### Bài toán 12 (IMO 1977)
Tìm tất cả các hàm số $f: \mathbb{N}^* \to \mathbb{N}^*$ thỏa mãn:
$$f(f(n)) < f(n+1), \quad \forall n \in \mathbb{N}^*$$
* **Kết luận:** $f(n) = n, \quad \forall n \in \mathbb{N}^*$.

#### Bài toán 13 (Phân hoạch quỹ đạo)
Chứng minh rằng không tồn tại hàm số $f: \mathbb{Z} \to \mathbb{Z}$ thỏa mãn:
$$f(f(n)) = n + 2025, \quad \forall n \in \mathbb{Z}$$
*(Lý do: $2025$ là số lẻ, không thể ghép thành các cặp quỹ đạo rời nhau).*

#### Bài toán 14
Tìm tất cả các hàm số $f: \mathbb{N}^* \to \mathbb{N}^*$ thỏa mãn:
1. $f(mf(n)) = n^2 f(m)$
2. $f(m+n) \le f(m) + f(n)$
* **Kết luận:** Không tồn tại hàm số nào thỏa mãn.

#### Bài toán 15 (Cauchy trên $\mathbb{Z}$)
Tìm tất cả các hàm số $f: \mathbb{Z} \to \mathbb{Z}$ thỏa mãn:
$$f(m + f(n)) = f(m) + n, \quad \forall m, n \in \mathbb{Z}$$
* **Kết luận:** $f(n) = n$ hoặc $f(n) = -n$.