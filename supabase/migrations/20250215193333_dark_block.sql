/*
  # Fix column names for member profiles
  
  1. Changes
    - Drop existing columns with incorrect casing
    - Add new columns with proper casing
    - Copy data to new columns
    - Drop old columns
    
  2. Security
    - Maintains existing RLS policies
*/

-- Add new columns with proper casing
ALTER TABLE members 
  ADD COLUMN "Firstname" text,
  ADD COLUMN "Lastname" text,
  ADD COLUMN "Name" text;

-- Copy data from old columns to new ones
UPDATE members 
SET 
  "Firstname" = firstname,
  "Lastname" = lastname,
  "Name" = name;

-- Drop old columns
ALTER TABLE members 
  DROP COLUMN firstname,
  DROP COLUMN lastname,
  DROP COLUMN name;

-- Add comment explaining casing convention
COMMENT ON TABLE members IS 'Member profiles with proper column casing (Firstname, Lastname, Name)';