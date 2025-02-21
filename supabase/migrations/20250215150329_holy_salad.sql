/*
  # Update aboutus field to support HTML content

  1. Changes
    - Add a new column `aboutus_html` to store HTML content
    - Copy existing aboutus content to the new column
    - Add a comment explaining the HTML support
*/

-- Add new column for HTML content
ALTER TABLE members ADD COLUMN aboutus_html text;

-- Copy existing aboutus content to the new column
UPDATE members SET aboutus_html = aboutus;

-- Add column comment
COMMENT ON COLUMN members.aboutus_html IS 'About us content with HTML support. Content should be sanitized before display.';