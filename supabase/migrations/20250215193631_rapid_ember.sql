/*
  # Fix column names case sensitivity
  
  1. Changes
    - Create new columns with proper casing
    - Copy data from existing columns
    - Drop old columns
    
  2. Security
    - Maintains existing RLS policies
*/

-- Create new columns with proper casing
ALTER TABLE members 
  ADD COLUMN IF NOT EXISTS "Firstname" text,
  ADD COLUMN IF NOT EXISTS "Lastname" text,
  ADD COLUMN IF NOT EXISTS "Name" text;

-- Copy data from existing columns to new ones if they exist
DO $$ 
BEGIN
  -- Update Firstname if old column exists
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'members' AND column_name = 'firstname'
  ) THEN
    UPDATE members SET "Firstname" = firstname;
  END IF;

  -- Update Lastname if old column exists
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'members' AND column_name = 'lastname'
  ) THEN
    UPDATE members SET "Lastname" = lastname;
  END IF;

  -- Update Name if old column exists
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'members' AND column_name = 'name'
  ) THEN
    UPDATE members SET "Name" = name;
  END IF;
END $$;

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