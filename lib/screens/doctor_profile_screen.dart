import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/custom_button.dart';
import 'appointment_scheduling_screen.dart';

class DoctorProfileScreen extends StatelessWidget {
  final Doctor doctor;

  const DoctorProfileScreen({Key? key, required this.doctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Doctor Image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.tealAccent.withOpacity(0.3),
                      AppColors.deepCharcoal,
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.graphite,
                      border: Border.all(
                        color: AppColors.tealAccent,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.tealAccent,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor Name and Specialization
                  Center(
                    child: Column(
                      children: [
                        Text(
                          doctor.name,
                          style: AppTextStyles.h2,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          doctor.specialization,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.tealAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        icon: Icons.star,
                        value: doctor.rating.toString(),
                        label: 'Rating',
                      ),
                      _buildStatCard(
                        icon: Icons.work_outline,
                        value: '${doctor.experience}+',
                        label: 'Years Exp.',
                      ),
                      _buildStatCard(
                        icon: Icons.people_outline,
                        value: '1.2K',
                        label: 'Patients',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  // About Section
                  Text(
                    'About',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    doctor.about,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Location
                  Text(
                    'Clinic Location',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.tealAccent.withOpacity(0.1),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusXs),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: AppColors.tealAccent,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            doctor.clinicLocation,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.directions,
                            color: AppColors.tealAccent,
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Available Days
                  Text(
                    'Available Days',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: doctor.availableDays.map((day) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.tealAccent.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusXs),
                          border: Border.all(
                            color: AppColors.tealAccent.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          day,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.tealAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),

                  // Book Appointment Button
                  CustomButton(
                    text: 'Book Appointment',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              AppointmentSchedulingScreen(doctor: doctor),
                        ),
                      );
                    },
                    icon: Icons.calendar_today,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(
            icon,
            color: AppColors.tealAccent,
            size: 28,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: AppTextStyles.h3,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }
}

