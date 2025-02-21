/*
  # Fix JWT verification and auth schema

  1. Changes
    - Create JWT verification function
    - Set up proper JWT claims handling
    - Add required auth functions
*/

-- Create JWT verification function
CREATE OR REPLACE FUNCTION auth.jwt()
RETURNS jsonb
LANGUAGE sql
STABLE
AS $$
  SELECT COALESCE(
    nullif(current_setting('request.jwt.claim', true), ''),
    '{}'
  )::jsonb;
$$;

-- Create function to get JWT claim
CREATE OR REPLACE FUNCTION auth.uid()
RETURNS uuid
LANGUAGE sql
STABLE
AS $$
  SELECT COALESCE(
    (auth.jwt() ->> 'sub')::uuid,
    '00000000-0000-0000-0000-000000000000'::uuid
  );
$$;

-- Create function to check if user is authenticated
CREATE OR REPLACE FUNCTION auth.role()
RETURNS text
LANGUAGE sql
STABLE
AS $$
  SELECT COALESCE(
    current_setting('request.jwt.claim.role', true),
    'anon'
  )::text;
$$;

-- Create function to get current user with proper error handling
CREATE OR REPLACE FUNCTION auth.current_user()
RETURNS auth.users
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT users.* FROM auth.users
  WHERE id = (
    SELECT NULLIF(auth.uid()::text, '00000000-0000-0000-0000-000000000000')::uuid
  );
$$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION auth.jwt TO authenticated;
GRANT EXECUTE ON FUNCTION auth.uid TO authenticated;
GRANT EXECUTE ON FUNCTION auth.role TO authenticated;
GRANT EXECUTE ON FUNCTION auth.current_user TO authenticated;

-- Add comments
COMMENT ON FUNCTION auth.jwt IS 'Gets the JWT claims from the current request';
COMMENT ON FUNCTION auth.uid IS 'Gets the user ID from the JWT';
COMMENT ON FUNCTION auth.role IS 'Gets the user role from the JWT';
COMMENT ON FUNCTION auth.current_user IS 'Gets the current authenticated user';