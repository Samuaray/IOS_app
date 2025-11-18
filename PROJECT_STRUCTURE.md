# ThumbnailTest - Project Structure Guide

This document explains the architecture, folder structure, and purpose of every file in the ThumbnailTest iOS app.

---

## 📐 Architecture Overview

The app follows the **MVVM (Model-View-ViewModel)** architecture pattern:

- **Models**: Data structures (User, Analysis, Thumbnail)
- **Views**: SwiftUI UI components (screens, buttons, cards)
- **ViewModels**: Business logic and state management (connects Models to Views)
- **Services**: API calls and external integrations (Supabase, StoreKit)

### Data Flow:
```
User Action → View → ViewModel → Service → API/Backend
                ↑        ↑          ↑
                └────────┴──────────┘
              (Updates via @Published)
```

---

## 📁 Folder Structure

```
ThumbnailTest/
├── App/                    # App entry points
├── Models/                 # Data structures
├── Services/               # API & external integrations
├── ViewModels/             # Business logic & state
├── Views/                  # UI components
│   ├── Auth/              # Login/Signup screens
│   ├── Home/              # Dashboard
│   ├── Analysis/          # Upload & results
│   ├── History/           # Past analyses
│   ├── Subscription/      # Paywall & monetization
│   ├── Settings/          # Account settings
│   └── Components/        # Reusable UI elements
├── Utilities/              # Helpers & constants
│   ├── Extensions/        # Swift extensions
│   └── Helpers/           # Utility functions
├── Assets.xcassets/       # Images & icons
└── Info.plist             # App configuration
```

---

## 📄 File-by-File Breakdown

### **App/** - Application Entry Points

#### `ThumbnailTestApp.swift`
- **Purpose**: Main app entry point with `@main` attribute
- **Responsibilities**:
  - Creates app lifecycle
  - Initializes global `AuthViewModel`
  - Provides environment objects to entire app
- **Key Code**:
  ```swift
  @StateObject private var authViewModel = AuthViewModel()
  var body: some Scene {
      WindowGroup {
          ContentView().environmentObject(authViewModel)
      }
  }
  ```

#### `ContentView.swift`
- **Purpose**: Root view that handles authentication routing
- **Responsibilities**:
  - Shows login screen if not authenticated
  - Shows main app (tabs) if authenticated
  - Observes `@EnvironmentObject var authViewModel`
- **Key Code**:
  ```swift
  if authViewModel.isAuthenticated {
      MainTabView()
  } else {
      LoginView()
  }
  ```

---

### **Models/** - Data Structures

#### `User.swift`
- **Purpose**: Represents a user account
- **Properties**:
  - `id`, `email`, `fullName`, `channelName`
  - `subscriptionTier` (free, creator, pro)
  - `analysesThisMonth` (usage tracking)
  - `createdAt`, `updatedAt`
- **Computed Properties**:
  - `isFreeTier` - checks if on free plan
  - `hasReachedLimit` - true if used 3/3 analyses
  - `remainingAnalyses` - how many left this month
  - `subscriptionDisplayName` - "Free", "Creator", "Pro"
- **Used By**: AuthViewModel, UserService, all views

#### `Analysis.swift`
- **Purpose**: Represents one thumbnail analysis session
- **Properties**:
  - `id`, `userId`, `videoTitle`, `category`
  - `thumbnails` - array of 2-4 thumbnails
  - `status` (analyzing, completed, failed)
  - `createdAt`
- **Computed Properties**:
  - `winner` - thumbnail with highest score
  - `thumbnailsCount` - number of thumbnails
- **Used By**: AnalysisViewModel, HistoryViewModel, all results views

#### `Thumbnail.swift`
- **Purpose**: Represents one thumbnail image with AI scores
- **Properties**:
  - `id`, `imageUrl`, `orderIndex` (1-4)
  - `overallScore` (0-100)
  - `faceScore`, `textReadabilityScore`, `colorScore`, `clarityScore`, `emotionalImpactScore`
  - `aiRecommendations` - array of improvement tips
