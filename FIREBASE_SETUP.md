# Firebase Setup Guide for Safe Space App

This guide will walk you through setting up Firebase for your Safe Space healthcare application.

## Prerequisites
- A Google account
- Flutter installed on your system
- FlutterFire CLI installed

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Enter project name: `safe-space-healthcare` (or your preferred name)
4. Accept terms and click "Continue"
5. Disable Google Analytics (optional) or configure it
6. Click "Create project"

## Step 2: Install FlutterFire CLI

If you haven't already, install the FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
```

Make sure the global pub executables are in your PATH.

## Step 3: Configure Firebase for Your Flutter App

Run the following command in your project directory:

```bash
flutterfire configure
```

This will:
- Ask you to select your Firebase project (select the one you created)
- Ask which platforms you want to support (select Android and iOS)
- Automatically create `firebase_options.dart` file
- Configure your Android and iOS projects

## Step 4: Enable Firebase Authentication

1. In Firebase Console, go to "Authentication" from the left sidebar
2. Click "Get started"
3. Enable the following sign-in methods:
   - **Email/Password**: Click on it and toggle "Enable"
   - **Google**: Click on it, toggle "Enable", and add your support email

## Step 5: Set Up Cloud Firestore

1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" for development (you can update rules later)
4. Select your preferred location (closest to your users)
5. Click "Enable"

### Recommended Firestore Security Rules

After testing, update your Firestore rules to:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Appointments collection - users can only access their own appointments
    match /appointments/{appointmentId} {
      allow read: if request.auth != null && 
                  (resource.data.userId == request.auth.uid || 
                   resource.data.doctorId == request.auth.uid);
      allow create: if request.auth != null && 
                    request.resource.data.userId == request.auth.uid;
      allow update, delete: if request.auth != null && 
                            resource.data.userId == request.auth.uid;
    }
    
    // Notifications collection - users can only read their own notifications
    match /notifications/{notificationId} {
      allow read: if request.auth != null && 
                  resource.data.userId == request.auth.uid;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
                            resource.data.userId == request.auth.uid;
    }
  }
}
```

## Step 6: Set Up Firebase Storage (Optional - for profile pictures)

1. In Firebase Console, go to "Storage"
2. Click "Get started"
3. Start in test mode
4. Click "Done"

### Recommended Storage Security Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User profile pictures
    match /users/{userId}/profile.{extension} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                   request.auth.uid == userId &&
                   request.resource.size < 5 * 1024 * 1024 && // 5MB limit
                   request.resource.contentType.matches('image/.*');
    }
  }
}
```

## Step 7: Configure Android (SHA-1 for Google Sign-In)

For Google Sign-In to work on Android, you need to add your SHA-1 key:

### Debug SHA-1 (for development)

1. Run this command to get your debug SHA-1:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   (On Windows: `gradlew signingReport`)

2. Copy the SHA-1 from the debug variant
3. In Firebase Console, go to Project Settings
4. Scroll to "Your apps" section
5. Click on your Android app
6. Add the SHA-1 certificate fingerprint

### Release SHA-1 (for production)

You'll need to add your release keystore SHA-1 before releasing the app.

## Step 8: Update Firebase Options (if needed)

The `firebase_options.dart` file should be automatically created in your `lib/` directory. If it's not there, run:

```bash
flutterfire configure
```

## Step 9: Test Your Setup

1. Run the app:
   ```bash
   flutter run
   ```

2. Try creating an account with email/password
3. Try signing in with Google
4. Book a test appointment
5. Update your profile

## Firestore Database Structure

Your Firestore database will have the following collections:

### `users` Collection
```json
{
  "userId": {
    "name": "string",
    "email": "string",
    "phone": "string",
    "dateOfBirth": "timestamp",
    "bloodGroup": "string",
    "address": "string",
    "medicalConditions": ["array of strings"],
    "allergies": ["array of strings"],
    "emergencyContact": "string",
    "emergencyContactPhone": "string",
    "photoUrl": "string",
    "createdAt": "timestamp",
    "updatedAt": "timestamp"
  }
}
```

### `appointments` Collection
```json
{
  "appointmentId": {
    "userId": "string",
    "doctorId": "string",
    "doctorName": "string",
    "doctorSpecialization": "string",
    "dateTime": "timestamp",
    "status": "confirmed|pending|completed|cancelled|delayed",
    "patientName": "string",
    "symptoms": "string",
    "notes": "string",
    "createdAt": "timestamp",
    "updatedAt": "timestamp"
  }
}
```

### `notifications` Collection
```json
{
  "notificationId": {
    "userId": "string",
    "title": "string",
    "message": "string",
    "type": "appointment|reminder|healthTip|message",
    "isRead": "boolean",
    "createdAt": "timestamp"
  }
}
```

## Troubleshooting

### Issue: Google Sign-In not working on Android
**Solution**: Make sure you've added your SHA-1 certificate to Firebase Console.

### Issue: "Firebase not initialized" error
**Solution**: Ensure `Firebase.initializeApp()` is called in `main()` before `runApp()`.

### Issue: Permission denied errors in Firestore
**Solution**: Check your Firestore security rules. Start with test mode for development.

### Issue: Package version conflicts
**Solution**: Run `flutter pub upgrade` to update compatible packages.

## Production Checklist

Before deploying to production:

- [ ] Update Firestore security rules (remove test mode)
- [ ] Update Firebase Storage security rules
- [ ] Add release SHA-1 to Firebase Console
- [ ] Enable App Check for additional security
- [ ] Set up Firebase Analytics (optional)
- [ ] Set up Firebase Crashlytics (optional)
- [ ] Configure email templates in Firebase Authentication
- [ ] Set up proper error logging
- [ ] Test all authentication flows
- [ ] Test appointment booking and management
- [ ] Test profile updates

## Need Help?

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)

## Firebase Features Integrated

✅ **Authentication**
- Email/Password sign-in
- Google Sign-In
- Password reset
- User management

✅ **Cloud Firestore**
- User profiles storage
- Appointments management
- Real-time updates
- Notifications

✅ **Firebase Storage** (ready to use)
- Profile picture uploads
- Medical records storage

✅ **Security**
- Authentication required for all operations
- User-specific data access
- Secure Firestore rules

