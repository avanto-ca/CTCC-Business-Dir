-- First ensure we're operating as superuser
SET ROLE postgres;

-- Enable RLS on categories table
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Public read access" ON categories;
DROP POLICY IF EXISTS "Admin manage access" ON categories;

-- Create policies
CREATE POLICY "Public read access"
  ON categories
  FOR SELECT
  TO public
  USING (true);

CREATE POLICY "Admin manage access"
  ON categories
  FOR ALL
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
COMMENT ON POLICY "Admin manage access" ON categories IS 'Only admins can manage categories';