/* ============================================================
   /api/ask-solution.js — Vercel Serverless Function
   Nhận đề bài, toàn bộ lời giải và câu hỏi của người dùng về một
   bước cụ thể; AI trả lời tập trung vào bước đó.
   ============================================================ */

const MISTRAL_API_KEY = process.env.MISTRAL_API_KEY;
const MISTRAL_MODEL = process.env.MISTRAL_MODEL || 'ministral-14b-latest';
const MISTRAL_ENDPOINT = 'https://api.mistral.ai/v1/chat/completions';

const { checkRateLimit, applyCors, readJsonBody } = require('./_lib');

module.exports = async function handler(req, res) {
  if (applyCors(req, res)) return;
  if (req.method !== 'POST') return res.status(405).json({ error: 'Chỉ chấp nhận POST' });

  if (checkRateLimit(req)) {
    return res.status(429).json({ error: 'Bạn hỏi quá nhiều. Vui lòng thử lại sau 1 giờ.' });
  }

  let body;
  try {
    body = await readJsonBody(req);
  } catch {
    return res.status(400).json({ error: 'Dữ liệu gửi lên không hợp lệ' });
  }
  if (!body || typeof body !== 'object') body = {};

  const problem = String(body.problem || '').slice(0, 4000);
  const solutionSteps = Array.isArray(body.solutionSteps)
    ? body.solutionSteps.map(s => String(s).slice(0, 2000))
    : [];
  const stepIndex = Number(body.stepIndex) || 0;
  const question = String(body.question || '').slice(0, 500);

  if (!problem || !question) {
    return res.status(400).json({ error: 'Thiếu đề bài hoặc câu hỏi' });
  }

  const stepContent = solutionSteps[stepIndex] || '(không có bước này)';

  if (!MISTRAL_API_KEY) {
    return res.status(200).json({
      answer: '(Chưa cấu hình MISTRAL_API_KEY nên đây là câu trả lời minh họa.)\n\n'
        + 'Bước bạn hỏi: ' + stepContent + '\n\n'
        + 'Hãy thử tự trả lời các câu hỏi sau: bước này dùng định nghĩa/định lý nào? '
        + 'Tại sao phép thế này hợp lệ (tập nguồn có chứa giá trị được thế không)? '
        + 'Mục tiêu của bước là gì — rút gọn điều kiện, tìm f(0), hay chứng minh đơn ánh/toàn ánh? '
        + 'Khi cấu hình key Mistral, AI sẽ giải thích chi tiết bước này.'
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
          {
            role: 'system',
            content: 'Bạn là trợ giảng Toán giải thích lời giải phương trình hàm. '
              + 'Trả lời tập trung ĐÚNG vào bước được hỏi, nêu rõ kỹ thuật hoặc định lý liên quan, '
              + 'dùng LaTeX ($...$) cho công thức, giải thích ngắn gọn dễ hiểu cho học sinh giỏi THPT.'
          },
          {
            role: 'user',
            content: [
              'ĐỀ BÀI:',
              problem,
              '',
              'LỜI GIẢI THAM KHẢO (theo bước):',
              ...solutionSteps.map((s, i) => `Bước ${i + 1}: ${s}`),
              '',
              `NGƯỜI HỌC HỎI VỀ BƯỚC ${stepIndex + 1}:`,
              `"${question}"`,
              '',
              'Hãy giải thích bước này.'
            ].join('\n')
          }
        ],
        temperature: 0.4
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
    const answer = aiData.choices?.[0]?.message?.content || '';

    /* Giai đoạn 2: lưu câu hỏi vào bảng solution_questions trong Supabase.
       Các trường đã có sẵn trong schema: exercise_id, solution_step, asked_by,
       question, answer, created_at. */

    return res.status(200).json({ answer });
  } catch (err) {
    return res.status(502).json({ error: 'Lỗi khi gọi Mistral API: ' + err.message });
  }
};
