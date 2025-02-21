/*
  # Add aboutus_html column to members table

  1. Changes
    - Add aboutus_html column to members table
    - Update existing records with formatted HTML content
*/

-- Add aboutus_html column if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'members' AND column_name = 'aboutus_html'
  ) THEN
    ALTER TABLE members ADD COLUMN aboutus_html text;
  END IF;
END $$;

-- Update existing records with formatted HTML content
UPDATE members
SET aboutus_html = CASE
  WHEN aboutus IS NOT NULL AND aboutus != '' THEN 
    '<div class="space-y-4"><p>' || aboutus || '</p></div>'
  ELSE NULL
END
WHERE aboutus IS NOT NULL;

-- Add comment
COMMENT ON COLUMN members.aboutus_html IS 'HTML-formatted about us content with proper styling';