/*
  # Fix JWT verification and user lookup

  1. Changes
    - Add proper JWT verification
    - Fix user lookup
    - Add necessary indexes
*/

-- Enable JWT verification
ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

-- Create policy for JWT verification
CREATE POLICY "Users can access own data via JWT"
  ON auth.users
  FOR SELECT
  TO authenticated
  USING (
    id = auth.uid()
  );

-- Add function to get current user
CREATE OR REPLACE FUNCTION auth.current_user()
RETURNS auth.users
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT *
  FROM auth.users
  WHERE id = auth.uid();
$$;

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS users_id_idx ON auth.users(id);
CREATE INDEX IF NOT EXISTS users_email_idx ON auth.users(email);

-- Grant necessary permissions
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT SELECT ON auth.users TO authenticated;
GRANT EXECUTE ON FUNCTION auth.current_user TO authenticated;

-- Add comments
COMMENT ON FUNCTION auth.current_user IS 'Gets the current authenticated user';