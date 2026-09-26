/* ============================================================
   /api/generate-exercises.js — Vercel Serverless Function
   Nhận yêu cầu tạo bộ bài tập, gọi Mistral API, kiểm tra JSON.
   API key chỉ nằm trong biến môi trường của Vercel — không bao giờ
   xuất hiện trong code phía trình duyệt.
   ============================================================ */

const MISTRAL_API_KEY = process.env.MISTRAL_API_KEY;
const MISTRAL_MODEL = process.env.MISTRAL_MODEL || 'mistral-small-2603';
const MISTRAL_ENDPOINT = 'https://api.mistral.ai/v1/chat/completions';

/* Giới hạn đơn giản (trong bộ nhớ, mỗi instance serverless một bộ đếm riêng).
   Giai đoạn sau sẽ chuyển sang đếm theo tài khoản trong Supabase. */
const RATE_LIMIT_MAX = 20;          // số yêu cầu tối đa trong cửa sổ
const RATE_LIMIT_WINDOW_MS = 60 * 60 * 1000; // 1 giờ
const requestLog = [];

function isRateLimited() {
  const now = Date.now();
  while (requestLog.length && now - requestLog[0] > RATE_LIMIT_WINDOW_MS) requestLog.shift();
  if (requestLog.length >= RATE_LIMIT_MAX) return true;
  requestLog.push(now);
  return false;
}

const DIFFICULTY_LABEL = { 1: 'cơ bản', 2: 'vận dụng', 3: 'nâng cao' };

function buildPrompt({ topic, technique, difficulty, count }) {
  return [
    'Bạn là giáo viên Toán chuyên về phương trình hàm cho học sinh giỏi THPT.',
    `Hãy tạo ${count} bài tập tự luyện thuộc chuyên đề: "${topic}".`,
    technique ? `Trọng tâm kỹ thuật cần luyện: "${technique}".` : 'Bám sát các kỹ thuật chính của chuyên đề.',
    `Mức độ: ${DIFFICULTY_LABEL[difficulty] || 'vận dụng'}.`,
    'Yêu cầu:',
    '- Đề bài viết bằng LaTeX (dùng $...$ cho công thức).',
    '- Mỗi bài có gợi ý ngắn và lời giải theo từng bước rõ ràng.',
    '- Trả về ĐÚNG định dạng JSON, không thêm văn bản nào khác:',
    '{"exercises":[{"title":"...","problem":"...","hint":"...","solutionSteps":["Bước 1","Bước 2"]}]}'
  ].join('\n');
}

function isValidPayload(data) {
  return data
    && Array.isArray(data.exercises)
    && data.exercises.every(e =>
      e && typeof e.problem === 'string'
      && Array.isArray(e.solutionSteps)
    );
}

