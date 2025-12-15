import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String specialization;
  final String licenseNumber;
  final int experience; // years of experience
  final String clinicName;
  final String clinicAddress;
  final double rating;
  final int totalPatients;
  final String? about;
  final List<String> availableDays;
  final String? photoUrl;
  final bool isAvailable;
  final String doctorType; // 'human' or 'pet'
  final String startTime; // e.g., "09:00"
  final String endTime; // e.g., "17:00"
  final DateTime createdAt;
  final DateTime? updatedAt;

  DoctorProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    required this.specialization,
    required this.licenseNumber,
    this.experience = 0,
    this.clinicName = '',
    this.clinicAddress = '',
    this.rating = 0.0,
    this.totalPatients = 0,
    this.about,
    this.availableDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    this.photoUrl,
    this.isAvailable = true,
    this.doctorType = 'human', // Default to human doctor
    this.startTime = '09:00',
    this.endTime = '17:00',
    required this.createdAt,
    this.updatedAt,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'specialization': specialization,
      'licenseNumber': licenseNumber,
      'experience': experience,
      'clinicName': clinicName,
      'clinicAddress': clinicAddress,
      'rating': rating,
      'totalPatients': totalPatients,
      'about': about,
      'availableDays': availableDays,
      'photoUrl': photoUrl,
      'isAvailable': isAvailable,
      'doctorType': doctorType,
      'startTime': startTime,
      'endTime': endTime,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create from Firestore document
  factory DoctorProfile.fromMap(String id, Map<String, dynamic> map) {
    return DoctorProfile(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      specialization: map['specialization'] ?? '',
      licenseNumber: map['licenseNumber'] ?? '',
      experience: map['experience'] ?? 0,
      clinicName: map['clinicName'] ?? '',
      clinicAddress: map['clinicAddress'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      totalPatients: map['totalPatients'] ?? 0,
      about: map['about'],
      availableDays: List<String>.from(map['availableDays'] ?? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']),
      photoUrl: map['photoUrl'],
      isAvailable: map['isAvailable'] ?? true,
      doctorType: map['doctorType'] ?? 'human',
      startTime: map['startTime'] ?? '09:00',
      endTime: map['endTime'] ?? '17:00',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Create a copy with updated fields
  DoctorProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? specialization,
    String? licenseNumber,
    int? experience,
    String? clinicName,
    String? clinicAddress,
    double? rating,
    int? totalPatients,
    String? about,
    List<String>? availableDays,
    String? photoUrl,
    bool? isAvailable,
    String? doctorType,
    String? startTime,
    String? endTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DoctorProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      specialization: specialization ?? this.specialization,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      experience: experience ?? this.experience,
      clinicName: clinicName ?? this.clinicName,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      rating: rating ?? this.rating,
      totalPatients: totalPatients ?? this.totalPatients,
      about: about ?? this.about,
      availableDays: availableDays ?? this.availableDays,
      photoUrl: photoUrl ?? this.photoUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      doctorType: doctorType ?? this.doctorType,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

