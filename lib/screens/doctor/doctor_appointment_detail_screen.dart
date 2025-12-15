import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/appointment.dart';

class DoctorAppointmentDetailScreen extends StatefulWidget {
  final Appointment appointment;

  const DoctorAppointmentDetailScreen({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  State<DoctorAppointmentDetailScreen> createState() => _DoctorAppointmentDetailScreenState();
}

class _DoctorAppointmentDetailScreenState extends State<DoctorAppointmentDetailScreen> {
  bool _isLoading = false;
  final _rejectionReasonController = TextEditingController();

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  Future<void> _acceptAppointment() async {
    setState(() => _isLoading = true);
    
    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      final doctorId = authService.currentUser?.uid;

      if (doctorId == null) throw 'Not authenticated';

      // Get doctor name
      final doctorProfile = await firestoreService.getDoctorProfile(doctorId);
      final doctorName = doctorProfile?.name ?? 'Doctor';

      await firestoreService.acceptAppointment(
        widget.appointment.id,
        widget.appointment.userId,
        doctorName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment accepted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _rejectAppointment() async {
    // Show rejection reason dialog
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text(
          'Reject Appointment',
          style: AppTextStyles.h3,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Please provide a reason for rejecting this appointment:',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            CustomTextField(
              label: 'Reason',
              hint: 'Enter rejection reason',
              controller: _rejectionReasonController,
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.button.copyWith(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_rejectionReasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a reason'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              Navigator.of(context).pop(_rejectionReasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (reason == null) return;

    setState(() => _isLoading = true);
    
    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      final doctorId = authService.currentUser?.uid;

      if (doctorId == null) throw 'Not authenticated';

      // Get doctor name
      final doctorProfile = await firestoreService.getDoctorProfile(doctorId);
      final doctorName = doctorProfile?.name ?? 'Doctor';

      await firestoreService.rejectAppointment(
        widget.appointment.id,
        widget.appointment.userId,
        doctorName,
        reason,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment rejected'),
            backgroundColor: AppColors.warning,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _completeAppointment() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text(
          'Complete Appointment',
          style: AppTextStyles.h3,
        ),
        content: Text(
          'Mark this appointment as completed?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: AppTextStyles.button.copyWith(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    
    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      final doctorId = authService.currentUser?.uid;

      if (doctorId == null) throw 'Not authenticated';

      // Get doctor name
      final doctorProfile = await firestoreService.getDoctorProfile(doctorId);
      final doctorName = doctorProfile?.name ?? 'Doctor';

      await firestoreService.completeAppointment(
        widget.appointment.id,
        widget.appointment.userId,
        doctorName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment marked as completed'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;
    
    Color statusColor;
    String statusText;

    switch (appointment.status) {
      case AppointmentStatus.pending:
        statusColor = AppColors.warning;
        statusText = 'Pending Approval';
        break;
      case AppointmentStatus.confirmed:
        statusColor = AppColors.tealAccent;
        statusText = 'Confirmed';
        break;
      case AppointmentStatus.completed:
        statusColor = AppColors.success;
        statusText = 'Completed';
        break;
      case AppointmentStatus.cancelled:
        statusColor = AppColors.textTertiary;
        statusText = 'Cancelled';
        break;
      case AppointmentStatus.rejected:
        statusColor = AppColors.error;
        statusText = 'Rejected';
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusText = 'Unknown';
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              statusColor.withValues(alpha: 0.05),
              AppColors.deepCharcoal,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
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
                            'Appointment Details',
                            style: AppTextStyles.h3,
                          ),
                          Text(
                            'ID: ${appointment.id.substring(0, 8)}...',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        statusText,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Patient Card
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              statusColor.withValues(alpha: 0.15),
                              AppColors.cardBackground,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              ),
                              child: Icon(
                                Icons.person,
                                color: statusColor,
                                size: 35,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appointment.patientName,
                                    style: AppTextStyles.h3.copyWith(fontSize: 18),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  if (appointment.patientPhone != null &&
                                      appointment.patientPhone!.isNotEmpty)
                                    Text(
                                      appointment.patientPhone!,
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

                      const SizedBox(height: AppSpacing.xxl),

                      // Date & Time Section
                      Text(
                        'Date & Time',
                        style: AppTextStyles.h3.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              Icons.calendar_today,
                              'Date',
                              DateFormat('EEEE, MMMM d, yyyy').format(appointment.dateTime),
                            ),
                            const Divider(height: AppSpacing.lg * 2),
                            _buildInfoRow(
                              Icons.access_time,
                              'Time',
                              DateFormat('h:mm a').format(appointment.dateTime),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // Appointment Info
                      Text(
                        'Appointment Info',
                        style: AppTextStyles.h3.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              Icons.medical_services,
                              'Type',
                              appointment.notes?.replaceFirst('Type: ', '') ?? 'General Consultation',
                            ),
                            if (appointment.symptoms.isNotEmpty) ...[
                              const Divider(height: AppSpacing.lg * 2),
                              _buildInfoRow(
                                Icons.note,
                                'Symptoms',
                                appointment.symptoms,
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Rejection Reason (if rejected)
                      if (appointment.status == AppointmentStatus.rejected &&
                          appointment.rejectionReason != null) ...[
                        const SizedBox(height: AppSpacing.xxl),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.error,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rejection Reason',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      appointment.rejectionReason!,
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
                      ],

                      const SizedBox(height: AppSpacing.xxxl),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              if (appointment.status == AppointmentStatus.pending)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.inputBorder.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Reject',
                          onPressed: _rejectAppointment,
                          isLoading: _isLoading,
                          isOutlined: true,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: CustomButton(
                          text: 'Accept',
                          onPressed: _acceptAppointment,
                          isLoading: _isLoading,
                          icon: Icons.check,
                        ),
                      ),
                    ],
                  ),
                ),

              // Complete Button for confirmed appointments
              if (appointment.status == AppointmentStatus.confirmed)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.inputBorder.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  child: CustomButton(
                    text: 'Mark as Completed',
                    onPressed: _completeAppointment,
                    isLoading: _isLoading,
                    icon: Icons.check_circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

