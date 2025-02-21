/*
  # Fix auth schema and permissions

  1. Changes
    - Create auth schema with proper structure
    - Add required tables and columns
    - Set up proper permissions
*/

-- Create auth schema if not exists
CREATE SCHEMA IF NOT EXISTS auth;

-- Create auth schema tables if they don't exist
CREATE TABLE IF NOT EXISTS auth.users (
  instance_id uuid,
  id uuid PRIMARY KEY,
  aud varchar(255),
  role varchar(255),
  email varchar(255) UNIQUE,
  encrypted_password varchar(255),
  email_confirmed_at timestamptz DEFAULT now(),
  invited_at timestamptz DEFAULT now(),
  confirmation_token varchar(255),
  confirmation_sent_at timestamptz,
  recovery_token varchar(255),
  recovery_sent_at timestamptz,
  email_change_token_new varchar(255),
  email_change varchar(255),
  email_change_sent_at timestamptz,
  last_sign_in_at timestamptz,
  raw_app_meta_data jsonb,
  raw_user_meta_data jsonb,
  is_super_admin boolean,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  phone varchar(255),
  phone_confirmed_at timestamptz,
  phone_change varchar(255),
  phone_change_token varchar(255),
  phone_change_sent_at timestamptz,
  confirmed_at timestamptz GENERATED ALWAYS AS (
    CASE WHEN email_confirmed_at IS NOT NULL OR phone_confirmed_at IS NOT NULL
    THEN LEAST(COALESCE(email_confirmed_at, 'infinity'::timestamptz), COALESCE(phone_confirmed_at, 'infinity'::timestamptz))
    END
  ) STORED,
  email_change_token_current varchar(255),
  email_change_confirm_status smallint DEFAULT 0,
  banned_until timestamptz,
  reauthentication_token varchar(255),
  reauthentication_sent_at timestamptz,
  is_sso_user boolean DEFAULT false,
  deleted_at timestamptz
);

-- Enable RLS
ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can access own data via JWT"
  ON auth.users
  FOR SELECT
  TO authenticated
  USING (
    id = auth.uid()
  );

-- Add indexes
CREATE INDEX IF NOT EXISTS users_instance_id_idx ON auth.users(instance_id);
CREATE INDEX IF NOT EXISTS users_email_idx ON auth.users(email);
CREATE INDEX IF NOT EXISTS users_id_idx ON auth.users(id);

-- Grant permissions
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT SELECT ON auth.users TO authenticated;
GRANT EXECUTE ON FUNCTION auth.current_user TO authenticated;

-- Add comments
COMMENT ON SCHEMA auth IS 'Auth schema for user authentication';
COMMENT ON TABLE auth.users IS 'Auth users table with proper schema';