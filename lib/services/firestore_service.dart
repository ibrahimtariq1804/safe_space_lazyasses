import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/appointment.dart';
import '../models/pet.dart';
import '../models/doctor_profile.dart';
import '../models/chat_message.dart';
import 'notification_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ USER PROFILE OPERATIONS ============

  // Get user profile
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        return UserProfile.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw 'Failed to get user profile: $e';
    }
  }

  // Get user profile stream
  Stream<UserProfile?> getUserProfileStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserProfile.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Update user profile
  Future<void> updateUserProfile(String userId, UserProfile profile) async {
    try {
      await _firestore.collection('users').doc(userId).update(
        profile.copyWith(updatedAt: DateTime.now()).toMap(),
      );
    } catch (e) {
      throw 'Failed to update user profile: $e';
    }
  }

  // ============ APPOINTMENT OPERATIONS ============

  // Create appointment
  Future<String> createAppointment(Appointment appointment) async {
    try {
      DocumentReference docRef = await _firestore.collection('appointments').add(
        appointment.toMap(),
      );
      return docRef.id;
    } catch (e) {
      throw 'Failed to create appointment: $e';
    }
  }

  // Get appointments for user
  Future<List<Appointment>> getUserAppointments(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          .get();

      final appointments = snapshot.docs
          .map((doc) => Appointment.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      
      // Sort in app to avoid index requirement
      appointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return appointments;
    } catch (e) {
      throw 'Failed to get appointments: $e';
    }
  }

  // Get appointments stream for user
  Stream<List<Appointment>> getUserAppointmentsStream(String userId) {
    return _firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final appointments = snapshot.docs
          .map((doc) => Appointment.fromMap(doc.id, doc.data()))
          .toList();
      
      // Sort in app instead of Firestore to avoid index requirement
      appointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return appointments;
    });
  }

  // Get upcoming appointments
  Future<List<Appointment>> getUpcomingAppointments(String userId) async {
    try {
      final now = DateTime.now();
      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          .get();

      final appointments = snapshot.docs
          .map((doc) => Appointment.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      
      // Filter and sort in app to avoid index requirement
      final upcoming = appointments
          .where((apt) => apt.dateTime.isAfter(now))
          .toList();
      upcoming.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return upcoming;
    } catch (e) {
      throw 'Failed to get upcoming appointments: $e';
    }
  }

  // Get appointments by status
  Future<List<Appointment>> getAppointmentsByStatus(
    String userId,
    AppointmentStatus status,
  ) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          .get();

      final appointments = snapshot.docs
          .map((doc) => Appointment.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      
      // Filter and sort in app to avoid index requirement
      final filtered = appointments
          .where((apt) => apt.status == status)
          .toList();
      filtered.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return filtered;
    } catch (e) {
      throw 'Failed to get appointments by status: $e';
    }
  }

  // Update appointment
  Future<void> updateAppointment(String appointmentId, Appointment appointment) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update(
        appointment.copyWith(updatedAt: DateTime.now()).toMap(),
      );
    } catch (e) {
      throw 'Failed to update appointment: $e';
    }
  }

  // Update appointment status
  Future<void> updateAppointmentStatus(
    String appointmentId,
    AppointmentStatus status,
  ) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': status.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw 'Failed to update appointment status: $e';
    }
  }

  // Cancel appointment
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await updateAppointmentStatus(appointmentId, AppointmentStatus.cancelled);
    } catch (e) {
      throw 'Failed to cancel appointment: $e';
    }
  }

  // Delete appointment
  Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).delete();
    } catch (e) {
      throw 'Failed to delete appointment: $e';
    }
  }

  // Get appointment by ID
  Future<Appointment?> getAppointment(String appointmentId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();

      if (doc.exists) {
        return Appointment.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw 'Failed to get appointment: $e';
    }
  }

  // Get booked time slots for a doctor on a specific date
  Future<List<String>> getBookedSlotsForDoctor(String doctorId, DateTime date) async {
    try {
      // Get start and end of the day
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      final appointments = snapshot.docs
          .map((doc) => Appointment.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .where((apt) {
            // Filter by date and only include pending/confirmed appointments
            // Rejected and cancelled slots become available again
            return apt.dateTime.isAfter(startOfDay) &&
                apt.dateTime.isBefore(endOfDay) &&
                (apt.status == AppointmentStatus.pending ||
                 apt.status == AppointmentStatus.confirmed);
          })
          .toList();

      // Convert appointment times to time slot strings (e.g., "09:00 AM")
      return appointments.map((apt) {
        final hour = apt.dateTime.hour;
        final minute = apt.dateTime.minute;
        final isPM = hour >= 12;
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        final period = isPM ? 'PM' : 'AM';
        final hourStr = displayHour.toString().padLeft(2, '0');
        final minuteStr = minute.toString().padLeft(2, '0');
        return '$hourStr:$minuteStr $period';
      }).toList();
    } catch (e) {
      // Return empty list on error to not block the UI
      return [];
    }
  }

  // ============ NOTIFICATION OPERATIONS ============

  // Create notification
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'isRead': false,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw 'Failed to create notification: $e';
    }
  }

  // Get notifications stream for user
  Stream<List<Map<String, dynamic>>> getNotificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return {...doc.data(), 'id': doc.id};
      }).toList()..sort((a, b) {
          final aTime = (a['createdAt'] as Timestamp).toDate();
          final bTime = (b['createdAt'] as Timestamp).toDate();
          return bTime.compareTo(aTime); // Newest first
        });
    });
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      throw 'Failed to mark notification as read: $e';
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      throw 'Failed to delete notification: $e';
    }
  }

  // Clear all notifications for user
  Future<void> clearAllNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      WriteBatch batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw 'Failed to clear notifications: $e';
    }
  }

  // Get user notifications
  Stream<QuerySnapshot> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  // ============ BATCH OPERATIONS ============

  // Batch update appointments
  Future<void> batchUpdateAppointments(
    List<String> appointmentIds,
    Map<String, dynamic> updates,
  ) async {
    try {
      WriteBatch batch = _firestore.batch();

      for (String id in appointmentIds) {
        DocumentReference docRef = _firestore.collection('appointments').doc(id);
        batch.update(docRef, updates);
      }

      await batch.commit();
    } catch (e) {
      throw 'Failed to batch update appointments: $e';
    }
  }

  // ============ PET PROFILE OPERATIONS ============

  // Create pet profile
  Future<String> createPetProfile(Pet pet) async {
    try {
      DocumentReference docRef = await _firestore.collection('pets').add(pet.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Failed to create pet profile: $e';
    }
  }

  // Get pet profile by user ID
  Future<Pet?> getPetProfileByUserId(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('pets')
          .where('ownerId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      final data = snapshot.docs.first.data() as Map<String, dynamic>;
      return Pet.fromMap({...data, 'id': snapshot.docs.first.id});
    } catch (e) {
      throw 'Failed to get pet profile: $e';
    }
  }

  // Get pet profile stream
  Stream<Pet?> getPetProfileStream(String userId) {
    return _firestore
        .collection('pets')
        .where('ownerId', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final data = snapshot.docs.first.data();
      return Pet.fromMap({...data, 'id': snapshot.docs.first.id});
    });
  }

  // Update pet profile
  Future<void> updatePetProfile(String petId, Pet pet) async {
    try {
      await _firestore.collection('pets').doc(petId).update(
            pet.copyWith(updatedAt: DateTime.now()).toMap(),
          );
    } catch (e) {
      throw 'Failed to update pet profile: $e';
    }
  }

  // Delete pet profile
  Future<void> deletePetProfile(String petId) async {
    try {
      await _firestore.collection('pets').doc(petId).delete();
    } catch (e) {
      throw 'Failed to delete pet profile: $e';
    }
  }

  // ============ DOCTOR PROFILE OPERATIONS ============

  // Create doctor profile
  Future<void> createDoctorProfile(String doctorId, DoctorProfile profile) async {
    try {
      await _firestore.collection('doctors').doc(doctorId).set(profile.toMap());
    } catch (e) {
      throw 'Failed to create doctor profile: $e';
    }
  }

  // Get doctor profile
  Future<DoctorProfile?> getDoctorProfile(String doctorId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('doctors').doc(doctorId).get();
      
      if (doc.exists) {
        return DoctorProfile.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw 'Failed to get doctor profile: $e';
    }
  }

  // Get doctor profile stream
  Stream<DoctorProfile?> getDoctorProfileStream(String doctorId) {
    return _firestore.collection('doctors').doc(doctorId).snapshots().map((doc) {
      if (doc.exists) {
        return DoctorProfile.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Update doctor profile
  Future<void> updateDoctorProfile(String doctorId, DoctorProfile profile) async {
    try {
      await _firestore.collection('doctors').doc(doctorId).update(
        profile.copyWith(updatedAt: DateTime.now()).toMap(),
      );
    } catch (e) {
      throw 'Failed to update doctor profile: $e';
    }
  }

  // Get all doctors for patient search
  Future<List<DoctorProfile>> getAllDoctors() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('doctors')
          .where('isAvailable', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => DoctorProfile.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Failed to get doctors: $e';
    }
  }

  // Get doctors stream for patient search
  Stream<List<DoctorProfile>> getDoctorsStream() {
    return _firestore
        .collection('doctors')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DoctorProfile.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // ============ DOCTOR APPOINTMENT OPERATIONS ============

  // Get appointments for doctor
  Future<List<Appointment>> getDoctorAppointments(String doctorId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      final appointments = snapshot.docs
          .map((doc) => Appointment.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      
      // Sort by date
      appointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return appointments;
    } catch (e) {
      throw 'Failed to get doctor appointments: $e';
    }
  }

  // Get appointments stream for doctor
  Stream<List<Appointment>> getDoctorAppointmentsStream(String doctorId) {
    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snapshot) {
      final appointments = snapshot.docs
          .map((doc) => Appointment.fromMap(doc.id, doc.data()))
          .toList();
      
      // Sort in app
      appointments.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return appointments;
    });
  }

  // Get pending appointments for doctor (needs acceptance)
  Stream<List<Appointment>> getDoctorPendingAppointmentsStream(String doctorId) {
    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snapshot) {
      final appointments = snapshot.docs
          .map((doc) => Appointment.fromMap(doc.id, doc.data()))
          .where((apt) => apt.status == AppointmentStatus.pending)
          .toList();
      
      // Sort by earliest first
      appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return appointments;
    });
  }

  // Get upcoming confirmed appointments for doctor
  Stream<List<Appointment>> getDoctorUpcomingAppointmentsStream(String doctorId) {
    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      final appointments = snapshot.docs
          .map((doc) => Appointment.fromMap(doc.id, doc.data()))
          .where((apt) => 
              apt.status == AppointmentStatus.confirmed &&
              apt.dateTime.isAfter(now))
          .toList();
      
      // Sort by earliest first
      appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return appointments;
    });
  }

  // Accept appointment (doctor confirms)
  Future<void> acceptAppointment(String appointmentId, String patientUserId, String doctorName) async {
    try {
      // Update appointment status
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': AppointmentStatus.confirmed.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Get the appointment details for scheduling local notifications
      final appointmentDoc = await _firestore.collection('appointments').doc(appointmentId).get();
      if (appointmentDoc.exists) {
        final appointment = Appointment.fromMap(appointmentDoc.id, appointmentDoc.data()!);
        
        // Schedule local notifications for the patient
        try {
          final notificationService = NotificationService();
          await notificationService.scheduleAppointmentReminder(
            appointment: appointment,
          );
        } catch (e) {
          // Don't fail the whole operation if notification scheduling fails
          print('Failed to schedule local notifications: $e');
        }
      }

      // Create in-app notification for patient
      await createNotification(
        userId: patientUserId,
        title: 'Appointment Confirmed',
        message: 'Dr. $doctorName has confirmed your appointment.',
        type: 'appointment',
      );
    } catch (e) {
      throw 'Failed to accept appointment: $e';
    }
  }

  // Reject appointment (doctor declines)
  Future<void> rejectAppointment(String appointmentId, String patientUserId, String doctorName, String reason) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': AppointmentStatus.rejected.name,
        'rejectionReason': reason,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Create notification for patient
      await createNotification(
        userId: patientUserId,
        title: 'Appointment Declined',
        message: 'Dr. $doctorName has declined your appointment. Reason: $reason',
        type: 'appointment',
      );
    } catch (e) {
      throw 'Failed to reject appointment: $e';
    }
  }

  // Complete appointment
  Future<void> completeAppointment(String appointmentId, String patientUserId, String doctorName) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': AppointmentStatus.completed.name,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Create notification for patient
      await createNotification(
        userId: patientUserId,
        title: 'Appointment Completed',
        message: 'Your appointment with Dr. $doctorName has been marked as completed.',
        type: 'appointment',
      );
    } catch (e) {
      throw 'Failed to complete appointment: $e';
    }
  }

  // Get doctor's today appointments
  Stream<List<Appointment>> getDoctorTodayAppointmentsStream(String doctorId) {
    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
      
      final appointments = snapshot.docs
          .map((doc) => Appointment.fromMap(doc.id, doc.data()))
          .where((apt) =>
              apt.dateTime.isAfter(startOfDay) &&
              apt.dateTime.isBefore(endOfDay) &&
              (apt.status == AppointmentStatus.confirmed || apt.status == AppointmentStatus.pending))
          .toList();
      
      // Sort by time
      appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return appointments;
    });
  }

  // Get doctor statistics
  Future<Map<String, int>> getDoctorStats(String doctorId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      final appointments = snapshot.docs
          .map((doc) => Appointment.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      return {
        'pending': appointments.where((a) => a.status == AppointmentStatus.pending).length,
        'todayAppointments': appointments.where((a) =>
            a.dateTime.isAfter(startOfDay) &&
            a.dateTime.isBefore(endOfDay) &&
            (a.status == AppointmentStatus.confirmed || a.status == AppointmentStatus.pending)).length,
        'totalPatients': appointments.map((a) => a.userId).toSet().length,
        'completedToday': appointments.where((a) =>
            a.status == AppointmentStatus.completed &&
            a.updatedAt != null &&
            a.updatedAt!.isAfter(startOfDay) &&
            a.updatedAt!.isBefore(endOfDay)).length,
      };
    } catch (e) {
      return {'pending': 0, 'todayAppointments': 0, 'totalPatients': 0, 'completedToday': 0};
    }
  }

  // Check if user is a doctor
  Future<bool> isDoctor(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('doctors').doc(userId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // ============ CHAT/MESSAGING OPERATIONS ============

  // Generate unique chat ID between patient and doctor
  String _generateChatId(String patientId, String doctorId) {
    // Always use same order to ensure consistent chat ID
    final ids = [patientId, doctorId]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  // Send a message
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
    required String senderType, // 'patient' or 'doctor'
  }) async {
    try {
      final chatId = _generateChatId(senderId, receiverId);
      
      await _firestore.collection('messages').add(
        ChatMessage(
          id: '',
          chatId: chatId,
          senderId: senderId,
          receiverId: receiverId,
          message: message,
          timestamp: DateTime.now(),
          isRead: false,
          senderType: senderType,
        ).toMap(),
      );
    } catch (e) {
      throw 'Failed to send message: $e';
    }
  }

  // Get messages stream for a specific chat (between patient and doctor)
  Stream<List<ChatMessage>> getChatMessagesStream({
    required String patientId,
    required String doctorId,
  }) {
    final chatId = _generateChatId(patientId, doctorId);
    
    return _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs
          .map((doc) => ChatMessage.fromMap(doc.id, doc.data()))
          .toList();
      
      // Sort in memory instead of Firestore to avoid index requirement
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    });
  }

  // Mark messages as read
  Future<void> markMessagesAsRead({
    required String patientId,
    required String doctorId,
    required String currentUserId,
  }) async {
    try {
      final chatId = _generateChatId(patientId, doctorId);
      
      final snapshot = await _firestore
          .collection('messages')
          .where('chatId', isEqualTo: chatId)
          .where('receiverId', isEqualTo: currentUserId)
          .where('isRead', isEqualTo: false)
          .get();

      WriteBatch batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw 'Failed to mark messages as read: $e';
    }
  }

  // Get unread message count for a user
  Future<int> getUnreadMessageCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  // Get list of doctors patient has confirmed appointments with (for chat inbox)
  Future<List<String>> getDoctorIdsWithConfirmedAppointments(String patientId) async {
    try {
      final snapshot = await _firestore
          .collection('appointments')
          .where('userId', isEqualTo: patientId)
          .where('status', isEqualTo: AppointmentStatus.confirmed.name)
          .get();

      final doctorIds = snapshot.docs
          .map((doc) {
            final data = doc.data();
            return data['doctorId'] as String?;
          })
          .where((id) => id != null)
          .cast<String>()
          .toSet()
          .toList();

      return doctorIds;
    } catch (e) {
      return [];
    }
  }

  // Get list of patients doctor has confirmed appointments with (for doctor's chat inbox)
  Future<List<String>> getPatientIdsWithConfirmedAppointments(String doctorId) async {
    try {
      final snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: AppointmentStatus.confirmed.name)
          .get();

      final patientIds = snapshot.docs
          .map((doc) {
            final data = doc.data();
            return data['userId'] as String?;
          })
          .where((id) => id != null)
          .cast<String>()
          .toSet()
          .toList();

      return patientIds;
    } catch (e) {
      return [];
    }
  }

  // Get user profiles by IDs (for doctor's chat inbox to show patient names)
  Future<List<UserProfile>> getUserProfilesByIds(List<String> userIds) async {
    if (userIds.isEmpty) return [];
    
    try {
      final profiles = <UserProfile>[];
      
      // Firestore 'in' query has a limit of 10 items, so we batch if needed
      for (var i = 0; i < userIds.length; i += 10) {
        final batch = userIds.skip(i).take(10).toList();
        final snapshot = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        
        profiles.addAll(
          snapshot.docs.map((doc) => UserProfile.fromMap(doc.id, doc.data()))
        );
      }
      
      return profiles;
    } catch (e) {
      return [];
    }
  }
}

