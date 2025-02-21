/*
  # Update contact submissions table

  1. Changes
    - Add business_url and category columns
    - Add indexes for better performance
    - Update comments for clarity

  2. Security
    - Maintain existing RLS policies
*/

-- Add new columns if they don't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'contact_submissions' AND column_name = 'business_url'
  ) THEN
    ALTER TABLE contact_submissions 
      ADD COLUMN business_url text,
      ADD COLUMN category text;
  END IF;
END $$;

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_contact_submissions_category 
  ON contact_submissions(category);

CREATE INDEX IF NOT EXISTS idx_contact_submissions_business_url 
  ON contact_submissions(business_url);

-- Update table comment
COMMENT ON TABLE contact_submissions IS 'Stores contact form submissions with complete business context';
COMMENT ON COLUMN contact_submissions.business_url IS 'Full URL of the business profile where the submission originated';
COMMENT ON COLUMN contact_submissions.category IS 'Business category name from the URL path';