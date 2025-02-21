-- First ensure we're operating as superuser
SET ROLE postgres;

-- Create required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create auth schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS auth;

-- Create auth.users table if it doesn't exist
CREATE TABLE IF NOT EXISTS auth.users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE,
  encrypted_password text,
  email_confirmed_at timestamptz DEFAULT now(),
  last_sign_in_at timestamptz,
  raw_app_meta_data jsonb DEFAULT '{"provider": "email", "providers": ["email"]}'::jsonb,
  raw_user_meta_data jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  role text DEFAULT 'authenticated',
  aud text DEFAULT 'authenticated'
);

-- Create user_roles table if it doesn't exist
CREATE TABLE IF NOT EXISTS user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role text NOT NULL CHECK (role IN ('admin', 'member')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id)
);

-- Enable RLS
ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to avoid conflicts
DROP POLICY IF EXISTS "Users can read own data" ON auth.users;
DROP POLICY IF EXISTS "Allow users to read own role" ON user_roles;
DROP POLICY IF EXISTS "Allow admins to manage roles" ON user_roles;

-- Create policies
CREATE POLICY "Users can read own data"
  ON auth.users
  FOR SELECT
  TO authenticated
  USING (id = auth.uid());

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

-- Create admin user
DO $$
DECLARE
  admin_uid uuid;
BEGIN
  -- First, remove any existing admin user
  DELETE FROM auth.users WHERE email = 'admin@ctcc.ca';
  DELETE FROM user_roles WHERE user_id IN (
    SELECT id FROM auth.users WHERE email = 'admin@ctcc.ca'
  );
  
  -- Create new admin user with minimal required fields
  INSERT INTO auth.users (
    email,
    encrypted_password,
    raw_user_meta_data
  )
  VALUES (
    'admin@ctcc.ca',
    crypt('CTCC2025Admin!', gen_salt('bf')),
    '{"name": "CTCC Admin"}'
  )
  RETURNING id INTO admin_uid;

  -- Assign admin role
  INSERT INTO user_roles (user_id, role)
  VALUES (admin_uid, 'admin');
END $$;

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS users_email_idx ON auth.users(email);
CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_roles_role ON user_roles(role);

-- Add comments
COMMENT ON TABLE auth.users IS 'Auth users table with minimal required fields';
COMMENT ON TABLE user_roles IS 'Stores user roles for access control';
COMMENT ON COLUMN user_roles.role IS 'User role (admin or member)';
COMMENT ON COLUMN user_roles.user_id IS 'References auth.users(id) for role assignment';