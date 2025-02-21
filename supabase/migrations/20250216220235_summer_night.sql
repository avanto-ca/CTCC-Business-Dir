/*
  # Fix auth schema and admin login

  1. Changes
    - Ensure auth schema exists
    - Create admin user with proper schema
    - Fix role-based access control
*/

-- First ensure auth schema exists
CREATE SCHEMA IF NOT EXISTS auth;

-- Create admin user with proper error handling
DO $$
DECLARE
  admin_uid uuid;
BEGIN
  -- First, remove any existing admin user
  DELETE FROM auth.users WHERE email = 'admin@ctcc.ca';
  
  -- Create new admin user with minimal required fields
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

-- Ensure proper indexes exist
CREATE INDEX IF NOT EXISTS users_email_idx ON auth.users(email);
CREATE INDEX IF NOT EXISTS users_instance_id_idx ON auth.users(instance_id);

-- Add comments
COMMENT ON SCHEMA auth IS 'Auth schema for user authentication';
COMMENT ON TABLE auth.users IS 'Auth users table with proper schema';