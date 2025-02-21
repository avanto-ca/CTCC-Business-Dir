-- Create function to generate SEO metadata
CREATE OR REPLACE FUNCTION generate_seo_metadata()
RETURNS TRIGGER AS $$
DECLARE
  category_name text;
  category_tags text[];
  category_desc text;
  business_name text;
  city text;
BEGIN
  -- Get category information
  SELECT name, seo_tags, description 
  INTO category_name, category_tags, category_desc
  FROM categories 
  WHERE id = NEW.category_id;

  -- Get business name
  business_name := COALESCE(NEW."Name", NEW."Firstname" || ' ' || NEW."Lastname");

  -- Extract city from address
  city := COALESCE(
    (regexp_matches(NEW.address, ',[^,]*,[^,]*$'))[1],
    'Toronto'
  );
  city := trim(both ' ,' from city);

  -- Generate rich keywords
  category_tags := array_cat(
    category_tags,
    ARRAY[
      business_name,
      city,
      'Tamil business',
      'CTCC member',
      'Canadian Tamil Chamber of Commerce'
    ]
  );

  -- Insert SEO metadata
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
  ) VALUES (
    NEW.id,
    business_name || ' - ' || category_name || ' | CTCC Directory',
    substring(
      CASE 
        WHEN NEW.aboutus IS NOT NULL AND NEW.aboutus != '' THEN 
          NEW.aboutus
        ELSE 
          business_name || ' provides professional ' || 
          lower(regexp_replace(category_name, '([A-Z])', ' \1', 'g')) || 
          ' services in ' || city || '. ' || category_desc
      END
      from 1 for 160
    ),
    category_tags,
    business_name || ' | CTCC Business Directory',
    substring(
      CASE 
        WHEN NEW.aboutus IS NOT NULL AND NEW.aboutus != '' THEN 
          NEW.aboutus
        ELSE 
          'Connect with ' || business_name || ', a trusted ' || 
          regexp_replace(category_name, '([A-Z])', ' \1', 'g') || 
          ' professional in ' || city || '. CTCC member.'
      END
      from 1 for 160
    ),
    business_name || ' | CTCC Directory',
    substring(
      CASE 
        WHEN NEW.aboutus IS NOT NULL AND NEW.aboutus != '' THEN 
          NEW.aboutus
        ELSE 
          'Professional ' || lower(regexp_replace(category_name, '([A-Z])', ' \1', 'g')) || 
          ' services by ' || business_name || ' in ' || city || '. CTCC member.'
      END
      from 1 for 160
    ),
    COALESCE(
      NEW.aboutus,
      'Professional ' || lower(regexp_replace(category_name, '([A-Z])', ' \1', 'g')) || 
      ' services provided by ' || business_name || ' in ' || city || '. ' || 
      category_desc
    )
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for automatic SEO metadata generation
DROP TRIGGER IF EXISTS generate_seo_metadata_trigger ON members;
CREATE TRIGGER generate_seo_metadata_trigger
  AFTER INSERT ON members
  FOR EACH ROW
  EXECUTE FUNCTION generate_seo_metadata();

-- Add comments
COMMENT ON FUNCTION generate_seo_metadata IS 'Automatically generates SEO metadata when a new member is created';
COMMENT ON TRIGGER generate_seo_metadata_trigger ON members IS 'Trigger to generate SEO metadata on member creation';