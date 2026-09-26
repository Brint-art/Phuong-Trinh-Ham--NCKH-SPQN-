/* ============================================================
   Hàm số — app.js
   Xử lý: nạp dữ liệu (Supabase → fallback data.js), điều hướng,
   render lý thuyết, lọc + hiển thị bài tập, mở/đóng lời giải,
   hỏi AI, AI tạo bộ bài.
   ============================================================ */

'use strict';

/* ---------- Tiện ích ---------- */
const $ = (sel, root = document) => root.querySelector(sel);
const $$ = (sel, root = document) => Array.from(root.querySelectorAll(sel));

function topicById(id) {
  return TOPICS.find(t => t.id === id);
}

function exerciseById(id) {
  return EXERCISES.find(e => e.id === id);
}

const DIFFICULTY_LABEL = { 1: 'Cơ bản', 2: 'Vận dụng', 3: 'Nâng cao' };

function escapeHtml(s) {
  return String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

/* Chuyển văn bản có \n thành các <p>, giữ nguyên LaTeX để MathJax xử lý */
function toHtml(text) {
  return text.split('\n').map(part => part.trim()).filter(Boolean)
    .map(part => `<p>${part}</p>`)
    .join('');
}

/* Gọi MathJax typeset lại sau khi render nội dung mới */
function typeset(root) {
  if (window.MathJax && window.MathJax.typesetPromise) {
    MathJax.typesetPromise([root]).catch(() => {});
  }
}

/* ---------- Nạp dữ liệu từ Supabase (Giai đoạn 2) ---------- */
/* Cấu hình nằm trong supabase-config.js (window.SUPABASE_CONFIG).
   Anon key được phép công khai vì Row Level Security chỉ cho đọc
   nội dung đã xuất bản. Chưa cấu hình / lỗi kết nối / bảng trống
   → dùng dữ liệu tĩnh trong data.js. */
const SUPABASE_CFG = window.SUPABASE_CONFIG || { url: '', anonKey: '' };

function supabaseClient() {
  if (!window.supabase || !SUPABASE_CFG.url || !SUPABASE_CFG.anonKey) return null;
  return window.supabase.createClient(SUPABASE_CFG.url, SUPABASE_CFG.anonKey);
}

async function fetchSupabaseData(sb) {
  const [topics, lessons, exercises, solutions] = await Promise.all([
    sb.from('topics').select('*').order('display_order'),
    sb.from('lessons').select('*').eq('is_published', true).order('display_order'),
    sb.from('exercises').select('*').eq('status', 'published'),
    sb.from('exercise_solutions').select('*').order('step_number')
  ]);
  const failed = [topics, lessons, exercises, solutions].find(r => r.error);
  if (failed) {
    console.warn('Không đọc được dữ liệu Supabase:', failed.error.message, '→ dùng dữ liệu tĩnh data.js');
    return null;
  }
  return {
    topics: topics.data,
    lessons: lessons.data,
    exercises: exercises.data,
    solutions: solutions.data
  };
}

/* Chuyển dữ liệu Supabase về đúng cấu trúc data.js để các hàm render không đổi.
   id nội bộ dùng slug (quen thuộc với data.js), uuid chỉ dùng để nối bảng. */
function mapSupabaseData(raw) {
  const topicUuidToSlug = {};
  const topics = (raw.topics || []).map(t => {
    const slug = t.slug || String(t.id);
    topicUuidToSlug[t.id] = slug;
    return {
      id: slug,
      title: t.title || '',
      slug,
      description: t.description || '',
      displayOrder: Number(t.display_order) || 0
    };
  });

  const lessons = (raw.lessons || [])
    .map(l => ({
      id: l.slug || String(l.id),
      topicId: topicUuidToSlug[l.topic_id] || null,
      title: l.title || '',
      displayOrder: Number(l.display_order) || 0,
      objective: l.objective || '',
      sections: Array.isArray(l.sections) ? l.sections : []
    }))
    .filter(l => l.topicId);

  const stepsByExercise = {};
  (raw.solutions || []).forEach(s => {
    if (!stepsByExercise[s.exercise_id]) stepsByExercise[s.exercise_id] = [];
    stepsByExercise[s.exercise_id].push({
      content: s.content_latex || '',
      explanation: s.explanation || ''
    });
  });

  const exercises = (raw.exercises || [])
    .map(e => ({
      id: e.slug || String(e.id),
      topicId: topicUuidToSlug[e.topic_id] || null,
      title: e.title || '',
      difficulty: Number(e.difficulty) || 1,
      techniques: Array.isArray(e.techniques) ? e.techniques : [],
      type: e.type || '',
      source: e.source || '',
      problem: e.problem_latex || '',
      related: Array.isArray(e.related) ? e.related : [],
      hint: e.hint || '',
      steps: stepsByExercise[e.id] || []
    }))
    .filter(e => e.topicId);

  return {
    topics,
    lessons,
    exercises,
    techniques: [...new Set(exercises.flatMap(e => e.techniques))]
  };
}

async function loadSiteData() {
  const sb = supabaseClient();
  if (!sb) return null;
  try {
    const raw = await Promise.race([
      fetchSupabaseData(sb),
      new Promise(resolve => setTimeout(() => resolve('timeout'), 6000))
    ]);
    if (raw === 'timeout' || raw === null) return null;
    return mapSupabaseData(raw);
  } catch (err) {
    console.warn('Lỗi kết nối Supabase:', err.message, '→ dùng dữ liệu tĩnh data.js');
    return null;
  }
}

/* Đường dẫn gọi API AI: mặc định cùng máy chủ với website.
   Khi chạy bằng server tĩnh (Sublime Server...), điền apiBase trong
   supabase-config.js trỏ về URL đã deploy trên Vercel để AI hoạt động. */
function apiUrl(apiPath) {
  return (SUPABASE_CFG.apiBase || '') + apiPath;
}

/* ---------- Điều hướng ---------- */
const PAGES = {
  home: '#page-home',
  theory: '#page-theory',
  exercises: '#page-exercises',
  ai: '#page-ai'
};

function navigate(page) {
  Object.entries(PAGES).forEach(([name, selector]) => {
    $(selector).classList.toggle('hidden', name !== page);
  });
  $$('[data-nav]').forEach(a => {
    a.classList.toggle('active', a.dataset.nav === page);
  });
  window.scrollTo({ top: 0 });
  if (page === 'theory') renderTheory();
  if (page === 'exercises') renderExercises();
  if (page === 'ai') renderAiForm();
}

$$('[data-nav]').forEach(a => {
  a.addEventListener('click', () => navigate(a.dataset.nav));
});

/* ---------- Trang chủ ---------- */
function renderHome() {
  const box = $('#home-topics');
  box.innerHTML = TOPICS.map(t => `
    <a class="topic-card" href="#theory" data-topic="${t.id}">
      <h3>${escapeHtml(t.title)}</h3>
      <p>${escapeHtml(t.description)}</p>
    </a>
  `).join('');
  $$('#home-topics .topic-card').forEach(card => {
    card.addEventListener('click', () => {
      currentTopicId = card.dataset.topic;
      navigate('theory');
    });
  });
}

/* ---------- Khu lý thuyết ---------- */
let currentTopicId = null;   // gán trong init() sau khi nạp dữ liệu
let currentLessonId = null;

function renderTheory() {
  const tabs = $('#theory-topic-tabs');
  tabs.innerHTML = TOPICS.map(t => `
    <button class="topic-tab ${t.id === currentTopicId ? 'active' : ''}" data-topic="${t.id}">
      ${escapeHtml(t.title)}
    </button>
  `).join('');
  $$('#theory-topic-tabs .topic-tab').forEach(tab => {
    tab.addEventListener('click', () => {
      currentTopicId = tab.dataset.topic;
      currentLessonId = null;
      renderTheory();
    });
  });
  renderLessonList();
  renderLessonDetail();
}

function renderLessonList() {
  const list = $('#lesson-list');
  const lessons = LESSONS
    .filter(l => l.topicId === currentTopicId)
    .sort((a, b) => a.displayOrder - b.displayOrder);
  list.innerHTML = lessons.map(l => `
    <div class="lesson-card" data-lesson="${l.id}">
      <div>
        <h3>${escapeHtml(l.title)}</h3>
        <p class="lesson-meta">Mục tiêu: ${escapeHtml(l.objective)}</p>
      </div>
      <span class="tag">${lessons.length ? '' : ''}</span>
    </div>
  `).join('');
  $$('#lesson-list .lesson-card').forEach(card => {
    card.addEventListener('click', () => {
      currentLessonId = card.dataset.lesson;
      renderLessonList();
      renderLessonDetail();
      window.scrollTo({ top: $('#lesson-detail').offsetTop - 80, behavior: 'smooth' });
    });
  });
}

function renderLessonDetail() {
  const box = $('#lesson-detail');
  if (!currentLessonId) {
    box.classList.add('hidden');
    return;
  }
  const lesson = LESSONS.find(l => l.id === currentLessonId);
  const topic = topicById(lesson.topicId);
  box.classList.remove('hidden');
  box.innerHTML = `
    <span class="back-link" id="lesson-back">← Chọn bài học khác</span>
    <h2>${escapeHtml(lesson.title)}</h2>
    <p class="page-desc"><strong>Mục tiêu bài học:</strong> ${escapeHtml(lesson.objective)}</p>
    ${lesson.sections.map(s => `
      <div class="lesson-block ${s.type}">
        <h3><span class="block-label">${s.type === 'definition' ? 'Định nghĩa' : s.type === 'theorem' ? 'Định lý' : s.type === 'technique' ? 'Kỹ thuật' : 'Ví dụ'}</span>${escapeHtml(s.title)}</h3>
        ${toHtml(s.body)}
      </div>
    `).join('')}
    <div class="solution-toggle-row">
      <button class="btn btn-outline" id="lesson-exercises">📝 Luyện bài tập của chuyên đề này</button>
    </div>
  `;
  $('#lesson-back').addEventListener('click', () => {
    currentLessonId = null;
    renderLessonDetail();
  });
  $('#lesson-exercises').addEventListener('click', () => {
    $('#filter-topic').value = lesson.topicId;
    navigate('exercises');
  });
  typeset(box);
}

/* ---------- Khu bài tập ---------- */
function populateFilters() {
  const topicSel = $('#filter-topic');
  topicSel.innerHTML = '<option value="">Tất cả</option>' +
    TOPICS.map(t => `<option value="${t.id}">${escapeHtml(t.title)}</option>`).join('');

  const techSel = $('#filter-technique');
  techSel.innerHTML = '<option value="">Tất cả</option>' +
    TECHNIQUES.map(t => `<option value="${escapeHtml(t)}">${escapeHtml(t)}</option>`).join('');

  const typeSel = $('#filter-type');
  const types = [...new Set(EXERCISES.map(e => e.type))];
  typeSel.innerHTML = '<option value="">Tất cả</option>' +
    types.map(t => `<option value="${escapeHtml(t)}">${escapeHtml(t)}</option>`).join('');

  const srcSel = $('#filter-source');
  const sources = [...new Set(EXERCISES.map(e => e.source))];
  srcSel.innerHTML = '<option value="">Tất cả</option>' +
    sources.map(s => `<option value="${escapeHtml(s)}">${escapeHtml(s)}</option>`).join('');
}

function getFilteredExercises() {
  const fTopic = $('#filter-topic').value;
  const fTech = $('#filter-technique').value;
  const fDiff = $('#filter-difficulty').value;
  const fType = $('#filter-type').value;
  const fSource = $('#filter-source').value;
  return EXERCISES.filter(e => {
    if (fTopic && e.topicId !== fTopic) return false;
    if (fTech && !e.techniques.includes(fTech)) return false;
    if (fDiff && String(e.difficulty) !== fDiff) return false;
    if (fType && e.type !== fType) return false;
    if (fSource && e.source !== fSource) return false;
    return true;
  });
}

function renderExercises() {
  $('#exercise-detail').classList.add('hidden');
  const list = $('#exercise-list');
  const items = getFilteredExercises();
  if (items.length === 0) {
    list.innerHTML = '<p class="page-desc">Không có bài tập nào khớp bộ lọc.</p>';
    return;
  }
  list.innerHTML = items.map(e => `
    <div class="exercise-card" data-exercise="${e.id}">
      <h3>${escapeHtml(e.title)}</h3>
      <div class="exercise-tags">
        <span class="tag">${escapeHtml(topicById(e.topicId).title)}</span>
        <span class="tag green">${DIFFICULTY_LABEL[e.difficulty]}</span>
        <span class="tag orange">${escapeHtml(e.type)}</span>
        <span class="tag purple">${escapeHtml(e.source)}</span>
      </div>
    </div>
  `).join('');
  $$('#exercise-list .exercise-card').forEach(card => {
    card.addEventListener('click', () => renderExerciseDetail(card.dataset.exercise));
  });
}

function renderExerciseDetail(id) {
  const e = exerciseById(id);
  const box = $('#exercise-detail');
  box.classList.remove('hidden');
  box.innerHTML = `
    <span class="back-link" id="exercise-back">← Danh sách bài tập</span>
    <h2>${escapeHtml(e.title)}</h2>
    <div class="exercise-tags">
      <span class="tag">${escapeHtml(topicById(e.topicId).title)}</span>
      <span class="tag green">${DIFFICULTY_LABEL[e.difficulty]}</span>
      <span class="tag orange">${escapeHtml(e.type)}</span>
      <span class="tag purple">${escapeHtml(e.source)}</span>
      ${e.techniques.map(t => `<span class="tag">${escapeHtml(t)}</span>`).join('')}
    </div>
    <h3>Đề bài</h3>
    <p class="problem">${e.problem}</p>
    <h3>Kiến thức liên quan</h3>
    <p>${e.related.map(r => escapeHtml(r)).join(' · ')}</p>
    <h3>Gợi ý</h3>
    <div class="hint-box">${e.hint}</div>
    <div class="solution-toggle-row">
      <button class="btn btn-primary" id="toggle-solution">Xem lời giải tham khảo</button>
    </div>
    <div class="solution-steps hidden" id="solution-steps">
      <h3>Lời giải tham khảo</h3>
      ${e.steps.map((s, i) => `
        <div class="solution-step">
          <div class="step-head">
            <strong>Bước ${i + 1}</strong>
            <button class="ask-ai-btn" data-exercise="${e.id}" data-step="${i}">🤖 Hỏi AI về bước này</button>
          </div>
          <div>${s.content}</div>
          <div class="step-explanation">💡 ${escapeHtml(s.explanation)}</div>
        </div>
      `).join('')}
    </div>
  `;
  $('#exercise-back').addEventListener('click', () => {
    box.classList.add('hidden');
    window.scrollTo({ top: $('#exercise-list').offsetTop - 80, behavior: 'smooth' });
  });
  $('#toggle-solution').addEventListener('click', () => {
    const steps = $('#solution-steps');
    const btn = $('#toggle-solution');
    const isHidden = steps.classList.contains('hidden');
    steps.classList.toggle('hidden', !isHidden);
    btn.textContent = isHidden ? 'Ẩn lời giải' : 'Xem lời giải tham khảo';
    if (isHidden) typeset(steps);
  });
  $$('.ask-ai-btn', box).forEach(btn => {
    btn.addEventListener('click', () => openAskModal(btn.dataset.exercise, Number(btn.dataset.step)));
  });
  typeset(box);
  window.scrollTo({ top: box.offsetTop - 80, behavior: 'smooth' });
}

/* ---------- Hỏi AI về lời giải ---------- */
const QUICK_QUESTIONS = [
  'Vì sao cần thế biến này?',
  'Bước này dùng định lý nào?',
  'Tại sao suy ra được điều đó?',
  'Có thể dùng cách khác không?',
  'Hãy giải thích đơn giản hơn.'
];

function openAskModal(exerciseId, stepIndex) {
  const e = exerciseById(exerciseId);
  const step = e.steps[stepIndex];
  $('#ask-exercise').value = exerciseId;
  $('#ask-step').value = stepIndex;
  $('#ask-question-label').textContent = `Bài: ${e.title} — Bước ${stepIndex + 1}: ${step.content.replace(/\$/g, '')}`;
  $('#ask-answers').innerHTML = QUICK_QUESTIONS.map(q =>
    `<button type="button" class="quick-question">${escapeHtml(q)}</button>`
  ).join('');
  $$('#ask-answers .quick-question').forEach(btn => {
    btn.addEventListener('click', () => {
      $('#ask-input').value = btn.textContent;
    });
  });
  $('#ask-result').innerHTML = '';
  $('#ask-modal').classList.remove('hidden');
  $('#ask-input').focus();
}

$('#ask-close').addEventListener('click', () => $('#ask-modal').classList.add('hidden'));
$('#ask-modal').addEventListener('click', (ev) => {
  if (ev.target === $('#ask-modal')) $('#ask-modal').classList.add('hidden');
});

$('#ask-form').addEventListener('submit', async (ev) => {
  ev.preventDefault();
  const e = exerciseById($('#ask-exercise').value);
  const stepIndex = Number($('#ask-step').value);
  const question = $('#ask-input').value.trim();
  if (!e || !question) return;

  const resultBox = $('#ask-result');
  resultBox.innerHTML = '<p>⏳ Đang gửi câu hỏi đến AI…</p>';

  try {
    const res = await fetch(apiUrl('/api/ask-solution'), {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        problem: e.problem,
        solutionSteps: e.steps.map(s => s.content),
        stepIndex,
        question
      })
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.error || 'Có lỗi xảy ra');
    resultBox.innerHTML = `<strong>🤖 AI trả lời:</strong>\n\n${escapeHtml(data.answer)}`;
    typeset(resultBox);
  } catch (err) {
    resultBox.innerHTML = `<p class="ai-error">Không thể kết nối API AI. ${escapeHtml(err.message)}</p>
      <p>Gợi ý: chạy <code>vercel dev</code> để dùng API, hoặc triển khai lên Vercel với biến môi trường MISTRAL_API_KEY.</p>`;
  }
});