- **Computed Properties**:
  - `scoreBreakdown` - formatted for UI display
  - `scoreColor` - color based on score range
  - `scoreGrade` - "Excellent", "Good", "Fair", "Needs Work"
- **Used By**: All results and detail views

#### `Subscription.swift`
- **Purpose**: Subscription-related data structures
- **Contains**:
  - `SubscriptionTier` enum (free, creator, pro)
  - `SubscriptionInfo` - detailed subscription data
  - `SubscriptionStatus` - StoreKit status info
- **Used By**: SubscriptionService, UserService, paywall views

---

### **Services/** - API & External Integrations

#### `APIService.swift`
- **Purpose**: Generic HTTP client for all API calls
- **Responsibilities**:
  - Makes GET, POST, PUT, DELETE requests
  - Handles authentication (JWT tokens)
  - Error mapping and handling
  - JSON encoding/decoding
- **Key Methods**:
  - `request<T: Decodable>()` - generic async request
  - `saveToken()` / `getToken()` - keychain storage
  - `clearToken()` - logout
- **Used By**: All other services (AuthService, AnalysisService, etc.)

#### `AuthService.swift`
- **Purpose**: User authentication and session management
- **Responsibilities**:
  - Email/password login and signup
  - Apple Sign-In integration (ready)
  - Google Sign-In integration (ready)
  - Token storage in Keychain (secure)
  - Session refresh
- **Key Methods**:
  - `login(email:password:)` → User
  - `signup(email:password:fullName:)` → User
  - `loginWithApple(idToken:)` → User
  - `logout()`
- **API Endpoints**:
  - POST `/auth/login`
  - POST `/auth/signup`
  - POST `/auth/apple`
  - POST `/auth/google`
- **Used By**: AuthViewModel

#### `ImageService.swift`
- **Purpose**: Image processing and upload
- **Responsibilities**:
  - Compress images before upload (saves bandwidth)
  - Upload to Supabase Storage (S3)
  - Generate signed URLs for backend
  - Delete images from storage
- **Key Methods**:
  - `compressImage(_ image: UIImage)` → Data
  - `uploadImage(_ imageData: Data, filename: String)` → URL
  - `uploadImages(_ images: [UIImage])` → [URL]
  - `deleteImage(url: String)`
- **Image Compression**:
  - Max width: 1200px
  - Quality: 0.7 (70%)
  - Format: JPEG
- **Used By**: AnalysisViewModel

#### `AnalysisService.swift`
- **Purpose**: Thumbnail analysis API
- **Responsibilities**:
  - Submit analysis requests to backend
  - Poll for analysis completion
  - Fetch analysis history
  - Delete analyses
- **Key Methods**:
  - `createAnalysis(imageUrls:videoTitle:category:)` → Analysis
  - `getAnalysis(id:)` → Analysis
  - `getHistory(page:limit:filter:)` → [Analysis]
  - `deleteAnalysis(id:)`
- **API Endpoints**:
  - POST `/analyses` - create new analysis
  - GET `/analyses/:id` - get single analysis
  - GET `/analyses` - get user's history
  - DELETE `/analyses/:id` - delete analysis
- **Used By**: AnalysisViewModel, HistoryViewModel

#### `UserService.swift`
- **Purpose**: User profile and account management
- **Responsibilities**:
  - Fetch user profile
  - Update profile (name, channel, niche)
  - Get subscription info
  - Delete account
- **Key Methods**:
  - `getProfile()` → User
  - `updateProfile(fullName:channelName:...)` → User
  - `getSubscription()` → SubscriptionInfo
  - `deleteAccount()`
- **API Endpoints**:
  - GET `/user/profile`
  - PUT `/user/profile`
  - GET `/user/subscription`
  - DELETE `/user/account`
- **Used By**: SettingsView, ProfileEditView

#### `SubscriptionService.swift`
- **Purpose**: In-app purchase (IAP) and StoreKit 2 integration
- **Responsibilities**:
  - Load products from App Store Connect
  - Handle purchases
  - Verify transactions
  - Restore purchases
  - Listen for transaction updates
  - Sync with backend
