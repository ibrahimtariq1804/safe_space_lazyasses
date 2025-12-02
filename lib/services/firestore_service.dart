import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/appointment.dart';
import '../models/pet.dart';

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
}

