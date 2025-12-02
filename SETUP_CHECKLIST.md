# Firebase Setup Checklist ✅

Complete these steps to get your Safe Space app running with Firebase!

## Before You Start
- [ ] Have a Google account ready
- [ ] Flutter is installed (`flutter doctor` shows no critical errors)
- [ ] Android Studio or VS Code is set up

---

## Step 1: Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```
- [ ] Command completed successfully
- [ ] No errors shown

---

## Step 2: Create Firebase Project

### In Browser (Firebase Console):
1. [ ] Go to https://console.firebase.google.com/
2. [ ] Click "Add project"
3. [ ] Enter project name: `safe-space-app`
4. [ ] Click "Continue"
5. [ ] Disable Google Analytics (or enable - your choice)
6. [ ] Click "Create project"
7. [ ] Wait for project creation
8. [ ] Click "Continue" when done

---

## Step 3: Configure Firebase in App

### In Terminal (in your project folder):
```bash
flutterfire configure
```

Answer the prompts:
- [ ] Select your Firebase project from list (use arrow keys)
- [ ] Select platforms: **Android** and **iOS** (press space to select, enter to confirm)
- [ ] Wait for configuration to complete
- [ ] Verify `lib/firebase_options.dart` was created

---

## Step 4: Enable Authentication

### In Firebase Console:
1. [ ] Click "Authentication" in left sidebar
2. [ ] Click "Get started" button
3. [ ] Click on "Email/Password"
   - [ ] Toggle "Enable" to ON
   - [ ] Click "Save"
4. [ ] Click on "Google"
   - [ ] Toggle "Enable" to ON
   - [ ] Select your email from dropdown (Project support email)
   - [ ] Click "Save"

---

## Step 5: Enable Cloud Firestore

### In Firebase Console:
1. [ ] Click "Firestore Database" in left sidebar
2. [ ] Click "Create database"
3. [ ] Select "Start in test mode" (radio button)
4. [ ] Click "Next"
5. [ ] Select your location (closest to you)
6. [ ] Click "Enable"
7. [ ] Wait for database creation (may take 1-2 minutes)

---

## Step 6: Add SHA-1 for Google Sign-In (Android)

### In Terminal:
```bash
cd android
./gradlew signingReport
```
(On Windows: `gradlew signingReport`)

- [ ] Command completed
- [ ] Copy the SHA-1 from "Variant: debug" section
  - Looks like: `SHA1: 1A:2B:3C:4D:...`

### In Firebase Console:
1. [ ] Click gear icon (⚙️) next to "Project Overview"
2. [ ] Click "Project settings"
3. [ ] Scroll to "Your apps" section
4. [ ] Click on your Android app
5. [ ] Scroll to "SHA certificate fingerprints"
6. [ ] Click "Add fingerprint"
7. [ ] Paste your SHA-1
8. [ ] Click "Save"

### In Terminal (go back to project root):
```bash
cd ..
```

---

## Step 7: Run the App

```bash
flutter run
```

- [ ] App launches successfully
- [ ] No Firebase initialization errors
- [ ] Can see the splash screen

---

## Step 8: Test Features

### Test Sign Up:
- [ ] Tap "Sign Up"
- [ ] Enter name, email, password
- [ ] Tap "Create Account"
- [ ] Account created successfully
- [ ] Redirected to home screen

### Test Sign In:
- [ ] Sign out (if logged in)
- [ ] Enter email and password
- [ ] Tap "Sign In"
- [ ] Logged in successfully

### Test Google Sign-In:
- [ ] Sign out
- [ ] Tap "Continue with Google"
- [ ] Select Google account
- [ ] Logged in successfully

### Test Appointment Booking:
- [ ] Navigate to "Search Doctors"
- [ ] Select a doctor
- [ ] Choose date and time
- [ ] Tap "Confirm Appointment"
- [ ] Appointment confirmed
- [ ] Appears in appointments list

### Check Firebase Console:
- [ ] Go to Authentication tab → see your user
- [ ] Go to Firestore tab → see collections:
  - [ ] `users` collection exists
  - [ ] Your user document is there
  - [ ] `appointments` collection exists
  - [ ] Your appointment is there
  - [ ] `notifications` collection exists

---

## Step 9: Build APK (Optional)

```bash
flutter build apk --release
```

- [ ] Build completed successfully
- [ ] APK created at: `build/app/outputs/flutter-apk/app-release.apk`

---

## Troubleshooting

### ❌ "Firebase not initialized" error
**Fix:**
- [ ] Make sure you ran `flutterfire configure`
- [ ] Check that `lib/firebase_options.dart` exists
- [ ] Restart the app

### ❌ Google Sign-In not working
**Fix:**
- [ ] Verify SHA-1 is added to Firebase Console
- [ ] Google provider is enabled in Authentication
- [ ] Run `flutter clean` then `flutter run`

### ❌ "Permission denied" in Firestore
**Fix:**
- [ ] Firestore is in "test mode"
- [ ] Go to Firestore → Rules tab
- [ ] Verify it says `allow read, write: if request.time < timestamp...`

### ❌ Package version conflicts
**Fix:**
```bash
flutter clean
flutter pub get
flutter run
```

### ❌ Gradle build errors
**Fix:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter run
```

---

## ✅ Success Indicators

You're all set when:
- ✅ App launches without errors
- ✅ Can create account with email/password
- ✅ Can sign in with Google
- ✅ Can book appointments
- ✅ Appointments appear in Firebase Console
- ✅ Profile updates work
- ✅ No Firebase errors in console

---

## 📱 For Assignment Submission

- [ ] App runs on physical device or emulator
- [ ] All features work (auth, appointments, profile)
- [ ] APK builds successfully
- [ ] Firebase Console shows data
- [ ] Ready to demonstrate

---

## 🎯 Quick Command Reference

```bash
# Install packages
flutter pub get

# Run app
flutter run

# Build APK
flutter build apk --release

# Check for issues
flutter doctor
flutter analyze

# Clean build
flutter clean

# Configure Firebase (if needed again)
flutterfire configure
```

---

## 📚 Documentation Files

- **Start here:** `QUICK_START.md`
- **Detailed setup:** `FIREBASE_SETUP.md`
- **Technical info:** `FIREBASE_INTEGRATION_SUMMARY.md`
- **Overview:** `README.md`

---

## 🎉 Once Complete

Congratulations! Your Safe Space app is now powered by Firebase with:
- 🔐 Secure authentication
- 💾 Real-time database
- 📱 Professional features
- ⚡ Live updates
- 🚀 Production-ready

**Ready for your assignment submission!** 🎓

---

**Questions?** Check the documentation files or Firebase Console's built-in help.

