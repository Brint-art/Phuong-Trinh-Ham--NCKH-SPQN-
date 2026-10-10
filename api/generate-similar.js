/* ============================================================
   /api/generate-similar.js — Vercel Serverless Function
   Tạo bài tập tự luận tương tự bằng AI sử dụng Few-Shot Prompting
   ============================================================ */

const MISTRAL_API_KEY = process.env.MISTRAL_API_KEY;
const MISTRAL_MODEL = process.env.MISTRAL_MODEL || 'ministral-14b-latest';
const MISTRAL_ENDPOINT = 'https://api.mistral.ai/v1/chat/completions';
const { checkRateLimit, applyCors } = require('./_lib');

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

function buildPrompt({ original_question, original_solution, tags }) {
  return [
    'Bạn là chuyên gia Toán Olympic chuyên sáng tác đề thi học sinh giỏi phương trình hàm THPT.',
    'Dưới đây là một BÀI TẬP GỐC và ĐÁP ÁN GỐC:',
    '--- BẮT ĐẦU BÀI GỐC ---',
    'ĐỀ BÀI:',
    original_question,
    'ĐÁP ÁN CHI TIẾT:',
    original_solution,
    '--- KẾT THÚC BÀI GỐC ---',
    '',
    `Dạng bài (Tags): ${tags ? tags.join(', ') : 'Không xác định'}`,
    '',
    'NHIỆM VỤ CỦA BẠN:',
    'Hãy tạo ra MỘT bài tập hoàn toàn MỚI tương đương về độ khó chuyên Toán, giữ nguyên tư duy logic nhưng THAY ĐỔI hoàn toàn biểu thức hàm, hệ số, đại lượng hoặc điều kiện để chống học vẹt.',
    '',
    'YÊU CẦU ĐỊNH DẠNG (BẮT BUỘC TRẢ VỀ JSON HỢP LỆ):',
    '- Sử dụng ký hiệu LaTeX (bọc trong $...$ hoặc $$...$$) cho công thức.',
    '- Lưu ý: Các ký tự \\ trong LaTeX phải được escape thành \\\\ trong JSON (ví dụ: \\\\frac).',
    '- Trả về đúng 4 trường:',
    '  + "de_bai_moi": Đề bài hoàn chỉnh.',
    '  + "dap_an_chi_tiet": Giải chi tiết từng bước, rõ ràng lập luận.',
    '  + "nghiem_cuoi": Hàm số hoặc giá trị đáp số cuối cùng (ví dụ: $f(x)=x$).',
    '  + "thay_doi": Giải thích ngắn gọn bạn đã thay đổi gì so với bài gốc để ra bài mới này.',
    'Ví dụ định dạng đầu ra:',
    '{',
    '  "de_bai_moi": "Tìm mọi hàm $f: \\\\mathbb{R} \\\\to \\\\mathbb{R}$...",',
    '  "dap_an_chi_tiet": "Bước 1: Thay x=0... \\n Bước 2:...",',
    '  "nghiem_cuoi": "$f(x) = 2x$",',
    '  "thay_doi": "Thay vì đổi biến x-y, tôi đã đổi thành x-2y và điều chỉnh hệ số để sinh ra phương trình hàm bậc nhất mới."',
    '}'
  ].join('\n');
}

function extractJson(text) {
  const cleaned = String(text || '').trim().replace(/^```(?:json)?\s*([\s\S]*?)\s*```$/, '$1');
  try { return JSON.parse(cleaned); } catch { }
  const a = cleaned.indexOf('{');
  const b = cleaned.lastIndexOf('}');
  if (a >= 0 && b > a) {
    try { return JSON.parse(cleaned.slice(a, b + 1)); } catch { }
  }
  return null;
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

  if (!MISTRAL_API_KEY) {
    // Demo trả về dữ liệu mẫu nếu chưa cấu hình Key
    return res.status(200).json({
      question: "Demo Đề bài AI: Tìm m để hàm số y = x^3 - 3mx^2 + 3 đồng biến trên R.",
      detailed_solution: "Demo Giải: Đạo hàm y' = 3x^2 - 6mx. \nĐể hàm đồng biến trên R thì $\\Delta \\le 0$...",
      nghiem_cuoi: "$m=0$",
      thay_doi: "Demo: Tôi chỉ trả về tĩnh do chưa cấu hình KEY."
    });
  }

  const MAX_RETRIES = 2;
  for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
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
            { role: 'system', content: 'Bạn là máy chủ tạo bài tập tự luận chuyên Toán Olympic định dạng JSON chuẩn.' },
            { role: 'user', content: buildPrompt(body) }
          ],
          temperature: 0.7 + (attempt * 0.1), // Tăng sáng tạo nếu thử lại
          response_format: { type: 'json_object' }
        })
      });

      if (aiRes.status === 429) {
        if (attempt === MAX_RETRIES) return res.status(429).json({ error: 'Mistral API đạt giới hạn quota (429). Vui lòng thử lại sau.' });
        await new Promise(r => setTimeout(r, 1500)); // wait and retry
        continue;
      }
      
      if (!aiRes.ok) {
        if (attempt === MAX_RETRIES) return res.status(502).json({ error: `Mistral API lỗi ${aiRes.status}` });
        continue;
      }

      const aiData = await aiRes.json();
      const content = aiData.choices?.[0]?.message?.content || '';
      const parsed = extractJson(content);
      
      if (parsed && parsed.de_bai_moi && parsed.dap_an_chi_tiet) {
        return res.status(200).json({
          question: parsed.de_bai_moi,
          detailed_solution: parsed.dap_an_chi_tiet,
          nghiem_cuoi: parsed.nghiem_cuoi || "Không xác định",
          thay_doi: parsed.thay_doi || "Không xác định"
        });
      }
      
      // If parsed is invalid and it's the last attempt
      if (attempt === MAX_RETRIES) {
        return res.status(502).json({ error: 'AI trả về cấu trúc JSON không hợp lệ sau nhiều lần thử.' });
      }
    } catch (err) {
      if (attempt === MAX_RETRIES) {
        return res.status(502).json({ error: 'Lỗi khi gọi Mistral API: ' + err.message });
      }
    }
  }
};
