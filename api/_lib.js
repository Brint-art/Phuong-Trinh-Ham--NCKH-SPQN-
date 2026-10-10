const RATE_LIMIT_MAX = 5; // 5 requests per hour per user/IP
const RATE_LIMIT_WINDOW_MS = 60 * 60 * 1000;
const requestLog = new Map();

// Chú ý: Đây là rate limit best-effort lưu trên bộ nhớ của từng Serverless function instance.

function getUserIdFromToken(authHeader) {
  if (!authHeader || !authHeader.startsWith('Bearer ')) return null;
  const token = authHeader.split(' ')[1];
  try {
    const payload = JSON.parse(Buffer.from(token.split('.')[1], 'base64').toString());
    return payload.sub || null;
  } catch (e) {
    return null;
  }
}

function getClientIp(req) {
  return req.headers['x-forwarded-for'] || req.headers['x-real-ip'] || req.socket?.remoteAddress || 'unknown';
}

function checkRateLimit(req, limit = RATE_LIMIT_MAX) {
  // Đã bỏ giới hạn theo yêu cầu của Admin
  return false;
}

function applyCors(req, res) {
  const allowedOrigins = (process.env.ALLOWED_ORIGINS || 'http://localhost:3000,http://localhost:8899').split(',').map(s => s.trim());
  const origin = req.headers.origin;
  
  if (allowedOrigins.includes(origin)) {
    res.setHeader('Access-Control-Allow-Origin', origin);
  } else {
    // Mặc định cho phép localhost nếu không khớp
    res.setHeader('Access-Control-Allow-Origin', allowedOrigins[0] || '*');
  }
  
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return true;
  }
  
  return false;
}

async function readJsonBody(req, maxLength = 10000) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', chunk => {
      body += chunk.toString();
      if (body.length > maxLength) {
        reject(new Error('Payload quá dài'));
      }
    });
    req.on('end', () => {
      try {
        resolve(JSON.parse(body || '{}'));
      } catch (e) {
        reject(new Error('JSON không hợp lệ'));
      }
    });
    req.on('error', reject);
  });
}

module.exports = {
  checkRateLimit,
  applyCors,
  readJsonBody
};
