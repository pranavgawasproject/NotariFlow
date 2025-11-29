# Apple App Store Setup Guide

## 🍎 Build iOS App

### Prerequisites

**Required:**
- macOS computer (Catalina or later)
- Xcode 15+ installed
- Apple Developer Account ($99/year)
- Physical iOS device for testing

### 1. Apple Developer Setup

1. **Enroll in Apple Developer Program:**
   - Visit: https://developer.apple.com/programs/
   - Cost: $99 USD/year
   - Approval: 1-2 business days

2. **Create App ID:**
   - Login to https://developer.apple.com/account
   - Certificates, Identifiers & Profiles → Identifiers
   - Click "+" to add new App ID
   - Bundle ID: `com.notariflow.app` (use your domain)
   - Enable capabilities: Push Notifications, Sign in with Apple

3. **Create Provisioning Profiles:**
   - Development profile (for testing)
   - Distribution profile (for App Store)

---

## 🛠️ Configure Flutter iOS Project

### Update Info.plist

Edit `ios/Runner/Info.plist`:

```xml
<key>CFBundleName</key>
<string>NotaryFlow</string>

<key>CFBundleDisplayName</key>
<string>NotaryFlow</string>

<key>CFBundleShortVersionString</key>
<string>1.0.0</string>

<key>CFBundleVersion</key>
<string>1</string>

<!-- Location permissions for mileage tracking -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>NotaryFlow needs your location to accurately track mileage for business trips and tax deductions.</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Allow NotaryFlow to track mileage even when the app is in the background for accurate trip recording.</string>

<!-- Camera permissions (future feature) -->
<key>NSCameraUsageDescription</key>
<string>NotaryFlow needs camera access to scan documents and capture signatures.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>NotaryFlow needs photo library access to save invoices and documents.</string>
```

### Update Build Settings

Edit `ios/Runner.xcodeproj/project.pbxproj` in Xcode:
- Set Team ID
- Set Bundle Identifier: `com.notariflow.app`
- Set Deployment Target: iOS 13.0 or higher

---

## 📱 Build IPA File

### From macOS Terminal:

```bash
# Navigate to project
cd /path/to/NotariFlow

# Clean previous builds
flutter clean
flutter pub get

# Build iOS release
flutter build ios --release

# Archive in Xcode
open ios/Runner.xcworkspace
```

### In Xcode:

1. **Select "Any iOS Device" target**
2. **Product → Archive**
3. **Wait for archiving** (5-10 minutes)
4. **Window → Organizer** opens
5. **Select archive → Distribute App**
6. **Choose "App Store Connect"**
7. **Upload** (requires Apple Developer login)

---

## 🏪 App Store Connect Setup

### 1. Create App Listing

**Login:** https://appstoreconnect.apple.com

**My Apps → + → New App:**
- Platform: iOS
- Name: NotaryFlow
- Primary Language: English (U.S.)
- Bundle ID: com.notariflow.app
- SKU: NOTARIFLOW001 (unique identifier)

### 2. App Information

**Category:** Business

**Subcategory:** Productivity

**Age Rating:**
- Complete questionnaire
- No violence, gambling, mature content
- Expected: 4+ rating

**Copyright:** © 2025 NotaryFlow

**Contact Information:**
- Email: support@notariflow.com
- Phone: Your business phone
- URL: https://notariflow.com

---

## 📝 App Store Listing Content

### App Name
**NotaryFlow - Business Manager**

### Subtitle (30 chars)
**Notary Invoice & Mileage App**

### Promotional Text (170 chars - can update without review)
```
Track mileage automatically, create professional invoices, and manage clients effortlessly. Built specifically for mobile notary professionals. Try it free!
```

### Description (4000 chars max)
```
NotaryFlow - Professional Business Management for Mobile Notaries

Transform your notary business with NotaryFlow, the complete management solution designed exclusively for mobile notary publics and signing agents. Save hours every week and maximize your tax deductions with powerful automation.

FEATURES THAT MATTER

GPS Mileage Tracking
• Automatic trip recording with one-tap timer
• IRS-compliant trip purpose logging
• Real-time reimbursement calculations
• Detailed history and export

Professional Invoicing
• Create invoices in 30 seconds
• Beautiful PDF generation
• Email directly to clients
• Track payment status (Pending/Paid/Overdue)
• Search and filter capabilities

Client Management
• Centralized contact database
• Quick search and retrieval
• One-tap call or email
• Complete client history

Fee Calculator
• Instant quote generation
• Signature + mileage calculations
• State-specific rates
• Professional estimates

Business Analytics
• Revenue tracking dashboard
• Monthly trends and insights
• Tax deduction summaries
• Performance metrics

Data Export
• CSV export for accounting
• QuickBooks integration
• Backup and sync
• Cloud storage

WHY NOTARIES CHOOSE NOTARYFLOW

✓ Purpose-built for notary professionals
✓ Saves 5+ hours per week on admin tasks
✓ Maximizes tax deductions with precise mileage logs
✓ Professional invoices that get paid faster
✓ Never lose client information again
✓ Works offline with automatic sync
✓ Secure cloud backup

PERFECT FOR
• Mobile Notary Publics
• Loan Signing Agents
• Signing Services
• Notary Businesses

WHAT USERS SAY

"NotaryFlow cut my admin time in half. The mileage tracker alone saves me thousands in tax deductions!" - Sarah M.

"Finally, an app made FOR notaries BY people who understand the business." - James R.

"The invoice feature is incredible. Professional PDFs in seconds." - Linda K.

FREE TO START

Download NotaryFlow now and experience the difference. No credit card required. Start managing your notary business like a pro today.

SUPPORT
Questions? Email us at support@notariflow.com
Privacy: https://notariflow.com/privacy
Terms: https://notariflow.com/terms

Transform your notary business. Download NotaryFlow now.
```

