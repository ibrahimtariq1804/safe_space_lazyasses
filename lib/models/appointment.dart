enum AppointmentStatus {
  pending,
  confirmed,
  completed,
  cancelled,
}

class Appointment {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialization;
  final DateTime dateTime;
  final AppointmentStatus status;
  final String patientName;
  final String symptoms;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.dateTime,
    required this.status,
    required this.patientName,
    this.symptoms = '',
  });
}

