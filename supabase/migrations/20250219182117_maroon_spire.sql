-- Add WhatsApp column to members table
ALTER TABLE members
ADD COLUMN whatsapp text;

-- Add comment
COMMENT ON COLUMN members.whatsapp IS 'WhatsApp number with country code (e.g., +1234567890)';