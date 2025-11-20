import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/custom_button.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDetailScreen({Key? key, required this.appointment})
      : super(key: key);

  Color _getStatusColor() {
    switch (appointment.status) {
      case AppointmentStatus.confirmed:
        return AppColors.success;
      case AppointmentStatus.pending:
        return AppColors.warning;
      case AppointmentStatus.completed:
        return AppColors.tealAccent;
      case AppointmentStatus.cancelled:
        return AppColors.error;
    }
  }

  String _getStatusText() {
    switch (appointment.status) {
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPast = appointment.dateTime.isBefore(DateTime.now());
    final isCancelled = appointment.status == AppointmentStatus.cancelled;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: _getStatusColor().withValues(alpha: 0.1),
                border: Border(
                  bottom: BorderSide(
                    color: _getStatusColor().withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: _getStatusColor(),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    _getStatusText(),
                    style: AppTextStyles.h4.copyWith(
                      color: _getStatusColor(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Doctor Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Doctor Information',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.graphite,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: AppColors.tealAccent,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appointment.doctorName,
                                  style: AppTextStyles.h3,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  appointment.doctorSpecialization,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Appointment Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appointment Details',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.calendar_today,
                            label: 'Date',
                            value: DateFormat('MMMM d, yyyy')
                                .format(appointment.dateTime),
                          ),
                          const Divider(),
                          _DetailRow(
                            icon: Icons.access_time,
                            label: 'Time',
                            value:
                                DateFormat('h:mm a').format(appointment.dateTime),
                          ),
                          const Divider(),
                          _DetailRow(
                            icon: Icons.person_outline,
                            label: 'Patient',
                            value: appointment.patientName,
                          ),
                          if (appointment.symptoms.isNotEmpty) ...[
                            const Divider(),
                            _DetailRow(
                              icon: Icons.notes,
                              label: 'Reason',
                              value: appointment.symptoms,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Action Buttons
            if (!isPast && !isCancelled)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Column(
                  children: [
                    CustomButton(
                      text: 'Reschedule Appointment',
                      onPressed: () {
                        // TODO: Implement reschedule
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Rescheduling feature coming soon!'),
                            backgroundColor: AppColors.tealAccent,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton(
                      onPressed: () {
                        _showCancelDialog(context);
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 54),
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                      ),
                      child: Text(
                        'Cancel Appointment',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text(
          'Cancel Appointment',
          style: AppTextStyles.h3,
        ),
        content: Text(
          'Are you sure you want to cancel this appointment?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'No, Keep it',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appointment cancelled'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.tealAccent,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

