import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/appointment.dart';
import '../models/doctor_profile.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import 'telemedicine_chat_screen.dart';

class ChatInboxScreen extends StatelessWidget {
  final bool isHumanMode;

  const ChatInboxScreen({Key? key, this.isHumanMode = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();
    final authService = context.read<AuthService>();
    final userId = authService.currentUser?.uid;
    final doctorType = isHumanMode ? 'human' : 'pet';

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              AppSpacing.xxl + 8,
              AppSpacing.xxl,
              AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.tealAccent.withValues(alpha: 0.1),
                  AppColors.deepCharcoal,
                ],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.tealAccent,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Messages',
                        style: AppTextStyles.h2.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Chat with your doctors',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Doctors List - Only show doctors with booked appointments
          Expanded(
            child: userId == null
                ? const Center(child: Text('Please log in to access messages'))
                : StreamBuilder<List<Appointment>>(
                    stream: firestoreService.getUserAppointmentsStream(userId),
                    builder: (context, appointmentSnapshot) {
                      if (appointmentSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColors.tealAccent),
                        );
                      }

                      if (appointmentSnapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 80,
                                color: AppColors.error.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                'Error loading appointments',
                                style: AppTextStyles.h3.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final appointments = appointmentSnapshot.data ?? [];
                      
                      // Filter ONLY confirmed appointments with matching doctorType
                      final confirmedAppointments = appointments
                          .where((apt) => 
                              apt.status == AppointmentStatus.confirmed &&
                              apt.doctorType == doctorType)
                          .toList();
                      
                      // Get unique doctor IDs from CONFIRMED appointments only
                      final doctorIds = confirmedAppointments
                          .map((apt) => apt.doctorId)
                          .toSet()
                          .toList();

                      if (doctorIds.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 80,
                                color: AppColors.textTertiary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                'No Doctors to Chat With',
                                style: AppTextStyles.h3.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Book an appointment first to chat with doctors',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return StreamBuilder<List<DoctorProfile>>(
                        stream: firestoreService.getDoctorsStream(),
                        builder: (context, doctorSnapshot) {
                          if (doctorSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(color: AppColors.tealAccent),
                            );
                          }

                          if (doctorSnapshot.hasError) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 80,
                                    color: AppColors.error.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  Text(
                                    'Error loading doctors',
                                    style: AppTextStyles.h3.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final allDoctors = doctorSnapshot.data ?? [];
                          
                          // Filter doctors: only show those with appointments AND matching doctorType
                          final doctors = allDoctors
                              .where((doc) => doctorIds.contains(doc.id) && doc.doctorType == doctorType)
                              .toList();

                          if (doctors.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 80,
                                    color: AppColors.textTertiary.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  Text(
                                    'No Doctors Available',
                                    style: AppTextStyles.h3.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'Book an appointment to start chatting',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            itemCount: doctors.length,
                            itemBuilder: (context, index) {
                              final doctor = doctors[index];
                              return _DoctorChatCard(
                                doctor: doctor,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => TelemedicineChatScreen(
                                        doctorId: doctor.id,
                                        doctorName: doctor.name,
                                        doctorSpecialization: doctor.specialization,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DoctorChatCard extends StatelessWidget {
  final DoctorProfile doctor;
  final VoidCallback onTap;

  const _DoctorChatCard({
    Key? key,
    required this.doctor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.graphite,
                      border: Border.all(
                        color: AppColors.tealAccent,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.medical_services,
                      color: AppColors.tealAccent,
                      size: 24,
                    ),
                  ),
                  if (doctor.isAvailable)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.cardBackground,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppSpacing.md),
              // Doctor Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dr. ${doctor.name}',
                      style: AppTextStyles.h4,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      doctor.specialization,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          doctor.rating.toString(),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Text(
                          '${doctor.experience} years exp.',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

