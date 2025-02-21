/*
  # Fix column names for member profiles
  
  1. Changes
    - Rename columns to use proper casing
    - Update existing data to match new column names
    
  2. Security
    - Maintains existing RLS policies
*/

-- Rename columns to use proper casing
ALTER TABLE members 
  RENAME COLUMN firstname TO "Firstname",
  RENAME COLUMN lastname TO "Lastname",
  RENAME COLUMN name TO "Name";

-- Add comment explaining casing convention
COMMENT ON TABLE members IS 'Member profiles with proper column casing (Firstname, Lastname, Name)';