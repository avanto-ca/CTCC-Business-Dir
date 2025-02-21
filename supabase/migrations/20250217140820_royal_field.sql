/*
  # Fix auth schema permissions

  1. Changes
    - Grant necessary permissions to auth schema
    - Create required roles and grant permissions
    - Set up proper RLS policies
*/

-- Create authenticated role if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'authenticated') THEN
    CREATE ROLE authenticated;
  END IF;
END
$$;

-- Grant necessary permissions
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA auth TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA auth TO authenticated;

-- Create or replace auth functions
CREATE OR REPLACE FUNCTION auth.jwt()
RETURNS jsonb
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(
    nullif(current_setting('request.jwt.claim', true), ''),
    '{}'
  )::jsonb;
$$;

CREATE OR REPLACE FUNCTION auth.uid()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(
    (auth.jwt() ->> 'sub')::uuid,
    '00000000-0000-0000-0000-000000000000'::uuid
  );
$$;

CREATE OR REPLACE FUNCTION auth.role()
RETURNS text
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(
    current_setting('request.jwt.claim.role', true),
    'anon'
  )::text;
$$;

-- Grant execute permissions on functions
GRANT EXECUTE ON FUNCTION auth.jwt TO authenticated;
GRANT EXECUTE ON FUNCTION auth.uid TO authenticated;
GRANT EXECUTE ON FUNCTION auth.role TO authenticated;

-- Create or replace RLS policies
DO $$
BEGIN
  -- Drop existing policies if they exist
  DROP POLICY IF EXISTS "Users can access own data" ON auth.users;
  DROP POLICY IF EXISTS "Users can access own identities" ON auth.identities;
  DROP POLICY IF EXISTS "Users can access own sessions" ON auth.sessions;
  
  -- Create new policies
  CREATE POLICY "Users can access own data"
    ON auth.users
    FOR SELECT
    TO authenticated
    USING (id = auth.uid());

  CREATE POLICY "Users can access own identities"
    ON auth.identities
    FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

  CREATE POLICY "Users can access own sessions"
    ON auth.sessions
    FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());
END
$$;

-- Add comments
COMMENT ON FUNCTION auth.jwt IS 'Gets the JWT claims from the current request';
COMMENT ON FUNCTION auth.uid IS 'Gets the user ID from the JWT';
COMMENT ON FUNCTION auth.role IS 'Gets the user role from the JWT';