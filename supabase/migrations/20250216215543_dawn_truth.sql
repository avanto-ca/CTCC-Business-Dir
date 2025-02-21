/*
  # Fix user roles and policies

  1. Changes
    - Drop and recreate user_roles table with proper constraints
    - Add RLS policies for user roles
    - Create admin user with proper role assignment
    - Add indexes for performance

  2. Security
    - Enable RLS on user_roles table
    - Add policies for role-based access
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

-- Add policies
CREATE POLICY "Allow users to read their own role"
  ON user_roles
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

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

-- Create admin user if not exists
DO $$
DECLARE
  admin_uid uuid;
BEGIN
  -- Try to find existing admin user first
  SELECT id INTO admin_uid
  FROM auth.users
  WHERE email = 'admin@ctcc.ca';

  -- Only create if doesn't exist
  IF admin_uid IS NULL THEN
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
      updated_at
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
      NOW()
    )
    RETURNING id INTO admin_uid;
  END IF;

  -- Assign admin role if we have a user ID
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