### Keywords (100 chars max - comma separated)
```
notary,invoice,mileage,business,signing agent,mobile notary,productivity,tracker,tax,deduction
```

### Support URL
`https://notariflow.com/support`

### Marketing URL (Optional)
`https://notariflow.com`

### Privacy Policy URL
`https://notariflow.com/privacy`

---

## 📸 App Previews & Screenshots

### App Icon
- **Size:** 1024 x 1024 px
- **Format:** PNG (no alpha channel)
- **No rounded corners** (iOS adds automatically)

### Screenshots Required

**iPhone 6.7" Display (iPhone 14 Pro Max):**
- Resolution: 1290 x 2796 px
- Required: 3-10 images

**iPhone 6.5" Display (iPhone 11 Pro Max):**
- Resolution: 1242 x 2688 px
- Required: 3-10 images

**iPad Pro 12.9" (Recommended):**
- Resolution: 2048 x 2732 px
- Required: 3-10 images

### Screenshot Ideas
1. Dashboard with revenue stats
2. Mileage tracker active trip
3. Invoice creation screen
4. Client management list
5. Analytics charts
6. Professional PDF invoice

**Tools to Create Screenshots:**
- Use iOS Simulator in Xcode
- Add text overlays highlighting features
- Keep UI clean and professional

### App Preview Videos (Optional but recommended)
- Length: 15-30 seconds
- Show: App in action, key features
- Required per device size
- File size: Max 500 MB

---

## 🔐 App Privacy

### Privacy Questions in App Store Connect

**Data Collection:**
- Name and Email: Yes (for account creation)
- Location: Yes (for mileage tracking - not shared)
- Usage Data: No
- Analytics: No

**Data Usage:**
- Third-party tracking: No
- Advertising: No
- App functionality: Yes

**Data Linked to User:**
- Contact info (name, email)
- Location data (for mileage only)

**Data Security:**
- Data encrypted in transit: Yes
- User can request data deletion: Yes

---

## 💰 Pricing & Availability

**Price:** Free

**Availability:** All territories (except countries with sanctions)

**Content Rights:** You own all content

---

## 🧪 TestFlight (Internal Testing)

### 1. Upload Build via Xcode
After archiving, build appears in App Store Connect

### 2. Enable TestFlight
- Go to TestFlight tab
- Add internal testers (up to 100)
- Add external testers (up to 10,000)

### 3. Invite Testers
- Send invitation links
- Testers install TestFlight app
- They download your build

**Testing Duration:** 90 days per build

---

## ✅ Pre-Submission Checklist

- [ ] Apple Developer account active ($99/year)
- [ ] App ID and provisioning profiles created
- [ ] Info.plist configured with permissions
- [ ] Build uploaded via Xcode
- [ ] App name and metadata completed
- [ ] 1024x1024 app icon uploaded
- [ ] Screenshots for all required sizes
- [ ] Privacy policy URL published
- [ ] Support URL working
- [ ] Age rating questionnaire completed
- [ ] Pricing set (Free)
- [ ] Countries selected
- [ ] TestFlight testing completed (recommended)
- [ ] All features tested on real device

---

## 🚀 Submit for Review

### Final Steps:
1. **Add Build** to version in App Store Connect
2. **Complete all required fields**
3. **Submit for Review**

### Review Process:
- **Duration:** 1-7 days (average 24-48 hours)
- **Common rejections:**
  - Missing privacy policy
  - Incomplete metadata
  - Crashes on launch
  - Misleading screenshots

### After Approval:
- **Manually release** or **Auto-release**
- App goes live on App Store
- Monitor reviews and ratings

---

## 📊 Post-Launch

**Monitor:**
- Crash reports in App Store Connect
- User reviews (respond within 48 hours)
- Sales and trends data

**Updates:**
- Increment CFBundleVersion for each build
- Increment CFBundleShortVersionString for feature updates
- Submit updates through same process

---

## 🆘 Common Issues

**"Invalid Bundle"**
→ Check Bundle ID matches App Store Connect

**"Missing compliance"**
→ Answer export compliance questions (encryption)

**"Invalid icon"**
→ Ensure 1024x1024 PNG with no alpha

**"Missing provisioning profile"**
→ Regenerate in Apple Developer portal

**"Xcode won't archive"**
→ Clean build folder: Product → Clean Build Folder

---

## 💡 Tips for Success

1. **Test on real device** before submission
2. **Complete TestFlight** with 10+ testers
3. **Perfect your screenshots** - first impression matters
4. **Write clear description** - focus on benefits
5. **Respond to reviews** - shows active support
6. **Update regularly** - keeps app in rankings

---

**Need a Mac?** Consider:
- Mac Mini (cheapest option for building)
- MacStadium (cloud Mac rental)
- Codemagic/Bitrise (CI/CD with Mac builders)

**Ready to submit?** Complete checklist and upload your build! 🎉
