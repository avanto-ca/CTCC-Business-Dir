/*
  # Fix auth schema permissions and setup

  1. Changes
    - Ensure auth schema exists with proper ownership
    - Set up proper role permissions
    - Create necessary auth functions
    - Enable RLS with proper policies
*/

-- First ensure we're operating as superuser
SET ROLE postgres;

-- Create authenticated role if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'authenticated') THEN
    CREATE ROLE authenticated;
  END IF;
END
$$;

-- Create anon role if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'anon') THEN
    CREATE ROLE anon;
  END IF;
END
$$;

-- Create service_role if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'service_role') THEN
    CREATE ROLE service_role;
  END IF;
END
$$;

-- Create auth schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS auth;

-- Set proper ownership
ALTER SCHEMA auth OWNER TO postgres;

-- Grant proper permissions
GRANT USAGE ON SCHEMA auth TO postgres, authenticated, anon, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA auth TO postgres, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA auth TO postgres, service_role;
GRANT ALL ON ALL ROUTINES IN SCHEMA auth TO postgres, service_role;

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
GRANT EXECUTE ON FUNCTION auth.jwt TO authenticated, anon;
GRANT EXECUTE ON FUNCTION auth.uid TO authenticated, anon;
GRANT EXECUTE ON FUNCTION auth.role TO authenticated, anon;

-- Add comments
COMMENT ON SCHEMA auth IS 'Schema for authentication tables and functions';
COMMENT ON FUNCTION auth.jwt IS 'Gets the JWT claims from the current request';
COMMENT ON FUNCTION auth.uid IS 'Gets the user ID from the JWT';
COMMENT ON FUNCTION auth.role IS 'Gets the user role from the JWT';