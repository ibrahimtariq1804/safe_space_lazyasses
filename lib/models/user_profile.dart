class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime dateOfBirth;
  final String bloodGroup;
  final String address;
  final List<String> medicalConditions;
  final List<String> allergies;
  final String emergencyContact;
  final String emergencyContactPhone;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.bloodGroup,
    required this.address,
    required this.medicalConditions,
    required this.allergies,
    required this.emergencyContact,
    required this.emergencyContactPhone,
  });
}

class Notification {
  final String id;
  final String title;
  final String message;
  final DateTime dateTime;
  final NotificationType type;
  final bool isRead;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.dateTime,
    required this.type,
    this.isRead = false,
  });
}

enum NotificationType {
  appointment,
  reminder,
  healthTip,
  message,
}

