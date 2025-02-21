/*
  # Fix column names case sensitivity
  
  1. Changes
    - Drop existing columns with incorrect casing
    - Add new columns with proper casing
    - Copy data to new columns
    - Drop old columns
    
  2. Security
    - Maintains existing RLS policies
*/

-- First, check if the properly cased columns already exist
DO $$ 
BEGIN
  -- Only add new columns if they don't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'members' AND column_name = 'Firstname'
  ) THEN
    ALTER TABLE members ADD COLUMN "Firstname" text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'members' AND column_name = 'Lastname'
  ) THEN
    ALTER TABLE members ADD COLUMN "Lastname" text;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'members' AND column_name = 'Name'
  ) THEN
    ALTER TABLE members ADD COLUMN "Name" text;
  END IF;
END $$;

-- Copy data from old columns to new ones
UPDATE members 
SET 
  "Firstname" = firstname,
  "Lastname" = lastname,
  "Name" = name;

-- Drop old columns if they exist
DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'members' AND column_name = 'firstname'
  ) THEN
    ALTER TABLE members DROP COLUMN firstname;
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'members' AND column_name = 'lastname'
  ) THEN
    ALTER TABLE members DROP COLUMN lastname;
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'members' AND column_name = 'name'
  ) THEN
    ALTER TABLE members DROP COLUMN name;
  END IF;
END $$;

-- Add comment explaining casing convention
COMMENT ON TABLE members IS 'Member profiles with proper column casing (Firstname, Lastname, Name)';