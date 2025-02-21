/*
  # Fix admin user creation

  1. Changes
    - Drop existing admin user
    - Create new admin user with all required fields
    - Add admin role
    - Add proper RLS policies
*/

-- First drop existing admin user
DO $$
BEGIN
  DELETE FROM auth.users WHERE email = 'admin@ctcc.ca';
  DELETE FROM user_roles WHERE user_id IN (
    SELECT id FROM auth.users WHERE email = 'admin@ctcc.ca'
  );
END $$;

-- Drop existing policy if it exists
DROP POLICY IF EXISTS "Allow admins to manage users" ON auth.users;

-- Create admin user with proper error handling
DO $$
DECLARE
  admin_uid uuid;
BEGIN
  -- Insert admin user
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
    last_sign_in_at,
    is_super_admin,
    phone,
    phone_confirmed_at,
    banned_until,
    invited_at,
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
    reauthentication_token,
    reauthentication_sent_at,
    is_sso_user,
    deleted_at
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
    false,
    NULL,
    NULL,
    NULL,
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
    '',
    NOW(),
    false,
    NULL
  )
  RETURNING id INTO admin_uid;

  -- Assign admin role
  IF admin_uid IS NOT NULL THEN
    INSERT INTO user_roles (user_id, role)
    VALUES (admin_uid, 'admin')
    ON CONFLICT (user_id) DO NOTHING;
  END IF;
END $$;

-- Create new policy for admin access
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