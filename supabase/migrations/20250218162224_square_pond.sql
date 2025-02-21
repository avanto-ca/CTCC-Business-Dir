-- First ensure we're operating as superuser
SET ROLE postgres;

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Users can read own role" ON user_roles;
DROP POLICY IF EXISTS "Admins can manage roles" ON user_roles;

-- Create new policies with proper checks
CREATE POLICY "Allow users to read own role"
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

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_role ON user_roles(role);

-- Add comments
COMMENT ON TABLE user_roles IS 'Stores user roles for access control';
COMMENT ON COLUMN user_roles.role IS 'User role (admin or member)';
COMMENT ON COLUMN user_roles.user_id IS 'References auth.users(id) for role assignment';
COMMENT ON POLICY "Allow users to read own role" ON user_roles IS 'Users can read their own role, admins can read all roles';
COMMENT ON POLICY "Allow admins to manage roles" ON user_roles IS 'Only admins can manage roles';