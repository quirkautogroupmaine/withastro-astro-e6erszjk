/*
  # Add Schema Fields for Posts

  1. New Fields
    - author_name (text) - Name of the author
    - author_title (text) - Author's title/role
    - author_image (text) - URL to author's image
    - word_count (integer) - Number of words in content
    - reading_time (integer) - Estimated reading time in minutes
    - keywords (text[]) - SEO keywords
    - article_section (text) - Section/category of the article
    - is_sponsored (boolean) - Whether the post is sponsored content
    - sponsor_name (text) - Name of the sponsor if sponsored
    - sponsor_logo (text) - URL to sponsor's logo
    - sponsor_url (text) - Sponsor's website URL
    - video_url (text) - URL to related video content
    - audio_url (text) - URL to related audio content
    - original_source_url (text) - URL to original content if syndicated
    - canonical_url (text) - Canonical URL if different from post URL
    - meta_title (text) - Custom meta title for SEO
    - meta_description (text) - Custom meta description for SEO
    - social_image (text) - Custom social sharing image URL

  2. Changes
    - Adds new columns to posts table
    - Adds validation checks
    - Adds indexes for performance

  3. Security
    - Maintains existing RLS policies
*/

-- Add new columns to posts table
DO $$ 
BEGIN
  -- Author Information
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'posts' AND column_name = 'author_name') THEN
    ALTER TABLE posts ADD COLUMN author_name text;
    COMMENT ON COLUMN posts.author_name IS 'Name of the content author';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'posts' AND column_name = 'author_title') THEN
    ALTER TABLE posts ADD COLUMN author_title text;
    COMMENT ON COLUMN posts.author_title IS 'Author''s title or role';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'posts' AND column_name = 'author_image') THEN
    ALTER TABLE posts ADD COLUMN author_image text;
    COMMENT ON COLUMN posts.author_image IS 'URL to author''s profile image';
  END IF;

  -- Content Metrics
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'posts' AND column_name = 'word_count') THEN
    ALTER TABLE posts ADD COLUMN word_count integer;
    COMMENT ON COLUMN posts.word_count IS 'Number of words in the content';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'posts' AND column_name = 'reading_time') THEN
    ALTER TABLE posts ADD COLUMN reading_time integer;
    COMMENT ON COLUMN posts.reading_time IS 'Estimated reading time in minutes';
  END IF;

  -- SEO Fields
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'posts' AND column_name = 'keywords') THEN
    ALTER TABLE posts ADD COLUMN keywords text[] DEFAULT '{}';
    COMMENT ON COLUMN posts.keywords IS 'SEO keywords for the post';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'posts' AND column_name = 'article_section') THEN
    ALTER TABLE posts ADD COLUMN article_section text;
    COMMENT ON COLUMN posts.article_section IS 'Section/category of the article';
  END IF;

  -- Sponsorship Information
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'posts' AND column_name = 'is_sponsored') THEN
    ALTER TABLE posts ADD COLUMN is_sponsored boolean DEFAULT false;
    COMMENT ON COLUMN posts.is_sponsored IS 'Whether the post is sponsored content';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'posts' AND column_name = 'sponsor_name') THEN
    ALTER TABLE posts ADD COLUMN sponsor_name text;
    COMMENT ON COLUMN posts.sponsor_name IS 'Name of the sponsor if sponsored';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'posts' AND column_name = 'sponsor_logo') THEN
    ALTER TABLE posts ADD COLUMN sponsor_logo text;
    COMMENT ON COLUMN posts.sponsor_logo IS 'URL to sponsor''s logo';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'posts' AND column_name = 'sponsor_url') THEN
    ALTER TABLE posts ADD COLUMN sponsor_url text;
    COMMENT ON COLUMN posts.sponsor_url IS 'Sponsor''s website URL';
  END IF;

  -- Media URLs
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'posts' AND column_name = 'video_url') THEN
    ALTER TABLE posts ADD COLUMN video_url text;
    COMMENT ON COLUMN posts.video_url IS 'URL to related video content';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'posts' AND column_name = 'audio_url') THEN
    ALTER TABLE posts ADD COLUMN audio_url text;
    COMMENT ON COLUMN posts.audio_url IS 'URL to related audio content';
  END IF;

  -- Source and Canonical URLs
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'posts' AND column_name = 'original_source_url') THEN
    ALTER TABLE posts ADD COLUMN original_source_url text;
    COMMENT ON COLUMN posts.original_source_url IS 'URL to original content if syndicated';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'posts' AND column_name = 'canonical_url') THEN
    ALTER TABLE posts ADD COLUMN canonical_url text;
    COMMENT ON COLUMN posts.canonical_url IS 'Canonical URL if different from post URL';
  END IF;

  -- Meta Information
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'posts' AND column_name = 'meta_title') THEN
    ALTER TABLE posts ADD COLUMN meta_title text;
    COMMENT ON COLUMN posts.meta_title IS 'Custom meta title for SEO';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'posts' AND column_name = 'meta_description') THEN
    ALTER TABLE posts ADD COLUMN meta_description text;
    COMMENT ON COLUMN posts.meta_description IS 'Custom meta description for SEO';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'posts' AND column_name = 'social_image') THEN
    ALTER TABLE posts ADD COLUMN social_image text;
    COMMENT ON COLUMN posts.social_image IS 'Custom social sharing image URL';
  END IF;
END $$;

-- Add validation checks
ALTER TABLE posts
  ADD CONSTRAINT posts_word_count_check 
    CHECK (word_count >= 0),
  ADD CONSTRAINT posts_reading_time_check
    CHECK (reading_time >= 0),
  ADD CONSTRAINT posts_url_checks
    CHECK (
      (video_url IS NULL OR video_url ~ '^https?://') AND
      (audio_url IS NULL OR audio_url ~ '^https?://') AND
      (original_source_url IS NULL OR original_source_url ~ '^https?://') AND
      (canonical_url IS NULL OR canonical_url ~ '^https?://')
    );

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS posts_article_section_idx ON posts (article_section);
CREATE INDEX IF NOT EXISTS posts_is_sponsored_idx ON posts (is_sponsored);
CREATE INDEX IF NOT EXISTS posts_keywords_idx ON posts USING GIN (keywords);