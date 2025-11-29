# Google Play Store Setup Guide

## 📱 Build Android App Bundle

### 1. Create Keystore (First Time Only)
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

**Save these details securely:**
- Keystore password
- Key alias: `upload`
- Key password

### 2. Configure Signing

Create `android/key.properties`:
```properties
storePassword=<your-keystore-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=/home/codespace/upload-keystore.jks
```

Add to `android/app/build.gradle` (before `android {`):
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Update `buildTypes` in same file:
```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled true
        shrinkResources true
    }
}
```

### 3. Build App Bundle
```bash
cd /workspaces/NotariFlow
flutter build appbundle --release
```

**Output:** `build/app/outputs/bundle/release/app-release.aab`

---

## 🏪 Google Play Console Setup

### Store Listing Information

**App Name:** NotaryFlow

**Short Description (80 chars):**
Professional business management app for mobile notary publics.

**Full Description (4000 chars max):**
```
NotaryFlow - The Complete Business Management Solution for Mobile Notaries

Streamline your notary business with NotaryFlow, the all-in-one app designed specifically for mobile notary professionals. Save time, maximize tax deductions, and grow your business with powerful tools that handle everything from mileage tracking to invoice generation.

✨ KEY FEATURES

📍 GPS Mileage Tracking
• Automatic trip recording with start/stop timer
• Purpose tracking for IRS compliance
• Reimbursement calculations at current IRS rates
• Detailed trip history and reports

💼 Invoice Management
• Create professional invoices in seconds
• Client lookup and auto-fill
• Status tracking (Pending, Paid, Overdue)
• PDF export and download
• Email invoices directly to clients
• Search and filter by date, client, or amount

👥 Client Database
• Store client contact information
• Quick search and retrieval
• One-tap to call or email
• Client history tracking

💰 Fee Calculator
• Instant notarization fee estimates
• Signature + mileage calculations
• Customizable rates by state
• Quick quotes for clients

📊 Analytics Dashboard
• Real-time revenue tracking
• Monthly trends and charts
• Tax deduction summaries
• Performance insights

📄 Data Export
• CSV export for accounting software
• Backup your business data
• Easy integration with QuickBooks, Excel

🔒 Secure & Private
• Firebase authentication
• Cloud backup and sync
• Your data is always safe
• Works offline with sync

💡 WHY NOTARYFLOW?

Built by notaries, for notaries. We understand the unique challenges of mobile notary work and designed NotaryFlow to save you hours every week on administrative tasks.

• No more manual mileage logs
• No more invoice templates in Word
• No more lost client information
• No more missed tax deductions

Perfect for:
✓ Mobile Notary Publics
✓ Signing Agents
✓ Loan Signing Agents
✓ Notary Businesses

🚀 GET STARTED FREE

Download NotaryFlow today and transform how you manage your notary business. Join thousands of notaries who are saving time and earning more.

---
Questions? Contact us at support@notariflow.com
Privacy Policy: https://notariflow.com/privacy
Terms of Service: https://notariflow.com/terms
```

**App Category:** Business

**Tags:** notary, business, invoice, mileage tracker, small business, mobile notary, productivity

**Contact Email:** support@notariflow.com

**Privacy Policy URL:** https://notariflow.com/privacy

---

## 📸 Required Graphics

### App Icon
- **Size:** 512 x 512 px
- **Format:** 32-bit PNG
- **Location:** Upload to `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`

### Feature Graphic
- **Size:** 1024 x 500 px
- **Format:** JPG or PNG
- **Content:** App name + key feature highlights

### Screenshots (Required: 2-8 images)
**Phone Screenshots:**
- Size: 1080 x 1920 px or higher
- Show: Dashboard, Mileage Tracker, Invoice List, Client Management
- Add captions highlighting features

**Tablet Screenshots (Optional but recommended):**
- Size: 1200 x 1920 px or higher

### Promo Video (Optional)
- YouTube URL
- 30-60 seconds showing app in action

---

## 🔐 Content Rating

Complete the questionnaire in Play Console:
- Select "Business/Productivity" category
- Answer violence/mature content questions (all "No")
- No ads, no user-generated content
- Target audience: Adults (18+)

**Expected Rating:** Everyone / PEGI 3

---

## 💵 Pricing & Distribution

**Price:** Free

**Countries:** All countries (select "Available in all current and future countries")

**Devices:** Phones and Tablets

**Android Versions:** Android 5.0 (API 21) and above

---

## ⚙️ App Releases

### Internal Testing Track (First)
1. Upload `app-release.aab`
2. Add internal testers (your email)
3. Test thoroughly (1-2 weeks)

### Closed Alpha (Optional)
1. Invite 20-100 testers
2. Gather feedback
3. Fix bugs

### Open Beta (Recommended)
1. Public testing
2. Build reviews and credibility
3. Final bug fixes

### Production Release
1. Upload final `app-release.aab`
2. Complete all store listing fields
3. Submit for review (1-3 days typically)

---

## 📋 Pre-Launch Checklist

- [ ] App bundle signed and uploaded
- [ ] All store listing fields completed
- [ ] 512x512 app icon uploaded
- [ ] Feature graphic created (1024x500)
- [ ] Minimum 2 phone screenshots
- [ ] Privacy policy published and linked
- [ ] Content rating questionnaire completed
- [ ] Pricing set to Free
- [ ] Countries selected (All)
- [ ] Target SDK version 34+ (Android 14)
- [ ] Permissions declared in manifest
- [ ] App tested on multiple devices
- [ ] Internal testing completed

---

## 🚀 Quick Build Commands

```bash
# Clean build
flutter clean
flutter pub get

# Build release bundle
flutter build appbundle --release

# Find output
ls -lh build/app/outputs/bundle/release/app-release.aab

# Build APK for testing (not for Play Store)
flutter build apk --release
```

---

## 📊 Post-Launch

1. **Monitor Console:**
   - Check crash reports daily
   - Respond to user reviews
   - Track installs and ratings

2. **Update Strategy:**
   - Fix critical bugs within 24 hours
   - Feature updates every 2-4 weeks
   - Maintain 4.0+ star rating

3. **ASO (App Store Optimization):**
   - Test different screenshots
   - A/B test descriptions
   - Update keywords based on search trends

---

## 🆘 Common Issues

**"Upload failed - version conflict"**
→ Increment versionCode in `android/app/build.gradle`

**"Missing permissions"**
→ Declare all permissions in `AndroidManifest.xml`

**"Target SDK too old"**
→ Update `targetSdkVersion` to 34 in `build.gradle`

**"Keystore not found"**
→ Check path in `key.properties` file

---

**Ready to publish? Upload your .aab file to Google Play Console!** 🎉
