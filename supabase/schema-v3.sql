-- ============================================================
-- Hàm số — Schema Supabase (Giai đoạn 3)
-- Cập nhật cấu trúc:
--   - Lý thuyết: 3 khung (bổ trợ, nền tảng, bài tập đặc trưng)
--   - Bài tập: 2 khung (đề bài, đáp án chi tiết), chuyển từ bảng phụ sang trường dữ liệu trực tiếp.
--   - AI Library: Lưu bài tập do AI sinh ra theo user.
-- ============================================================

-- 1. Bảng `lessons`: Thêm 3 cột khung mới
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS supplementary_knowledge TEXT DEFAULT '';
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS foundational_knowledge TEXT DEFAULT '';
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS characteristic_exercises TEXT DEFAULT '';

-- Di chuyển dữ liệu từ `sections` JSON sang 3 cột mới (nếu chưa migrate)
DO $$
DECLARE
    lesson_record RECORD;
    section_json JSONB;
    v_supp TEXT;
    v_found TEXT;
    v_char TEXT;
BEGIN
    FOR lesson_record IN SELECT id, sections FROM lessons WHERE sections IS NOT NULL AND sections != '[]'::jsonb LOOP
        v_supp := '';
        v_found := '';
        v_char := '';
        
        FOR section_json IN SELECT * FROM jsonb_array_elements(lesson_record.sections) LOOP
            IF section_json->>'type' = 'definition' OR section_json->>'type' = 'theorem' THEN
                v_found := v_found || '<h4>' || COALESCE(section_json->>'title', '') || '</h4><p>' || COALESCE(section_json->>'body', '') || '</p>';
            ELSIF section_json->>'type' = 'technique' THEN
                v_supp := v_supp || '<h4>' || COALESCE(section_json->>'title', '') || '</h4><p>' || COALESCE(section_json->>'body', '') || '</p>';
            ELSIF section_json->>'type' = 'example' THEN
                v_char := v_char || '<h4>' || COALESCE(section_json->>'title', '') || '</h4><p>' || COALESCE(section_json->>'body', '') || '</p>';
            END IF;
        END LOOP;
        
        UPDATE lessons 
        SET 
            foundational_knowledge = CASE WHEN foundational_knowledge = '' THEN v_found ELSE foundational_knowledge END,
            supplementary_knowledge = CASE WHEN supplementary_knowledge = '' THEN v_supp ELSE supplementary_knowledge END,
            characteristic_exercises = CASE WHEN characteristic_exercises = '' THEN v_char ELSE characteristic_exercises END
        WHERE id = lesson_record.id;
    END LOOP;
END $$;

-- 2. Bảng `exercises`: Cập nhật cấu trúc 2 khung
ALTER TABLE exercises ADD COLUMN IF NOT EXISTS lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE;
ALTER TABLE exercises ADD COLUMN IF NOT EXISTS question TEXT DEFAULT '';
ALTER TABLE exercises ADD COLUMN IF NOT EXISTS detailed_solution TEXT DEFAULT '';
ALTER TABLE exercises ADD COLUMN IF NOT EXISTS tags TEXT[] DEFAULT '{}';
ALTER TABLE exercises ADD COLUMN IF NOT EXISTS display_order INT DEFAULT 0;
ALTER TABLE exercises ADD COLUMN IF NOT EXISTS is_published BOOLEAN DEFAULT true;

-- Di chuyển dữ liệu từ `problem_latex` sang `question`
UPDATE exercises SET question = problem_latex WHERE question = '' AND problem_latex IS NOT NULL;

-- Di chuyển dữ liệu từ bảng `exercise_solutions` (nếu có) sang `detailed_solution`
DO $$
DECLARE
    ex_record RECORD;
    v_solution TEXT;
BEGIN
    -- Gom nhóm tất cả step_number thành một text
    FOR ex_record IN SELECT id FROM exercises LOOP
        SELECT string_agg(content_latex || ' ' || explanation, e'\n' ORDER BY step_number)
        INTO v_solution
        FROM exercise_solutions
        WHERE exercise_id = ex_record.id;
        
        IF v_solution IS NOT NULL AND v_solution != '' THEN
            UPDATE exercises 
            SET detailed_solution = v_solution
            WHERE id = ex_record.id AND detailed_solution = '';
        END IF;
    END LOOP;
END $$;

-- 3. Tạo bảng `profiles` nếu chưa có (dành cho RLS role)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  role TEXT DEFAULT 'user'
);
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can read own profile" ON profiles;
CREATE POLICY "Users can read own profile" ON profiles FOR SELECT USING (auth.uid() = id);

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
-- Hàm tiện ích kiểm tra admin
CREATE OR REPLACE FUNCTION public.is_admin() RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid() AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Quyền cho admin trên bảng lessons
DROP POLICY IF EXISTS "Admin can manage lessons" ON lessons;
CREATE POLICY "Admin can manage lessons" ON lessons
  FOR ALL TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());

-- Quyền cho admin trên bảng exercises
DROP POLICY IF EXISTS "Admin can manage exercises" ON exercises;
CREATE POLICY "Admin can manage exercises" ON exercises
  FOR ALL TO authenticated
  USING (is_admin())
  WITH CHECK (is_admin());