- **Key Methods**:
  - `loadProducts()` - fetch from App Store
  - `purchase(_ product: Product)` → Transaction?
  - `restorePurchases()`
  - `updateSubscriptionStatus()`
- **Product IDs**:
  - `com.thumbnailtest.creator.monthly` - $9.99/month with 7-day trial
  - `com.thumbnailtest.pro.monthly` - $29.99/month (optional)
- **Transaction Verification**:
  - Uses StoreKit 2's built-in `checkVerified()` for security
  - Prevents fraud and jailbreak exploits
- **Used By**: SubscriptionViewModel, PaywallView

---

### **ViewModels/** - Business Logic & State Management

#### `AuthViewModel.swift`
- **Purpose**: Manages authentication state for entire app
- **Responsibilities**:
  - Login/signup flows
  - Session management
  - Current user state
  - Auto-login on app launch
- **Published State**:
  - `@Published var currentUser: User?`
  - `@Published var isAuthenticated: Bool`
  - `@Published var isLoading: Bool`
  - `@Published var errorMessage: String?`
- **Key Methods**:
  - `login(email:password:)`
  - `signup(email:password:fullName:)`
  - `logout()`
  - `checkAuthStatus()` - auto-login
- **Used By**: All views via `@EnvironmentObject`

#### `AnalysisViewModel.swift`
- **Purpose**: Manages thumbnail analysis workflow
- **Responsibilities**:
  - Image selection and upload
  - Analysis submission
  - Results fetching
  - Progress tracking
- **Published State**:
  - `@Published var selectedImages: [UIImage]`
  - `@Published var currentAnalysis: Analysis?`
  - `@Published var isAnalyzing: Bool`
  - `@Published var progress: Double`
- **Key Methods**:
  - `addImages(_ images: [UIImage])`
  - `removeImage(at index: Int)`
  - `uploadAndAnalyze(videoTitle:category:)`
  - `pollForResults(analysisId:)`
- **Used By**: UploadView, NewAnalysisView, AnalysisResultsView

#### `HistoryViewModel.swift`
- **Purpose**: Manages analysis history list
- **Responsibilities**:
  - Load past analyses with pagination
  - Search by video title
  - Filter by status/category
  - Pull-to-refresh
  - Delete analyses
- **Published State**:
  - `@Published var analyses: [Analysis]`
  - `@Published var searchText: String`
  - `@Published var selectedFilter: FilterOption`
  - `@Published var isLoading: Bool`
- **Key Methods**:
  - `loadAnalyses(page:)`
  - `search(_ query: String)`
  - `applyFilter(_ filter: FilterOption)`
  - `refresh()`
  - `deleteAnalysis(_ id: String)`
- **Used By**: HistoryView, AnalysisHistoryRow

#### `SubscriptionViewModel.swift`
- **Purpose**: Manages subscription UI state
- **Responsibilities**:
  - Load products from SubscriptionService
  - Handle purchase flows
  - Show success/error messages
  - Restore purchases
- **Published State**:
  - `@Published var products: [Product]`
  - `@Published var isPurchasing: Bool`
  - `@Published var showSuccessMessage: Bool`
  - `@Published var errorMessage: String?`
  - `@Published var subscriptionStatus: SubscriptionStatus?`
- **Key Methods**:
  - `loadProducts()`
  - `purchase(_ product: Product)`
  - `restorePurchases()`
- **Used By**: PaywallView, SubscriptionManagementView

---

### **Views/** - UI Components

### **Views/Auth/** - Authentication Screens

#### `LoginView.swift`
- **Purpose**: Email/password login screen
- **UI Elements**:
  - Email text field
  - Password text field (secure)
  - "Log In" button
  - "Don't have an account?" link to SignupView
  - Apple/Google sign-in buttons (ready for integration)
- **State Management**:
  - Uses `@EnvironmentObject var authViewModel`
  - Shows loading spinner during login
  - Displays error alerts
- **Design**: Full-screen gradient background, centered card

