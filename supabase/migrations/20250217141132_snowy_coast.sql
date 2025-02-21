/*
  # Fix auth schema permissions

  1. Changes
    - Ensure postgres role has proper permissions
    - Set correct schema ownership
    - Grant necessary permissions to roles
    - Fix function permissions
*/

-- First ensure we're operating as superuser
SET ROLE postgres;

-- Create required roles if they don't exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'authenticated') THEN
    CREATE ROLE authenticated;
  END IF;

  IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'anon') THEN
    CREATE ROLE anon;
  END IF;

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
GRANT ALL ON ALL TABLES IN SCHEMA auth TO postgres;
GRANT ALL ON ALL SEQUENCES IN SCHEMA auth TO postgres;
GRANT ALL ON ALL ROUTINES IN SCHEMA auth TO postgres;

-- Grant service role permissions
GRANT ALL ON ALL TABLES IN SCHEMA auth TO service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA auth TO service_role;
GRANT ALL ON ALL ROUTINES IN SCHEMA auth TO service_role;

-- Grant authenticated and anon permissions
GRANT USAGE ON SCHEMA auth TO authenticated, anon;
GRANT SELECT ON ALL TABLES IN SCHEMA auth TO authenticated, anon;
GRANT EXECUTE ON FUNCTION auth.jwt() TO authenticated, anon;
GRANT EXECUTE ON FUNCTION auth.uid() TO authenticated, anon;
GRANT EXECUTE ON FUNCTION auth.role() TO authenticated, anon;

-- Ensure all auth tables are owned by postgres
DO $$
DECLARE
  table_name text;
BEGIN
  FOR table_name IN (SELECT tablename FROM pg_tables WHERE schemaname = 'auth')
  LOOP
    EXECUTE format('ALTER TABLE auth.%I OWNER TO postgres', table_name);
  END LOOP;
END
$$;

-- Ensure all auth functions are owned by postgres
DO $$
DECLARE
  function_name text;
BEGIN
  FOR function_name IN (
    SELECT p.proname 
    FROM pg_proc p 
    JOIN pg_namespace n ON p.pronamespace = n.oid 
    WHERE n.nspname = 'auth'
  )
  LOOP
    EXECUTE format('ALTER FUNCTION auth.%I() OWNER TO postgres', function_name);
  END LOOP;
END
$$;

-- Add comments
COMMENT ON SCHEMA auth IS 'Schema for authentication with proper ownership and permissions';