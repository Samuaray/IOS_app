# ThumbnailTest Backend Setup Guide

Complete guide to setting up the Supabase backend for ThumbnailTest iOS app.

## Prerequisites

1. **Supabase Account** - https://supabase.com (Free tier works!)
2. **OpenAI API Key** - https://platform.openai.com/api-keys
3. **Supabase CLI** (optional, for Edge Functions):
   ```bash
   npm install -g supabase
   ```

---

## Step 1: Create Supabase Project

1. Go to https://supabase.com/dashboard
2. Click "New Project"
3. Fill in:
   - **Name**: ThumbnailTest
   - **Database Password**: (generate a strong password - save it!)
   - **Region**: Choose closest to your users
4. Click "Create new project"
5. Wait 2-3 minutes for setup to complete

---

## Step 2: Set Up Database

### 2.1 Run Database Schema

1. In Supabase Dashboard, go to **SQL Editor**
2. Click "New Query"
3. Copy the entire contents of `backend/schema.sql`
4. Paste into the SQL Editor
5. Click "Run" or press `Cmd/Ctrl + Enter`
6. You should see: "Success. No rows returned"

### 2.2 Verify Tables Created

1. Go to **Database** > **Tables**
2. You should see 3 tables:
   - `users`
   - `analyses`
   - `thumbnails`

---

## Step 3: Set Up Storage (for images)

1. In Supabase Dashboard, go to **Storage**
2. Click "Create a new bucket"
3. Fill in:
   - **Name**: `thumbnails`
   - **Public bucket**: ✅ Checked
   - **File size limit**: 10 MB
   - **Allowed MIME types**: image/jpeg, image/png, image/heic
4. Click "Create bucket"

### 3.1 Configure Bucket Policies

1. Click on the `thumbnails` bucket
2. Go to **Policies** tab
3. Click "New Policy" > "For full customization"
4. **Policy for INSERT:**
   ```sql
   CREATE POLICY "Users can upload thumbnails"
   ON storage.objects
   FOR INSERT
   WITH CHECK (
     bucket_id = 'thumbnails' AND
     auth.uid() IS NOT NULL
   );
   ```

5. **Policy for SELECT (public read):**
   ```sql
   CREATE POLICY "Public can view thumbnails"
   ON storage.objects
   FOR SELECT
   USING (bucket_id = 'thumbnails');
   ```

---

## Step 4: Set Up Authentication

### 4.1 Email Authentication

1. Go to **Authentication** > **Providers**
2. **Email** provider is enabled by default
3. Configure settings:
   - **Enable email confirmations**: ✅ (optional for MVP)
   - **Enable email change confirmations**: ✅
   - **Minimum password length**: 8

### 4.2 Apple Sign-In (Optional)

1. In Supabase: **Authentication** > **Providers**
2. Enable **Apple** provider
3. You'll need:
   - **Service ID**: (from Apple Developer)
   - **Team ID**: (from Apple Developer)
   - **Key ID**: (from Apple Developer)
   - **Private Key**: (from Apple Developer)
4. Follow Supabase docs: https://supabase.com/docs/guides/auth/social-login/auth-apple

### 4.3 Google Sign-In (Optional)

1. In Supabase: **Authentication** > **Providers**
2. Enable **Google** provider
3. You'll need:
   - **Client ID**: (from Google Cloud Console)
   - **Client Secret**: (from Google Cloud Console)
4. Follow Supabase docs: https://supabase.com/docs/guides/auth/social-login/auth-google

---

## Step 5: Deploy OpenAI Analysis Function

### Option A: Using Supabase CLI (Recommended)

1. **Install Supabase CLI:**
   ```bash
   npm install -g supabase
   ```

2. **Login to Supabase:**
   ```bash
   supabase login
   ```

3. **Link to your project:**
   ```bash
   cd backend
   supabase link --project-ref YOUR_PROJECT_REF
   ```
   (Find YOUR_PROJECT_REF in: Settings > General > Reference ID)

4. **Set OpenAI API key secret:**
   ```bash
   supabase secrets set OPENAI_API_KEY=sk-your-actual-key-here
   ```

5. **Deploy the function:**
   ```bash
   supabase functions deploy analyze-thumbnails
   ```

6. **Verify deployment:**
   - Go to **Edge Functions** in Supabase Dashboard
   - You should see `analyze-thumbnails` function

### Option B: Manual Deployment (via Dashboard)

1. Go to **Edge Functions** in Supabase Dashboard
2. Click "Create a new function"
3. Name: `analyze-thumbnails`
4. Copy code from `backend/supabase/functions/analyze-thumbnails/index.ts`
5. Paste into editor
6. Click "Deploy function"
7. Go to **Edge Functions** > **Settings**
8. Add secret: `OPENAI_API_KEY` = `sk-your-key-here`

---

## Step 6: Get API Keys

### 6.1 Supabase Keys

1. Go to **Settings** > **API**
2. Copy these values:
   - **Project URL**: `https://xxx.supabase.co`
   - **anon / public key**: `eyJhbG...` (starts with eyJ)
   - **service_role key**: (keep this SECRET!)

### 6.2 Update iOS App

Open `/ThumbnailTest/Utilities/Constants.swift` and update:

```swift
struct API {
    static let baseURL = "https://xxx.supabase.co" // Your Supabase URL
}
```

Create a new file: `/ThumbnailTest/Config.swift`:

