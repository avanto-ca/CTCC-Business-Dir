/*
  # Add initials-based avatars for community members
  
  1. Schema Changes
    - Add function to generate initials from name
    - Update avatar handling for community members
    
  2. Security
    - Maintains existing RLS policies
*/

-- Create function to generate initials from name
CREATE OR REPLACE FUNCTION get_name_initials(full_name text)
RETURNS text
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  words text[];
  initials text := '';
BEGIN
  -- Split name into words
  words := regexp_split_to_array(trim(full_name), '\s+');
  
  -- Get first letter of first word
  IF array_length(words, 1) >= 1 THEN
    initials := initials || upper(left(words[1], 1));
  END IF;
  
  -- Get first letter of last word if different from first
  IF array_length(words, 1) >= 2 THEN
    initials := initials || upper(left(words[array_length(words, 1)], 1));
  END IF;
  
  RETURN initials;
END;
$$;

-- Add comment
COMMENT ON FUNCTION get_name_initials IS 'Generates initials from a full name (e.g., "John Smith" -> "JS")';