module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Chỉ chấp nhận POST' });

  if (isRateLimited()) {
    return res.status(429).json({ error: 'Bạn tạo bài quá nhiều. Vui lòng thử lại sau 1 giờ.' });
  }

  let body;
  try {
    body = JSON.parse(req.body || '');
  } catch {
    return res.status(400).json({ error: 'Dữ liệu gửi lên không hợp lệ' });
  }

  const topic = String(body.topic || '').slice(0, 200);
  const technique = String(body.technique || '').slice(0, 100);
  const difficulty = Number(body.difficulty) || 2;
  const count = Math.min(Math.max(Number(body.count) || 3, 1), 10);
  if (!topic) return res.status(400).json({ error: 'Thiếu chuyên đề' });

  /* Chưa cấu hình key: trả về bộ bài mẫu để giao diện vẫn hoạt động */
  if (!MISTRAL_API_KEY) {
    return res.status(200).json({
      isDemo: true,
      note: 'Chưa cấu hình MISTRAL_API_KEY',
      exercises: demoExercises(topic, count)
    });
  }

  try {
    const aiRes = await fetch(MISTRAL_ENDPOINT, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${MISTRAL_API_KEY}`
      },
      body: JSON.stringify({
        model: MISTRAL_MODEL,
        messages: [
          { role: 'system', content: 'Bạn chỉ trả về JSON hợp lệ, đúng cấu trúc được yêu cầu.' },
          { role: 'user', content: buildPrompt({ topic, technique, difficulty, count }) }
        ],
        temperature: 0.7,
        response_format: { type: 'json_object' }
      })
    });

    if (aiRes.status === 429) {
      return res.status(502).json({ error: 'Mistral API đạt giới hạn quota (429). Hãy kiểm tra billing/quota của tài khoản Mistral.' });
    }
    if (!aiRes.ok) {
      return res.status(502).json({ error: `Mistral API lỗi ${aiRes.status}` });
    }

    const aiData = await aiRes.json();
    const content = aiData.choices?.[0]?.message?.content || '';
    let parsed;
    try {
      parsed = JSON.parse(content);
    } catch {
      return res.status(502).json({ error: 'AI trả về JSON không hợp lệ' });
    }
    if (!isValidPayload(parsed)) {
      return res.status(502).json({ error: 'AI trả về cấu trúc không đúng (thiếu trường exercises/problem/solutionSteps)' });
    }

    /* Giai đoạn 2: lưu vào bảng ai_generation_requests trong Supabase.
       Các trường đã có sẵn trong schema: requested_by, topic_id, technique,
       difficulty, exercise_count, model, created_at. */

    return res.status(200).json({
      isDemo: false,
      model: MISTRAL_MODEL,
      exercises: parsed.exercises
    });
  } catch (err) {
    return res.status(502).json({ error: 'Lỗi khi gọi Mistral API: ' + err.message });
  }
};

/* Bộ bài mẫu — chỉ dùng khi chưa có API key, để thử giao diện */
function demoExercises(topic, count) {
  const samples = [
    {
      title: 'Bài mẫu 1',
      problem: 'Tìm tất cả các hàm $f: \\mathbb{R} \\to \\mathbb{R}$ thỏa mãn $f(x + y) = f(x) + f(y)$ với mọi $x, y \\in \\mathbb{R}$, biết $f$ liên tục.',
      hint: 'Tính f(0), sau đó mở rộng từ ℕ lên ℚ rồi dùng tính trù mật.',
      solutionSteps: ['Thế x = y = 0 được f(0) = 0.', 'Quy nạp được f(n) = nf(1) với n ∈ ℕ, mở rộng ra ℚ.', 'Dùng tính liên tục và trù mật suy ra f(x) = cx với c = f(1).']
    },
    {
      title: 'Bài mẫu 2',
      problem: 'Tìm tất cả các đa thức $P$ thỏa mãn $P(x + 1) = P(x) + 2x + 1$ với mọi $x \\in \\mathbb{R}$.',
      hint: 'So sánh bậc hai vế rồi đặt dạng tổng quát của P.',
      solutionSteps: ['Vế phải bậc 1 nên deg P = 2, đặt P(x) = ax² + bx + c.', 'Thay vào điều kiện và so sánh hệ số tìm được a = 1, b = 0, c tùy ý.', 'Kết luận P(x) = x² + c.']
    },
    {
      title: 'Bài mẫu 3',
      problem: 'Cho $f: \\mathbb{N} \\to \\mathbb{N}$ thỏa mãn $f(n + 1) > f(f(n))$ với mọi $n \\in \\mathbb{N}$. Chứng minh $f(n) = n$.',
      hint: 'Dùng nguyên lý cực hạn: xét giá trị nhỏ nhất của f.',
      solutionSteps: ['Gọi m là giá trị nhỏ nhất của f, giả sử đạt tại n₀.', 'Nếu n₀ > 0 thì f(n₀) > f(f(n₀ − 1)) ≥ m, mâu thuẫn tính nhỏ nhất của m.', 'Vậy f(0) = m, tiếp tục chỉ ra m = 0 và quy nạp được f(n) = n.']
    }
  ];
  const picked = [];
  for (let i = 0; i < count; i++) picked.push(samples[i % samples.length]);
  return picked.map((s, i) => ({ ...s, title: `${s.title} (${i + 1})` }));
}
