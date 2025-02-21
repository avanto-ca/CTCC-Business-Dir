/*
  # Fix logo path handling

  1. Changes
    - Update logo paths to use consistent format
    - Remove duplicate /Logos/ prefixes
  
  2. Security
    - Maintain existing RLS policies
*/

-- Update existing logo paths to use consistent format
UPDATE members
SET logo = 
  CASE 
    WHEN logo LIKE 'http%' THEN logo
    WHEN logo LIKE '/Logos/%' THEN regexp_replace(logo, '^/Logos/', '')
    ELSE logo
  END
WHERE logo IS NOT NULL;

-- Add comment
COMMENT ON TABLE members IS 'Member profiles with normalized logo paths';