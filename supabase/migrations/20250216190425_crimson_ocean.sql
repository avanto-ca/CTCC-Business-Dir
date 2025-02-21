/*
  # Add test SEO metadata and improve structure
  
  1. Changes
    - Add test SEO metadata entries
    - Add indexes for performance
    - Add validation constraints
    
  2. Security
    - Maintain existing RLS policies
    - Add row-level validation
*/

-- Add check constraints for SEO fields
ALTER TABLE seo_metadata
  ADD CONSTRAINT seo_title_length CHECK (char_length(title) BETWEEN 10 AND 60),
  ADD CONSTRAINT seo_description_length CHECK (char_length(description) BETWEEN 50 AND 160),
  ADD CONSTRAINT seo_keywords_count CHECK (array_length(keywords, 1) BETWEEN 3 AND 20);

-- Add composite index for member lookup with timestamp
CREATE INDEX idx_seo_metadata_member_updated 
ON seo_metadata(member_id, updated_at DESC);

-- Insert test SEO metadata for existing members
INSERT INTO seo_metadata (
  member_id,
  title,
  description,
  keywords,
  og_title,
  og_description,
  twitter_title,
  twitter_description,
  schema_description
)
SELECT 
  m.id,
  CASE 
    WHEN m."Name" IS NOT NULL THEN m."Name" || ' - Professional Services | CTCC Directory'
    ELSE m."Firstname" || ' ' || m."Lastname" || ' - Professional Services | CTCC Directory'
  END as title,
  CASE 
    WHEN m.aboutus IS NOT NULL THEN 
      substring(m.aboutus from 1 for 155) || '...'
    ELSE 
      'Professional services provided by ' || 
      COALESCE(m."Name", m."Firstname" || ' ' || m."Lastname") || 
      ' in ' || split_part(m.address, ',', 2)
  END as description,
  ARRAY[
    COALESCE(m."Name", m."Firstname" || ' ' || m."Lastname"),
    split_part(m.address, ',', 2),
    'CTCC member',
    'Tamil business',
    'professional services'
  ] as keywords,
  CASE 
    WHEN m."Name" IS NOT NULL THEN m."Name" || ' | CTCC Business Directory'
    ELSE m."Firstname" || ' ' || m."Lastname" || ' | CTCC Business Directory'
  END as og_title,
  CASE 
    WHEN m.aboutus IS NOT NULL THEN 
      substring(m.aboutus from 1 for 155) || '...'
    ELSE 
      'Connect with ' || COALESCE(m."Name", m."Firstname" || ' ' || m."Lastname") || 
      ' through the CTCC Business Directory'
  END as og_description,
  CASE 
    WHEN m."Name" IS NOT NULL THEN m."Name" || ' | CTCC Directory'
    ELSE m."Firstname" || ' ' || m."Lastname" || ' | CTCC Directory'
  END as twitter_title,
  CASE 
    WHEN m.aboutus IS NOT NULL THEN 
      substring(m.aboutus from 1 for 155) || '...'
    ELSE 
      'Professional services by ' || COALESCE(m."Name", m."Firstname" || ' ' || m."Lastname") || 
      ' in ' || split_part(m.address, ',', 2)
  END as twitter_description,
  COALESCE(m.aboutus, 
    'Professional services provided by ' || 
    COALESCE(m."Name", m."Firstname" || ' ' || m."Lastname") || 
    ' in ' || split_part(m.address, ',', 2)
  ) as schema_description
FROM members m
WHERE NOT EXISTS (
  SELECT 1 FROM seo_metadata s WHERE s.member_id = m.id
)
AND m."Firstname" IS NOT NULL 
AND m."Lastname" IS NOT NULL;

-- Add comment explaining the SEO metadata structure
COMMENT ON TABLE seo_metadata IS 'SEO metadata for member profiles with length constraints and validation';