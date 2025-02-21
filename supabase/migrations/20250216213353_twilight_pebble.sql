/*
  # Fix admin user creation and authentication

  1. Changes
    - Add unique constraint on email column
    - Create admin user with proper password hashing
    - Assign admin role
    - Add proper RLS policies
*/

-- First ensure email is unique
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'users_email_key'
  ) THEN
    ALTER TABLE auth.users 
      ADD CONSTRAINT users_email_key UNIQUE (email);
  END IF;
END $$;

-- Create admin user with proper error handling
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
      updated_at,
      confirmation_sent_at,
      confirmed_at,
      last_sign_in_at
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
      NOW(),
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

-- Add RLS policies for admin access
CREATE POLICY "Allow admins to manage users"
  ON auth.users
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

-- Add comment
COMMENT ON TABLE user_roles IS 'Stores user roles including admin access';