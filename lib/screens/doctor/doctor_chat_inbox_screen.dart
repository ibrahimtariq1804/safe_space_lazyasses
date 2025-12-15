import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_text_styles.dart';
import 'doctor_chat_screen.dart';

class DoctorChatInboxScreen extends StatelessWidget {
  const DoctorChatInboxScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();
    final authService = context.read<AuthService>();
    final doctorId = authService.currentUser?.uid;

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
                        'Chat with your patients',
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

          // Patients List - Only show patients with confirmed appointments
          Expanded(
            child: doctorId == null
                ? const Center(child: Text('Please log in to access messages'))
                : FutureBuilder<List<String>>(
                    future: firestoreService.getPatientIdsWithConfirmedAppointments(doctorId),
                    builder: (context, patientIdsSnapshot) {
                      if (patientIdsSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColors.tealAccent),
                        );
                      }

                      if (patientIdsSnapshot.hasError) {
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
                                'Error loading patients',
                                style: AppTextStyles.h3.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final patientIds = patientIdsSnapshot.data ?? [];

                      if (patientIds.isEmpty) {
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
                                'No Patients to Chat With',
                                style: AppTextStyles.h3.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Patients will appear here after appointments are confirmed',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return FutureBuilder<List<UserProfile>>(
                        future: firestoreService.getUserProfilesByIds(patientIds),
                        builder: (context, profileSnapshot) {
                          if (profileSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(color: AppColors.tealAccent),
                            );
                          }

                          if (profileSnapshot.hasError) {
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
                                    'Error loading patient profiles',
                                    style: AppTextStyles.h3.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          final patients = profileSnapshot.data ?? [];

                          if (patients.isEmpty) {
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
                                    'No Patient Profiles Available',
                                    style: AppTextStyles.h3.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            itemCount: patients.length,
                            itemBuilder: (context, index) {
                              final patient = patients[index];
                              return _PatientChatCard(
                                patient: patient,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => DoctorChatScreen(
                                        patientId: patient.id,
                                        patientName: patient.name,
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

class _PatientChatCard extends StatelessWidget {
  final UserProfile patient;
  final VoidCallback onTap;

  const _PatientChatCard({
    Key? key,
    required this.patient,
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
                  Icons.person,
                  color: AppColors.tealAccent,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Patient Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: AppTextStyles.h4,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    if (patient.phone != null)
                      Text(
                        patient.phone!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    if (patient.email.isNotEmpty)
                      Text(
                        patient.email,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        overflow: TextOverflow.ellipsis,
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

