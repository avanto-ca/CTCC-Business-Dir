export interface Member {
  id: string
  Name?: string
  Firstname?: string
  Lastname?: string
  logo: string
  address: string
  category_id: string
  phone: string
  email?: string
  website?: string
  iframe?: string
  aboutus?: string  // Supports HTML content
  aboutus_html?: string  // New field for HTML content
  sectionItem1?: string
  sectionItem2?: string
  sectionItem3?: string
  sectionItem4?: string
  sectionItem5?: string
  facebook?: string
  linkedin?: string
  twitter?: string
  instagram?: string
  whatsapp?: string
  created_at?: string
}

export interface CommunityMember {
  id: string
  name: string
  email?: string
  phone?: string
  avatar?: string
  category_id: string
  created_at?: string
  updated_at?: string
}

export interface SEOMetadata {
  id: string
  member_id: string
  title?: string
  description?: string
  keywords?: string[]
  og_title?: string
  og_description?: string
  twitter_title?: string
  twitter_description?: string
  schema_description?: string
  created_at?: string
  updated_at?: string
}

export interface Category {
  id: string
  name: string
  icon: string
  url: string
  seo_tags: string[]
  description: string
  color: string
  created_at?: string
}

export type BusinessCategory = {
  name: string
  count: number
  icon: React.ElementType
}