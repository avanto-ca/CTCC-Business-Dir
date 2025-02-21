/*
  # Fix SEO metadata constraints and content

  1. Changes
    - Adjust description generation to meet length requirements
    - Ensure proper keyword count
    - Add fallback descriptions
    
  2. Security
    - Maintain existing RLS policies
*/

-- First, clear existing metadata to prevent constraint violations
TRUNCATE TABLE seo_metadata;

-- Insert SEO metadata with properly formatted content
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
  -- Title (10-60 chars)
  CASE 
    WHEN m."Name" IS NOT NULL THEN 
      substring(m."Name" || ' - Professional Services | CTCC Directory' from 1 for 60)
    ELSE 
      substring(m."Firstname" || ' ' || m."Lastname" || ' - Professional Services | CTCC Directory' from 1 for 60)
  END as title,
  
  -- Description (50-160 chars)
  CASE 
    WHEN m.aboutus IS NOT NULL AND length(m.aboutus) > 50 THEN 
      substring(m.aboutus from 1 for 157) || '...'
    WHEN m.aboutus IS NOT NULL AND length(m.aboutus) >= 50 AND length(m.aboutus) <= 160 THEN 
      m.aboutus
    ELSE 
      'Professional ' || c.name || ' services provided by ' || 
      COALESCE(m."Name", m."Firstname" || ' ' || m."Lastname") || 
      ' in ' || split_part(m.address, ',', 2) || '. Member of CTCC.'
  END as description,
  
  -- Keywords (3-20 items)
  ARRAY[
    COALESCE(m."Name", m."Firstname" || ' ' || m."Lastname"),
    split_part(m.address, ',', 2),
    'CTCC member',
    'Tamil business',
    'professional services',
    c.name,
    'Canadian Tamil Chamber of Commerce'
  ] || c.seo_tags[1:13] as keywords,
  
  -- Social media titles
  CASE 
    WHEN m."Name" IS NOT NULL THEN 
      substring(m."Name" || ' | CTCC Business Directory' from 1 for 60)
    ELSE 
      substring(m."Firstname" || ' ' || m."Lastname" || ' | CTCC Business Directory' from 1 for 60)
  END as og_title,
  
  -- Social media descriptions
  CASE 
    WHEN m.aboutus IS NOT NULL AND length(m.aboutus) > 50 THEN 
      substring(m.aboutus from 1 for 157) || '...'
    WHEN m.aboutus IS NOT NULL AND length(m.aboutus) >= 50 AND length(m.aboutus) <= 160 THEN 
      m.aboutus
    ELSE 
      'Connect with ' || COALESCE(m."Name", m."Firstname" || ' ' || m."Lastname") || 
      ', a trusted ' || c.name || ' professional in ' || split_part(m.address, ',', 2) || 
      '. CTCC member.'
  END as og_description,
  
  CASE 
    WHEN m."Name" IS NOT NULL THEN 
      substring(m."Name" || ' | CTCC Directory' from 1 for 60)
    ELSE 
      substring(m."Firstname" || ' ' || m."Lastname" || ' | CTCC Directory' from 1 for 60)
  END as twitter_title,
  
  CASE 
    WHEN m.aboutus IS NOT NULL AND length(m.aboutus) > 50 THEN 
      substring(m.aboutus from 1 for 157) || '...'
    WHEN m.aboutus IS NOT NULL AND length(m.aboutus) >= 50 AND length(m.aboutus) <= 160 THEN 
      m.aboutus
    ELSE 
      'Professional ' || c.name || ' services by ' || 
      COALESCE(m."Name", m."Firstname" || ' ' || m."Lastname") || 
      ' in ' || split_part(m.address, ',', 2) || '. CTCC member.'
  END as twitter_description,
  
  -- Schema description (no length limit)
  COALESCE(
    m.aboutus,
    'Professional ' || c.name || ' services provided by ' || 
    COALESCE(m."Name", m."Firstname" || ' ' || m."Lastname") || 
    ' in ' || split_part(m.address, ',', 2) || '. ' || c.description
  ) as schema_description
FROM members m
JOIN categories c ON m.category_id = c.id
WHERE m."Firstname" IS NOT NULL 
AND m."Lastname" IS NOT NULL;

-- Add comment explaining the metadata structure
COMMENT ON TABLE seo_metadata IS 'SEO metadata for member profiles with proper length constraints and rich content';