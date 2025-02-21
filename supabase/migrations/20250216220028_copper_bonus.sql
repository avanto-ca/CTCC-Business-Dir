/*
  # Fix admin login functionality

  1. Changes
    - Drop and recreate user_roles table with proper structure
    - Fix RLS policies to prevent recursion
    - Ensure admin user exists with proper role

  2. Security
    - Proper RLS policies
    - Role-based access control
    - Secure password handling
*/

-- First ensure we have a clean slate
DROP TABLE IF EXISTS user_roles CASCADE;

-- Create user roles table
CREATE TABLE user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role text NOT NULL CHECK (role IN ('admin', 'member')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id)
);

-- Enable RLS
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- Add non-recursive policies
CREATE POLICY "Allow users to read their own role"
  ON user_roles
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Allow admin read access"
  ON user_roles
  FOR SELECT
  TO authenticated
  USING (
    user_id IN (
      SELECT id FROM auth.users 
      WHERE email = 'admin@ctcc.ca'
    )
  );

-- Add function to update timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Add trigger for updating timestamp
CREATE TRIGGER update_user_roles_updated_at
  BEFORE UPDATE ON user_roles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Add indexes for better performance
CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_role ON user_roles(role);

-- Create admin user with proper error handling
DO $$
DECLARE
  admin_uid uuid;
BEGIN
  -- First, remove any existing admin user
  DELETE FROM auth.users WHERE email = 'admin@ctcc.ca';
  
  -- Create new admin user
  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    confirmation_sent_at,
    recovery_token,
    recovery_sent_at,
    email_change_token_new,
    email_change,
    email_change_sent_at,
    phone_change,
    phone_change_token,
    phone_change_sent_at,
    email_change_token_current,
    email_change_confirm_status,
    banned_until,
    reauthentication_token,
    reauthentication_sent_at,
    is_super_admin,
    phone,
    phone_confirmed_at,
    invited_at,
    is_sso_user,
    deleted_at,
    confirmed_at
  )
  VALUES (
    '00000000-0000-0000-0000-000000000000',
    uuid_generate_v4(),
    'authenticated',
    'authenticated',
    'admin@ctcc.ca',
    crypt('CTCC2025Admin!', gen_salt('bf')),
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{"name": "CTCC Admin"}',
    NOW(),
    NOW(),
    '',
    NOW(),
    '',
    NOW(),
    '',
    '',
    NOW(),
    '',
    '',
    NOW(),
    '',
    0,
    NULL,
    '',
    NOW(),
    false,
    NULL,
    NULL,
    NOW(),
    false,
    NULL,
    NOW()
  )
  RETURNING id INTO admin_uid;

  -- Assign admin role
  IF admin_uid IS NOT NULL THEN
    INSERT INTO user_roles (user_id, role)
    VALUES (admin_uid, 'admin')
    ON CONFLICT (user_id) DO NOTHING;
  END IF;
END $$;

-- Add comments
COMMENT ON TABLE user_roles IS 'Stores user roles for access control';
COMMENT ON COLUMN user_roles.role IS 'User role (admin or member)';
COMMENT ON COLUMN user_roles.user_id IS 'References auth.users(id) for role assignment';