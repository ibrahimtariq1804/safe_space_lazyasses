import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;

  const DoctorCard({
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
              // Doctor Avatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  color: AppColors.graphite,
                  image: doctor.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(doctor.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: doctor.imageUrl.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 32,
                        color: AppColors.textTertiary,
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              
              // Doctor Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: AppTextStyles.h4,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      doctor.specialization,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.tealAccent,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            doctor.clinicLocation,
                            style: AppTextStyles.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Rating
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tealAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: AppColors.tealAccent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          doctor.rating.toString(),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.tealAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${doctor.experience} years',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

