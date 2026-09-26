-- ============================================================
-- Hàm số — Schema Supabase (Giai đoạn 2)
-- Cách chạy: Supabase Dashboard → SQL Editor → dán toàn bộ file → Run.
-- An toàn chạy lại nhiều lần (dùng IF NOT EXISTS).
--
-- File chỉ gồm những gì website thực sự cần:
--   1. Tạo 4 bảng dữ liệu (nếu chưa có) — khớp cấu trúc data.js.
--   2. Bổ sung cột còn thiếu vào schema cũ:
--      lessons: slug, objective, sections
--      exercises: slug, type, techniques, related, hint
--   3. Dọn cột cũ không dùng: lessons.content_mdx.
--   4. Row Level Security: trình duyệt chỉ đọc được nội dung đã xuất bản.
-- ============================================================

-- ---------- 1) Bảng (chỉ gồm cột website dùng) ----------

create table if not exists topics (
  id uuid primary key default gen_random_uuid(),
  slug text unique,               -- id nội bộ của website (không dấu, không khoảng trắng)
  title text not null,
  description text default '',
  display_order int not null default 0,
  created_at timestamptz default now()
);

create table if not exists lessons (
  id uuid primary key default gen_random_uuid(),
  topic_id uuid references topics(id) on delete cascade,
  slug text unique,
  title text not null,
  objective text default '',      -- mục tiêu bài học
  sections jsonb default '[]'::jsonb,  -- mảng {type, title, body}, type: definition|theorem|technique|example
  display_order int not null default 0,
  is_published boolean not null default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists exercises (
  id uuid primary key default gen_random_uuid(),
  topic_id uuid references topics(id) on delete cascade,
  slug text unique,
  title text not null,
  problem_latex text not null,    -- đề bài (LaTeX $...$)
  difficulty smallint not null default 1,  -- 1: cơ bản, 2: vận dụng, 3: nâng cao
  type text default '',           -- dạng bài, ví dụ: "Tìm hàm số"
  techniques text[] default '{}', -- kỹ thuật giải: {"thay biến","cauchy"}
  related text[] default '{}',    -- kiến thức liên quan
  hint text default '',           -- gợi ý
  source text default '',         -- nguồn bài
  status text not null default 'draft',  -- bài hiển thị khi status = 'published'
  created_at timestamptz default now()
);

create table if not exists exercise_solutions (
  id uuid primary key default gen_random_uuid(),
  exercise_id uuid references exercises(id) on delete cascade,
  step_number int not null,
  content_latex text not null,
  explanation text default ''
);

-- ---------- 2) Bổ sung cột còn thiếu cho schema cũ ----------
-- (Bảng topics và exercise_solutions đã khớp, không cần bổ sung.)

alter table lessons add column if not exists slug text;
alter table lessons add column if not exists objective text default '';
alter table lessons add column if not exists sections jsonb default '[]'::jsonb;

alter table exercises add column if not exists slug text;
alter table exercises add column if not exists type text default '';
alter table exercises add column if not exists techniques text[] default '{}';
alter table exercises add column if not exists related text[] default '{}';
alter table exercises add column if not exists hint text default '';

-- ---------- 3) Dọn cột cũ không dùng ----------
-- Website đọc bài học qua objective + sections, không dùng content_mdx.

alter table lessons drop column if exists content_mdx;

-- ---------- 4) Row Level Security ----------
-- Trình duyệt dùng publishable key — chỉ đọc được nội dung đã xuất bản.
-- Bạn (chủ dự án) dùng Supabase Dashboard để nhập/sửa dữ liệu, không bị RLS chặn.

alter table topics enable row level security;
alter table lessons enable row level security;
alter table exercises enable row level security;
alter table exercise_solutions enable row level security;

drop policy if exists "topics_public_read" on topics;
create policy "topics_public_read" on topics
  for select to anon, authenticated
  using (true);

drop policy if exists "lessons_public_read" on lessons;
create policy "lessons_public_read" on lessons
  for select to anon, authenticated
  using (is_published = true);

drop policy if exists "exercises_public_read" on exercises;
create policy "exercises_public_read" on exercises
  for select to anon, authenticated
  using (status = 'published');

drop policy if exists "solutions_public_read" on exercise_solutions;
create policy "solutions_public_read" on exercise_solutions
  for select to anon, authenticated
  using (
    exists (
      select 1 from exercises ex
      where ex.id = exercise_solutions.exercise_id
        and ex.status = 'published'
    )
  );

-- ---------- 5) Quyền đọc cho anon (đề phòng default privileges) ----------

grant usage on schema public to anon;
grant select on topics, lessons, exercises, exercise_solutions to anon;
