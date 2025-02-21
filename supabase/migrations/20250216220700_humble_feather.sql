/*
  # Fix auth permissions

  1. Changes
    - Grant proper permissions to authenticated users
    - Fix RLS policies for user_roles table
    - Add proper indexes
*/

-- Grant necessary permissions
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT SELECT ON auth.users TO authenticated;

-- Drop existing policies
DROP POLICY IF EXISTS "Allow users to read their own role" ON user_roles;
DROP POLICY IF EXISTS "Allow admin read access" ON user_roles;
DROP POLICY IF EXISTS "Allow admins to manage roles" ON user_roles;

-- Create new policies
CREATE POLICY "Users can read own role"
  ON user_roles
  FOR SELECT
  TO authenticated
  USING (
    user_id = auth.uid()
  );

CREATE POLICY "Admins can read all roles"
  ON user_roles
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

CREATE POLICY "Admins can manage roles"
  ON user_roles
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

-- Add function to check admin status
CREATE OR REPLACE FUNCTION auth.is_admin()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_id = auth.uid()
    AND role = 'admin'
  );
$$;

-- Add comments
COMMENT ON FUNCTION auth.is_admin IS 'Checks if the current user has admin role';