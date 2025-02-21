/*
  # Update members table to support HTML content in aboutus

  1. Changes
    - Add new column `aboutus_html` to store HTML content
    - Copy existing aboutus content to the new column
    - Add a comment explaining the HTML support

  2. Security
    - No changes to RLS policies needed as this maintains existing read-only access
*/

-- Add new column for HTML content if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'members' AND column_name = 'aboutus_html'
  ) THEN
    ALTER TABLE members ADD COLUMN aboutus_html text;
    
    -- Copy existing aboutus content to the new column
    UPDATE members SET aboutus_html = aboutus;
    
    -- Add column comment
    COMMENT ON COLUMN members.aboutus_html IS 'About us content with HTML support. Content should be sanitized before display.';
  END IF;
END $$;