/* ---------- AI tạo bộ bài ---------- */
function renderAiForm() {
  const topicSel = $('#ai-topic');
  topicSel.innerHTML = TOPICS.map(t =>
    `<option value="${t.id}">${escapeHtml(t.title)}</option>`
  ).join('');
  const techSel = $('#ai-technique');
  techSel.innerHTML = '<option value="">Tất cả kỹ thuật</option>' +
    TECHNIQUES.map(t => `<option value="${escapeHtml(t)}">${escapeHtml(t)}</option>`).join('');
}

$('#ai-form').addEventListener('submit', async (ev) => {
  ev.preventDefault();
  const topic = topicById($('#ai-topic').value);
  const technique = $('#ai-technique').value;
  const difficulty = Number($('#ai-difficulty').value);
  const count = Math.min(Math.max(Number($('#ai-count').value) || 3, 1), 10);

  const status = $('#ai-status');
  const resultBox = $('#ai-result');
  const submitBtn = $('#ai-submit');

  status.className = 'ai-status';
  status.textContent = '⏳ AI đang tạo bộ bài…';
  resultBox.classList.add('hidden');
  submitBtn.disabled = true;

  try {
    const res = await fetch(apiUrl('/api/generate-exercises'), {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ topic: topic.title, technique, difficulty, count })
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.error || 'Có lỗi xảy ra');
    renderAiResult(data, topic);
    status.textContent = data.isDemo
      ? '⚠️ Đây là bộ bài mẫu (chưa cấu hình MISTRAL_API_KEY). Cấu hình key để AI tạo bài thật.'
      : '✅ Đã tạo xong bộ bài.';
  } catch (err) {
    status.className = 'ai-status ai-error';
    status.textContent = 'Không thể kết nối API AI. ' + err.message;
  } finally {
    submitBtn.disabled = false;
  }
});

