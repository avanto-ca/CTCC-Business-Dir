-- First ensure we're operating as superuser
SET ROLE postgres;

-- Enable RLS on categories table
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Public read access" ON categories;
DROP POLICY IF EXISTS "Admin manage access" ON categories;
DROP POLICY IF EXISTS "Admin update access" ON categories;
DROP POLICY IF EXISTS "Admin delete access" ON categories;

-- Create policies with proper access control
CREATE POLICY "Public read access"
  ON categories
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Admin insert access"
  ON categories
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

CREATE POLICY "Admin update access"
  ON categories
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

CREATE POLICY "Admin delete access"
  ON categories
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

-- Add comments
COMMENT ON POLICY "Public read access" ON categories IS 'Anyone can read categories';
COMMENT ON POLICY "Admin insert access" ON categories IS 'Only admins can create new categories';
COMMENT ON POLICY "Admin update access" ON categories IS 'Only admins can update categories';
COMMENT ON POLICY "Admin delete access" ON categories IS 'Only admins can delete categories';