#### `SignupView.swift`
- **Purpose**: New user registration
- **UI Elements**:
  - Full name text field
  - Email text field
  - Password text field (with strength indicator)
  - "Create Account" button
  - "Already have an account?" link to LoginView
- **Validation**:
  - Email format check
  - Password minimum 8 characters
  - Full name required
- **Design**: Matches LoginView style

---

### **Views/Home/** - Dashboard

#### `HomeView.swift`
- **Purpose**: Main dashboard after login
- **UI Elements**:
  - Welcome message with user name
  - Usage stats card (free tier: "2 of 3 analyses used")
  - Quick action buttons ("New Analysis", "View History")
  - Recent analyses preview (last 3)
  - Tips and insights section
- **State Management**:
  - Uses `@EnvironmentObject var authViewModel`
  - Fetches recent analyses on appear
- **Design**: Scrollable, card-based layout

---

### **Views/Analysis/** - Upload & Results

#### `NewAnalysisView.swift`
- **Purpose**: Orchestrates the full analysis workflow
- **Workflow Steps**:
  1. Upload (select 2-4 thumbnails)
  2. Details (enter video title, category)
  3. Loading (analyzing with AI)
  4. Results (show scores and winner)
- **Responsibilities**:
  - Step navigation
  - Free tier limit checking → trigger paywall
  - Pass data between steps
- **State Management**:
  - `@State private var currentStep: AnalysisStep`
  - Uses `AnalysisViewModel` for data
- **Paywall Integration**:
  - Shows PaywallView if `user.hasReachedLimit`

#### `UploadView.swift`
- **Purpose**: Image selection screen (Step 1)
- **UI Elements**:
  - 2x2 grid of thumbnail slots
  - "Photo Library" button (opens ImagePicker)
  - "Take Photo" button (opens CameraPicker)
  - Delete buttons on each thumbnail
  - "Continue" button (requires 2-4 images)
- **Image Handling**:
  - Max 4 thumbnails
  - Shows placeholder boxes for empty slots
  - Drag to reorder (future enhancement)
- **Validation**: Disabled "Continue" until 2+ images selected

#### `DetailsView.swift`
- **Purpose**: Capture analysis context (Step 2)
- **UI Elements**:
  - Video title text field
  - Category picker (Tech, Education, Entertainment, etc.)
  - Optional notes field
  - "Analyze Thumbnails" button
- **Design**: Simple form with clear labels

#### `LoadingView.swift`
- **Purpose**: Animated loading screen during analysis (Step 3)
- **UI Elements**:
  - Spinning thumbnail icons animation
  - "Analyzing your thumbnails..." text
  - Progress bar (0-100%)
  - AI processing messages ("Analyzing faces...", "Checking readability...")
- **Animation**:
  - Rotating thumbnails
  - Pulsing effects
  - Smooth progress updates
- **Duration**: 10-30 seconds (actual AI processing time)

#### `AnalysisResultsView.swift`
- **Purpose**: Main results screen showing winner and all scores (Step 4)
- **UI Elements**:
  - **Winner Section**: Trophy icon, "Thumbnail #2 is your winner!", large score
  - **Comparison Grid**: 2x2 grid of all thumbnails with scores
  - **Quick Insights**: 3-4 bullet points of key findings
  - **Actions**: "View Detailed Breakdown", "Start New Analysis", "Share Results"
- **Interactions**:
  - Tap thumbnail → opens ThumbnailDetailView
  - Swipe to dismiss (goes back to home)
- **Design**: Celebration feel for winner, clear visual hierarchy

#### `ThumbnailDetailView.swift`
- **Purpose**: Deep dive into one thumbnail's scores
- **UI Elements**:
  - Large thumbnail image (full width)
  - **Overall Score**: 140px circular score with gradient ring
  - **Score Breakdown**: 5 horizontal bars with icons
    - 👤 Face Detection (0-100)
    - 📝 Text Readability (0-100)
    - 🎨 Color Psychology (0-100)
    - 🔍 Visual Clarity (0-100)
    - ❤️ Emotional Impact (0-100)
  - **AI Recommendations**: List of improvement tips
    - ✅ "Strong eye contact creates connection"
    - ⚠️ "Text could be larger for mobile viewers"
