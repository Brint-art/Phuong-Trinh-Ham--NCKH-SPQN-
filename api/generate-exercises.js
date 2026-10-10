/* ============================================================
   /api/generate-exercises.js — Vercel Serverless Function
   Nhận yêu cầu tạo bộ bài tập, gọi Mistral API, kiểm tra JSON.
   API key chỉ nằm trong biến môi trường của Vercel — không bao giờ
   xuất hiện trong code phía trình duyệt.
   ============================================================ */

const MISTRAL_API_KEY = process.env.MISTRAL_API_KEY;
const MISTRAL_MODEL = process.env.MISTRAL_MODEL || 'ministral-14b-latest';
const MISTRAL_ENDPOINT = 'https://api.mistral.ai/v1/chat/completions';
const { checkRateLimit, applyCors } = require('./_lib');



const DIFFICULTY_LABEL = { 1: 'cơ bản', 2: 'vận dụng', 3: 'nâng cao' };

/* Đọc body JSON tương thích mọi môi trường:
   - Vercel: req.body đã được parse sẵn thành object.
   - server.js local: req.body là chuỗi thô.
   - Runtime chưa parse: tự đọc stream của req. */
async function readJsonBody(req) {
  if (req.body && typeof req.body === 'object') return req.body;
  if (typeof req.body === 'string' && req.body.trim()) return JSON.parse(req.body);
  const raw = await new Promise((resolve, reject) => {
    let data = '';
    req.on('data', c => { data += c; if (data.length > 1e6) req.destroy(); });
    req.on('end', () => resolve(data));
    req.on('error', reject);
  });
  if (!raw.trim()) throw new Error('empty body');
  return JSON.parse(raw);
}

function buildPrompt({ topic, technique, difficulty, count }) {
  return [
    'Bạn là giáo viên Toán chuyên về phương trình hàm cho học sinh giỏi THPT.',
    `Hãy tạo ${count} bài tập tự luyện thuộc chuyên đề: "${topic}".`,
    technique ? `Trọng tâm kỹ thuật cần luyện: "${technique}".` : 'Bám sát các kỹ thuật chính của chuyên đề.',
    `Mức độ: ${DIFFICULTY_LABEL[difficulty] || 'vận dụng'}.`,
    'Yêu cầu:',
    '- Đề bài viết bằng LaTeX (dùng $...$ cho công thức).',
    '- Mỗi bài có gợi ý ngắn và lời giải theo từng bước rõ ràng.',
    '- Định dạng chuỗi (bắt buộc):',
    '+ title/problem/hint phải nằm trên ĐÚNG MỘT dòng, xuống dòng phải viết thành \\n.',
    '+ solutionSteps là MẢNG CHUỖI (không phải mảng object), mỗi bước tối đa 2 câu.',
    '+ không dùng $$, không dùng danh sách gạch đầu dòng bên trong chuỗi.',
    '- Trả về ĐÚNG định dạng JSON, không thêm văn bản nào khác:',
    '{"exercises":[{"title":"...","problem":"...","hint":"...","solutionSteps":["Bước 1","Bước 2"]}]}',
    '+ Quy tắc escape JSON: mỗi dấu \\ trong LaTeX phải ghi thành hai dấu \\ liên tiếp.'
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

/* Model nhỏ hay bọc JSON trong fence Markdown (```json ... ```) hoặc chèn thêm
   văn bản thừa → bỏ fence, nếu vẫn hỏng thì lấy khối {...} lớn nhất. */
function extractJson(text) {
  const cleaned = String(text || '').trim().replace(/^```(?:json)?\s*([\s\S]*?)\s*```$/, '$1');
  try { return JSON.parse(cleaned); } catch { /* xuống bước sau */ }
  const a = cleaned.indexOf('{');
  const b = cleaned.lastIndexOf('}');
  if (a >= 0 && b > a) {
    try { return JSON.parse(cleaned.slice(a, b + 1)); } catch { /* hết cách */ }
  }
  return null;
}

/* JSON "ăn" mất dấu gạch chéo của LaTeX: model ghi "\mathbb" (1 dấu \) thì
   JSON.parse biến \math thành ký tự backspace + "mathbb", "\to" thành tab + "o"
   → MathJax báo "Math input error". Phục hồi lại các ký tự điều khiển này. */
function repairLatex(s) {
  return String(s || '')
    .replace(/\x08/g, '\\b')
    .replace(/\x0c/g, '\\f')
    .replace(/\t/g, '\\t')
    .replace(/\r/g, '\\r');
}

module.exports = async function handler(req, res) {
  if (applyCors(req, res)) return;
  if (req.method !== 'POST') return res.status(405).json({ error: 'Chỉ chấp nhận POST' });

  if (checkRateLimit(req, 20)) { // 20 requests per hour for generate
    return res.status(429).json({ error: 'Bạn đã tạo quá nhiều. Vui lòng thử lại sau.' });
  }



  let body;
  try {
    body = await readJsonBody(req);
  } catch {
    return res.status(400).json({ error: 'Dữ liệu gửi lên không hợp lệ' });
  }
  if (!body || typeof body !== 'object') body = {};

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
        /* Ép Mistral trả JSON hợp lệ — nếu không model hay bọc ```json hoặc
           nhét ký tự xuống dòng thô vào chuỗi làm JSON.parse thất bại. */
        response_format: { type: 'json_object' }
      })
    });

    if (aiRes.status === 429) {
      return res.status(502).json({ error: 'Mistral API đạt giới hạn quota (429). Hãy kiểm tra billing/quota của tài khoản Mistral.' });
    }
    if (!aiRes.ok) {
      const detail = await aiRes.text().catch(() => '');
      return res.status(502).json({ error: `Mistral API lỗi ${aiRes.status} (model: ${MISTRAL_MODEL}). ${detail.slice(0, 300)}` });
    }

    const aiData = await aiRes.json();
    const content = aiData.choices?.[0]?.message?.content || '';
    const parsed = extractJson(content);
    if (!parsed) {
      return res.status(502).json({ error: 'AI trả về JSON không hợp lệ' });
    }
    if (!isValidPayload(parsed)) {
      return res.status(502).json({ error: 'AI trả về cấu trúc không đúng (thiếu trường exercises/problem/solutionSteps)' });
    }

    /* Chuẩn hóa: có model trả solutionSteps là mảng object {step, content} */
    parsed.exercises = parsed.exercises
      .slice(0, count)   /* model hay trả nhiều hơn số bài yêu cầu */
      .map(ex => ({
      ...ex,
      title: repairLatex(ex.title),
      problem: repairLatex(ex.problem),
      hint: repairLatex(ex.hint),
      solutionSteps: (ex.solutionSteps || []).map(s =>
        repairLatex(typeof s === 'string' ? s : String(s?.content ?? s?.step ?? JSON.stringify(s))))
    }));

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
