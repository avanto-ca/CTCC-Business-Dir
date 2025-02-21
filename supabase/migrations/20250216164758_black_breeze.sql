/*
  # Add business name to contact submissions

  1. Changes
    - Add business_name column to store the member's name from the URL
    - Add index for better query performance
    - Update comments for clarity

  2. Security
    - Maintain existing RLS policies
*/

-- Add business_name column if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'contact_submissions' AND column_name = 'business_name'
  ) THEN
    ALTER TABLE contact_submissions 
      ADD COLUMN business_name text;
  END IF;
END $$;

-- Add index for better query performance
CREATE INDEX IF NOT EXISTS idx_contact_submissions_business_name 
  ON contact_submissions(business_name);

-- Update table comment
COMMENT ON TABLE contact_submissions IS 'Stores contact form submissions with complete business context';
COMMENT ON COLUMN contact_submissions.business_name IS 'Business name from the URL path (e.g., FirstName-LastName)';