-- Add proper error handling for realtor profile lookups
CREATE OR REPLACE FUNCTION get_realtor_profile(member_id integer)
RETURNS TABLE (
  id uuid,
  realtor_id text,
  realtor_url text
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT rp.id, rp.realtor_id, rp.realtor_url
  FROM realtor_profiles rp
  WHERE rp.member_id = $1;
  
  -- If no rows returned, return null values
  IF NOT FOUND THEN
    RETURN QUERY SELECT NULL::uuid, NULL::text, NULL::text;
  END IF;
END;
$$;

-- Add comment
COMMENT ON FUNCTION get_realtor_profile IS 'Safely retrieves realtor profile with proper null handling';