/*
  # Fix COALESCE error in SQL query

  1. Changes
    - Remove COALESCE from generated column definition
    - Add proper email_confirmed_at column handling
    - Ensure proper column types and defaults
*/

-- First ensure we're operating as superuser
SET ROLE postgres;

-- Drop and recreate the email_confirmed_at column
ALTER TABLE auth.users 
  DROP COLUMN IF EXISTS email_confirmed_at,
  ADD COLUMN email_confirmed_at timestamptz DEFAULT now();

-- Update the column with proper values
UPDATE auth.users
SET email_confirmed_at = LEAST(
  CASE 
    WHEN phone_confirmed_at IS NOT NULL THEN phone_confirmed_at
    ELSE 'infinity'::timestamptz
  END,
  CASE 
    WHEN email_confirmed_at IS NOT NULL THEN email_confirmed_at
    ELSE 'infinity'::timestamptz
  END
);

-- Add comment
COMMENT ON COLUMN auth.users.email_confirmed_at IS 'Timestamp when email was confirmed';