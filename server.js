/* ============================================================
   Hàm số — server.js (chạy local không cần Vercel CLI)
   Yêu cầu: Node.js 18 trở lên. Chạy: node server.js
   - Phục vụ file tĩnh (index.html, styles.css, app.js...)
   - Chạy hai API AI trong thư mục api/ (dùng lại nguyên code,
     không cần npm install bất kỳ thư viện nào)
   - Đọc MISTRAL_API_KEY từ file .env.local hoặc biến môi trường
   ============================================================ */
'use strict';

const http = require('http');
const fs = require('fs');
const path = require('path');

const ROOT = __dirname;
const PORT = Number(process.env.PORT) || 3000;

/* ---------- Nạp biến môi trường từ file .env (tự làm, không cần thư viện) ---------- */
function loadEnv(file) {
  try {
    fs.readFileSync(file, 'utf8').split(/\r?\n/).forEach(line => {
      const m = line.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*)\s*$/);
      if (m && !process.env[m[1]]) process.env[m[1]] = m[2].replace(/^["']|["']$/g, '');
    });
  } catch { /* file không tồn tại thì bỏ qua */ }
}
loadEnv(path.join(ROOT, '.env.local'));
loadEnv(path.join(ROOT, '.env'));

/* ---------- Nạp hai hàm API (đúng kiểu Vercel: handler(req, res)) ---------- */
const apiHandlers = {};
for (const name of ['generate-exercises', 'ask-solution']) {
  const file = path.join(ROOT, 'api', name + '.js');
  if (fs.existsSync(file)) apiHandlers['/api/' + name] = require(file);
}

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.png': 'image/png',
  '.ico': 'image/x-icon'
};

function readBody(req) {
  return new Promise((resolve, reject) => {
    let data = '';
    req.on('data', c => { data += c; if (data.length > 1e6) req.destroy(); });
    req.on('end', () => resolve(data));
    req.on('error', reject);
  });
}

const server = http.createServer(async (req, res) => {
  const pathname = decodeURIComponent(new URL(req.url, 'http://localhost').pathname);

  /* ---------- API AI ---------- */
  const handler = apiHandlers[pathname];
  if (handler) {
    /* Bộ chuyển đổi nhỏ để hàm trong api/ chạy được như trên Vercel */
    res.json = obj => { res.setHeader('Content-Type', 'application/json; charset=utf-8'); res.end(JSON.stringify(obj)); };
    res.status = code => {
      res.statusCode = code;
      return { json: res.json, send: body => res.end(body), end: body => res.end(body) };
    };
    req.body = await readBody(req);
    try {
      await handler(req, res);
    } catch (err) {
      console.error('Lỗi API:', err);
      if (!res.headersSent) { res.statusCode = 500; res.end('Lỗi máy chủ: ' + err.message); }
    }
    return;
  }

  /* Chặn không phục vụ file ẩn (.env.local...) và mã nguồn trong api/ */
  const segments = pathname.split('/');
  if (segments.some(seg => seg.startsWith('.')) || segments[1] === 'api') {
    res.statusCode = 404;
    return res.end('404');
  }

  /* ---------- File tĩnh ---------- */
  let filePath = path.join(ROOT, pathname === '/' ? 'index.html' : pathname);
  try {
    if (fs.statSync(filePath).isDirectory()) filePath = path.join(filePath, 'index.html');
    const data = fs.readFileSync(filePath);
    res.setHeader('Content-Type', MIME[path.extname(filePath)] || 'application/octet-stream');
    res.end(data);
  } catch {
    res.statusCode = 404;
    res.setHeader('Content-Type', 'text/plain; charset=utf-8');
    res.end('404 — Không tìm thấy ' + pathname);
  }
});

server.listen(PORT, () => {
  console.log('Hàm số đang chạy: http://localhost:' + PORT);
  console.log(process.env.MISTRAL_API_KEY
    ? 'AI đã sẵn sàng (có MISTRAL_API_KEY).'
    : 'Chưa có MISTRAL_API_KEY (tạo file .env.local) — AI sẽ trả về bộ bài mẫu.');
});
