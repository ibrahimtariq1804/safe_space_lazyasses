import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/appointment.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/custom_button.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final Appointment appointment;

  const AppointmentDetailScreen({Key? key, required this.appointment})
      : super(key: key);

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  bool _isProcessing = false;

  Color _getStatusColor() {
    switch (widget.appointment.status) {
      case AppointmentStatus.confirmed:
        return AppColors.success;
      case AppointmentStatus.pending:
        return AppColors.warning;
      case AppointmentStatus.completed:
        return AppColors.tealAccent;
      case AppointmentStatus.cancelled:
        return AppColors.textTertiary;
      case AppointmentStatus.rejected:
        return AppColors.error;
      case AppointmentStatus.delayed:
        return Colors.orange;
    }
  }

  String _getStatusText() {
    switch (widget.appointment.status) {
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.pending:
        return 'Pending Confirmation';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.rejected:
        return 'Rejected by Doctor';
      case AppointmentStatus.delayed:
        return 'Delayed';
    }
  }

  IconData _getStatusIcon() {
    switch (widget.appointment.status) {
      case AppointmentStatus.confirmed:
        return Icons.check_circle_outline;
      case AppointmentStatus.pending:
        return Icons.schedule;
      case AppointmentStatus.completed:
        return Icons.done_all;
      case AppointmentStatus.cancelled:
        return Icons.cancel_outlined;
      case AppointmentStatus.rejected:
        return Icons.block;
      case AppointmentStatus.delayed:
        return Icons.access_time;
    }
  }

  Future<void> _cancelAppointment() async {
    setState(() => _isProcessing = true);
    
    try {
      final firestoreService = context.read<FirestoreService>();
      final notificationService = context.read<NotificationService>();
      
      // Update appointment status in Firestore
      await firestoreService.updateAppointmentStatus(
        widget.appointment.id,
        AppointmentStatus.cancelled,
      );
      
      // Cancel scheduled notifications
      await notificationService.cancelAppointmentNotifications(widget.appointment.id);
      
      // Show cancellation notification
      await notificationService.showAppointmentCancelledNotification(
        doctorName: widget.appointment.doctorName,
        appointmentTime: widget.appointment.dateTime,
      );
      
      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
        Navigator.of(context).pop(); // Go back to previous screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment cancelled successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel appointment: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPast = widget.appointment.dateTime.isBefore(DateTime.now());
    final isCancelled = widget.appointment.status == AppointmentStatus.cancelled;
    final isRejected = widget.appointment.status == AppointmentStatus.rejected;
    final isCompleted = widget.appointment.status == AppointmentStatus.completed;

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
                    _getStatusIcon(),
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

            // Rejection Reason Banner
            if (widget.appointment.status == AppointmentStatus.rejected &&
                widget.appointment.rejectionReason != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.lg,
                ),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Rejection Reason',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      widget.appointment.rejectionReason!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
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
                                  widget.appointment.doctorName,
                                  style: AppTextStyles.h3,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  widget.appointment.doctorSpecialization,
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
                                .format(widget.appointment.dateTime),
                          ),
                          const Divider(),
                          _DetailRow(
                            icon: Icons.access_time,
                            label: 'Time',
                            value:
                                DateFormat('h:mm a').format(widget.appointment.dateTime),
                          ),
                          const Divider(),
                          _DetailRow(
                            icon: Icons.person_outline,
                            label: 'Patient',
                            value: widget.appointment.patientName,
                          ),
                          if (widget.appointment.symptoms.isNotEmpty) ...[
                            const Divider(),
                            _DetailRow(
                              icon: Icons.notes,
                              label: 'Reason',
                              value: widget.appointment.symptoms,
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
            if (!isPast && !isCancelled && !isRejected && !isCompleted)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Column(
                  children: [
                    CustomButton(
                      text: 'Reschedule Appointment',
                      onPressed: () {
                        if (_isProcessing) return;
                        // Navigate back and prompt to book again
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please book a new appointment to reschedule'),
                            backgroundColor: AppColors.tealAccent,
                          ),
                        );
                      },
                      isLoading: _isProcessing,
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
      barrierDismissible: !_isProcessing,
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
            onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
            child: Text(
              'No, Keep it',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _isProcessing ? null : _cancelAppointment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Yes, Cancel'),
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


