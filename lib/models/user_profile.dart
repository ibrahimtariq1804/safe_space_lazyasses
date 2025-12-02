import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime? dateOfBirth;
  final String? bloodGroup;
  final String? address;
  final List<String> medicalConditions;
  final List<String> allergies;
  final String? emergencyContact;
  final String? emergencyContactPhone;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.dateOfBirth,
    this.bloodGroup,
    this.address,
    this.medicalConditions = const [],
    this.allergies = const [],
    this.emergencyContact,
    this.emergencyContactPhone,
    this.photoUrl,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'bloodGroup': bloodGroup,
      'address': address,
      'medicalConditions': medicalConditions,
      'allergies': allergies,
      'emergencyContact': emergencyContact,
      'emergencyContactPhone': emergencyContactPhone,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create from Firestore document
  factory UserProfile.fromMap(String id, Map<String, dynamic> map) {
    return UserProfile(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      dateOfBirth: map['dateOfBirth'] != null
          ? (map['dateOfBirth'] as Timestamp).toDate()
          : null,
      bloodGroup: map['bloodGroup'],
      address: map['address'],
      medicalConditions: List<String>.from(map['medicalConditions'] ?? []),
      allergies: List<String>.from(map['allergies'] ?? []),
      emergencyContact: map['emergencyContact'],
      emergencyContactPhone: map['emergencyContactPhone'],
      photoUrl: map['photoUrl'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Create a copy with updated fields
  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    DateTime? dateOfBirth,
    String? bloodGroup,
    String? address,
    List<String>? medicalConditions,
    List<String>? allergies,
    String? emergencyContact,
    String? emergencyContactPhone,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      address: address ?? this.address,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      allergies: allergies ?? this.allergies,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
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

