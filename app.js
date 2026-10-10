'use strict';

/* ---------- Tiện ích ---------- */
const $ = (sel, root = document) => root.querySelector(sel);
const $$ = (sel, root = document) => Array.from(root.querySelectorAll(sel));

let TOPICS = [];
let LESSONS = [];
let EXERCISES = [];
let AI_LIBRARY = [];
let currentUser = null;
let currentRole = 'user';

function escapeHtml(s) {
  if (!s) return '';
  return String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function toHtml(text) {
  if (!text) return '';
  return text.split('\n').map(part => part.trim()).filter(Boolean)
    .map(part => {
      let escaped = escapeHtml(part);
      if (escaped.startsWith('### ')) {
        return `<h4>${escaped.substring(4)}</h4>`;
      }
      return `<p>${escaped}</p>`;
    })
    .join('');
}

function typeset(root) {
  if (window.MathJax && window.MathJax.typesetPromise) {
    MathJax.typesetPromise([root]).catch(() => {});
  }
}

/* ---------- Supabase Init ---------- */
const SUPABASE_CFG = window.SUPABASE_CONFIG || { url: '', anonKey: '' };
let _sbClient = null;

function sb() {
  if (_sbClient) return _sbClient;
  if (!window.supabase || !SUPABASE_CFG.url || !SUPABASE_CFG.anonKey) return null;
  _sbClient = window.supabase.createClient(SUPABASE_CFG.url, SUPABASE_CFG.anonKey);
  return _sbClient;
}

/* ---------- API Của AI ---------- */
function apiUrl(apiPath) {
  return (SUPABASE_CFG.apiBase || '') + apiPath;
}

async function callAiApi(apiPath, payload) {
  const limit = 5;
  const windowMs = 60 * 60 * 1000;
  
  let logs = JSON.parse(localStorage.getItem('ai_request_logs') || '[]');
  const now = Date.now();
  logs = logs.filter(t => now - t <= windowMs);
  
  if (logs.length >= limit) {
    throw new Error('Bạn đã tạo bài quá nhiều. Vui lòng thử lại sau 1 giờ.');
  }

  const headers = { 'Content-Type': 'application/json' };
  
  const client = sb();
  if (client) {
    const { data } = await client.auth.getSession();
    if (data && data.session && data.session.access_token) {
      headers['Authorization'] = `Bearer ${data.session.access_token}`;
    }
  }

  try {
    const res = await fetch(apiUrl(apiPath), {
      method: 'POST',
      headers,
      body: JSON.stringify(payload)
    });
    const data = await res.json();
    if (!res.ok) throw new Error(data.error || 'Lỗi server');
    
    logs.push(now);
    localStorage.setItem('ai_request_logs', JSON.stringify(logs));
    
    return data;
  } catch (err) {
    throw err;
  }
}

/* ---------- Load Data ---------- */
async function loadData() {
  const client = sb();
  if (!client) {
    const msg = 'Chưa cấu hình Supabase hoặc thiếu thư viện. Vui lòng kiểm tra supabase-config.js.';
    console.error(msg);
    if ($('#home-topics')) $('#home-topics').innerHTML = `<p style="color:red; text-align:center; padding: 2rem;">${msg}</p>`;
    return;
  }

  try {
    const [tRes, lRes, eRes] = await Promise.all([
      client.from('topics').select('*').order('display_order'),
      client.from('lessons').select('*').order('display_order'),
      client.from('exercises').select('*').order('display_order')
    ]);

    if (tRes.error) throw tRes.error;
    if (lRes.error) throw lRes.error;
    if (eRes.error) throw eRes.error;

    TOPICS = tRes.data || [];
    LESSONS = lRes.data || [];
    EXERCISES = eRes.data || [];

    if (currentUser) {
      const libRes = await client.from('ai_library').select('*').eq('user_id', currentUser.id);
      if (libRes.data) AI_LIBRARY = libRes.data;
    }
  } catch (err) {
    const msg = 'Lỗi tải dữ liệu Supabase: ' + (err.message || 'Không xác định');
    console.error(err);
    if ($('#home-topics')) $('#home-topics').innerHTML = `<p style="color:red; text-align:center; padding: 2rem;">${msg}</p>`;
  }
}

/* ---------- Điều Hướng ---------- */
const PAGES = {
  home: '#page-home',
  theory: '#page-theory',
  exercises: '#page-exercises',
  library: '#page-library', // ID placeholder
  admin: '#page-admin'
};

function navigate(page) {
  Object.entries(PAGES).forEach(([name, selector]) => {
    const el = $(selector);
    if (el) el.classList.toggle('hidden', name !== page);
  });
  $$('[data-nav]').forEach(a => {
    a.classList.toggle('active', a.dataset.nav === page);
  });
  window.scrollTo({ top: 0 });

  if (page === 'home') renderHome();
  if (page === 'theory') renderTheory();
  if (page === 'exercises') renderExercises();
  if (page === 'admin') renderAdmin();
  if (page === 'library') renderLibrary();
}

window.addEventListener('hashchange', () => {
  const name = (location.hash || '').replace('#', '');
  navigate(PAGES[name] ? name : 'home');
});

/* ---------- UI Rendering ---------- */

function renderHome() {
  const box = $('#home-topics');
  if(!box) return;
  box.innerHTML = TOPICS.map(t => `
    <a class="topic-card" href="#theory" data-topic="${t.id}">
      <h3>${escapeHtml(t.title)}</h3>
      <p>${escapeHtml(t.description)}</p>
    </a>
  `).join('');
  
  $$('#home-topics .topic-card').forEach(card => {
    card.addEventListener('click', () => {
      currentTopicId = card.dataset.topic;
    });
  });
}

let currentTopicId = null;
let currentLessonId = null;
let activeLessonFilterId = null;

function renderTheory() {
  const tabs = $('#theory-topic-tabs');
  if(!tabs) return;
  tabs.innerHTML = TOPICS.map(t => `
    <button class="topic-tab ${t.id == currentTopicId ? 'active' : ''}" data-topic="${t.id}">
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

  const list = $('#lesson-list');
  const lessons = LESSONS.filter(l => l.topic_id == currentTopicId);
  list.innerHTML = lessons.map(l => `
    <div class="lesson-card" data-lesson="${l.id}">
      <h3>${escapeHtml(l.title)}</h3>
    </div>
  `).join('');

  $$('#lesson-list .lesson-card').forEach(card => {
    card.addEventListener('click', () => {
      currentLessonId = card.dataset.lesson;
      renderTheory();
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });
  });

  if (currentLessonId) {
    tabs.classList.add('hidden');
    list.classList.add('hidden');
  } else {
    tabs.classList.remove('hidden');
    list.classList.remove('hidden');
  }

  renderLessonDetail();
}

function renderLessonDetail() {
  const box = $('#lesson-detail');
  if (!box) return;
  if (!currentLessonId) {
    box.classList.add('hidden');
    return;
  }
  const lesson = LESSONS.find(l => l.id == currentLessonId);
  box.classList.remove('hidden');
  box.innerHTML = `
    <span class="back-link" id="lesson-back">← Chọn bài học khác</span>
    <h2>${escapeHtml(lesson.title)}</h2>
    
    <div class="lesson-block">
      <h3>1. Kiến thức bổ trợ</h3>
      ${toHtml(lesson.supplementary_knowledge)}
    </div>
    
    <div class="lesson-block">
      <h3>2. Kiến thức nền tảng</h3>
      ${toHtml(lesson.foundational_knowledge)}
    </div>
    
    <div class="lesson-block">
      <h3>3. Bài tập đặc trưng</h3>
      ${toHtml(lesson.characteristic_exercises)}
    </div>
    
    <div class="solution-toggle-row">
      <button class="btn btn-outline" id="lesson-exercises">Luyện bài tập phần này</button>
    </div>
  `;

  $('#lesson-back').addEventListener('click', () => {
    currentLessonId = null;
    renderTheory();
  });


  $('#lesson-exercises').addEventListener('click', () => {
    activeLessonFilterId = currentLessonId;
    navigate('exercises');
  });

  typeset(box);
}

function renderExercises() {
  const list = $('#exercise-list');
  if(!list) return;
  $('#exercise-detail').classList.add('hidden');
  list.classList.remove('hidden');
  $('#exercise-filters')?.classList.remove('hidden');
  
  let filteredExercises = EXERCISES;
  let noticeHtml = '';

  if (activeLessonFilterId) {
    filteredExercises = EXERCISES.filter(e => e.lesson_id == activeLessonFilterId);
    const lesson = LESSONS.find(l => l.id == activeLessonFilterId);
    noticeHtml = `
      <div class="exercise-card" style="background: var(--primary-color); color: white; padding: 10px 15px; margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center;">
        <span style="font-weight: bold;">Đang hiển thị bài tập của: ${lesson ? escapeHtml(lesson.title) : ''}</span>
        <button id="clear-lesson-filter" class="btn btn-outline" style="background: white; color: var(--primary-color); padding: 5px 10px; font-size: 0.9em; min-width: auto; height: auto;">Hiển thị tất cả</button>
      </div>
    `;
  }

  list.innerHTML = noticeHtml + filteredExercises.map(e => {
    const lesson = LESSONS.find(l => l.id == e.lesson_id);
    return `
      <div class="exercise-card" data-exercise="${e.id}" style="cursor: pointer;">
        <div style="margin-bottom: 10px; font-weight: bold; font-size: 1.1em; line-height: 1.5;">
          ${toHtml(e.question)}
        </div>
        <div class="exercise-tags" style="margin-top: 15px;">
          <span class="tag" style="background: #f0f0f0; border: 1px solid #ddd; color: #555;">📖 ${lesson ? escapeHtml(lesson.title) : 'Không xác định'}</span>
          ${(e.tags || []).map(t => `<span class="tag">${escapeHtml(t)}</span>`).join('')}
        </div>
      </div>
    `;
  }).join('');

  if (activeLessonFilterId) {
    $('#clear-lesson-filter')?.addEventListener('click', () => {
      activeLessonFilterId = null;
      renderExercises();
    });
  }

  $$('#exercise-list .exercise-card').forEach(card => {
    card.addEventListener('click', () => renderExerciseDetail(card.dataset.exercise));
  });

  typeset(list);
}

function renderExerciseDetail(id) {
  const e = EXERCISES.find(x => x.id == id);
  const box = $('#exercise-detail');
  $('#exercise-list').classList.add('hidden');
  $('#exercise-filters').classList.add('hidden');
  box.classList.remove('hidden');
  window.scrollTo({ top: 0, behavior: 'smooth' });
  
  // Xử lý chèn nút 💡 vào từng dòng đáp án
  const solutionLines = (e.detailed_solution || '').split('\n').map(line => line.trim()).filter(Boolean);
  const solutionHtml = solutionLines.map((line, index) => `
    <p class="solution-line">
      ${escapeHtml(line)}
      <span class="ask-icon" title="Hỏi AI bước này" data-line="${escapeHtml(line)}" data-problem="${escapeHtml(e.question)}" data-steps="${escapeHtml(JSON.stringify(solutionLines))}" data-index="${index}">💡</span>
    </p>
  `).join('');

  box.innerHTML = `
    <span class="back-link" id="exercise-back">← Danh sách bài tập</span>
    
    <div class="exercise-block">
      <h3>Đề bài</h3>
      ${toHtml(e.question)}
    </div>
    
    <div style="display:flex; gap:10px;">
        <button class="btn btn-primary" id="toggle-solution">Xem đáp án chi tiết</button>
        <button class="btn btn-outline" id="generate-similar-ai">Tạo câu hỏi tương tự (AI)</button>
    </div>
    
    <div class="exercise-block hidden" id="solution-box" style="margin-top: 20px;">
      <h3>Đáp án chi tiết</h3>
      ${solutionHtml}
    </div>
  `;

  $('#exercise-back').addEventListener('click', () => {
    box.classList.add('hidden');
    $('#exercise-list').classList.remove('hidden');
    $('#exercise-filters').classList.remove('hidden');
  });

  $('#toggle-solution').addEventListener('click', (btn) => {
    $('#solution-box').classList.toggle('hidden');
    btn.target.style.display = 'none';
  });

  $('#generate-similar-ai').addEventListener('click', async (btn) => {
    btn.target.innerText = 'Đang tạo...';
    btn.target.disabled = true;
    try {
      const lesson = LESSONS.find(l => l.id === e.lesson_id);
      const foundational = lesson ? lesson.foundational_knowledge : '';
      const data = await callAiApi('/api/generate-similar', {
         original_question: e.question,
         original_solution: e.detailed_solution,
         tags: e.tags,
         foundational_knowledge: foundational
      });
      // Show in Modal instead of replacing view
      $('#generate-content').innerHTML = `
        <div class="exercise-block">
          <h4 style="margin-bottom:10px;">Đề bài</h4>
          ${toHtml(data.question)}
        </div>
        <div class="exercise-block" style="margin-top: 20px;">
          <h4 style="margin-bottom:10px;">Đáp án chi tiết</h4>
          ${toHtml(data.detailed_solution)}
        </div>
        ${data.nghiem_cuoi && data.nghiem_cuoi !== "Không xác định" ? `
        <div class="exercise-block" style="margin-top: 20px;">
          <h4 style="margin-bottom:10px; color: var(--primary-color);">Đáp số (Nghiệm cuối)</h4>
          ${toHtml(data.nghiem_cuoi)}
        </div>` : ''}
        ${data.thay_doi && data.thay_doi !== "Không xác định" ? `
        <div class="exercise-block" style="margin-top: 20px;">
          <h4 style="margin-bottom:10px; color: var(--secondary-color);">Phân tích thay đổi so với bài gốc</h4>
          ${toHtml(data.thay_doi)}
        </div>` : ''}
      `;
      $('#generate-modal').classList.remove('hidden');
      $('#save-library-ai').classList.remove('hidden');

      // Clear old listeners by cloning
      const oldSaveBtn = $('#save-library-ai');
      const newSaveBtn = oldSaveBtn.cloneNode(true);
      oldSaveBtn.parentNode.replaceChild(newSaveBtn, oldSaveBtn);

      newSaveBtn.addEventListener('click', async () => {
         if(!currentUser) return alert('Đăng nhập để lưu');
         newSaveBtn.innerText = 'Đang lưu...';
         const client = sb();
         await client.from('ai_library').insert([{
             user_id: currentUser.id,
             original_exercise_id: id,
             question: data.question,
             detailed_solution: data.detailed_solution
         }]);
         alert('Đã lưu vào thư viện!');
         newSaveBtn.innerText = 'Đã lưu';
         newSaveBtn.disabled = true;
         loadData();
      });
      typeset($('#generate-content'));
    } catch(err) {
      alert('Lỗi: ' + err.message);
      btn.target.innerText = 'Tạo câu hỏi tương tự (AI)';
      btn.target.disabled = false;
    }
  });

  // Gắn event cho Nút Hỏi AI
  $$('.ask-icon', box).forEach(icon => {
    icon.addEventListener('click', (ev) => {
      const target = ev.target;
      openAskModal(
        target.dataset.line,
        target.dataset.problem,
        target.dataset.steps,
        target.dataset.index
      );
    });
  });

  typeset(box);
}

/* ---------- Hybrid AI Logic ---------- */
let currentAiContext = null;

async function openAskModal(lineText, problem, stepsStr, indexStr) {
  currentAiContext = { 
    line: lineText, 
    problem: problem,
    solutionSteps: JSON.parse(stepsStr || '[]'),
    stepIndex: parseInt(indexStr || '0')
  };
  $('#ask-quick-explanation').innerHTML = "<em>Đang hỏi Gia sư AI...</em>";
  $('#ask-modal').classList.remove('hidden');
  
  try {
    const data = await callAiApi('/api/ask-solution', {
      problem: currentAiContext.problem,
      solutionSteps: currentAiContext.solutionSteps,
      stepIndex: currentAiContext.stepIndex,
      question: "Giải thích ngắn gọn bước này giúp tôi."
    });
    
    const dataObj = typeof data === 'string' ? JSON.parse(data) : data;
    $('#ask-quick-explanation').innerHTML = `<strong>Giải thích nhanh:</strong> ${toHtml(dataObj.answer || data.answer)}`;
    typeset($('#ask-quick-explanation'));
  } catch (err) {
    $('#ask-quick-explanation').innerHTML = `<span style="color:red">Lỗi: ${escapeHtml(err.message)}</span>`;
  }
}

$('#ask-close')?.addEventListener('click', () => {
  $('#ask-modal').classList.add('hidden');
});

$('#btn-open-chat')?.addEventListener('click', () => {
  $('#ask-modal').classList.add('hidden');
  $('#chat-sidebar').classList.remove('hidden');
  
  const chatBody = $('#chat-messages');
  chatBody.innerHTML = `
    <div class="chat-msg ai">Chào bạn, tôi là Gia sư AI. Bạn đang thắc mắc về bước: <strong>"${escapeHtml(currentAiContext.line)}"</strong>. Bạn muốn hỏi thêm chi tiết gì?</div>
  `;
});

$('#chat-close')?.addEventListener('click', () => {
  $('#chat-sidebar').classList.add('hidden');
});

$('#generate-close')?.addEventListener('click', () => {
  $('#generate-modal').classList.add('hidden');
});

$('#chat-form')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  const input = $('#chat-input');
  const text = input.value.trim();
  if(!text) return;

  const chatBody = $('#chat-messages');
  chatBody.innerHTML += `<div class="chat-msg user">${escapeHtml(text)}</div>`;
  input.value = '';
  
  // Tạm hiển thị AI đang nghĩ
  const typingId = 'ai-typing-' + Date.now();
  chatBody.innerHTML += `<div class="chat-msg ai" id="${typingId}"><em>Đang suy nghĩ...</em></div>`;
  chatBody.scrollTop = chatBody.scrollHeight;

  try {
    const data = await callAiApi('/api/ask-solution', {
      problem: currentAiContext.problem,
      solutionSteps: currentAiContext.solutionSteps,
      stepIndex: currentAiContext.stepIndex,
      question: text
    });
    
    const dataObj = typeof data === 'string' ? JSON.parse(data) : data;
    const typingIndicator = document.getElementById(typingId);
    if (typingIndicator) typingIndicator.remove();
    chatBody.innerHTML += `<div class="chat-msg ai">${toHtml(dataObj.answer || data.answer)}</div>`;
    typeset(chatBody);
  } catch (err) {
    const typingIndicator = document.getElementById(typingId);
    if (typingIndicator) typingIndicator.remove();
    chatBody.innerHTML += `<div class="chat-msg ai" style="color:red">Lỗi: ${escapeHtml(err.message)}</div>`;
  }
  chatBody.scrollTop = chatBody.scrollHeight;
});


/* ---------- Admin Logic ---------- */
function renderAdmin() {
  if (!currentUser) {
    $('#admin-notice').classList.remove('hidden');
    $('#admin-notice').innerHTML = "Vui lòng đăng nhập để truy cập Admin.";
    $('#admin-body').classList.add('hidden');
    return;
  }
  if (currentRole !== 'admin') {
    $('#admin-notice').classList.remove('hidden');
    $('#admin-notice').innerHTML = "Bạn không có quyền quản trị. Chỉ tài khoản Admin mới được phép vào khu vực này.";
    $('#admin-body').classList.add('hidden');
    return;
  }
  
  $('#admin-notice').classList.add('hidden');
  $('#admin-body').classList.remove('hidden');

  // Populate Selects
  const topicSel = $('#admin-lesson-topic');
  if(topicSel) topicSel.innerHTML = TOPICS.map(t => `<option value="${t.id}">${escapeHtml(t.title)}</option>`).join('');

  const lessonSel = $('#admin-exercise-lesson');
  if(lessonSel) lessonSel.innerHTML = LESSONS.map(l => `<option value="${l.id}">${escapeHtml(l.title)}</option>`).join('');

  renderAdminLists();
}

function renderAdminLists() {
  const lessonList = $('#admin-lessons-list');
  if (lessonList) {
    lessonList.innerHTML = '<h3>Danh sách Lý thuyết</h3>' + LESSONS.map(l => `
      <div style="border: 1px solid #ddd; padding: 10px; margin-bottom: 10px;">
        <strong>${escapeHtml(l.title)}</strong> (Slug: ${escapeHtml(l.slug)})
        <span style="font-size:0.8em; padding:2px 6px; border-radius:4px; margin-left:8px; background: ${l.is_published ? '#d1fae5' : '#fef3c7'}; color: ${l.is_published ? '#065f46' : '#92400e'}">
          ${l.is_published ? 'Đã xuất bản' : 'Bản nháp'}
        </span>
        <div style="margin-top: 10px;">
          <button class="btn btn-primary btn-edit-lesson" data-id="${l.id}" style="padding: 4px 8px; font-size: 0.9em;">Sửa</button>
          <button class="btn btn-outline btn-delete-lesson" data-id="${l.id}" style="padding: 4px 8px; font-size: 0.9em; color: red; border-color: red;">Xóa</button>
        </div>
      </div>
    `).join('');
  }

  const exList = $('#admin-exercises-list');
  if (exList) {
    exList.innerHTML = '<h3>Danh sách Bài tập</h3>' + EXERCISES.map(e => {
      const lessonTitle = LESSONS.find(l => l.id === e.lesson_id)?.title || 'Không rõ';
      return `
      <div style="border: 1px solid #ddd; padding: 10px; margin-bottom: 10px;">
        <strong>Bài thuộc: ${escapeHtml(lessonTitle)}</strong>
        <span style="font-size:0.8em; padding:2px 6px; border-radius:4px; margin-left:8px; background: ${e.is_published ? '#d1fae5' : '#fef3c7'}; color: ${e.is_published ? '#065f46' : '#92400e'}">
          ${e.is_published ? 'Đã xuất bản' : 'Bản nháp'}
        </span>
        <p>${escapeHtml(e.question || '').substring(0, 100)}...</p>
        <div style="margin-top: 10px;">
          <button class="btn btn-primary btn-edit-exercise" data-id="${e.id}" style="padding: 4px 8px; font-size: 0.9em;">Sửa</button>
          <button class="btn btn-outline btn-delete-exercise" data-id="${e.id}" style="padding: 4px 8px; font-size: 0.9em; color: red; border-color: red;">Xóa</button>
        </div>
      </div>
    `}).join('');
  }
}

document.addEventListener('click', async e => {
  if (e.target.matches('.btn-edit-lesson')) {
    const l = LESSONS.find(x => x.id === e.target.dataset.id);
    if (!l) return;
    $('#admin-lesson-id').value = l.id;
    $('#admin-lesson-topic').value = l.topic_id;
    $('#admin-lesson-title').value = l.title;
    $('#admin-lesson-slug').value = l.slug;
    $('#admin-lesson-supplementary').value = l.supplementary_knowledge || '';
    $('#admin-lesson-foundational').value = l.foundational_knowledge || '';
    $('#admin-lesson-characteristic').value = l.characteristic_exercises || '';
    $('#admin-lesson-published').checked = !!l.is_published;
    $('#admin-lesson-title').focus();
  }
  
  if (e.target.matches('.btn-delete-lesson')) {
    if (confirm('Bạn có chắc muốn xóa bài học này? Mọi bài tập của bài học cũng sẽ bị xóa vĩnh viễn!')) {
      const client = sb();
      await client.from('lessons').delete().eq('id', e.target.dataset.id);
      await loadData();
      renderAdmin();
    }
  }

  if (e.target.matches('.btn-edit-exercise')) {
    const ex = EXERCISES.find(x => x.id === e.target.dataset.id);
    if (!ex) return;
    $('#admin-exercise-id').value = ex.id;
    $('#admin-exercise-lesson').value = ex.lesson_id;
    $('#admin-exercise-tags').value = (ex.tags || []).join(', ');
    $('#admin-exercise-question').value = ex.question || '';
    $('#admin-exercise-solution').value = ex.detailed_solution || '';
    $('#admin-exercise-published').checked = !!ex.is_published;
    $('#admin-exercise-question').focus();
  }
  
  if (e.target.matches('.btn-delete-exercise')) {
    if (confirm('Bạn có chắc muốn xóa bài tập này?')) {
      const client = sb();
      await client.from('exercises').delete().eq('id', e.target.dataset.id);
      await loadData();
      renderAdmin();
    }
  }
});

$('#admin-lesson-clear')?.addEventListener('click', () => {
  $('#admin-lesson-form').reset();
  $('#admin-lesson-id').value = '';
  $('#admin-lesson-published').checked = false;
});

$('#admin-exercise-clear')?.addEventListener('click', () => {
  $('#admin-exercise-form').reset();
  $('#admin-exercise-id').value = '';
  $('#admin-exercise-published').checked = false;
});

$('#admin-lesson-title')?.addEventListener('input', (e) => {
  const slugInput = $('#admin-lesson-slug');
  if (!slugInput.value || slugInput.dataset.auto === 'true') {
    const slug = e.target.value.toLowerCase().trim().replace(/đ/g, 'd').replace(/[\s\W-]+/g, '-').replace(/^-+|-+$/g, '');
    slugInput.value = slug;
    slugInput.dataset.auto = 'true';
  }
});

$('#admin-lesson-slug')?.addEventListener('input', (e) => {
  e.target.dataset.auto = 'false';
});

$('#admin-lesson-preview')?.addEventListener('click', () => {
  const box = $('#admin-lesson-preview-box');
  box.innerHTML = `
    <h4>1. Kiến thức bổ trợ</h4>
    ${toHtml($('#admin-lesson-supplementary').value)}
    <h4>2. Kiến thức nền tảng</h4>
    ${toHtml($('#admin-lesson-foundational').value)}
    <h4>3. Bài tập đặc trưng</h4>
    ${toHtml($('#admin-lesson-characteristic').value)}
  `;
  box.classList.remove('hidden');
  typeset(box);
});

$('#admin-exercise-preview')?.addEventListener('click', () => {
  const box = $('#admin-exercise-preview-box');
  box.innerHTML = `
    <h4>Đề bài</h4>
    ${toHtml($('#admin-exercise-question').value)}
    <h4>Đáp án chi tiết</h4>
    ${toHtml($('#admin-exercise-solution').value)}
  `;
  box.classList.remove('hidden');
  typeset(box);
});

$('#admin-lesson-form')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  const id = $('#admin-lesson-id').value;
  const data = {
    topic_id: $('#admin-lesson-topic').value,
    title: $('#admin-lesson-title').value,
    slug: $('#admin-lesson-slug').value,
    supplementary_knowledge: $('#admin-lesson-supplementary').value,
    foundational_knowledge: $('#admin-lesson-foundational').value,
    characteristic_exercises: $('#admin-lesson-characteristic').value,
    is_published: $('#admin-lesson-published').checked
  };
  const client = sb();
  
  let res;
  if (id) res = await client.from('lessons').update(data).eq('id', id);
  else res = await client.from('lessons').insert([data]);
  
  if(res.error) alert('Lỗi: ' + res.error.message);
  else {
    alert('Lưu bài học thành công!');
    $('#admin-lesson-form').reset();
    $('#admin-lesson-id').value = '';
    await loadData();
    renderAdmin();
  }
});

$('#admin-exercise-form')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  const id = $('#admin-exercise-id').value;
  const data = {
    lesson_id: $('#admin-exercise-lesson').value,
    tags: $('#admin-exercise-tags').value.split(',').map(s=>s.trim()).filter(Boolean),
    question: $('#admin-exercise-question').value,
    detailed_solution: $('#admin-exercise-solution').value,
    is_published: $('#admin-exercise-published').checked
  };
  const client = sb();
  
  let res;
  if (id) res = await client.from('exercises').update(data).eq('id', id);
  else res = await client.from('exercises').insert([data]);
  
  if(res.error) alert('Lỗi: ' + res.error.message);
  else {
    alert('Lưu bài tập thành công!');
    $('#admin-exercise-form').reset();
    $('#admin-exercise-id').value = '';
    await loadData();
    renderAdmin();
  }
});

/* ---------- Thư viện AI ---------- */
function renderLibrary() {
  const list = $('#library-list');
  if (!currentUser) {
    list.innerHTML = '<p class="page-desc">Vui lòng đăng nhập để xem thư viện cá nhân của bạn.</p>';
    return;
  }
  if (AI_LIBRARY.length === 0) {
    list.innerHTML = '<p class="page-desc">Bạn chưa lưu bài tập AI nào. Hãy sang phần "Bài tập" và tạo câu hỏi tương tự bằng AI nhé.</p>';
    return;
  }
  list.innerHTML = AI_LIBRARY.map(item => `
    <div class="exercise-card" style="margin-bottom: 20px;">
      <h3 style="margin-bottom: 10px;">${escapeHtml(item.question)}</h3>
      <details>
        <summary style="cursor: pointer; font-weight: bold; margin-bottom: 10px; color: var(--primary-color);">Xem đáp án chi tiết</summary>
        <div class="lesson-block">${toHtml(item.detailed_solution)}</div>
      </details>
      <button class="btn btn-outline btn-delete-ai" data-id="${item.id}" style="margin-top: 10px; color: red; border-color: red;">Xóa khỏi thư viện</button>
    </div>
  `).join('');

  typeset(list);

  $$('.btn-delete-ai').forEach(btn => {
    btn.addEventListener('click', async () => {
      const id = btn.dataset.id;
      if(confirm('Bạn có chắc muốn xóa bài tập này?')) {
        const client = sb();
        await client.from('ai_library').delete().eq('id', id);
        AI_LIBRARY = AI_LIBRARY.filter(i => i.id !== id);
        renderLibrary();
      }
    });
  });
}

/* ---------- Xác thực ---------- */
async function updateAuthState(session) {
  currentUser = session?.user || null;
  currentRole = 'user';
  if (currentUser) {
    const { data } = await sb().from('profiles').select('role').eq('id', currentUser.id).maybeSingle();
    if (data) currentRole = data.role;
  }
  renderAuth();
}

function renderAuth() {
  const box = $('#auth-box');
  const navAdmin = $('#nav-admin');
  const navLibrary = $('#nav-library');
  
  if (currentUser) {
    const name = currentUser.user_metadata?.name || currentUser.email;
    box.innerHTML = `<span style="margin-right:10px; font-weight: 500;">👤 ${escapeHtml(name)}</span> <button class="btn btn-outline" id="btn-logout" style="padding: 4px 8px; font-size: 0.9em;">Đăng xuất</button>`;
    $('#btn-logout').addEventListener('click', async () => {
      await sb().auth.signOut();
    });
    
    navLibrary.classList.remove('hidden');
    if (currentRole === 'admin') {
      navAdmin.classList.remove('hidden');
    } else {
      navAdmin.classList.add('hidden');
    }
  } else {
    box.innerHTML = `<button class="btn btn-primary" id="btn-show-auth" style="padding: 4px 12px;">Đăng nhập</button>`;
    $('#btn-show-auth').addEventListener('click', () => {
      $('#auth-modal').classList.remove('hidden');
    });
    navLibrary.classList.add('hidden');
    navAdmin.classList.add('hidden');
  }
}

function setupAuthModal() {
  let isLogin = true;
  const modal = $('#auth-modal');
  const form = $('#auth-form');
  const msg = $('#auth-msg');
  const nameLabel = $('#auth-name').parentElement;
  
  $('#auth-close').addEventListener('click', () => modal.classList.add('hidden'));
  
  $('#mode-login').addEventListener('click', () => {
    isLogin = true;
    $('#mode-login').classList.add('active');
    $('#mode-signup').classList.remove('active');
    nameLabel.style.display = 'none';
    $('#auth-submit').textContent = 'Đăng nhập';
    msg.textContent = '';
  });
  
  $('#mode-signup').addEventListener('click', () => {
    isLogin = false;
    $('#mode-signup').classList.add('active');
    $('#mode-login').classList.remove('active');
    nameLabel.style.display = 'flex';
    $('#auth-submit').textContent = 'Đăng ký';
    msg.textContent = '';
  });
  
  nameLabel.style.display = 'none';
  
  form.addEventListener('submit', async e => {
    e.preventDefault();
    const email = $('#auth-email').value;
    const password = $('#auth-password').value;
    const name = $('#auth-name').value;
    const client = sb();
    
    if (!client) {
      msg.textContent = 'Lỗi kết nối máy chủ Supabase.';
      msg.style.color = 'red';
      return;
    }
    
    msg.textContent = 'Đang xử lý...';
    msg.style.color = 'var(--text-color)';
    
    try {
      if (isLogin) {
        const { error } = await client.auth.signInWithPassword({ email, password });
        if (error) {
          msg.textContent = 'Lỗi đăng nhập: ' + (error.message.includes('Invalid login') ? 'Sai email hoặc mật khẩu' : error.message);
          msg.style.color = 'red';
        } else {
          modal.classList.add('hidden');
          form.reset();
        }
      } else {
        const { error } = await client.auth.signUp({
          email, password,
          options: { data: { name } }
        });
        if (error) {
          msg.textContent = 'Lỗi đăng ký: ' + error.message;
          msg.style.color = 'red';
        } else {
          msg.textContent = 'Đăng ký thành công! Bạn có thể đăng nhập ngay.';
          msg.style.color = 'green';
          form.reset();
        }
      }
    } catch (err) {
      msg.textContent = 'Lỗi: ' + err.message;
      msg.style.color = 'red';
    }
  });
}

/* ---------- Khởi chạy ---------- */
async function init() {
  setupAuthModal();
  const client = sb();
  
  if (client) {
    const { data: { session } } = await client.auth.getSession();
    await updateAuthState(session);
    
    client.auth.onAuthStateChange(async (event, session) => {
      await updateAuthState(session);
      await loadData();
      const hashPage = (location.hash || '').replace('#', '');
      navigate(PAGES[hashPage] ? hashPage : 'home');
    });
  }

  await loadData();
  
  const hashPage = (location.hash || '').replace('#', '');
  navigate(PAGES[hashPage] ? hashPage : 'home');
}

document.addEventListener('DOMContentLoaded', init);
