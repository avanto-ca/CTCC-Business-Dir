-- Create function to handle missing SEO metadata
CREATE OR REPLACE FUNCTION get_member_seo_metadata(member_id integer)
RETURNS TABLE (
  id uuid,
  title text,
  description text,
  keywords text[],
  og_title text,
  og_description text,
  twitter_title text,
  twitter_description text,
  schema_description text
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.id,
    s.title,
    s.description,
    s.keywords,
    s.og_title,
    s.og_description,
    s.twitter_title,
    s.twitter_description,
    s.schema_description
  FROM seo_metadata s
  WHERE s.member_id = $1;
  
  -- If no rows returned, return null values
  IF NOT FOUND THEN
    RETURN QUERY SELECT 
      NULL::uuid,
      NULL::text,
      NULL::text,
      NULL::text[],
      NULL::text,
      NULL::text,
      NULL::text,
      NULL::text,
      NULL::text;
  END IF;
END;
$$;

-- Add comment
COMMENT ON FUNCTION get_member_seo_metadata IS 'Safely retrieves SEO metadata with proper null handling';