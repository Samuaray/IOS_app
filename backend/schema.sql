-- ThumbnailTest Database Schema
-- For Supabase (PostgreSQL)
-- Run this in Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- USERS TABLE
-- =====================================================
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255), -- null for social login
  apple_id VARCHAR(255) UNIQUE,
  google_id VARCHAR(255) UNIQUE,

  -- Profile
  full_name VARCHAR(255),
  channel_name VARCHAR(255),
  content_niche VARCHAR(50),
  subscriber_range VARCHAR(50),
  upload_frequency VARCHAR(50),

  -- Subscription
  subscription_tier VARCHAR(20) DEFAULT 'free' CHECK (subscription_tier IN ('free', 'creator', 'pro')),
  subscription_status VARCHAR(20) DEFAULT 'active' CHECK (subscription_status IN ('active', 'canceled', 'expired')),
  subscription_expires_at TIMESTAMP WITH TIME ZONE,
  stripe_customer_id VARCHAR(255),

  -- Usage tracking
  analyses_this_month INTEGER DEFAULT 0,
  analyses_reset_at TIMESTAMP WITH TIME ZONE DEFAULT DATE_TRUNC('month', NOW() + INTERVAL '1 month'),

  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_login_at TIMESTAMP WITH TIME ZONE
);

-- Indexes for users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_subscription_tier ON users(subscription_tier);
CREATE INDEX idx_users_apple_id ON users(apple_id) WHERE apple_id IS NOT NULL;
CREATE INDEX idx_users_google_id ON users(google_id) WHERE google_id IS NOT NULL;

-- =====================================================
-- ANALYSES TABLE
-- =====================================================
CREATE TABLE analyses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,

  -- Analysis details
  video_title VARCHAR(500),
  category VARCHAR(50),
  notes TEXT,

  -- Status
  status VARCHAR(20) DEFAULT 'completed' CHECK (status IN ('draft', 'processing', 'completed', 'failed')),
  published BOOLEAN DEFAULT false,
  published_at TIMESTAMP WITH TIME ZONE,

  -- Performance tracking
  youtube_video_id VARCHAR(50),
  youtube_video_url VARCHAR(500),
  actual_ctr DECIMAL(5,2),
  actual_views INTEGER,
  selected_thumbnail_id UUID,

  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for analyses
CREATE INDEX idx_analyses_user_id ON analyses(user_id);
CREATE INDEX idx_analyses_created_at ON analyses(created_at DESC);
CREATE INDEX idx_analyses_status ON analyses(status);
CREATE INDEX idx_analyses_user_created ON analyses(user_id, created_at DESC);

-- =====================================================
-- THUMBNAILS TABLE
-- =====================================================
CREATE TABLE thumbnails (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  analysis_id UUID REFERENCES analyses(id) ON DELETE CASCADE NOT NULL,

  -- Image data
  image_url VARCHAR(500) NOT NULL,
  image_s3_key VARCHAR(500) NOT NULL,
  order_index INTEGER NOT NULL,

  -- Scores (0-100)
  overall_score INTEGER CHECK (overall_score >= 0 AND overall_score <= 100),
  face_visibility_score INTEGER CHECK (face_visibility_score >= 0 AND face_visibility_score <= 100),
  text_readability_score INTEGER CHECK (text_readability_score >= 0 AND text_readability_score <= 100),
  color_contrast_score INTEGER CHECK (color_contrast_score >= 0 AND color_contrast_score <= 100),
  visual_clarity_score INTEGER CHECK (visual_clarity_score >= 0 AND visual_clarity_score <= 100),
  emotional_impact_score INTEGER CHECK (emotional_impact_score >= 0 AND emotional_impact_score <= 100),
  predicted_ctr DECIMAL(5,2),

  -- Analysis results
  is_winner BOOLEAN DEFAULT false,
  is_selected BOOLEAN DEFAULT false,
  face_detected BOOLEAN,
  text_detected TEXT,
  recommendations JSONB,

  -- Raw data
  ai_analysis_raw JSONB,

  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for thumbnails
CREATE INDEX idx_thumbnails_analysis_id ON thumbnails(analysis_id);
CREATE INDEX idx_thumbnails_overall_score ON thumbnails(overall_score DESC);

-- =====================================================
-- ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE analyses ENABLE ROW LEVEL SECURITY;
ALTER TABLE thumbnails ENABLE ROW LEVEL SECURITY;

-- Users: Users can only see/update their own profile
CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (auth.uid() = id);

-- Analyses: Users can only see/modify their own analyses
CREATE POLICY "Users can view own analyses"
  ON analyses FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own analyses"
  ON analyses FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own analyses"
  ON analyses FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own analyses"
  ON analyses FOR DELETE
  USING (auth.uid() = user_id);

-- Thumbnails: Users can access thumbnails of their analyses
CREATE POLICY "Users can view thumbnails of own analyses"
  ON thumbnails FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM analyses
      WHERE analyses.id = thumbnails.analysis_id
      AND analyses.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert thumbnails for own analyses"
  ON thumbnails FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM analyses
      WHERE analyses.id = thumbnails.analysis_id
      AND analyses.user_id = auth.uid()
    )
  );

-- =====================================================
-- FUNCTIONS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for users table
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger for analyses table
CREATE TRIGGER update_analyses_updated_at
  BEFORE UPDATE ON analyses
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Function to reset monthly analysis count
CREATE OR REPLACE FUNCTION reset_monthly_analyses()
RETURNS void AS $$
BEGIN
  UPDATE users
  SET
    analyses_this_month = 0,
    analyses_reset_at = DATE_TRUNC('month', NOW() + INTERVAL '1 month')
  WHERE analyses_reset_at <= NOW();
END;
$$ LANGUAGE plpgsql;

-- Function to increment analysis count
CREATE OR REPLACE FUNCTION increment_user_analysis_count()
RETURNS TRIGGER AS $$
BEGIN
  -- Only increment for completed analyses
  IF NEW.status = 'completed' THEN
    UPDATE users
    SET analyses_this_month = analyses_this_month + 1
    WHERE id = NEW.user_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to increment count when analysis is completed
CREATE TRIGGER increment_analysis_count
  AFTER INSERT ON analyses
  FOR EACH ROW
  EXECUTE FUNCTION increment_user_analysis_count();

-- =====================================================
-- STORAGE BUCKETS (Run in Supabase Storage settings)
-- =====================================================
-- Create a bucket called 'thumbnails' with public access for uploaded images
-- Settings: Public bucket, 10MB max file size, allowed types: image/jpeg, image/png, image/heic

-- =====================================================
-- SEED DATA (Optional - for testing)
-- =====================================================
-- Insert test user (for development only)
-- INSERT INTO users (email, full_name, subscription_tier)
-- VALUES ('test@example.com', 'Test User', 'free');
