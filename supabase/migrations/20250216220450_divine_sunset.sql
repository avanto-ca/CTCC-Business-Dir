/*
  # Add Yoga admin user

  1. Changes
    - Create new admin user for yoga@avanto.ca
    - Assign admin role
*/

-- Create admin user with proper error handling
DO $$
DECLARE
  yoga_uid uuid;
BEGIN
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
    'yoga@avanto.ca',
    crypt('CTCC2025Admin!', gen_salt('bf')),
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{"name": "Yoga Admin"}',
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
  RETURNING id INTO yoga_uid;

  -- Assign admin role
  IF yoga_uid IS NOT NULL THEN
    INSERT INTO user_roles (user_id, role)
    VALUES (yoga_uid, 'admin')
    ON CONFLICT (user_id) DO NOTHING;
  END IF;
END $$;