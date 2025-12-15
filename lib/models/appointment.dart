import 'package:cloud_firestore/cloud_firestore.dart';

enum AppointmentStatus {
  pending,    // Newly booked, waiting for doctor confirmation
  confirmed,  // Accepted by doctor
  completed,
  cancelled,  // Cancelled by patient
  rejected,   // Rejected by doctor
  delayed,
}

class Appointment {
  final String id;
  final String userId;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialization;
  final DateTime dateTime;
  final AppointmentStatus status;
  final String patientName;
  final String symptoms;
  final String? notes;
  final String? rejectionReason; // Reason if doctor rejects
  final String? patientPhone;    // Patient contact
  final String doctorType;       // 'human' or 'pet'
  final DateTime createdAt;
  final DateTime? updatedAt;

  Appointment({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.dateTime,
    required this.status,
    required this.patientName,
    this.symptoms = '',
    this.notes,
    this.rejectionReason,
    this.patientPhone,
    this.doctorType = 'human',
    required this.createdAt,
    this.updatedAt,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialization': doctorSpecialization,
      'dateTime': Timestamp.fromDate(dateTime),
      'status': status.name,
      'patientName': patientName,
      'symptoms': symptoms,
      'notes': notes,
      'rejectionReason': rejectionReason,
      'patientPhone': patientPhone,
      'doctorType': doctorType,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Create from Firestore document
  factory Appointment.fromMap(String id, Map<String, dynamic> map) {
    return Appointment(
      id: id,
      userId: map['userId'] ?? '',
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      doctorSpecialization: map['doctorSpecialization'] ?? '',
      dateTime: (map['dateTime'] as Timestamp).toDate(),
      status: AppointmentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => AppointmentStatus.pending,
      ),
      patientName: map['patientName'] ?? '',
      symptoms: map['symptoms'] ?? '',
      notes: map['notes'],
      rejectionReason: map['rejectionReason'],
      patientPhone: map['patientPhone'],
      doctorType: map['doctorType'] ?? 'human',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Create a copy with updated fields
  Appointment copyWith({
    String? id,
    String? userId,
    String? doctorId,
    String? doctorName,
    String? doctorSpecialization,
    DateTime? dateTime,
    AppointmentStatus? status,
    String? patientName,
    String? symptoms,
    String? notes,
    String? rejectionReason,
    String? patientPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Appointment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialization: doctorSpecialization ?? this.doctorSpecialization,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      patientName: patientName ?? this.patientName,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      patientPhone: patientPhone ?? this.patientPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