- **Design**: Scrollable, detailed analysis report

---

### **Views/History/** - Past Analyses

#### `HistoryView.swift`
- **Purpose**: List of all past thumbnail analyses
- **UI Elements**:
  - Search bar (searches video titles)
  - Filter chips (All, Published, Draft)
  - Advanced filter button (opens sheet)
  - List of analyses (AnalysisHistoryRow for each)
  - Pull-to-refresh
  - "No analyses yet" empty state
- **Features**:
  - Infinite scroll pagination
  - Swipe-to-delete
  - Tap row → opens AnalysisResultsView
- **State Management**: Uses `HistoryViewModel`

#### `AnalysisHistoryRow.swift`
- **Purpose**: Single row in history list
- **UI Elements**:
  - 4 thumbnail previews (2x2 mini grid)
  - Video title (bold)
  - Date and status badge
  - Winner indicator (crown icon on winning thumbnail)
  - Chevron for navigation
- **Design**: Compact, scannable list item

---

### **Views/Subscription/** - Monetization

#### `PaywallView.swift`
- **Purpose**: Beautiful subscription sales page
- **UI Elements**:
  - **Header**: Crown icon, "Unlock Unlimited Analyses"
  - **Features List**:
    - ✨ Unlimited thumbnail analyses
    - 📊 Advanced insights & recommendations
    - 🎯 Priority processing
    - 📈 Historical data & trends
  - **Product Cards**:
    - Creator tier ($9.99/mo) - "MOST POPULAR" badge
    - Pro tier ($29.99/mo) - "FOR TEAMS" badge
  - **Free Trial**: "Start 7-day free trial, then $9.99/month"
  - **Footer**: Terms, Privacy, Restore Purchases links
- **Interactions**:
  - Tap product → starts purchase flow
  - Shows loading during purchase
  - Success → dismisses and shows confetti
- **Design**: Premium feel with gradients, large CTAs

#### `SubscriptionManagementView.swift`
- **Purpose**: Manage active subscription
- **UI Elements**:
  - **Current Plan Card**:
    - FREE badge (gray) or PREMIUM badge (gold gradient)
    - Plan name and benefits
    - "Upgrade" button (if free) or "Current Plan" (if paid)
  - **Usage Section** (free tier only):
    - "Analyses Used: 2 of 3"
    - Progress bar with gradient fill
    - "Resets on Dec 1, 2025"
  - **Subscription Details** (paid users):
    - "Next billing date: Dec 1, 2025"
    - "Renews automatically"
    - "Manage Subscription" button → opens App Store
  - **Features List**: What's included in current plan
  - **Restore Purchases** button
- **Deep Links**:
  - "Manage Subscription" → `UIApplication.openURL()` to App Store subscriptions
- **Design**: Clean, informative, not pushy

---

### **Views/Settings/** - Account Settings

#### `SettingsView.swift`
- **Purpose**: Account and app settings hub
- **Sections**:
  1. **Profile Header**:
     - Avatar with initials (gradient background)
     - Full name
     - Email
     - Subscription badge

  2. **Account**:
     - 👑 Subscription → SubscriptionManagementView
     - 👤 Edit Profile → ProfileEditView

  3. **Support & Legal**:
     - ❓ Help Center (external link)
     - 🔒 Privacy Policy (external link)
     - 📄 Terms of Service (external link)

  4. **About**:
     - ℹ️ Version 1.0.0 (1)
     - 🌐 Website (external link)

  5. **Danger Zone** (red text):
     - 🚪 Log Out (confirmation alert)
     - 🗑️ Delete Account (warning alert)
- **Design**: Standard iOS Settings-style grouped list

#### `ProfileEditView.swift`
- **Purpose**: Edit user profile information
- **Form Fields**:
  - Full Name
  - YouTube Channel Name
  - Content Niche (picker: Tech, Education, Entertainment, etc.)
  - Subscriber Range (picker: <1K, 1K-10K, 10K-100K, etc.)
  - Upload Frequency (picker: Daily, Weekly, Bi-weekly, Monthly)