function renderAiResult(data, topic) {
  const resultBox = $('#ai-result');
  const exercises = data.exercises || [];
  if (exercises.length === 0) {
    resultBox.innerHTML = '<p>AI không trả về bài nào. Hãy thử lại.</p>';
    resultBox.classList.remove('hidden');
    return;
  }
  resultBox.innerHTML = `
    <div class="ai-result-actions">
      <button class="btn btn-primary" id="print-set">🖨️ In bộ bài</button>
      <button class="btn btn-outline" id="save-set">💾 Lưu bộ bài (JSON)</button>
    </div>
    ${exercises.map((ex, i) => `
      <div class="ai-exercise">
        <h3>Bài ${i + 1}. ${escapeHtml(ex.title || '')}</h3>
        <p><strong>Đề bài:</strong> ${escapeHtml(ex.problem || '')}</p>
        ${ex.hint ? `<div class="hint-box"><strong>Gợi ý:</strong> ${escapeHtml(ex.hint)}</div>` : ''}
        ${(ex.solutionSteps && ex.solutionSteps.length) ? `
          <div class="solution-toggle-row">
            <button class="btn btn-ghost toggle-ai-solution">Xem lời giải</button>
          </div>
          <div class="solution-steps hidden">
            ${ex.solutionSteps.map((s, j) => `<div class="solution-step"><strong>Bước ${j + 1}.</strong> ${escapeHtml(s)}</div>`).join('')}
          </div>
        ` : ''}
      </div>
    `).join('')}
  `;
  $$('.toggle-ai-solution', resultBox).forEach(btn => {
    btn.addEventListener('click', () => {
      const steps = btn.closest('.ai-exercise').querySelector('.solution-steps');
      const isHidden = steps.classList.contains('hidden');
      steps.classList.toggle('hidden', !isHidden);
      btn.textContent = isHidden ? 'Ẩn lời giải' : 'Xem lời giải';
      if (isHidden) typeset(steps);
    });
  });
  $('#print-set').addEventListener('click', () => {
    const originalTitle = document.title;
    document.title = `Bộ bài tự luyện — ${topic.title}`;
    window.print();
    document.title = originalTitle;
  });
  $('#save-set').addEventListener('click', () => {
    const blob = new Blob([JSON.stringify({ topic: topic.title, generatedAt: new Date().toISOString(), exercises }, null, 2)], { type: 'application/json' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = 'bo-bai-tu-luyen.json';
    a.click();
    URL.revokeObjectURL(a.href);
  });
  resultBox.classList.remove('hidden');
  typeset(resultBox);
}

/* ---------- Khởi động ---------- */
/* Loại bỏ bài học/bài tập không còn chuyên đề tương ứng sau khi trộn
   dữ liệu Supabase + tĩnh — tránh lỗi hiển thị do dữ liệu lệch nhau. */
function pruneOrphans() {
  const topicIds = new Set(TOPICS.map(t => t.id));
  [LESSONS, EXERCISES].forEach(list => {
    const kept = list.filter(item => topicIds.has(item.topicId));
    list.length = 0;
    list.push(...kept);
  });
}

async function init() {
  const remote = await loadSiteData();
  const useFallback = SUPABASE_CFG.useStaticFallback !== false;
  /* Database chỉ "kích hoạt" khi đã có ít nhất một bài học hoặc bài tập.
     Nếu Supabase mới chỉ có chuyên đề (topics) thì website vẫn dùng dữ liệu
     tĩnh — tránh hiển thị các chuyên đề rỗng không có bài học nào. */
  const dbActive = remote && (remote.lessons.length > 0 || remote.exercises.length > 0);
  if (remote && dbActive) {
    if (useFallback) {
      if (remote.topics.length) { TOPICS.length = 0; TOPICS.push(...remote.topics); }
      if (remote.lessons.length) { LESSONS.length = 0; LESSONS.push(...remote.lessons); }
      if (remote.exercises.length) { EXERCISES.length = 0; EXERCISES.push(...remote.exercises); }
      if (remote.techniques.length) { TECHNIQUES.length = 0; TECHNIQUES.push(...remote.techniques); }
    } else {
      TOPICS.length = 0; TOPICS.push(...remote.topics);
      LESSONS.length = 0; LESSONS.push(...remote.lessons);
      EXERCISES.length = 0; EXERCISES.push(...remote.exercises);
      TECHNIQUES.length = 0; TECHNIQUES.push(...remote.techniques);
    }
    pruneOrphans();
  }
  currentTopicId = TOPICS[0] ? TOPICS[0].id : null;
  currentLessonId = null;

  populateFilters();
  renderHome();

  $$('#exercise-filters select').forEach(sel => sel.addEventListener('change', renderExercises));
  $('#filter-reset').addEventListener('click', () => {
    $$('#exercise-filters select').forEach(sel => { sel.value = ''; });
    renderExercises();
  });
}

init();
