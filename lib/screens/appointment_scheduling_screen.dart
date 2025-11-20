import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/doctor.dart';
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
                  onTap: () => setState(() => _selectedDate = date),
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
        Text(
          'Available Time Slots',
          style: AppTextStyles.h3.copyWith(fontSize: 18),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: _timeSlots.map((time) {
            final isSelected = _selectedTimeSlot == time;
            final isPast = _isPastTime(time);

            return InkWell(
              onTap: isPast ? null : () => setState(() => _selectedTimeSlot = time),
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
                      : isPast
                          ? AppColors.cardBackground.withValues(alpha: 0.5)
                          : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
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
                      Icons.access_time,
                      size: 18,
                      color: isSelected
                          ? AppColors.deepCharcoal
                          : isPast
                              ? AppColors.textTertiary.withValues(alpha: 0.5)
                              : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      time,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isSelected
                            ? AppColors.deepCharcoal
                            : isPast
                                ? AppColors.textTertiary.withValues(alpha: 0.5)
                                : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        decoration: isPast ? TextDecoration.lineThrough : null,
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
          ? () => _showConfirmationDialog(context)
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
      icon: Icons.check_circle_outline,
    );
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
                        AppColors.success.withValues(alpha: 0.2),
                        AppColors.success.withValues(alpha: 0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 60,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Appointment Confirmed!',
                  style: AppTextStyles.h2.copyWith(fontSize: 22),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Your appointment has been successfully scheduled',
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
