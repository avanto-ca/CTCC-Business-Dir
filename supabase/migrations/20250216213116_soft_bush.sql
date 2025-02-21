/*
  # Fix admin user creation

  1. Changes
    - Add unique constraint on email column
    - Create admin user with proper error handling
    - Assign admin role
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