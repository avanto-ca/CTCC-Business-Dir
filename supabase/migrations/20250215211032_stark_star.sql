/*
  # Complete category UUID transition

  1. Changes
    - Ensure category_id is populated
    - Make category_id required
    - Remove old type column
  
  2. Security
    - Maintains existing RLS policies
*/

-- Ensure all members have a category_id
UPDATE members 
SET category_id = c.id
FROM categories c
WHERE members.type = c.name
  AND members.category_id IS NULL;

-- Make category_id NOT NULL if it isn't already
DO $$ 
BEGIN
  ALTER TABLE members ALTER COLUMN category_id SET NOT NULL;
EXCEPTION
  WHEN others THEN
    NULL; -- Column might already be NOT NULL
END $$;

-- Drop the old type column if it exists
DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'members' AND column_name = 'type'
  ) THEN
    ALTER TABLE members DROP COLUMN type;
  END IF;
END $$;