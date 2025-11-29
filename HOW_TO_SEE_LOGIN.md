# 🚀 Quick Guide: See Login & Signup Pages

## Method 1: Use Logout Button (Easiest)

1. **Open your app** (currently logged in with anonymous auth)
2. **Click "Settings"** tab (bottom right on mobile, or sidebar on desktop)
3. **Scroll down** to bottom of settings page
4. **Click the 3-dot menu (⋮)** in the top right
5. **Click "Logout"**
6. 🎉 **You'll see the LOGIN PAGE!**

## Method 2: Clear Browser Data

1. Open **Developer Tools** (F12 or Right-click → Inspect)
2. Go to **Application** tab
3. Click **Clear storage**
4. Click **Clear site data**
5. Refresh the page
6. 🎉 **LOGIN PAGE appears!**

---

## 📋 What You'll See:

### LOGIN PAGE:
```
┌─────────────────────────┐
│   [NotaryFlow Logo]     │
│                         │
│   Welcome Back!         │
│   Sign in to continue   │
│                         │
│   📧 Email              │
│   ├─────────────────┤   │
│                         │
│   🔒 Password           │
│   ├─────────────────┤   │
│                         │
│   [ LOGIN BUTTON ]      │
│                         │
│   Forgot Password?      │
│                         │
│   Don't have account?   │
│   👉 Sign Up           │
└─────────────────────────┘
```

### When you click "Sign Up":
```
┌─────────────────────────┐
│   [NotaryFlow Logo]     │
│                         │
│   Create Account        │
│   Join NotaryFlow       │
│                         │
│   👤 Full Name          │
│   ├─────────────────┤   │
│                         │
│   📧 Email              │
│   ├─────────────────┤   │
│                         │
│   🔒 Password           │
│   ├─────────────────┤   │
│                         │
│   🔒 Confirm Password   │
│   ├─────────────────┤   │
│                         │
│   [CREATE ACCOUNT]      │
│                         │
│   Already have account? │
│   👉 Login             │
└─────────────────────────┘
```

---

## 📁 Where to Upload Logo:

**In VS Code (Codespaces):**

1. Look at left sidebar (File Explorer)
2. Find folder: `assets/images/`
3. Right-click on `images` folder
4. Click **"Upload..."**
5. Select your logo file
6. **Recommended name**: `logo.png`

**Folder path:**
```
NotariFlow/
  └── assets/
      └── images/
          └── logo.png  ← Put your logo here!
```

---

## 🎨 Logo Specifications:

**Best Practices:**
- ✅ Format: PNG with transparent background
- ✅ Size: 512x512 px (square) or 800x200 px (wide)
- ✅ Max file size: 500 KB
- ✅ Colors: Match your brand

**The logo appears in:**
1. Login screen (top center, 120px height)
2. Signup screen (top center, 100px height)  
3. App sidebar (40px height when logged in)

---

## 🔐 Current Authentication Status:

Your app is running with **anonymous authentication** right now.

To test Login/Signup:
1. Logout (Settings → Menu → Logout)
2. Create new account with email/password
3. Login with that account

**Both authentication methods work!** ✅
- Anonymous (current)
- Email/Password (ready to use)

---

## ⚡ After Adding Logo:

1. Add logo to `assets/images/logo.png`
2. Run: `flutter build web --release`
3. Rebuild takes ~1-2 minutes
4. Logo appears automatically! 🎉

No code changes needed - it's already integrated!
