@echo off
echo ========================================
echo Firebase Setup for Safe Space App
echo ========================================
echo.

echo Step 1: Checking Flutter...
flutter --version
if %errorlevel% neq 0 (
    echo ERROR: Flutter not found!
    pause
    exit /b 1
)
echo ✓ Flutter is ready
echo.

echo Step 2: Installing packages...
flutter pub get
echo ✓ Packages installed
echo.

echo Step 3: Configuring Firebase...
echo.
echo IMPORTANT: You need to:
echo 1. Create a Firebase project at: https://console.firebase.google.com/
echo 2. Name it: safe-space-app
echo.
echo Press any key to continue with configuration...
pause > nul
echo.

echo Running flutterfire configure...
echo (Use arrow keys to select your project, space to select platforms)
echo.
flutterfire configure

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Firebase configuration failed!
    echo Make sure you created a Firebase project first.
    pause
    exit /b 1
)

echo.
echo ✓ Firebase configured!
echo.
echo ========================================
echo NEXT STEPS:
echo ========================================
echo 1. Go to Firebase Console: https://console.firebase.google.com/
echo 2. Enable Authentication (Email/Password + Google)
echo 3. Enable Firestore Database (test mode)
echo 4. Run: flutter run
echo.
echo See DO_THIS_NOW.md for detailed instructions!
echo ========================================
pause

