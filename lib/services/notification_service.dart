import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/appointment.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions (Android 13+)
    await _requestPermissions();

    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // You can navigate to specific screens based on payload
    print('Notification tapped: ${response.payload}');
  }

  // Show immediate notification (appointment confirmed)
  Future<void> showAppointmentConfirmedNotification({
    required String doctorName,
    required DateTime appointmentTime,
    required String appointmentId,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'appointment_channel',
      'Appointments',
      channelDescription: 'Notifications for appointment updates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      appointmentId.hashCode,
      '✅ Appointment Confirmed',
      'Your appointment with $doctorName is confirmed for ${_formatDateTime(appointmentTime)}',
      notificationDetails,
      payload: 'appointment:$appointmentId',
    );
  }

  // Schedule reminder notification (30 minutes before)
  Future<void> scheduleAppointmentReminder({
    required Appointment appointment,
  }) async {
    // Schedule for 30 minutes before appointment
    final reminderTime = appointment.dateTime.subtract(const Duration(minutes: 30));

    // Don't schedule if time has passed
    if (reminderTime.isBefore(DateTime.now())) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Appointment reminders',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      sound: RawResourceAndroidNotificationSound('notification'),
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      appointment.id.hashCode + 1000, // Different ID for reminder
      '⏰ Appointment Reminder',
      'Your appointment with ${appointment.doctorName} is in 30 minutes!',
      tz.TZDateTime.from(reminderTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'reminder:${appointment.id}',
    );
  }

  // Cancel scheduled notifications for an appointment
  Future<void> cancelAppointmentNotifications(String appointmentId) async {
    await _notifications.cancel(appointmentId.hashCode);
    await _notifications.cancel(appointmentId.hashCode + 1000);
  }

  // Show appointment cancelled notification
  Future<void> showAppointmentCancelledNotification({
    required String doctorName,
    required DateTime appointmentTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'appointment_channel',
      'Appointments',
      channelDescription: 'Notifications for appointment updates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      '❌ Appointment Cancelled',
      'Your appointment with $doctorName on ${_formatDateTime(appointmentTime)} has been cancelled',
      notificationDetails,
    );
  }

  // Show appointment rescheduled notification
  Future<void> showAppointmentRescheduledNotification({
    required String doctorName,
    required DateTime newTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'appointment_channel',
      'Appointments',
      channelDescription: 'Notifications for appointment updates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      '🔄 Appointment Rescheduled',
      'Your appointment with $doctorName has been rescheduled to ${_formatDateTime(newTime)}',
      notificationDetails,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year} at $hour:$minute $period';
  }
}

