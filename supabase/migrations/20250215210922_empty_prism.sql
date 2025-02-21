/*
  # Update members table to use category UUIDs

  1. Changes
    - Add category_id column to members table
    - Update existing records with correct category UUIDs
    - Add foreign key constraint
    - Drop old type column
  
  2. Security
    - Maintains existing RLS policies
*/

-- First, ensure the category_id column exists
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'members' AND column_name = 'category_id'
  ) THEN
    ALTER TABLE members ADD COLUMN category_id uuid;
  END IF;
END $$;

-- Update members with category IDs
UPDATE members 
SET category_id = c.id
FROM categories c
WHERE members.type = c.name;

-- Add foreign key constraint if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.constraint_column_usage 
    WHERE table_name = 'members' AND column_name = 'category_id'
  ) THEN
    ALTER TABLE members 
      ADD CONSTRAINT fk_member_category_id 
      FOREIGN KEY (category_id) 
      REFERENCES categories(id);
  END IF;
END $$;

-- Make category_id NOT NULL after we've populated it
ALTER TABLE members ALTER COLUMN category_id SET NOT NULL;

-- Drop the old type column
ALTER TABLE members DROP COLUMN type;