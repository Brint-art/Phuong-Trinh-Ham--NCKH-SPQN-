-- ============================================================
-- Hàm số — Schema Supabase (Giai đoạn 4 - RLS)
-- Cập nhật RLS: Disallow self-review
-- Tác giả (admin) không được tự Publish bài của mình.
-- ============================================================

set search_path = public;

-- Xóa policy ALL cũ trên exercises
DROP POLICY IF EXISTS "Admin can manage exercises" ON exercises;

-- Tách thành các policy chi tiết:
-- 1. Insert: Admin có thể tạo bài tập, nhưng nếu là bài của mình (created_by = auth.uid()) thì không được Publish ngay.
CREATE POLICY "Admin can insert exercises" ON exercises 
  FOR INSERT TO authenticated
  WITH CHECK (app_is_admin() AND (created_by != auth.uid() OR is_published = false));

-- 2. Update: Admin có thể sửa bài tập, nhưng nếu là bài của mình thì bản lưu (NEW) phải là draft (is_published = false).
-- Nghĩa là không thể tự chuyển bài mình sang Publish, và cũng không thể sửa bài mình ĐÃ Publish (phải nhờ admin khác).
CREATE POLICY "Admin can update exercises" ON exercises 
  FOR UPDATE TO authenticated
  USING (app_is_admin())
  WITH CHECK (app_is_admin() AND (created_by != auth.uid() OR is_published = false));

-- 3. Delete: Admin có thể xóa (tuỳ ý)
CREATE POLICY "Admin can delete exercises" ON exercises 
  FOR DELETE TO authenticated
  USING (app_is_admin());
