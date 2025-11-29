# 📤 How to Upload Your Logo

## Step 1: Add Your Logo File

1. **In VS Code File Explorer** (left sidebar):
   - Navigate to: `assets/images/`
   - Right-click on the `images` folder
   - Select **"Upload..."**
   - Choose your logo file (PNG, JPG, or SVG)
   - Name it: `logo.png` (or `logo.jpg`)

2. **Or drag and drop**:
   - Simply drag your logo file into the `assets/images/` folder

## Step 2: Recommended Logo Sizes

- **Main Logo**: 512x512 px (square) or 800x200 px (wide)
- **Format**: PNG with transparent background (best)
- **File size**: Keep under 500KB for web performance

## Step 3: The logo will appear in:
- ✅ Login page (centered at top)
- ✅ Sign up page (centered at top)
- ✅ Navigation sidebar (when logged in)

---

# 🔐 How to Access Login & Signup

## Current Setup: Email/Password Authentication

When you open the app, you'll see:

### 1️⃣ **Login Screen** (Shows First)
- Email field
- Password field
- "Login" button
- **"Don't have an account? Sign Up"** link at bottom

### 2️⃣ **Sign Up Screen** (Click "Sign Up" link)
- Name field
- Email field
- Password field
- Confirm Password field
- "Create Account" button
- **"Already have an account? Login"** link at bottom

## 🎯 How to Access:

### For New Users:
1. Open app → You'll see **Login Screen**
2. Click **"Don't have an account? Sign Up"** at bottom
3. Fill in your details
4. Click **"Create Account"**
5. You'll be automatically logged in

### For Existing Users:
1. Open app → You'll see **Login Screen**
2. Enter email and password
3. Click **"Login"**

### To Test Right Now:
Since you currently use **anonymous auth**, you need to:
1. Sign out from the current session
2. You'll see the Login screen

**Quick way to see login screen:**
- The app automatically redirects to Login when not authenticated
- Just refresh the page if you want to test

---

# 🎨 Logo Usage in Code

Your logo is automatically used in:

```dart
// Login Screen
Image.asset('assets/images/logo.png', height: 120)

// Sign Up Screen  
Image.asset('assets/images/logo.png', height: 100)

// Sidebar (when logged in)
Image.asset('assets/images/logo.png', height: 40)
```

If you don't upload a logo yet, the app shows an icon placeholder.

---

# ✨ What's Already Implemented:

✅ **Login Screen** with email/password  
✅ **Sign Up Screen** with validation  
✅ **Forgot Password** functionality  
✅ **Auto-login** after signup  
✅ **Session persistence** (stays logged in)  
✅ **Logout button** in settings  

---

# 🔧 To Switch from Anonymous to Email Auth:

The current code already supports both! Just:
1. Logout from current session
2. You'll see Login/Signup screens
3. Create a new account with email/password

That's it! 🎉