- **Actions**:
  - "Save Changes" button → calls `UserService.updateProfile()`
  - Shows loading during save
  - Auto-dismisses on success
- **Design**: Standard form with sections

---

### **Views/Components/** - Reusable UI Elements

#### `PrimaryButton.swift`
- **Purpose**: Main call-to-action button
- **Props**:
  - `title: String` - button text
  - `isLoading: Bool` - shows spinner
  - `action: () -> Void` - tap handler
- **Design**:
  - Full-width
  - Gradient background (red theme)
  - White bold text
  - Rounded corners
  - Disabled state (gray)
- **Used By**: All forms and actions

#### `CustomTextField.swift`
- **Purpose**: Styled text input field
- **Props**:
  - `placeholder: String`
  - `text: Binding<String>`
  - `isSecure: Bool` - for passwords
  - `keyboardType: UIKeyboardType`
- **Design**:
  - White background
  - Gray border
  - Padding
  - Icon support (optional)
- **Used By**: Login, Signup, DetailsView

#### `CircularScoreView.swift`
- **Purpose**: Animated circular progress ring with score
- **Props**:
  - `score: Int` (0-100)
  - `size: CGFloat` (default 140)
- **Design**:
  - Gradient stroke (color changes based on score)
  - Score text in center
  - Animated fill on appear (0% → score%)
- **Color Coding**:
  - 0-40: Red (needs work)
  - 41-70: Orange (fair)
  - 71-85: Blue (good)
  - 86-100: Green (excellent)
- **Used By**: ThumbnailDetailView, ThumbnailResultCard

#### `ScoreBar.swift`
- **Purpose**: Horizontal bar chart for individual metrics
- **Props**:
  - `title: String` - metric name
  - `score: Int` (0-100)
  - `icon: String` - SF Symbol name
- **Design**:
  - Icon on left
  - Title text
  - Gray background bar
  - Gradient filled bar (width = score%)
  - Score number on right
  - Animated fill on appear
- **Used By**: ThumbnailDetailView

#### `ThumbnailResultCard.swift`
- **Purpose**: Compact thumbnail card with score
- **Props**:
  - `thumbnail: Thumbnail`
  - `onTap: () -> Void`
- **Design**:
  - Thumbnail image (aspect fill)
  - Gradient overlay on bottom
  - Score badge in top-right corner
  - Winner crown icon (if highest score)
- **Used By**: AnalysisResultsView grid

#### `ImagePicker.swift`
- **Purpose**: UIKit PhotosPicker wrapper for SwiftUI
- **Props**:
  - `selectedImages: Binding<[UIImage]>`
  - `selectionLimit: Int` (default 4)
- **Implementation**:
  - Uses `PHPickerViewController`
  - Supports multi-select
  - Returns UIImage array
- **Used By**: UploadView

#### `CameraPicker.swift`
- **Purpose**: UIKit Camera wrapper for SwiftUI
- **Props**:
  - `selectedImage: Binding<UIImage?>`
- **Implementation**:
  - Uses `UIImagePickerController`
  - Camera source type
  - Returns single UIImage
- **Used By**: UploadView

---

### **Views/MainTabView.swift**
- **Purpose**: Bottom tab navigation container
- **Tabs**:
  1. 🏠 Home → HomeView
  2. ➕ Analyze → Triggers NewAnalysisView sheet (not a real tab)
  3. 🕐 History → HistoryView
  4. ⚙️ Settings → SettingsView
- **Trick**: Tab 2 (Analyze) doesn't show a view - it triggers a sheet and resets to Home
- **Design**: Red accent color for selected tabs

---

### **Utilities/** - Helpers & Constants

