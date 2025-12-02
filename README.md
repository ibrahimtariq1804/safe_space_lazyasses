# Safe Space - Healthcare Platform 🏥

A comprehensive healthcare platform for both humans and pets, built with Flutter and Firebase.

## 🌟 Features

### Authentication 🔐
- Email/Password registration and login
- Google Sign-In integration
- Password reset functionality
- Secure session management

### Appointment Management 📅
- Browse and search doctors by specialization
- Book appointments with real-time availability
- Manage appointments (upcoming, past, cancelled)
- Real-time appointment status updates
- Appointment notifications

### Profile Management 👤
- Comprehensive user profiles
- Medical history tracking
- Allergy and condition management
- Emergency contact information
- Pet profiles for veterinary care

### Real-Time Features ⚡
- Live appointment updates
- Instant profile synchronization
- Real-time notifications
- Automatic data refresh

## 🏗️ Architecture

### Tech Stack
- **Frontend:** Flutter 3.0+
- **Backend:** Firebase (Authentication, Firestore, Storage)
- **State Management:** Provider
- **UI/UX:** Custom Material Design with dark theme

### Project Structure
```
lib/
├── main.dart                  # App entry point with Firebase initialization
├── models/                    # Data models with Firestore serialization
│   ├── appointment.dart
│   ├── doctor.dart
│   ├── pet.dart
│   └── user_profile.dart
├── screens/                   # UI screens
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── home_screen.dart
│   ├── appointment_scheduling_screen.dart
│   ├── appointments_list_screen.dart
│   ├── human_profile_screen.dart
│   └── edit_human_profile_screen.dart
├── services/                  # Business logic layer
│   ├── auth_service.dart     # Firebase Authentication
│   └── firestore_service.dart # Firestore operations
├── widgets/                   # Reusable components
│   ├── custom_button.dart
│   ├── custom_text_field.dart
│   └── doctor_card.dart
└── utils/                     # Theme and styling
    ├── app_colors.dart
    ├── app_spacing.dart
    ├── app_text_styles.dart
    └── app_theme.dart
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK
- Android Studio / Xcode
- Firebase account

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd safe_space_lazyasses
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Firebase** (IMPORTANT!)
   
   Follow the detailed guide in `QUICK_START.md` or:
   
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase
   flutterfire configure
   ```
   
   Then:
   - Enable Authentication (Email/Password + Google)
   - Enable Cloud Firestore (test mode)
   - Add SHA-1 for Google Sign-In

4. **Run the app**
   ```bash
   flutter run
   ```

## 📖 Documentation

- **[QUICK_START.md](QUICK_START.md)** - Get up and running in 5 minutes
- **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)** - Complete Firebase setup guide
- **[FIREBASE_INTEGRATION_SUMMARY.md](FIREBASE_INTEGRATION_SUMMARY.md)** - Technical integration details

## 🔥 Firebase Integration

This app uses Firebase for:

### Authentication
- Email/Password authentication
- Google Sign-In
- Password reset
- User session management

### Cloud Firestore
- User profiles storage
- Appointment bookings
- Notifications
- Real-time data synchronization

### Database Structure
```
firestore/
├── users/
│   └── {userId}/
│       ├── name, email, phone
│       ├── dateOfBirth, bloodGroup
│       ├── medicalConditions, allergies
│       └── emergencyContact
├── appointments/
│   └── {appointmentId}/
│       ├── userId, doctorId
│       ├── dateTime, status
│       └── patientName, symptoms
└── notifications/
    └── {notificationId}/
        ├── userId, title, message
        └── type, isRead, createdAt
```

## 🎨 UI/UX Highlights

- **Dark Theme:** Modern dark design optimized for medical professionals
- **Teal Accent:** Calming medical-grade color scheme
- **Responsive:** Adapts to different screen sizes
- **Intuitive:** Easy-to-navigate interface
- **Accessible:** High contrast for readability
- **Loading States:** Clear feedback for all operations

## 🔒 Security

- User authentication required for all operations
- Firestore security rules for data isolation
- Input validation on all forms
- Secure password handling (min 6 characters)
- Email validation
- Protected routes

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ⚠️ Web (requires additional Firebase setup)
- ⚠️ Desktop (requires additional configuration)

## 🛠️ Development

### Run in Debug Mode
```bash
flutter run
```

### Build Release APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Run Tests
```bash
flutter test
```

### Check for Issues
```bash
flutter doctor
flutter analyze
```

## 📦 Key Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
  firebase_storage: ^12.3.4
  google_sign_in: ^6.2.2
  
  # UI
  google_fonts: ^6.1.0
  flutter_svg: ^2.0.9
  
  # Utilities
  intl: ^0.19.0
  provider: ^6.1.1
```

## 🎯 Features Roadmap

### Current Version (v1.0.0)
- ✅ User authentication (Email/Password, Google)
- ✅ Appointment booking and management
- ✅ Profile management
- ✅ Real-time data synchronization
- ✅ Notifications system

### Future Enhancements
- [ ] Push notifications (FCM)
- [ ] Video telemedicine consultations
- [ ] Prescription management
- [ ] Medical records upload
- [ ] Payment integration
- [ ] Chat with doctors
- [ ] Appointment reminders
- [ ] Multi-language support

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is created for educational purposes as part of an academic assignment.

## 👥 Authors

- Your Name - Initial work and Firebase integration

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for the backend infrastructure
- Material Design for UI guidelines

## 📞 Support

For issues and questions:
1. Check `QUICK_START.md` for common setup issues
2. Review `FIREBASE_SETUP.md` for Firebase configuration
3. See `FIREBASE_INTEGRATION_SUMMARY.md` for technical details

## 🎓 Academic Note

This application demonstrates:
- Mobile app development with Flutter
- Backend integration with Firebase
- Real-time data synchronization
- User authentication and authorization
- Database design and management
- Clean architecture principles
- State management patterns
- Modern UI/UX design
- Production-ready error handling

---

**Built with ❤️ using Flutter and Firebase**

