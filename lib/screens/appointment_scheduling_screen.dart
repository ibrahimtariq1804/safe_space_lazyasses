import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/doctor.dart';
import '../models/appointment.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/custom_button.dart';

class AppointmentSchedulingScreen extends StatefulWidget {
  final Doctor doctor;

  const AppointmentSchedulingScreen({Key? key, required this.doctor})
      : super(key: key);

  @override
  State<AppointmentSchedulingScreen> createState() =>
      _AppointmentSchedulingScreenState();
}

class _AppointmentSchedulingScreenState
    extends State<AppointmentSchedulingScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  String _appointmentType = 'In-Person';
  bool _isBooking = false;
  List<String> _bookedSlots = [];
  bool _isLoadingSlots = false;

  final List<String> _timeSlots = [
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '02:00 PM',
    '02:30 PM',
    '03:00 PM',
    '03:30 PM',
    '04:00 PM',
    '04:30 PM',
  ];

  @override
  void initState() {
    super.initState();
    _loadBookedSlots();
  }

  Future<void> _loadBookedSlots() async {
    setState(() => _isLoadingSlots = true);
    try {
      final firestoreService = context.read<FirestoreService>();
      final bookedSlots = await firestoreService.getBookedSlotsForDoctor(
        widget.doctor.id,
        _selectedDate,
      );
      if (mounted) {
        setState(() {
          _bookedSlots = bookedSlots;
          _isLoadingSlots = false;
          // Clear selected time slot if it's now booked
          if (_selectedTimeSlot != null && _bookedSlots.contains(_selectedTimeSlot)) {
            _selectedTimeSlot = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSlots = false);
      }
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedTimeSlot = null; // Reset time slot when date changes
    });
    _loadBookedSlots(); // Reload booked slots for new date
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.tealAccent.withValues(alpha: 0.05),
              AppColors.deepCharcoal,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDoctorCard(),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildAppointmentType(),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildDateSelector(),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildTimeSlots(),
                      const SizedBox(height: AppSpacing.xxxl),
                      _buildConfirmButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: AppColors.tealAccent,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Book Appointment',
                  style: AppTextStyles.h3,
                ),
                Text(
                  'Choose your preferred slot',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.tealAccent.withValues(alpha: 0.15),
            AppColors.cardBackground,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.tealAccent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.tealAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.tealAccent,
              size: 35,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctor.name,
                  style: AppTextStyles.h3.copyWith(fontSize: 18),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.doctor.specialization,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 16,
                      color: AppColors.tealAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.doctor.rating.toString(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.tealAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Icon(
                      Icons.work_outline,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.doctor.experience} years',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Appointment Type',
          style: AppTextStyles.h3.copyWith(fontSize: 18),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildTypeOption(
                'In-Person',
                Icons.person_outline,
                _appointmentType == 'In-Person',
                () => setState(() => _appointmentType = 'In-Person'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildTypeOption(
                'Video Call',
                Icons.videocam_outlined,
                _appointmentType == 'Video Call',
                () => setState(() => _appointmentType = 'Video Call'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeOption(
      String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.tealAccent
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected
                ? AppColors.tealAccent
                : AppColors.inputBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.tealAccent.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.deepCharcoal
                  : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected
                    ? AppColors.deepCharcoal
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Date',
              style: AppTextStyles.h3.copyWith(fontSize: 18),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.tealAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppColors.tealAccent,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    DateFormat('MMM yyyy').format(_selectedDate),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.tealAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 21,
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              final isSelected = date.day == _selectedDate.day &&
                  date.month == _selectedDate.month &&
                  date.year == _selectedDate.year;
              final isToday = date.day == DateTime.now().day &&
                  date.month == DateTime.now().month &&
                  date.year == DateTime.now().year;

              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: InkWell(
                  onTap: () => _onDateSelected(date),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 75,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.tealAccent,
                                AppColors.tealAccentLight,
                              ],
                            )
                          : null,
                      color: isSelected ? null : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : isToday
                                ? AppColors.tealAccent.withValues(alpha: 0.5)
                                : AppColors.inputBorder,
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.tealAccent.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE').format(date),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isSelected
                                ? AppColors.deepCharcoal
                                : AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          date.day.toString(),
                          style: AppTextStyles.h2.copyWith(
                            color: isSelected
                                ? AppColors.deepCharcoal
                                : AppColors.textPrimary,
                            fontSize: 24,
                          ),
                        ),
                        if (isToday && !isSelected) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.tealAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlots() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Available Time Slots',
              style: AppTextStyles.h3.copyWith(fontSize: 18),
            ),
            if (_isLoadingSlots) ...[
              const SizedBox(width: AppSpacing.md),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.tealAccent),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: _timeSlots.map((time) {
            final isSelected = _selectedTimeSlot == time;
            final isPast = _isPastTime(time);
            final isBooked = _bookedSlots.contains(time);
            final isUnavailable = isPast || isBooked;

            return InkWell(
              onTap: isUnavailable ? null : () => setState(() => _selectedTimeSlot = time),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.tealAccent,
                            AppColors.tealAccentLight,
                          ],
                        )
                      : null,
                  color: isSelected
                      ? null
                      : isUnavailable
                          ? AppColors.cardBackground.withValues(alpha: 0.5)
                          : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : isBooked
                            ? AppColors.error.withValues(alpha: 0.3)
                            : isPast
                                ? AppColors.inputBorder.withValues(alpha: 0.3)
                                : AppColors.inputBorder,
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.tealAccent.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isBooked ? Icons.block : Icons.access_time,
                      size: 18,
                      color: isSelected
                          ? AppColors.deepCharcoal
                          : isBooked
                              ? AppColors.error.withValues(alpha: 0.5)
                              : isPast
                                  ? AppColors.textTertiary.withValues(alpha: 0.5)
                                  : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      isBooked ? '$time (Booked)' : time,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isSelected
                            ? AppColors.deepCharcoal
                            : isBooked
                                ? AppColors.error.withValues(alpha: 0.5)
                                : isPast
                                    ? AppColors.textTertiary.withValues(alpha: 0.5)
                                    : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        decoration: isUnavailable ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  bool _isPastTime(String timeSlot) {
    if (_selectedDate.day != DateTime.now().day ||
        _selectedDate.month != DateTime.now().month ||
        _selectedDate.year != DateTime.now().year) {
      return false;
    }

    final now = DateTime.now();
    final parts = timeSlot.split(' ');
    final timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final isPM = parts[1] == 'PM';

    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;

    final slotTime = DateTime(now.year, now.month, now.day, hour, minute);
    return slotTime.isBefore(now);
  }

  Widget _buildConfirmButton() {
    return CustomButton(
      text: _selectedTimeSlot != null
          ? 'Confirm Appointment'
          : 'Select Time Slot',
      onPressed: _selectedTimeSlot != null
          ? () => _confirmAndBookAppointment()
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Please select a time slot'),
                  backgroundColor: AppColors.warning,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
              );
            },
      isLoading: _isBooking,
      icon: Icons.check_circle_outline,
    );
  }

  Future<void> _confirmAndBookAppointment() async {
    setState(() => _isBooking = true);

    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        throw 'Please log in to book an appointment';
      }

      // Get user profile to get name
      final userProfile = await firestoreService.getUserProfile(currentUser.uid);
      final userName = userProfile?.name ?? currentUser.displayName ?? 'User';

      // Combine date and time
      final appointmentDateTime = _combineDateTime(_selectedDate, _selectedTimeSlot!);

      // Get doctor profile to fetch doctor type
      final doctorProfile = await firestoreService.getDoctorProfile(widget.doctor.id);
      final doctorType = doctorProfile?.doctorType ?? 'human';

      // Create appointment with pending status (awaiting doctor confirmation)
      final appointment = Appointment(
        id: '',
        userId: currentUser.uid,
        doctorId: widget.doctor.id,
        doctorName: widget.doctor.name,
        doctorSpecialization: widget.doctor.specialization,
        dateTime: appointmentDateTime,
        status: AppointmentStatus.pending, // Pending until doctor accepts
        patientName: userName,
        patientPhone: userProfile?.phone,
        symptoms: '',
        notes: 'Type: $_appointmentType',
        doctorType: doctorType,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      await firestoreService.createAppointment(appointment);

      // Create notification for doctor only
      await firestoreService.createNotification(
        userId: widget.doctor.id,
        title: 'New Appointment Request',
        message: '$userName has requested an appointment on ${DateFormat('MMM d, y').format(appointmentDateTime)} at $_selectedTimeSlot.',
        type: 'appointment',
      );

      // Note: Notification to patient will be sent when doctor accepts the appointment
      // Local notifications and reminders will also be scheduled at that time

      if (mounted) {
        setState(() => _isBooking = false);
        _showConfirmationDialog(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isBooking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to book appointment: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  DateTime _combineDateTime(DateTime date, String timeSlot) {
    // Parse time slot (e.g., "09:00 AM")
    final timeParts = timeSlot.split(' ');
    final hourMinute = timeParts[0].split(':');
    int hour = int.parse(hourMinute[0]);
    final minute = int.parse(hourMinute[1]);
    final isPM = timeParts[1] == 'PM';

    if (isPM && hour != 12) {
      hour += 12;
    } else if (!isPM && hour == 12) {
      hour = 0;
    }

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.graphite,
                  AppColors.deepCharcoal,
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              border: Border.all(
                color: AppColors.tealAccent.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.tealAccent.withValues(alpha: 0.2),
                        AppColors.tealAccent.withValues(alpha: 0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.schedule,
                    color: AppColors.tealAccent,
                    size: 60,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Appointment Requested!',
                  style: AppTextStyles.h2.copyWith(fontSize: 22),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Your request has been sent. Waiting for doctor confirmation.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: AppColors.tealAccent.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.person_outline,
                        widget.doctor.name,
                      ),
                      const Divider(height: AppSpacing.lg * 2),
                      _buildInfoRow(
                        Icons.calendar_today,
                        DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                      ),
                      const Divider(height: AppSpacing.lg * 2),
                      _buildInfoRow(
                        Icons.access_time,
                        _selectedTimeSlot!,
                      ),
                      const Divider(height: AppSpacing.lg * 2),
                      _buildInfoRow(
                        _appointmentType == 'In-Person'
                            ? Icons.person_outline
                            : Icons.videocam_outlined,
                        _appointmentType,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                CustomButton(
                  text: 'Done',
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  icon: Icons.done,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.tealAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.tealAccent,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
