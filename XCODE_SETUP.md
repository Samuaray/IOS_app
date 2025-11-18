# Xcode Project Setup

The source code is ready, but you need to generate the Xcode project file to open it in Xcode.

## Option 1: Using XcodeGen (Recommended)

XcodeGen automatically creates the .xcodeproj file from the `project.yml` configuration.

### Install XcodeGen

```bash
brew install xcodegen
```

### Generate the Project

```bash
cd /home/user/IOS_app
xcodegen generate
```

This will create `ThumbnailTest.xcodeproj` - then open it:

```bash
open ThumbnailTest.xcodeproj
```

---

## Option 2: Create Manually in Xcode

If you don't want to use XcodeGen, follow these steps:

### 1. Create New Project in Xcode

1. Open Xcode
2. File → New → Project
3. Choose **iOS** → **App**
4. Fill in:
   - Product Name: `ThumbnailTest`
   - Team: (your team)
   - Organization Identifier: `com.thumbnailtest`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **None**
   - Include Tests: **Unchecked**
5. Save it in `/home/user/IOS_app` (replace the existing ThumbnailTest folder)

### 2. Add All Source Files

Xcode will create a basic project. Now add all the existing files:

1. **Delete** the default `ContentView.swift` and `ThumbnailTestApp.swift` files Xcode created
2. Right-click on the `ThumbnailTest` folder in Xcode
3. **Add Files to "ThumbnailTest"...**
4. Navigate to `/home/user/IOS_app/ThumbnailTest`
5. Select all folders (App, Models, Services, Utilities, ViewModels, Views)
6. **Important**: Check "Create groups" (not "Create folder references")
7. Click **Add**

### 3. Configure Project Settings

1. Select `ThumbnailTest` project in navigator
2. Select `ThumbnailTest` target
3. **General** tab:
   - Bundle Identifier: `com.thumbnailtest.app`
   - Deployment Target: iOS 16.0
   - Supported Destinations: iPhone, iPad
4. **Signing & Capabilities** tab:
   - Select your Team
   - Automatic signing

### 4. Add Required Frameworks

The project uses:
- StoreKit (for subscriptions) - auto-linked
- SwiftUI - auto-linked
- PhotosUI (for image picker) - auto-linked
- Combine (for reactive programming) - auto-linked

All frameworks should auto-link when you build.

---

## File Structure

Your project should have this structure:

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
├── Services/
│   ├── APIService.swift
│   ├── AuthService.swift
│   ├── ImageService.swift
│   ├── AnalysisService.swift
│   ├── UserService.swift
│   └── SubscriptionService.swift
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── AnalysisViewModel.swift
│   ├── HistoryViewModel.swift
│   └── SubscriptionViewModel.swift
├── Views/
│   ├── Auth/
│   ├── Home/
│   ├── Analysis/
│   ├── History/
│   ├── Subscription/
│   ├── Settings/
│   ├── Components/
│   └── MainTabView.swift
├── Utilities/
│   ├── Constants.swift
│   ├── Extensions/
│   └── Helpers/
├── Assets.xcassets/
├── Info.plist
└── Config.swift (you'll create this)
```

---

## Next Steps After Opening in Xcode

1. **Build** (⌘ + B) to check for errors
2. **Update Constants.swift** with your Supabase URL
3. **Create Config.swift** with Supabase credentials
4. **Run** (⌘ + R) on simulator or device

---

## Troubleshooting

### "No such module 'StoreKit'"
StoreKit should auto-link. Try:
- Clean Build Folder (⌘ + Shift + K)
- Rebuild (⌘ + B)

### Missing Files
Make sure all Swift files are added to the target:
- Select file in navigator
- File Inspector (right panel)
- Target Membership: Check "ThumbnailTest"

### Build Errors
Common fixes:
- Clean Build Folder (⌘ + Shift + K)
- Delete Derived Data: Xcode → Preferences → Locations → Derived Data → Delete
- Restart Xcode

---

That's it! Your Xcode project should now be ready to build and run. 🚀
