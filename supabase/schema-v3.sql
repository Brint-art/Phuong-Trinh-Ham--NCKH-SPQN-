-- ============================================================
-- Hàm số — Schema Supabase (Giai đoạn 3 - Gộp V2 & V3 + Dọn Dẹp)
-- Cập nhật cấu trúc:
--   - Bỏ qua các bảng cũ: ai_generation_requests, solution_questions, exercise_solutions
--   - Tạo bảng profiles và trigger tự tạo user
--   - Lý thuyết: 3 khung (bổ trợ, nền tảng, bài tập đặc trưng)
--   - Bài tập: 2 khung (đề bài, đáp án chi tiết), chuyển từ bảng phụ sang trường dữ liệu trực tiếp.
--   - AI Library: Lưu bài tập do AI sinh ra theo user.
-- ============================================================

set search_path = public;

-- ============================================================
-- A. DỌN DẸP BẢN CŨ
-- ============================================================
DROP TABLE IF EXISTS public.ai_generation_requests CASCADE;
DROP TABLE IF EXISTS public.solution_questions CASCADE;
DROP TABLE IF EXISTS public.exercise_solutions CASCADE;
ALTER TABLE IF EXISTS public.exercises DROP COLUMN IF EXISTS status;
-- Không xóa type enum exercise_status vì PostgreSQL không cho xóa dễ dàng nếu đang bị reference ở đâu đó, 
-- nhưng ta đã bỏ cột status.

-- ============================================================
-- B. TÀI KHOẢN VÀ QUYỀN (PROFILES & ADMIN)
-- ============================================================

DO $$ BEGIN
    CREATE TYPE public.user_role AS ENUM ('student', 'admin');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT,
  role public.user_role DEFAULT 'student',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION public.app_role() RETURNS text
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT coalesce((SELECT p.role::text FROM public.profiles p WHERE p.id = auth.uid()), 'anon')
$$;

CREATE OR REPLACE FUNCTION public.app_is_admin() RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT public.app_role() = 'admin'
$$;

GRANT EXECUTE ON FUNCTION public.app_role(), public.app_is_admin() TO anon, authenticated, service_role;

CREATE OR REPLACE FUNCTION public.handle_new_user() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role)
  VALUES (
    new.id,
    coalesce(nullif(new.raw_user_meta_data ->> 'full_name', ''), split_part(new.email, '@', 1)),
    'student'
  )
  ON CONFLICT (id) DO UPDATE SET full_name = coalesce(nullif(EXCLUDED.full_name, ''), profiles.full_name);
  RETURN new;
END $$;

DROP TRIGGER IF EXISTS hamso_handle_new_user ON auth.users;
CREATE TRIGGER hamso_handle_new_user
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================
-- C. CẤU TRÚC HỌC LIỆU (LESSONS & EXERCISES)
-- ============================================================

-- 1. Bảng `lessons`: Thêm 3 cột khung mới
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS supplementary_knowledge TEXT DEFAULT '';
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS foundational_knowledge TEXT DEFAULT '';
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS characteristic_exercises TEXT DEFAULT '';

-- 2. Bảng `exercises`: Cập nhật cấu trúc 2 khung
ALTER TABLE exercises ADD COLUMN IF NOT EXISTS lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE;
ALTER TABLE exercises ADD COLUMN IF NOT EXISTS question TEXT DEFAULT '';
ALTER TABLE exercises ADD COLUMN IF NOT EXISTS detailed_solution TEXT DEFAULT '';
ALTER TABLE exercises ADD COLUMN IF NOT EXISTS tags TEXT[] DEFAULT '{}';
ALTER TABLE exercises ADD COLUMN IF NOT EXISTS display_order INT DEFAULT 0;
ALTER TABLE exercises ADD COLUMN IF NOT EXISTS is_published BOOLEAN DEFAULT false;

-- Cột is_published cho lessons
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS is_published BOOLEAN DEFAULT false;

-- Bỏ NOT NULL cho title và problem_latex để admin thêm dễ dàng qua form mới
ALTER TABLE exercises ADD COLUMN IF NOT EXISTS title TEXT;
ALTER TABLE exercises ADD COLUMN IF NOT EXISTS problem_latex TEXT;
ALTER TABLE exercises ALTER COLUMN title DROP NOT NULL;
ALTER TABLE exercises ALTER COLUMN problem_latex DROP NOT NULL;

-- 3. Bảng `profiles` đã được tạo trong schema-v3 nên bỏ qua ở đây.

-- 4. Bảng `ai_library` (Lưu trữ bài do AI sinh)
CREATE TABLE IF NOT EXISTS ai_library (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  original_exercise_id UUID REFERENCES exercises(id) ON DELETE SET NULL,
  question TEXT NOT NULL,
  detailed_solution TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS cho `ai_library`: Chỉ người dùng đọc/ghi của chính mình
ALTER TABLE ai_library ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage their own ai_library" ON ai_library;
CREATE POLICY "Users can manage their own ai_library" ON ai_library
  FOR ALL TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 5. RLS cho Admin (Insert/Update/Delete)
-- Đã có hàm app_is_admin() từ schema-v2-roles.sql nên không tạo lại is_admin() ở đây.

-- Quyền cho admin trên bảng lessons
DROP POLICY IF EXISTS "Admin can manage lessons" ON lessons;
CREATE POLICY "Admin can manage lessons" ON lessons
  FOR ALL TO authenticated
  USING (app_is_admin())
  WITH CHECK (app_is_admin());

-- Quyền cho admin trên bảng exercises
DROP POLICY IF EXISTS "Admin can manage exercises" ON exercises;
CREATE POLICY "Admin can manage exercises" ON exercises
  FOR ALL TO authenticated
  USING (app_is_admin())
  WITH CHECK (app_is_admin());

-- Sửa RLS cho học sinh chỉ đọc bài đã xuất bản
DROP POLICY IF EXISTS "lesson_read" ON lessons;
CREATE POLICY "lesson_read" ON lessons FOR SELECT TO anon, authenticated
  USING (is_published = true OR app_is_admin());

DROP POLICY IF EXISTS "exercise_read" ON exercises;
CREATE POLICY "exercise_read" ON exercises FOR SELECT TO anon, authenticated
  USING (is_published = true OR app_is_admin());