#### `Constants.swift`
- **Purpose**: Centralized design system and configuration
- **Sections**:
  - **API**: Base URLs for dev/staging/prod
  - **Colors**: Brand colors with hex values
    - `primaryRed = #FF0050`
    - `scoreExcellent = green gradient`
    - `textPrimary = #1A1A1A`
  - **Typography**: Font sizes
    - `displayLarge = 34pt bold`
    - `headlineMedium = 20pt semibold`
    - `bodyMedium = 16pt regular`
  - **Spacing**: Consistent spacing values
    - `spacing4 = 4pt`
    - `spacing8 = 8pt`
    - `spacing16 = 16pt`
  - **CornerRadius**: Rounding values
    - `small = 8pt`
    - `medium = 12pt`
    - `large = 16pt`
  - **Subscription**: Pricing and limits
    - `freeTierLimit = 3`
    - `creatorMonthlyPrice = 9.99`
- **Benefits**:
  - Single source of truth for design
  - Easy to rebrand
  - Consistent UI across app
- **Used By**: Every view and component

#### `Extensions/Color+Extensions.swift`
- **Purpose**: SwiftUI Color utilities
- **Extensions**:
  - `Color(hex: String)` - create from hex string
  - `Color.scoreGradient(for score: Int)` - gradient based on score
  - `Color.random` - random color for testing
- **Used By**: Constants, all views

#### `Extensions/View+Extensions.swift`
- **Purpose**: SwiftUI View modifiers
- **Extensions**:
  - `.cornerRadius(_ radius: CGFloat, corners: UIRectCorner)` - selective corners
  - `.placeholder(when:)` - conditional placeholder
  - `.hideKeyboard()` - dismiss keyboard
  - `.snapshot()` - convert view to image
- **Used By**: Various views for common UI patterns

---

### **Configuration Files**

#### `Info.plist`
- **Purpose**: App metadata and permissions
- **Key Values**:
  - `CFBundleDisplayName` = "ThumbnailTest"
  - `CFBundleVersion` = "1"
  - `CFBundleShortVersionString` = "1.0.0"
  - `NSPhotoLibraryUsageDescription` = Why we need photo access
  - `NSCameraUsageDescription` = Why we need camera access
  - `UIApplicationSceneManifest` - scene configuration
  - `UISupportedInterfaceOrientations` - portrait + landscape
- **Used By**: iOS system

#### `project.yml`
- **Purpose**: XcodeGen project configuration
- **Defines**:
  - Bundle ID: `com.thumbnailtest.app`
  - Deployment target: iOS 16.0
  - Source directories
  - Frameworks (StoreKit, SwiftUI, PhotosUI)
  - Build settings
- **Used By**: XcodeGen to generate .xcodeproj

#### `Assets.xcassets/`
- **Purpose**: Image and color assets catalog
- **Contents**:
  - AppIcon (app icon, all sizes)
  - Launch images (optional)
  - Custom images (future: logos, placeholders)
  - Color sets (future: dynamic colors for dark mode)
- **Used By**: All views via `Image("name")`

---

## 🔄 How Components Work Together

### Example: User Analyzes Thumbnails

1. **User taps "Analyze" tab**
   - `MainTabView` sets `showingNewAnalysis = true`
   - Presents `NewAnalysisView` as sheet

2. **NewAnalysisView shows UploadView**
   - User selects 4 images via `ImagePicker`
   - Images stored in `AnalysisViewModel.selectedImages`

3. **User proceeds to DetailsView**
   - Enters "My Gaming Video" as title
   - Selects "Gaming" category

4. **User taps "Analyze Thumbnails"**
   - `NewAnalysisView` checks free tier limit:
     - If reached → shows `PaywallView`
     - If not reached → proceeds to `LoadingView`

5. **Analysis starts (LoadingView)**
   - `AnalysisViewModel.uploadAndAnalyze()` is called
   - `ImageService.uploadImages()` uploads to Supabase Storage
   - `AnalysisService.createAnalysis()` sends URLs to backend
   - Backend edge function calls OpenAI Vision API
   - `AnalysisViewModel` polls every 2 seconds for results

