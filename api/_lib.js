const RATE_LIMIT_MAX = 60;
const RATE_LIMIT_WINDOW_MS = 60 * 60 * 1000;
const requestLog = new Map();

function getClientIp(req) {
  return req.headers['x-forwarded-for'] || req.headers['x-real-ip'] || req.socket?.remoteAddress || 'unknown';
}

function checkRateLimit(req, limit = RATE_LIMIT_MAX) {
  const ip = getClientIp(req);
  const now = Date.now();
  
  if (!requestLog.has(ip)) {
    requestLog.set(ip, []);
  }
  
  const history = requestLog.get(ip);
  // Remove entries outside window
  while (history.length > 0 && now - history[0] > RATE_LIMIT_WINDOW_MS) {
    history.shift();
  }
  
  if (history.length >= limit) {
    return true; // Rate limited
  }
  
  history.push(now);
  return false;
}

function applyCors(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return true; // Indicates request was handled
  }
  
  return false;
}

module.exports = {
  checkRateLimit,
  applyCors
};
