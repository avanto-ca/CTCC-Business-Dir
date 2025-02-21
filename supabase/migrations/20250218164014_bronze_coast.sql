-- First ensure we're operating as superuser
SET ROLE postgres;

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Users can read own data" ON auth.users;
DROP POLICY IF EXISTS "Allow users to read own role" ON user_roles;
DROP POLICY IF EXISTS "Allow admins to manage roles" ON user_roles;

-- Create policies with proper names and conditions
CREATE POLICY "Allow users to read own data"
  ON auth.users
  FOR SELECT
  TO authenticated
  USING (id = auth.uid());

CREATE POLICY "Allow users to read roles"
  ON user_roles
  FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

CREATE POLICY "Allow admins to manage roles"
  ON user_roles
  FOR ALL
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

-- Add comments
COMMENT ON POLICY "Allow users to read own data" ON auth.users IS 'Users can only read their own data';
COMMENT ON POLICY "Allow users to read roles" ON user_roles IS 'Users can read their own role, admins can read all roles';
COMMENT ON POLICY "Allow admins to manage roles" ON user_roles IS 'Only admins can manage roles';