6. **Results ready (AnalysisResultsView)**
   - Backend returns `Analysis` with scored `Thumbnails`
   - `AnalysisViewModel.currentAnalysis` is updated
   - View shows winner and grid
   - User taps thumbnail #2 → opens `ThumbnailDetailView`

7. **User views details (ThumbnailDetailView)**
   - Shows breakdown: Face 85, Text 72, Color 90, etc.
   - Shows recommendations: "Great eye contact!", "Brighten background"

8. **User goes to History**
   - `HistoryViewModel` loads from `AnalysisService.getHistory()`
   - Analysis appears in `HistoryView` list
   - User can tap to view again or swipe to delete

---

## 🎨 Design System Summary

### Colors
- **Primary**: Red (#FF0050) - CTAs, accents
- **Text**: Black (#1A1A1A) primary, Gray (#6B7280) secondary
- **Scores**: Green (excellent), Blue (good), Orange (fair), Red (poor)
- **Backgrounds**: White, Light Gray (#F9FAFB)

### Typography
- **Display**: 34pt bold - hero headings
- **Headline**: 20-24pt semibold - section titles
- **Body**: 16pt regular - main text
- **Caption**: 12-14pt regular - metadata

### Spacing
- Consistent 4pt grid: 4, 8, 12, 16, 24, 32, 48

### Components
- Rounded corners (8-16pt)
- Gradient buttons
- Card-based layouts
- Bottom sheets for modals

---

## 🔐 Security & Privacy

### Secure Data Storage
- **Tokens**: Stored in iOS Keychain (not UserDefaults)
- **Passwords**: Never stored locally
- **Images**: Uploaded to Supabase Storage with signed URLs

### Permissions
- **Photo Library**: Required for image selection (explained in Info.plist)
- **Camera**: Optional for taking new photos (explained in Info.plist)

### API Security
- **JWT Tokens**: Included in all authenticated requests
- **HTTPS Only**: All API calls use secure connections
- **Transaction Verification**: StoreKit 2 validates all purchases

---

## 📱 App Capabilities

### Current Features
- ✅ Email/password authentication
- ✅ Upload 2-4 thumbnails
- ✅ AI-powered thumbnail analysis
- ✅ Detailed score breakdowns (5 metrics)
- ✅ Analysis history with search/filter
- ✅ Free tier (3 analyses/month)
- ✅ In-app subscriptions (StoreKit 2)
- ✅ Profile management
- ✅ Account deletion

### Ready for Integration
- 🔜 Apple Sign-In (code ready)
- 🔜 Google Sign-In (code ready)
- 🔜 Dark mode support (colors defined)

### Future Enhancements
- 📅 Export results as PDF/image
- 📅 Share to social media
- 📅 Team collaboration
- 📅 Thumbnail A/B test scheduling
- 📅 Historical trend charts

---

## 🚀 Getting Started as a Developer

### 1. Understand the Flow
- Start with `ThumbnailTestApp.swift` → `ContentView.swift`
- Follow authentication: `AuthViewModel` → `AuthService` → backend
- Trace analysis flow: `NewAnalysisView` → `AnalysisViewModel` → `AnalysisService` → backend

### 2. Key Files to Read First
1. `Constants.swift` - understand design system
2. `User.swift` + `Analysis.swift` - data models
3. `AuthViewModel.swift` - how state works
4. `APIService.swift` - how API calls are made
5. `NewAnalysisView.swift` - main user flow

### 3. Common Tasks
- **Add new view**: Create in `Views/`, use Constants for styling
- **Add API endpoint**: Add method to relevant Service
- **Change colors**: Update `Constants.swift` only
- **Add ViewModel state**: Add `@Published` property, call service method

### 4. Run the App
- Follow `XCODE_SETUP.md` for project setup
- Follow `backend/SETUP.md` for backend setup
- Test with mock data first (comment out API calls)

---

## 📚 Additional Documentation

- **Backend Setup**: See `backend/SETUP.md`
- **Xcode Setup**: See `XCODE_SETUP.md`
- **PRD**: See `PRD-ThumbnailTester.md` for product requirements

---

**Questions?** This is a living document. Update it as the app evolves!
