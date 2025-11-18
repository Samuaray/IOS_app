# Product Requirements Document (PRD)
# ThumbnailTest - YouTube Thumbnail A/B Testing App

**Version:** 1.0  
**Date:** November 17, 2025  
**Status:** Ready for Development  
**Target Platform:** iOS (iPhone & iPad)  
**Minimum iOS Version:** 16.0+

---

## TABLE OF CONTENTS

1. [Executive Summary](#1-executive-summary)
2. [Product Overview](#2-product-overview)
3. [Target Users](#3-target-users)
4. [Core Features & Requirements](#4-core-features--requirements)
5. [Technical Architecture](#5-technical-architecture)
6. [Data Models](#6-data-models)
7. [API Specifications](#7-api-specifications)
8. [UI/UX Specifications](#8-uiux-specifications)
9. [MVP Scope & Priorities](#9-mvp-scope--priorities)
10. [Implementation Phases](#10-implementation-phases)

---

## 1. EXECUTIVE SUMMARY

### Product Vision
ThumbnailTest helps YouTube creators make data-driven thumbnail decisions before publishing by providing AI-powered predictions on thumbnail click-through rates (CTR).

### Business Model
- **Free Tier:** 3 thumbnail analyses per month
- **Creator Tier:** $9.99/month - unlimited analyses
- **Pro Tier:** $29.99/month - advanced features (future)

### Success Metrics
- **Launch Target:** 1,000 signups in 3 months
- **Activation:** 60% complete first analysis within 24 hours
- **Conversion:** 10% free-to-paid conversion rate
- **Revenue:** $5K MRR by month 6

---

## 2. PRODUCT OVERVIEW

### Problem Statement
YouTube creators spend hours designing thumbnails but have no way to test them before publishing. By the time poor performance is evident, the algorithm has already decided the video's fate. The first 24-48 hours are critical for video success.

### Solution
An iOS app that:
1. Accepts multiple thumbnail variants (2-4 images)
2. Analyzes them using AI for predicted CTR performance
3. Provides actionable feedback and recommendations
4. Tracks actual performance over time
5. Identifies patterns in successful thumbnails

### Key Value Propositions
- **Confidence:** Know which thumbnail will perform best before publishing
- **Speed:** Get instant analysis instead of waiting for real data
- **Learning:** Understand what makes thumbnails successful
- **ROI:** Better CTR = More views = More revenue

---

## 3. TARGET USERS

### Primary Persona: "Growing Gary"
- **Age:** 25-35 years old
- **Subscribers:** 5K-50K
- **Upload Frequency:** 2-4 videos per week
- **Pain Points:**
  - Spends 30+ minutes per thumbnail, still guesses
  - Can't predict which option will perform better
  - Sees competitors' thumbnails work but doesn't know why
- **Tech Level:** Moderate - uses Photoshop/Canva
- **Goals:** Grow channel, improve CTR, save time

### Secondary Persona: "Part-Time Paula"
- **Age:** 28-45 years old
- **Subscribers:** 1K-10K
- **Upload Frequency:** 1-2 videos per week
- **Pain Points:**
  - Limited time to create/test thumbnails
  - Doesn't understand what makes thumbnails work
  - Frustrated by low views despite good content
- **Tech Level:** Basic - uses Canva templates
- **Goals:** Make thumbnails faster, gain confidence

---

## 4. CORE FEATURES & REQUIREMENTS

## 4.1 AUTHENTICATION & ONBOARDING

### REQ-AUTH-001: User Authentication
**Priority:** MUST HAVE (MVP)  
**Description:** Users must be able to sign up and log in to the app.

**Acceptance Criteria:**
- [ ] Sign up with Apple Sign-In
- [ ] Sign up with Google Sign-In
- [ ] Sign up with Email/Password
- [ ] Passwords must be minimum 8 characters
- [ ] Email validation required
- [ ] "Forgot Password" flow available
- [ ] Session persists after app restart
- [ ] Auto-login on subsequent opens

**Technical Notes:**
- Use Firebase Authentication or Supabase Auth
- Store auth tokens securely in Keychain
- Implement JWT token refresh logic

---

### REQ-AUTH-002: User Onboarding
**Priority:** SHOULD HAVE (Post-MVP)  
**Description:** First-time users see a tutorial explaining the app.

**Acceptance Criteria:**
- [ ] 3-screen onboarding flow
- [ ] Screen 1: "Upload Multiple Thumbnails"
- [ ] Screen 2: "Get AI-Powered Scores"
- [ ] Screen 3: "Choose the Winner"
- [ ] Skip button on each screen
- [ ] "Get Started" button on final screen
- [ ] Only shown once per user
- [ ] Can be accessed later from Settings

**Data Collection (Optional):**
- Channel name
- Content niche (dropdown: Gaming, Tech, Lifestyle, Education, Entertainment, Business, Other)
- Upload frequency (Weekly/Monthly)
- Subscriber count range (<1K, 1K-10K, 10K-50K, 50K-100K, 100K+)

---

## 4.2 THUMBNAIL UPLOAD & ANALYSIS

### REQ-UPLOAD-001: Image Upload
**Priority:** MUST HAVE (MVP)  
**Description:** Users can upload 2-4 thumbnail images for analysis.

**Acceptance Criteria:**
- [ ] Upload minimum 2 images
- [ ] Upload maximum 4 images
- [ ] Select from photo library
- [ ] Take photos with camera
- [ ] Supported formats: JPG, PNG, HEIC
- [ ] Maximum file size: 10MB per image
- [ ] Images display as thumbnail grid
- [ ] Delete uploaded image before analysis
- [ ] Reorder images (drag and drop)
- [ ] Warning if image resolution is low (<1280x720)

**Technical Notes:**
- Use PHPicker for photo library access
- Request camera permissions
- Compress images client-side before upload
- Upload to S3 or similar storage
- Generate unique filename (UUID)

---

### REQ-UPLOAD-002: Analysis Context (Optional)
**Priority:** SHOULD HAVE (Post-MVP)  
**Description:** Users can provide context to improve analysis accuracy.

**Acceptance Criteria:**
- [ ] Video title input field (optional, 100 char max)
- [ ] Category dropdown (optional)
- [ ] Notes text area (optional, 500 char max)
- [ ] Fields saved with analysis
- [ ] Fields editable later in history

**Categories:**
- Gaming
- Tech & Software
- Lifestyle & Vlog
- Education & How-To
- Entertainment
- Business & Finance
- Health & Fitness
- Cooking & Food
- Other

---

### REQ-ANALYSIS-001: AI Analysis Engine
**Priority:** MUST HAVE (MVP)  
**Description:** System analyzes thumbnails and provides scores.

**Acceptance Criteria:**
- [ ] Analysis completes in <10 seconds
- [ ] Each thumbnail receives overall score (0-100)
- [ ] Individual factor scores:
  - Face Visibility (0-100)
  - Text Readability (0-100)
  - Color Contrast (0-100)
  - Visual Clarity (0-100)
  - Emotional Impact (0-100)
- [ ] Predicted CTR percentage (realistic: 2-12%)
- [ ] Face detection (yes/no)
- [ ] Text detection (extract any text)
- [ ] 3-5 specific recommendations per thumbnail
- [ ] Winner identified (highest overall score)
- [ ] Loading indicator during processing

**Technical Implementation:**
```
MVP: Use OpenAI GPT-4 Vision API
- Send all thumbnails in single request
- Use structured JSON response
- Parse and validate response
- Fallback to deterministic scoring if API fails

Alternative: Claude Vision API (Anthropic)
- Similar capabilities
- Potentially better analysis

Future: Custom ML Model
- Train on thumbnail dataset
- Lower cost per analysis
- Better accuracy over time
```

**AI Prompt Template:**
```
Analyze these YouTube thumbnail images for predicted CTR performance.

Context:
- Video Title: [TITLE]
- Category: [CATEGORY]
- Target audience: YouTube viewers

For each thumbnail, evaluate these factors (0-100 scale):

1. Face Visibility: Are faces clearly visible? Is emotion identifiable? 
   Rate higher for: clear facial expressions, direct eye contact, close-up faces
   Rate lower for: obscured faces, small faces, no emotion visible

2. Text Readability: Is text legible at thumbnail size (320x180)?
   Rate higher for: bold text, high contrast, 3-5 words max, large font
   Rate lower for: small text, low contrast, too many words, complex fonts

3. Color Contrast: Do colors stand out? Is there visual hierarchy?
   Rate higher for: complementary colors, bold contrasts, clear focal point
   Rate lower for: muddy colors, low contrast, cluttered composition

4. Visual Clarity: Is the thumbnail easy to understand at a glance?
   Rate higher for: simple composition, clear subject, not cluttered
   Rate lower for: too many elements, confusing layout, unclear subject

5. Emotional Impact: Does it evoke curiosity, emotion, or intrigue?
   Rate higher for: strong emotions, mystery, surprise elements
   Rate lower for: bland expressions, boring composition, no hook

Provide:
- Overall score (weighted average, 0-100)
- Individual scores for each factor
- Predicted CTR (realistic: 2-12% range)
- Whether faces detected (boolean)
- Any text detected (string)
- 3-5 specific, actionable recommendations
- Which thumbnail is the winner

Return as JSON:
{
  "thumbnails": [
    {
      "thumbnailIndex": 0,
      "overallScore": 87,
      "scores": {
        "faceVisibility": 95,
        "textReadability": 82,
        "colorContrast": 88,
        "visualClarity": 90,
        "emotionalImpact": 85
      },
      "predictedCTR": 8.7,
      "faceDetected": true,
      "textDetected": "BUILD iOS APPS",
      "recommendations": [
        "Excellent face visibility creates strong connection",
        "Text could be 15% larger for mobile viewing",
        "Strong color contrast makes thumbnail pop",
        "Consider adding urgency element (e.g., 'NOW', 'NEW')"
      ]
    }
  ],
  "winner": 0
}
```

---

### REQ-ANALYSIS-002: Results Display
**Priority:** MUST HAVE (MVP)  
**Description:** Show analysis results in clear, actionable format.

**Acceptance Criteria:**
- [ ] Side-by-side thumbnail comparison
- [ ] Winner highlighted with visual indicator (gold border + badge)
- [ ] Overall scores prominently displayed
- [ ] "View Details" button for each thumbnail
- [ ] "Save Analysis" button
- [ ] Share button (screenshot results)
- [ ] Clear visual hierarchy (winner first)

**Visual Design:**
```
┌─────────────────────────────────────┐
│  Your Results                    [X] │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────┐          ┌─────────┐  │
│  │🏆       │          │         │  │
│  │ [IMG1]  │          │ [IMG2]  │  │
│  │         │          │         │  │
│  └─────────┘          └─────────┘  │
│   Score: 87            Score: 72   │
│   CTR: 8.7%            CTR: 6.2%   │
│                                     │
│   [View Details]      [View Details]│
│                                     │
│  ┌─────────┐          ┌─────────┐  │
│  │ [IMG3]  │          │ [IMG4]  │  │
│  │         │          │         │  │
│  └─────────┘          └─────────┘  │
│   Score: 79            Score: 81   │
│   CTR: 7.1%            CTR: 7.5%   │
│                                     │
│   [View Details]      [View Details]│
│                                     │
├─────────────────────────────────────┤
│           [Save Analysis]           │
│           [Share Results]           │
└─────────────────────────────────────┘
```

---

### REQ-ANALYSIS-003: Thumbnail Detail View
**Priority:** MUST HAVE (MVP)  
**Description:** Detailed breakdown for individual thumbnails.

**Acceptance Criteria:**
- [ ] Full-size thumbnail display
- [ ] Overall score with visual indicator (circular progress)
- [ ] Factor breakdown with bar charts:
  - Face Visibility: XX/100
  - Text Readability: XX/100
  - Color Contrast: XX/100
  - Visual Clarity: XX/100
  - Emotional Impact: XX/100
- [ ] Predicted CTR displayed prominently
- [ ] Recommendations list (3-5 bullet points)
- [ ] Face detection indicator
- [ ] Detected text displayed
- [ ] "Use This Thumbnail" button
- [ ] Back button to results

**Future Features (Post-MVP):**
- Heatmap overlay (predicted eye focus areas)
- Side-by-side comparison view
- Export this analysis as image

---

## 4.3 HISTORY & TRACKING

### REQ-HISTORY-001: Analysis History
**Priority:** MUST HAVE (MVP)  
**Description:** Users can view all past thumbnail analyses.

**Acceptance Criteria:**
- [ ] List view of all analyses
- [ ] Sort by date (newest first)
- [ ] Each item shows:
  - Thumbnail preview grid (2-4 images)
  - Date analyzed
  - Video title (if provided)
  - Status badge (Draft/Published/Tracked)
  - Winner indicator (gold star)
- [ ] Tap to open full results
- [ ] Empty state when no analyses
- [ ] Pull to refresh
- [ ] Infinite scroll (20 per page)

**Search & Filter (Post-MVP):**
- [ ] Search by video title
- [ ] Filter by date range
- [ ] Filter by status
- [ ] Filter by category

---

### REQ-HISTORY-002: Performance Tracking
**Priority:** SHOULD HAVE (Post-MVP)  
**Description:** Track which thumbnail was used and actual performance.

**Acceptance Criteria:**
- [ ] Mark which thumbnail was actually used
- [ ] Add actual CTR manually (decimal input)
- [ ] Add YouTube video URL (optional)
- [ ] Update status to "Published"
- [ ] Compare predicted vs actual CTR
- [ ] Show accuracy indicator (% difference)

**Future (Pro Tier):**
- [ ] YouTube API integration
- [ ] Automatic CTR tracking
- [ ] Weekly email with performance summary

---

## 4.4 SUBSCRIPTION & MONETIZATION

### REQ-SUB-001: Free Tier Limits
**Priority:** MUST HAVE (MVP)  
**Description:** Free users limited to 3 analyses per month.

**Acceptance Criteria:**
- [ ] Track analyses count per user
- [ ] Reset counter on 1st of each month
- [ ] Display remaining analyses (e.g., "2 of 3 left")
- [ ] Show upgrade prompt when limit reached
- [ ] Block new analysis creation when at limit
- [ ] View past analyses without limit

---

### REQ-SUB-002: Subscription Tiers
**Priority:** MUST HAVE (MVP)  
**Description:** Multiple subscription tiers with different features.

**Tier Structure:**

**FREE**
- 3 analyses per month
- Basic scoring
- History access
- No advanced features

**CREATOR - $9.99/month**
- Unlimited analyses
- All 5 factor scores
- Detailed recommendations
- Performance tracking
- Export results
- Priority support

**PRO - $29.99/month** (Future)
- Everything in Creator
- YouTube API integration
- Automatic CTR tracking
- Competitor analysis
- Trend alerts
- Team features (3 seats)

---

### REQ-SUB-003: In-App Purchase Implementation
**Priority:** MUST HAVE (MVP)  
**Description:** Handle subscription purchases through iOS.

**Acceptance Criteria:**
- [ ] Use StoreKit 2 for subscriptions
- [ ] Monthly auto-renewable subscription
- [ ] 7-day free trial for Creator tier (first time only)
- [ ] Subscription management in Settings
- [ ] Restore purchases functionality
- [ ] Handle subscription status changes
- [ ] Receipt validation
- [ ] Graceful error handling for failed payments
- [ ] Clear pricing display

**Paywall Triggers:**
- When user reaches free tier limit
- "Upgrade" button in Settings
- "Pro" badge on locked features
- Onboarding flow (soft sell)

**Paywall Design:**
```
┌─────────────────────────────────────┐
│          Unlock Unlimited       [X] │
├─────────────────────────────────────┤
│                                     │
│  ✓ Unlimited thumbnail analyses    │
│  ✓ Detailed scoring breakdowns     │
│  ✓ Performance tracking             │
│  ✓ Export & share results          │
│  ✓ Priority support                 │
│                                     │
│  ┌─────────────────────────────┐   │
│  │       Creator Plan          │   │
│  │       $9.99/month           │   │
│  │   7-day free trial          │   │
│  └─────────────────────────────┘   │
│                                     │
│     [Start Free Trial]              │
│                                     │
│     Restore Purchases               │
│                                     │
│  Cancel anytime. Terms apply.       │
└─────────────────────────────────────┘
```

---

## 4.5 USER PROFILE & SETTINGS

### REQ-PROFILE-001: User Profile
**Priority:** SHOULD HAVE (Post-MVP)  
**Description:** Users can manage their profile information.

**Acceptance Criteria:**
- [ ] View/edit display name
- [ ] View/edit channel name
- [ ] Update content niche
- [ ] Update subscriber range
- [ ] Update email (with verification)
- [ ] Change password
- [ ] Save button with loading state
- [ ] Success/error messages

---

### REQ-SETTINGS-001: App Settings
**Priority:** SHOULD HAVE (Post-MVP)  
**Description:** Configure app preferences and account settings.

**Acceptance Criteria:**
- [ ] Dark mode toggle (or follow system)
- [ ] Notification preferences
- [ ] Subscription management
  - View current plan
  - View renewal date
  - Cancel subscription
  - Upgrade/downgrade
- [ ] Help & Support
  - FAQ link
  - Contact support
  - Tutorial replay
- [ ] Legal
  - Terms of Service
  - Privacy Policy
- [ ] Account
  - Delete account (with confirmation)
  - Log out
- [ ] App version display

---

## 4.6 INSIGHTS DASHBOARD

### REQ-INSIGHTS-001: Basic Insights
**Priority:** NICE TO HAVE (Post-MVP)  
**Description:** Show user their performance patterns over time.

**Acceptance Criteria:**
- [ ] Total analyses count
- [ ] Average prediction score
- [ ] Accuracy rate (if CTR data available)
- [ ] Most analyzed category
- [ ] Date range selector (7d, 30d, 90d, All)

**Insights to Show:**
- Your highest-rated thumbnails (top 5)
- Face vs no-face performance
- Text-heavy vs minimal text performance
- Most successful colors
- Best performing day/time to publish (if enough data)

---

## 5. TECHNICAL ARCHITECTURE

## 5.1 TECH STACK

### iOS App (Frontend)
```
Language: Swift 5.9+
Framework: SwiftUI
Minimum iOS: 16.0+
IDE: Xcode 15+

Key Dependencies:
- Firebase SDK (Auth, Analytics, Crashlytics)
- Kingfisher (image caching)
- StoreKit 2 (in-app purchases)

Architecture:
- MVVM pattern
- Async/await for concurrency
- Combine for reactive programming
```

### Backend (API)
```
Option 1 (Recommended for MVP): 
- Supabase (Backend-as-a-Service)
  - PostgreSQL database
  - Authentication
  - Storage
  - Real-time subscriptions
  - Row Level Security

Option 2:
- Node.js + Express
- PostgreSQL
- JWT authentication
- AWS S3 for storage

Option 3:
- Python + FastAPI
- PostgreSQL
- JWT authentication
- AWS S3 for storage
```

### AI/ML
```
MVP: OpenAI GPT-4 Vision API
- Endpoint: /v1/chat/completions
- Model: gpt-4-vision-preview
- Cost: ~$0.01 per image
- Response time: 3-5 seconds

Alternative: Anthropic Claude Vision
- Model: claude-3-opus-20240229
- Similar capabilities
- May provide better analysis

Future: Custom Model
- TensorFlow or PyTorch
- Train on YouTube thumbnail dataset
- Host on AWS SageMaker
- Lower cost per analysis
```

### Infrastructure
```
MVP Recommendation:
- Supabase for backend
- Vercel for any frontend dashboards
- OpenAI API for analysis

Production:
- AWS (EC2, RDS, S3, CloudFront)
- Redis for caching
- Sentry for error tracking
- Mixpanel/PostHog for analytics
```

---

## 5.2 SYSTEM ARCHITECTURE DIAGRAM

```
┌─────────────────────────────────────────────────────┐
│                   iOS App (Swift/SwiftUI)           │
│  ┌─────────────────────────────────────────────┐   │
│  │  Views (SwiftUI)                            │   │
│  │  ├─ AuthView                                │   │
│  │  ├─ HomeView                                │   │
│  │  ├─ AnalysisView                            │   │
│  │  ├─ ResultsView                             │   │
│  │  └─ HistoryView                             │   │
│  └─────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────┐   │
│  │  ViewModels (MVVM)                          │   │
│  │  ├─ AuthViewModel                           │   │
│  │  ├─ AnalysisViewModel                       │   │
│  │  └─ HistoryViewModel                        │   │
│  └─────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────┐   │
│  │  Services                                   │   │
│  │  ├─ APIService (networking)                 │   │
│  │  ├─ AuthService                             │   │
│  │  ├─ ImageService                            │   │
│  │  └─ SubscriptionService (StoreKit)          │   │
│  └─────────────────────────────────────────────┘   │
└──────────────────────┬──────────────────────────────┘
                       │ HTTPS/REST API
                       ▼
┌─────────────────────────────────────────────────────┐
│              Backend API (Node.js/Python)           │
│  ┌─────────────────────────────────────────────┐   │
│  │  API Routes                                 │   │
│  │  ├─ /auth (signup, login)                   │   │
│  │  ├─ /analysis (create, get, list)           │   │
│  │  ├─ /upload (presigned URLs)                │   │
│  │  └─ /user (profile, subscription)           │   │
│  └─────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────┐   │
│  │  Services                                   │   │
│  │  ├─ AuthService                             │   │
│  │  ├─ AnalysisService ──────┐                 │   │
│  │  ├─ ImageService          │                 │   │
│  │  └─ SubscriptionService   │                 │   │
│  └─────────────────────────────┼───────────────┘   │
└────────────────────────────────┼───────────────────┘
                                 │
        ┌────────────────────────┼────────────────────┐
        │                        │                    │
        ▼                        ▼                    ▼
┌───────────────┐    ┌───────────────────┐   ┌──────────────┐
│  PostgreSQL   │    │  OpenAI Vision    │   │   AWS S3     │
│   Database    │    │       API         │   │Image Storage │
│               │    │                   │   │              │
│ ├─ users      │    │ GPT-4-Vision      │   │ Uploads/     │
│ ├─ analyses   │    │ API               │   │ Thumbnails   │
│ ├─ thumbnails │    │                   │   │              │
│ └─ insights   │    └───────────────────┘   └──────────────┘
└───────────────┘
```

---

## 5.3 SECURITY REQUIREMENTS

### REQ-SEC-001: Data Security
**Acceptance Criteria:**
- [ ] All API calls use HTTPS only
- [ ] JWT tokens for authentication
- [ ] Tokens stored in iOS Keychain
- [ ] API keys never stored in client code
- [ ] Environment variables for sensitive config
- [ ] User images deleted after 90 days
- [ ] PII encrypted at rest
- [ ] GDPR compliance (data export/deletion)

### REQ-SEC-002: API Security
**Acceptance Criteria:**
- [ ] Rate limiting (100 requests/hour per user)
- [ ] Request validation (schema checking)
- [ ] SQL injection prevention (parameterized queries)
- [ ] CORS configured correctly
- [ ] Auth token expiration (24 hours)
- [ ] Refresh token rotation

---

## 6. DATA MODELS

## 6.1 DATABASE SCHEMA

### Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255),
  apple_id VARCHAR(255) UNIQUE,
  google_id VARCHAR(255) UNIQUE,
  
  -- Profile
  full_name VARCHAR(255),
  channel_name VARCHAR(255),
  content_niche VARCHAR(50),
  subscriber_range VARCHAR(50),
  upload_frequency VARCHAR(50),
  
  -- Subscription
  subscription_tier VARCHAR(20) DEFAULT 'free',
  subscription_status VARCHAR(20) DEFAULT 'active',
  subscription_expires_at TIMESTAMP,
  stripe_customer_id VARCHAR(255),
  
  -- Usage tracking
  analyses_this_month INTEGER DEFAULT 0,
  analyses_reset_at TIMESTAMP DEFAULT NOW(),
  
  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  last_login_at TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_subscription_tier ON users(subscription_tier);
```

### Analyses Table
```sql
CREATE TABLE analyses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  -- Analysis details
  video_title VARCHAR(500),
  category VARCHAR(50),
  notes TEXT,
  
  -- Status
  status VARCHAR(20) DEFAULT 'completed',
  published BOOLEAN DEFAULT false,
  published_at TIMESTAMP,
  
  -- Performance tracking
  youtube_video_id VARCHAR(50),
  youtube_video_url VARCHAR(500),
  actual_ctr DECIMAL(5,2),
  actual_views INTEGER,
  selected_thumbnail_id UUID,
  
  -- Metadata
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_analyses_user_id ON analyses(user_id);
CREATE INDEX idx_analyses_created_at ON analyses(created_at DESC);
CREATE INDEX idx_analyses_status ON analyses(status);
```

### Thumbnails Table
```sql
CREATE TABLE thumbnails (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  analysis_id UUID REFERENCES analyses(id) ON DELETE CASCADE,
  
  -- Image data
  image_url VARCHAR(500) NOT NULL,
  image_s3_key VARCHAR(500) NOT NULL,
  order_index INTEGER NOT NULL,
  
  -- Scores
  overall_score INTEGER,
  face_visibility_score INTEGER,
  text_readability_score INTEGER,
  color_contrast_score INTEGER,
  visual_clarity_score INTEGER,
  emotional_impact_score INTEGER,
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
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_thumbnails_analysis_id ON thumbnails(analysis_id);
CREATE INDEX idx_thumbnails_overall_score ON thumbnails(overall_score DESC);
```

### User Insights Table (Future)
```sql
CREATE TABLE user_insights (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  
  insight_type VARCHAR(50), -- 'pattern', 'trend', 'recommendation'
  insight_data JSONB,
  
  generated_at TIMESTAMP DEFAULT NOW(),
  expires_at TIMESTAMP
);

CREATE INDEX idx_insights_user_id ON user_insights(user_id);
CREATE INDEX idx_insights_type ON user_insights(insight_type);
```

---

## 7. API SPECIFICATIONS

## 7.1 BASE URL
```
Production: https://api.thumbnailtest.app/v1
Staging: https://staging-api.thumbnailtest.app/v1
Local: http://localhost:3000/v1
```

## 7.2 AUTHENTICATION
All endpoints (except auth) require Bearer token:
```
Authorization: Bearer {JWT_TOKEN}
```

## 7.3 API ENDPOINTS

### Authentication

#### POST /auth/signup
Create new user account.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securePassword123",
  "fullName": "John Doe"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "fullName": "John Doe",
      "subscriptionTier": "free",
      "analysesThisMonth": 0,
      "createdAt": "2025-11-17T10:00:00Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

---

#### POST /auth/login
Login existing user.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "user": { /* user object */ },
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

---

#### POST /auth/apple
Login with Apple Sign-In.

**Request Body:**
```json
{
  "identityToken": "appleToken",
  "authorizationCode": "appleAuthCode",
  "fullName": "John Doe" // optional, first time only
}
```

---

#### POST /auth/google
Login with Google Sign-In.

**Request Body:**
```json
{
  "idToken": "googleIdToken"
}
```

---

### Analysis

#### POST /analysis/create
Create new thumbnail analysis.

**Request Body:**
```json
{
  "videoTitle": "How to Build iOS Apps in 2025",
  "category": "education",
  "notes": "Testing face vs no-face variants",
  "thumbnails": [
    {
      "imageUrl": "https://s3.../uuid1.jpg",
      "order": 1
    },
    {
      "imageUrl": "https://s3.../uuid2.jpg",
      "order": 2
    }
  ]
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "analysisId": "uuid",
    "status": "completed",
    "createdAt": "2025-11-17T10:30:00Z",
    "videoTitle": "How to Build iOS Apps in 2025",
    "category": "education",
    "thumbnails": [
      {
        "id": "thumb-uuid-1",
        "imageUrl": "https://s3.../uuid1.jpg",
        "orderIndex": 1,
        "overallScore": 87,
        "scores": {
          "faceVisibility": 95,
          "textReadability": 82,
          "colorContrast": 88,
          "visualClarity": 90,
          "emotionalImpact": 85
        },
        "predictedCTR": 8.7,
        "isWinner": true,
        "faceDetected": true,
        "textDetected": "BUILD iOS APPS",
        "recommendations": [
          "Excellent face visibility creates strong viewer connection",
          "Text could be 10% larger for better mobile readability",
          "Strong color contrast makes thumbnail stand out",
          "Facial expression conveys expertise and confidence"
        ]
      },
      {
        "id": "thumb-uuid-2",
        "imageUrl": "https://s3.../uuid2.jpg",
        "orderIndex": 2,
        "overallScore": 72,
        "scores": {
          "faceVisibility": 0,
          "textReadability": 88,
          "colorContrast": 75,
          "visualClarity": 85,
          "emotionalImpact": 70
        },
        "predictedCTR": 6.2,
        "isWinner": false,
        "faceDetected": false,
        "textDetected": "iOS Development Guide",
        "recommendations": [
          "Consider adding a face for better emotional connection",
          "Text is readable but lacks visual hierarchy",
          "Color scheme is good but could be more bold",
          "Add element of surprise or curiosity"
        ]
      }
    ]
  }
}
```

---

#### GET /analysis/:id
Get specific analysis by ID.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "analysis": { /* full analysis object */ }
  }
}
```

---

#### GET /analysis/list
Get user's analysis history.

**Query Parameters:**
- `page` (number): Page number (default: 1)
- `limit` (number): Items per page (default: 20, max: 50)
- `status` (string): Filter by status ('completed', 'draft')
- `category` (string): Filter by category
- `search` (string): Search video titles

**Response (200):**
```json
{
  "success": true,
  "data": {
    "analyses": [ /* array of analysis objects */ ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 45,
      "totalPages": 3
    }
  }
}
```

---

#### PUT /analysis/:id
Update analysis (add CTR, mark thumbnail as used).

**Request Body:**
```json
{
  "published": true,
  "publishedAt": "2025-11-17T12:00:00Z",
  "selectedThumbnailId": "thumb-uuid-1",
  "youtubeVideoUrl": "https://youtube.com/watch?v=abc123",
  "actualCtr": 9.2,
  "actualViews": 15000
}
```

---

### Image Upload

#### POST /upload/presigned-url
Get presigned URL for S3 upload.

**Request Body:**
```json
{
  "fileName": "thumbnail1.jpg",
  "fileType": "image/jpeg",
  "fileSize": 2048000
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "uploadUrl": "https://s3.../presigned-url",
    "imageUrl": "https://s3.../final-url",
    "imageKey": "uploads/user-id/uuid.jpg",
    "expiresIn": 300
  }
}
```

**Client Flow:**
1. Get presigned URL from API
2. Upload image directly to S3 using presigned URL
3. Use returned imageUrl in analysis creation

---

### User

#### GET /user/profile
Get current user profile.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "fullName": "John Doe",
      "channelName": "Tech with John",
      "contentNiche": "education",
      "subscriberRange": "10k-50k",
      "subscriptionTier": "creator",
      "subscriptionStatus": "active",
      "subscriptionExpiresAt": "2025-12-17T10:00:00Z",
      "analysesThisMonth": 12,
      "analysesResetAt": "2025-12-01T00:00:00Z",
      "createdAt": "2025-01-15T10:00:00Z"
    }
  }
}
```

---

#### PUT /user/profile
Update user profile.

**Request Body:**
```json
{
  "fullName": "John Doe",
  "channelName": "Tech with John",
  "contentNiche": "education",
  "subscriberRange": "50k-100k"
}
```

---

#### GET /user/subscription
Get subscription details.

**Response (200):**
```json
{
  "success": true,
  "data": {
    "subscription": {
      "tier": "creator",
      "status": "active",
      "expiresAt": "2025-12-17T10:00:00Z",
      "isTrial": false,
      "trialEndsAt": null,
      "canUpgrade": true,
      "canDowngrade": false,
      "nextBillingDate": "2025-12-17T10:00:00Z",
      "features": {
        "unlimitedAnalyses": true,
        "detailedScoring": true,
        "performanceTracking": true,
        "exportResults": true
      }
    }
  }
}
```

---

### Error Responses

All errors follow this format:
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": {} // optional, additional context
  }
}
```

**Common Error Codes:**
- `AUTH_REQUIRED` (401): Missing or invalid auth token
- `FORBIDDEN` (403): Insufficient permissions
- `NOT_FOUND` (404): Resource not found
- `VALIDATION_ERROR` (400): Invalid request data
- `RATE_LIMIT` (429): Too many requests
- `ANALYSIS_LIMIT` (403): Free tier limit reached
- `SERVER_ERROR` (500): Internal server error

**Example:**
```json
{
  "success": false,
  "error": {
    "code": "ANALYSIS_LIMIT",
    "message": "You've reached your monthly limit of 3 analyses. Upgrade to Creator for unlimited analyses.",
    "details": {
      "currentCount": 3,
      "limit": 3,
      "resetAt": "2025-12-01T00:00:00Z"
    }
  }
}
```

---

## 8. UI/UX SPECIFICATIONS

## 8.1 DESIGN SYSTEM

### Colors
```swift
// Primary
let primaryRed = Color(hex: "#FF0050")
let primaryDark = Color(hex: "#282828")

// Semantic
let successGreen = Color(hex: "#00D26A")
let warningOrange = Color(hex: "#FFB800")
let errorRed = Color(hex: "#FF3B30")

// Backgrounds
let backgroundLight = Color.white
let backgroundDark = Color(hex: "#1C1C1E")
let cardBackground = Color(hex: "#F5F5F5") // light mode
let cardBackgroundDark = Color(hex: "#2C2C2E") // dark mode

// Text
let textPrimary = Color.black
let textPrimaryDark = Color.white
let textSecondary = Color(hex: "#8E8E93")

// Score gradients
let scoreVeryLow = [Color(hex: "#FF3B30"), Color(hex: "#FF6B30")] // 0-40
let scoreLow = [Color(hex: "#FFB800"), Color(hex: "#FFA800")] // 41-70
let scoreGood = [Color(hex: "#007AFF"), Color(hex: "#0056D6")] // 71-85
let scoreExcellent = [Color(hex: "#00D26A"), Color(hex: "#00B85C")] // 86-100
```

### Typography
```swift
// Use San Francisco (system font)
let headlineXL = Font.system(size: 34, weight: .bold)
let headlineLarge = Font.system(size: 28, weight: .bold)
let headlineMedium = Font.system(size: 22, weight: .semibold)
let headlineSmall = Font.system(size: 18, weight: .semibold)

let bodyLarge = Font.system(size: 17, weight: .regular)
let bodyMedium = Font.system(size: 15, weight: .regular)
let bodySmall = Font.system(size: 13, weight: .regular)

let captionLarge = Font.system(size: 12, weight: .medium)
let captionSmall = Font.system(size: 11, weight: .regular)
```

### Spacing
```swift
let spacing2: CGFloat = 2
let spacing4: CGFloat = 4
let spacing8: CGFloat = 8
let spacing12: CGFloat = 12
let spacing16: CGFloat = 16
let spacing20: CGFloat = 20
let spacing24: CGFloat = 24
let spacing32: CGFloat = 32
let spacing40: CGFloat = 40
```

### Corner Radius
```swift
let radiusSmall: CGFloat = 8
let radiusMedium: CGFloat = 12
let radiusLarge: CGFloat = 16
let radiusXLarge: CGFloat = 20
let radiusFull: CGFloat = 999 // pill shape
```

### Shadows
```swift
let shadowLight = Color.black.opacity(0.05)
let shadowMedium = Color.black.opacity(0.1)
let shadowDark = Color.black.opacity(0.15)
```

---

## 8.2 KEY SCREENS & WIREFRAMES

### Home Screen
```
┌─────────────────────────────────────────┐
│  ☰                          🔔  👤      │ <- Navigation Bar
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────────────────────────┐  │
│  │  📊  Analyze New Thumbnails      │  │ <- Primary CTA
│  │  Find your winning thumbnail      │  │
│  └──────────────────────────────────┘  │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │  This Month                      │  │
│  │  ──────────────────────────────  │  │
│  │  📈  12  Analyses                │  │
│  │  ⭐  85  Avg Score                │  │
│  │  ✓  89% Accuracy                 │  │
│  └──────────────────────────────────┘  │
│                                         │
│  Recent Analyses                   See All│
│  ────────────────────────────────────  │
│  ┌──────────────────────────────────┐  │
│  │ [🖼️][🖼️]  iOS Apps Tutorial     │  │
│  │ Winner: #1  •  Nov 15  •  ⭐87  │  │
│  └──────────────────────────────────┘  │
│  ┌──────────────────────────────────┐  │
│  │ [🖼️][🖼️]  React Native Guide    │  │
│  │ Winner: #2  •  Nov 14  •  ⭐82  │  │
│  └──────────────────────────────────┘  │
│                                         │
│  💡 Quick Tip                           │
│  ────────────────────────────────────  │
│  Your thumbnails with faces score      │
│  15% higher on average!                 │
│                                         │
└─────────────────────────────────────────┘
```

---

### New Analysis Flow

**Step 1: Upload Thumbnails**
```
┌─────────────────────────────────────────┐
│  ←  Upload Thumbnails              Skip │
├─────────────────────────────────────────┤
│                                         │
│  Upload 2-4 thumbnail options           │
│                                         │
│  ┌──────────────┐  ┌──────────────┐   │
│  │              │  │              │   │
│  │      +       │  │   [Image 1]  │   │
│  │  Add Photo   │  │              │   │
│  │              │  │      [X]     │   │
│  └──────────────┘  └──────────────┘   │
│                                         │
│  ┌──────────────┐  ┌──────────────┐   │
│  │              │  │              │   │
│  │      +       │  │      +       │   │
│  │  Add Photo   │  │  Add Photo   │   │
│  │              │  │              │   │
│  └──────────────┘  └──────────────┘   │
│                                         │
│  • Select from library or camera        │
│  • Minimum 2 thumbnails required        │
│                                         │
│         [Continue]  (2/4 added)         │
│                                         │
└─────────────────────────────────────────┘
```

**Step 2: Add Details (Optional)**
```
┌─────────────────────────────────────────┐
│  ←  Add Details (Optional)              │
├─────────────────────────────────────────┤
│                                         │
│  Help us analyze better                 │
│                                         │
│  Video Title (Optional)                 │
│  ┌───────────────────────────────────┐ │
│  │ How to Build iOS Apps in 2025     │ │
│  └───────────────────────────────────┘ │
│                                         │
│  Category (Optional)                    │
│  ┌───────────────────────────────────┐ │
│  │ Education & How-To            ▾   │ │
│  └───────────────────────────────────┘ │
│                                         │
│  Notes (Optional)                       │
│  ┌───────────────────────────────────┐ │
│  │ Testing face vs no face           │ │
│  │                                   │ │
│  └───────────────────────────────────┘ │
│                                         │
│                                         │
│         [Skip]      [Analyze Now]       │
│                                         │
└─────────────────────────────────────────┘
```

**Step 3: Analyzing**
```
┌─────────────────────────────────────────┐
│                                         │
│                                         │
│            [Loading Animation]          │
│                                         │
│         Analyzing your thumbnails...    │
│                                         │
│         ████████░░░░░░░░░░  60%         │
│                                         │
│                                         │
└─────────────────────────────────────────┘
```

**Step 4: Results**
```
┌─────────────────────────────────────────┐
│  ←  Results                        [⚙]  │
├─────────────────────────────────────────┤
│                                         │
│  🏆 Thumbnail #1 is your winner!        │
│                                         │
│  ┌──────────────────┐ ┌──────────────┐ │
│  │   🥇             │ │              │ │
│  │  ┌────────────┐  │ │┌────────────┐│ │
│  │  │            │  │ ││            ││ │
│  │  │  [IMAGE 1] │  │ ││  [IMAGE 2] ││ │
│  │  │            │  │ ││            ││ │
│  │  └────────────┘  │ │└────────────┘│ │
│  │                  │ │              │ │
│  │  Score: 87/100   │ │ Score: 72/100│ │
│  │  CTR: 8.7%       │ │ CTR: 6.2%    │ │
│  │  ──────────────  │ │ ─────────────│ │
│  │  ■■■■■■■■■□ 87%  │ │ ■■■■■■■□□□ 72%│ │
│  │  [View Details]  │ │[View Details]│ │
│  └──────────────────┘ └──────────────┘ │
│                                         │
│  ┌──────────────────┐ ┌──────────────┐ │
│  │  ┌────────────┐  │ │┌────────────┐│ │
│  │  │            │  │ ││            ││ │
│  │  │  [IMAGE 3] │  │ ││  [IMAGE 4] ││ │
│  │  │            │  │ ││            ││ │
│  │  └────────────┘  │ │└────────────┘│ │
│  │                  │ │              │ │
│  │  Score: 79/100   │ │ Score: 81/100│ │
│  │  CTR: 7.1%       │ │ CTR: 7.5%    │ │
│  │  ──────────────  │ │ ─────────────│ │
│  │  ■■■■■■■■□□ 79%  │ │ ■■■■■■■■□□ 81%│ │
│  │  [View Details]  │ │[View Details]│ │
│  └──────────────────┘ └──────────────┘ │
│                                         │
│     [Save Analysis]   [Share Results]   │
│                                         │
└─────────────────────────────────────────┘
```

---

### Thumbnail Detail View
```
┌─────────────────────────────────────────┐
│  ←  Thumbnail #1                   [↗]  │
├─────────────────────────────────────────┤
│  ┌───────────────────────────────────┐ │
│  │                                   │ │
│  │         [FULL SIZE IMAGE]         │ │
│  │                                   │ │
│  │                                   │ │
│  └───────────────────────────────────┘ │
│                                         │
│  Overall Score              🏆 Winner   │
│  ┌──────────────────────────────────┐  │
│  │        ⭕ 87/100                 │  │
│  │     (Circular Progress)          │  │
│  └──────────────────────────────────┘  │
│                                         │
│  Predicted CTR: 8.7%                    │
│  ────────────────────────────────────  │
│                                         │
│  Score Breakdown                        │
│  ────────────────────────────────────  │
│  Face Visibility           95  ■■■■■■■■■■│
│  Text Readability          82  ■■■■■■■■□□│
│  Color Contrast            88  ■■■■■■■■■□│
│  Visual Clarity            90  ■■■■■■■■■□│
│  Emotional Impact          85  ■■■■■■■■□□│
│                                         │
│  ✓ Face detected                        │
│  📝 Text: "BUILD iOS APPS"              │
│                                         │
│  Recommendations                        │
│  ────────────────────────────────────  │
│  • Excellent face visibility creates    │
│    strong viewer connection             │
│  • Text could be 10% larger for better  │
│    mobile readability                   │
│  • Strong color contrast makes          │
│    thumbnail stand out                  │
│  • Facial expression conveys expertise  │
│                                         │
│         [Use This Thumbnail]            │
│                                         │
└─────────────────────────────────────────┘
```

---

### History Screen
```
┌─────────────────────────────────────────┐
│  History                         [🔍]   │
├─────────────────────────────────────────┤
│  ┌───────────────────────────────────┐ │
│  │ 🔍 Search by title...             │ │
│  └───────────────────────────────────┘ │
│                                         │
│  [All] [Published] [Draft]   [Filter▾] │
│                                         │
│  Today                                  │
│  ┌───────────────────────────────────┐ │
│  │ [🖼️][🖼️][🖼️]  iOS Apps Tutorial   │ │
│  │ 🏆 Winner: #1  •  3:45 PM         │ │
│  │ ⭐ 87  •  Education                │ │
│  └───────────────────────────────────┘ │
│                                         │
│  Yesterday                              │
│  ┌───────────────────────────────────┐ │
│  │ [🖼️][🖼️][🖼️]  React Native Guide  │ │
│  │ 🏆 Winner: #2  •  ✓ Published     │ │
│  │ ⭐ 82  •  CTR: 7.8%  •  Education  │ │
│  └───────────────────────────────────┘ │
│  ┌───────────────────────────────────┐ │
│  │ [🖼️][🖼️]  Python Tutorial          │ │
│  │ 🏆 Winner: #1  •  Draft            │ │
│  │ ⭐ 79  •  Education                │ │
│  └───────────────────────────────────┘ │
│                                         │
│  Nov 14                                 │
│  ┌───────────────────────────────────┐ │
│  │ [🖼️][🖼️][🖼️][🖼️]  Gaming Setup    │ │
│  │ 🏆 Winner: #3  •  ✓ Published     │ │
│  │ ⭐ 85  •  CTR: 9.2%  •  Gaming     │ │
│  └───────────────────────────────────┘ │
│                                         │
│  [Load More]                            │
│                                         │
└─────────────────────────────────────────┘
```

---

### Paywall (Free Tier Limit)
```
┌─────────────────────────────────────────┐
│                                    [X]  │
│                                         │
│          🚀 Upgrade to Creator          │
│                                         │
│  You've used all 3 free analyses        │
│  this month. Upgrade for unlimited!     │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  ✓  Unlimited thumbnail analyses  │ │
│  │  ✓  Detailed scoring breakdowns   │ │
│  │  ✓  Performance tracking          │ │
│  │  ✓  Export & share results        │ │
│  │  ✓  Priority support              │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │       Creator Plan                │ │
│  │       $9.99/month                 │ │
│  │   7-day free trial                │ │
│  └───────────────────────────────────┘ │
│                                         │
│      [Start 7-Day Free Trial]           │
│                                         │
│         Restore Purchases               │
│                                         │
│  Cancel anytime. Terms & Privacy apply. │
│  Resets on Dec 1, 2025                  │
│                                         │
└─────────────────────────────────────────┘
```

---

## 9. MVP SCOPE & PRIORITIES

### MUST HAVE (MVP - Launch)
**Target: 8 weeks**

**Week 1-2: Foundation**
- [ ] Authentication (email, Apple Sign-In)
- [ ] Database setup (users, analyses, thumbnails)
- [ ] Basic API endpoints (auth, profile)
- [ ] iOS project structure (SwiftUI, MVVM)
- [ ] Navigation setup

**Week 3-4: Core Features**
- [ ] Image upload flow (photo library, camera)
- [ ] S3 integration for image storage
- [ ] OpenAI Vision API integration
- [ ] Analysis engine (create, score, save)
- [ ] Results screen (side-by-side comparison)

**Week 5-6: Polish & Monetization**
- [ ] Thumbnail detail view
- [ ] History list view
- [ ] Free tier limit (3/month)
- [ ] In-app purchase (Creator tier $9.99/mo)
- [ ] Subscription management

**Week 7-8: Testing & Launch**
- [ ] Bug fixes
- [ ] Error handling
- [ ] Loading states
- [ ] Empty states
- [ ] App Store assets
- [ ] Beta testing (TestFlight)
- [ ] Submit to App Store

---

### SHOULD HAVE (Post-MVP - Month 2-3)

- [ ] Onboarding tutorial (3 screens)
- [ ] Dark mode support
- [ ] Profile management
- [ ] Category selection
- [ ] Search & filter in history
- [ ] Manual CTR tracking
- [ ] Basic insights dashboard
- [ ] Email notifications
- [ ] iPad optimization
- [ ] Accessibility improvements

---

### NICE TO HAVE (Future - Month 4+)

- [ ] YouTube API integration
- [ ] Automatic CTR tracking
- [ ] Competitor analysis
- [ ] Trend alerts
- [ ] Heatmap predictions
- [ ] Custom thumbnail templates
- [ ] Team collaboration
- [ ] Batch analysis (10+ images)
- [ ] Export reports (PDF)
- [ ] Social sharing
- [ ] Referral program

---

## 10. IMPLEMENTATION PHASES

## PHASE 1: FOUNDATION (Week 1-2)

### Backend Setup
```bash
# Create new Node.js project
npm init -y
npm install express cors dotenv pg jsonwebtoken bcrypt

# Or Python
pip install fastapi uvicorn sqlalchemy psycopg2 python-jose bcrypt

# Database
# Use Supabase (recommended) or PostgreSQL locally
```

### iOS Setup
```bash
# Create new iOS project in Xcode
# File > New > Project > iOS > App
# Name: ThumbnailTest
# Interface: SwiftUI
# Language: Swift

# Add packages
# - Firebase (auth, analytics)
# - Kingfisher (image caching)
```

### Tasks
1. Set up Git repository
2. Create database schema
3. Implement user authentication (backend)
4. Implement auth screens (iOS)
5. Set up API service layer
6. Test authentication flow end-to-end

---

## PHASE 2: IMAGE UPLOAD (Week 3)

### Backend Tasks
1. Set up AWS S3 bucket (or Supabase storage)
2. Implement presigned URL generation
3. Image upload endpoint
4. Image validation (size, format)

### iOS Tasks
1. Image picker integration (PHPicker)
2. Camera integration
3. Image compression
4. Upload progress indicator
5. Thumbnail grid display
6. Delete/reorder functionality

---

## PHASE 3: AI ANALYSIS (Week 4)

### Backend Tasks
1. OpenAI API integration
2. Analysis service layer
3. Prompt engineering
4. Response parsing
5. Score calculation
6. Store results in database
7. Error handling (API failures, timeouts)

### iOS Tasks
1. Analysis creation flow
2. Loading screen with animation
3. Results screen
4. Score visualization
5. Winner highlighting

---

## PHASE 4: DETAILS & HISTORY (Week 5)

### Backend Tasks
1. Analysis list endpoint (pagination)
2. Analysis update endpoint
3. Search/filter logic
4. Thumbnail detail endpoint

### iOS Tasks
1. Thumbnail detail view
2. Score breakdown UI
3. Recommendations list
4. History list view
5. Search bar
6. Pull to refresh
7. Empty states

---

## PHASE 5: MONETIZATION (Week 6)

### Backend Tasks
1. Subscription tier tracking
2. Usage limits enforcement
3. Subscription webhook (App Store)
4. Receipt validation

### iOS Tasks
1. StoreKit 2 integration
2. Product configuration
3. Paywall screen
4. Purchase flow
5. Subscription management
6. Restore purchases
7. Free trial logic

---

## PHASE 6: POLISH & LAUNCH (Week 7-8)

### Tasks
1. Comprehensive testing
2. Fix critical bugs
3. Add loading states everywhere
4. Add error messages
5. Improve empty states
6. Add haptic feedback
7. Performance optimization
8. Create App Store assets:
   - App icon
   - Screenshots (6.5", 5.5")
   - App preview video (optional)
   - Description & keywords
9. Beta testing (10-20 users)
10. Submit to App Store
11. Monitor crash reports
12. Quick hotfixes if needed

---

## 11. DEVELOPMENT GUIDELINES

### Code Organization (iOS)

```
ThumbnailTest/
├── App/
│   ├── ThumbnailTestApp.swift
│   └── ContentView.swift
├── Models/
│   ├── User.swift
│   ├── Analysis.swift
│   ├── Thumbnail.swift
│   └── Subscription.swift
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── AnalysisViewModel.swift
│   ├── HistoryViewModel.swift
│   └── SubscriptionViewModel.swift
├── Views/
│   ├── Auth/
│   │   ├── LoginView.swift
│   │   ├── SignupView.swift
│   │   └── OnboardingView.swift
│   ├── Home/
│   │   ├── HomeView.swift
│   │   └── StatsCardView.swift
│   ├── Analysis/
│   │   ├── NewAnalysisView.swift
│   │   ├── UploadView.swift
│   │   ├── DetailsView.swift
│   │   ├── LoadingView.swift
│   │   ├── ResultsView.swift
│   │   └── ThumbnailDetailView.swift
│   ├── History/
│   │   ├── HistoryView.swift
│   │   └── AnalysisRowView.swift
│   └── Settings/
│       ├── SettingsView.swift
│       ├── ProfileView.swift
│       └── SubscriptionView.swift
├── Services/
│   ├── APIService.swift
│   ├── AuthService.swift
│   ├── ImageService.swift
│   ├── AnalysisService.swift
│   └── SubscriptionService.swift
├── Utilities/
│   ├── Constants.swift
│   ├── Extensions/
│   │   ├── Color+Extensions.swift
│   │   ├── View+Extensions.swift
│   │   └── Image+Extensions.swift
│   └── Components/
│       ├── PrimaryButton.swift
│       ├── ScoreCard.swift
│       └── ThumbnailCard.swift
└── Resources/
    ├── Assets.xcassets
    └── Info.plist
```

---

### Error Handling Best Practices

**Backend:**
```javascript
// Use consistent error format
class AppError extends Error {
  constructor(code, message, statusCode = 500) {
    super(message);
    this.code = code;
    this.statusCode = statusCode;
  }
}

// Example usage
if (user.analysesThisMonth >= 3 && user.subscriptionTier === 'free') {
  throw new AppError(
    'ANALYSIS_LIMIT',
    'You\'ve reached your monthly limit',
    403
  );
}
```

**iOS:**
```swift
enum APIError: LocalizedError {
    case networkError
    case decodingError
    case serverError(String)
    case analysisLimit
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Check your internet connection"
        case .decodingError:
            return "Something went wrong. Please try again."
        case .serverError(let message):
            return message
        case .analysisLimit:
            return "You've reached your monthly limit"
        }
    }
}
```

---

### Testing Checklist

**Unit Tests:**
- [ ] Authentication logic
- [ ] Score calculation
- [ ] API response parsing
- [ ] Subscription validation

**Integration Tests:**
- [ ] Full analysis flow (upload → analyze → save)
- [ ] Authentication flow
- [ ] Subscription purchase flow

**UI Tests:**
- [ ] Navigation flows
- [ ] Form validation
- [ ] Error states
- [ ] Empty states

**Manual Testing:**
- [ ] Test on multiple devices (iPhone 14, 15, iPad)
- [ ] Test on different iOS versions (16, 17, 18)
- [ ] Test slow network conditions
- [ ] Test offline behavior
- [ ] Test with large images (>5MB)
- [ ] Test free tier limits
- [ ] Test subscription purchase
- [ ] Test restore purchases

---

## 12. DEPLOYMENT CHECKLIST

### Backend Deployment
- [ ] Environment variables configured
- [ ] Database migrations run
- [ ] SSL certificate configured
- [ ] CORS configured correctly
- [ ] Rate limiting enabled
- [ ] Error tracking (Sentry) configured
- [ ] Analytics configured
- [ ] Backup strategy in place
- [ ] Health check endpoint working

### iOS App Store
- [ ] App icon (1024x1024)
- [ ] Screenshots (all required sizes)
- [ ] App description (< 4000 chars)
- [ ] Keywords (< 100 chars)
- [ ] Privacy policy URL
- [ ] Terms of service URL
- [ ] Support URL
- [ ] App category selected
- [ ] Content rating completed
- [ ] In-app purchases configured
- [ ] TestFlight beta tested
- [ ] Review notes for Apple

---

## 13. LAUNCH STRATEGY

### Pre-Launch (Week -1)
- [ ] Create landing page
- [ ] Set up email list
- [ ] Prepare social media accounts
- [ ] Write launch blog post
- [ ] Create demo video
- [ ] Reach out to beta testers for reviews

### Launch Day
- [ ] Submit to App Store
- [ ] Post on Product Hunt
- [ ] Post on Reddit (r/iOSProgramming, r/YouTube)
- [ ] Tweet announcement
- [ ] Email list announcement
- [ ] Post in relevant Facebook groups
- [ ] Monitor crash reports
- [ ] Respond to feedback quickly

### Post-Launch (Week 1-4)
- [ ] Daily metrics monitoring
- [ ] User feedback collection
- [ ] Bug fixes (priority: P0 > P1 > P2)
- [ ] Iterate on AI prompts
- [ ] A/B test paywall
- [ ] Plan next features based on feedback

---

## 14. SUCCESS METRICS & KPIs

### Acquisition
- Signups per day
- Signup source (organic, paid, referral)
- App Store page views
- App Store conversion rate

### Activation
- % of signups who complete first analysis
- Time to first analysis
- Onboarding completion rate

### Engagement
- DAU / MAU ratio
- Analyses per user per month
- Time spent in app
- Retention (D1, D7, D30)

### Monetization
- Free to paid conversion rate
- Trial to paid conversion rate
- Monthly Recurring Revenue (MRR)
- Average Revenue Per User (ARPU)
- Churn rate

### Quality
- App Store rating
- Crash-free rate (target: >99.5%)
- API response time (target: <3s)
- User satisfaction (NPS score)

---

## 15. SUPPORT & DOCUMENTATION

### User Documentation
- [ ] Getting started guide
- [ ] FAQ page
- [ ] Tutorial videos
- [ ] Best practices for thumbnails
- [ ] How to interpret scores
- [ ] Subscription management help

### Developer Documentation
- [ ] API documentation (Swagger/OpenAPI)
- [ ] Database schema docs
- [ ] Deployment guide
- [ ] Troubleshooting guide
- [ ] Contributing guide (if open source)

---

## 16. LEGAL & COMPLIANCE

- [ ] Privacy Policy (GDPR compliant)
- [ ] Terms of Service
- [ ] Data retention policy (90 days)
- [ ] Data deletion process
- [ ] Cookie policy (if web dashboard)
- [ ] Apple App Store guidelines compliance
- [ ] OpenAI API terms compliance
- [ ] User content policy

---

## 17. FUTURE ROADMAP (6-12 months)

**Q1 2026**
- YouTube API integration
- Automatic CTR tracking
- Advanced insights dashboard
- iPad optimization

**Q2 2026**
- Competitor analysis
- Trend alerts
- Custom thumbnail templates
- Batch analysis

**Q3 2026**
- Team collaboration features
- API for third-party integrations
- White-label solution for agencies
- Desktop app (Mac)

**Q4 2026**
- Custom ML model (lower costs)
- Video preview testing
- Title A/B testing
- Multi-platform support (TikTok, Instagram)

---

## 18. CONTACT & RESOURCES

**Project Manager:** [Your Name]
**Technical Lead:** Claude Code
**Design Lead:** [Designer Name]

**Resources:**
- Design Files: [Figma Link]
- API Documentation: [Swagger Link]
- Issue Tracker: [GitHub/Jira Link]
- Slack Channel: #thumbnailtest
- Deployment: [Production URL]

---

## APPENDIX A: TECHNICAL DECISIONS

### Why SwiftUI over UIKit?
- Modern declarative syntax
- Less boilerplate code
- Better for rapid prototyping
- Native iOS 16+ features
- Easier animations and transitions

### Why OpenAI Vision over Custom Model (MVP)?
- Faster time to market (no training data needed)
- Good accuracy out of the box
- Easy to iterate on prompts
- Can always switch to custom model later

### Why Supabase over Custom Backend?
- Faster development
- Built-in auth, storage, database
- Real-time capabilities
- Row-level security
- Good free tier for MVP
- Can migrate to custom backend if needed

---

## APPENDIX B: SAMPLE DATA

### Sample Analysis Response
```json
{
  "analysisId": "550e8400-e29b-41d4-a716-446655440000",
  "status": "completed",
  "createdAt": "2025-11-17T10:30:00Z",
  "videoTitle": "How to Build iOS Apps in 2025",
  "category": "education",
  "thumbnails": [
    {
      "id": "thumb-1",
      "imageUrl": "https://storage.example.com/thumb1.jpg",
      "orderIndex": 1,
      "overallScore": 87,
      "scores": {
        "faceVisibility": 95,
        "textReadability": 82,
        "colorContrast": 88,
        "visualClarity": 90,
        "emotionalImpact": 85
      },
      "predictedCTR": 8.7,
      "isWinner": true,
      "faceDetected": true,
      "textDetected": "BUILD iOS APPS",
      "recommendations": [
        "Excellent face visibility creates strong viewer connection",
        "Text could be 10% larger for better mobile readability",
        "Strong color contrast makes thumbnail stand out in feed",
        "Facial expression conveys expertise and confidence"
      ]
    }
  ]
}
```

---

## REVISION HISTORY

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Nov 17, 2025 | Product Team | Initial PRD created |

---

**END OF DOCUMENT**
