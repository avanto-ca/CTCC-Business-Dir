/*
  # Add avatars for community members

  1. Schema Changes
    - Add avatar column to community_members table
    - Add avatar_url function for consistent URL handling
    - Update sample data with avatars

  2. Security
    - Maintains existing RLS policies
    - Public read access
    - Admin-only write access
*/

-- Add avatar column
ALTER TABLE community_members 
ADD COLUMN avatar text;

-- Create function to get avatar URL
CREATE OR REPLACE FUNCTION get_avatar_url(avatar text)
RETURNS text
LANGUAGE sqla
IMMUTABLE
AS $$
  SELECT CASE
    WHEN avatar IS NULL OR avatar = '' THEN NULL
    WHEN avatar LIKE 'http%' THEN avatar
    ELSE '/avatars/' || avatar
  END;
$$;

-- Update sample data with avatars
UPDATE community_members SET avatar = 
  CASE name
    WHEN 'John Smith' THEN 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&h=200&fit=crop'
    WHEN 'Mary Johnson' THEN 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&h=200&fit=crop'
    WHEN 'David Brown' THEN 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&h=200&fit=crop'
    WHEN 'Sarah Wilson' THEN 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&h=200&fit=crop'
    WHEN 'Michael Lee' THEN 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=200&h=200&fit=crop'
    WHEN 'Jennifer Chen' THEN 'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=200&h=200&fit=crop'
    WHEN 'Robert Taylor' THEN 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=200&h=200&fit=crop'
    WHEN 'Patricia Martinez' THEN 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=200&h=200&fit=crop'
    WHEN 'William Anderson' THEN 'https://images.unsplash.com/photo-1463453091185-61582044d556?q=80&w=200&h=200&fit=crop'
    WHEN 'Elizabeth Thomas' THEN 'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?q=80&w=200&h=200&fit=crop'
  END;

-- Add comments
COMMENT ON COLUMN community_members.avatar IS 'Avatar image URL or filename';
COMMENT ON FUNCTION get_avatar_url IS 'Returns the full URL for an avatar image';