```swift
struct SupabaseConfig {
    static let url = "https://xxx.supabase.co"
    static let anonKey = "eyJhbG..." // Your anon key
}
```

---

## Step 7: Test the Backend

### 7.1 Test User Registration

Use Supabase Auth API or the iOS app to create a test user:

```bash
curl -X POST 'https://xxx.supabase.co/auth/v1/signup' \
-H "apikey: YOUR_ANON_KEY" \
-H "Content-Type: application/json" \
-d '{
  "email": "test@example.com",
  "password": "testpassword123"
}'
```

### 7.2 Verify User Created

1. Go to **Authentication** > **Users**
2. You should see your test user

### 7.3 Test Analysis Function

```bash
# Get access token first (login)
curl -X POST 'https://xxx.supabase.co/auth/v1/token?grant_type=password' \
-H "apikey: YOUR_ANON_KEY" \
-H "Content-Type: application/json" \
-d '{
  "email": "test@example.com",
  "password": "testpassword123"
}'

# Save the access_token from response, then:
curl -X POST 'https://xxx.supabase.co/functions/v1/analyze-thumbnails' \
-H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
-H "Content-Type: application/json" \
-d '{
  "videoTitle": "Test Video",
  "category": "Education",
  "thumbnails": [
    {"imageUrl": "https://example.com/image1.jpg", "order": 1},
    {"imageUrl": "https://example.com/image2.jpg", "order": 2}
  ]
}'
```

---

## Step 8: iOS App Configuration

### 8.1 Update Constants

Edit `/ThumbnailTest/Utilities/Constants.swift`:

```swift
struct API {
    // Update with your Supabase URL
    static let baseURL = "https://xxx.supabase.co"

    #if DEBUG
    static let currentURL = baseURL + "/functions/v1"
    #else
    static let currentURL = baseURL + "/functions/v1"
    #endif
}
```

### 8.2 Update AuthService for Supabase

You'll need to modify `AuthService.swift` to use Supabase Auth endpoints:

- Signup: `POST /auth/v1/signup`
- Login: `POST /auth/v1/token?grant_type=password`
- Apple: `POST /auth/v1/token?grant_type=id_token`
- Google: `POST /auth/v1/token?grant_type=id_token`

---

## Step 9: Environment Variables

Create `backend/.env` (copy from `.env.example`):

```bash
cp .env.example .env
```

Fill in your actual values:

```
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=eyJhbG...
SUPABASE_SERVICE_KEY=eyJhbG...

OPENAI_API_KEY=sk-...

# These are for Phase 5 (Subscriptions)
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

**⚠️ NEVER commit `.env` to git!** (It's in .gitignore)

---

## Step 10: Monthly Reset (Cron Job)

To reset free tier counts monthly:

1. Go to **Database** > **Cron Jobs** (pg_cron extension)
2. Enable pg_cron if not enabled
3. Create a new cron job:

```sql
SELECT cron.schedule(
  'reset-monthly-analyses',
  '0 0 1 * *', -- Run at midnight on 1st of each month
  $$
  SELECT reset_monthly_analyses();
  $$
);
```

---

## Troubleshooting

### "Missing authorization header"
- Make sure you're sending `Authorization: Bearer <token>` header
- Token must be valid (not expired)

### "OpenAI API error"
- Verify `OPENAI_API_KEY` is set correctly in Edge Function secrets
- Check OpenAI account has credits
- Ensure you're using `gpt-4-vision-preview` model

### "Row Level Security policy violation"
- Make sure RLS policies are created (from schema.sql)
- Verify user is authenticated
- Check user owns the resource they're trying to access

### Edge Function timeout
- OpenAI API can take 5-10 seconds
- Default timeout is 60s, should be fine
- Check function logs in Supabase Dashboard

---

## Cost Estimation

**Supabase (Free Tier):**
- 500 MB database storage
- 1 GB file storage
- 2 GB bandwidth
- 50,000 monthly active users
- **Cost: FREE** (upgrade to $25/mo for more)

**OpenAI Vision API:**
- ~$0.01 per image analyzed
- 4 images per analysis = $0.04
- 1,000 analyses = $40
- **Cost: Pay as you go**

---

## Next Steps

✅ Backend is now ready!

**Test the app:**
1. Build and run iOS app
2. Create account
3. Upload thumbnails
4. See AI analysis!

**Phase 5: Monetization**
- Set up Stripe
- Implement StoreKit 2
- Connect subscriptions

---

## Support Resources

- **Supabase Docs**: https://supabase.com/docs
- **OpenAI API Docs**: https://platform.openai.com/docs
- **Edge Functions Guide**: https://supabase.com/docs/guides/functions
- **Row Level Security**: https://supabase.com/docs/guides/auth/row-level-security

---

## Quick Reference

**Supabase Dashboard**: https://supabase.com/dashboard
**Project URL**: https://xxx.supabase.co
**Edge Functions URL**: https://xxx.supabase.co/functions/v1

**Endpoints:**
- Auth Signup: `POST /auth/v1/signup`
- Auth Login: `POST /auth/v1/token?grant_type=password`
- Analyze: `POST /functions/v1/analyze-thumbnails`
- User Profile: `GET /rest/v1/users?id=eq.{user_id}`
- Analyses List: `GET /rest/v1/analyses?user_id=eq.{user_id}`

That's it! Your backend is ready to power ThumbnailTest! 🚀
