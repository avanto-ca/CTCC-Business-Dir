-- Add social media columns to members table
ALTER TABLE members
ADD COLUMN facebook text,
ADD COLUMN linkedin text,
ADD COLUMN twitter text,
ADD COLUMN instagram text;

-- Add comments
COMMENT ON COLUMN members.facebook IS 'Facebook profile URL';
COMMENT ON COLUMN members.linkedin IS 'LinkedIn profile URL';
COMMENT ON COLUMN members.twitter IS 'Twitter profile URL';
COMMENT ON COLUMN members.instagram IS 'Instagram profile URL';