import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import 'search_doctors_screen.dart';
import 'pet_profile_screen.dart';
import 'human_profile_screen.dart';
import 'telemedicine_chat_screen.dart';
import 'notifications_screen.dart';
import 'appointments_list_screen.dart';
import 'medical_records_screen.dart';
import 'pet_medical_records_screen.dart';

class HomeScreen extends StatelessWidget {
  final bool isHumanMode;

  const HomeScreen({super.key, this.isHumanMode = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Profile
              _buildHeader(context),
              
              const SizedBox(height: AppSpacing.xxl),
              
              // Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildQuickActions(context),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xxxl),
              
              // For You Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'For You',
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildHealthTips(),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xxxl),
              
              // Upcoming Appointments
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Upcoming Appointments',
                            style: AppTextStyles.h3,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AppointmentsListScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'View All',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.tealAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildAppointmentCard(context),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
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
          // Avatar - Clickable to go to profile
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => isHumanMode
                      ? const HumanProfileScreen()
                      : const PetProfileScreen(),
                ),
              );
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.graphite,
                border: Border.all(
                  color: AppColors.tealAccent,
                  width: 2,
                ),
              ),
              child: Icon(
                isHumanMode ? Icons.person : Icons.pets,
                size: 30,
                color: AppColors.tealAccent,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          
          // User Info - Also clickable
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => isHumanMode
                        ? const HumanProfileScreen()
                        : const PetProfileScreen(),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, John 👋',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    isHumanMode ? 'Human Healthcare' : 'Pet Healthcare',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.tealAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Notification Icon - Clickable
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Stack(
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textPrimary,
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'icon': Icons.search,
        'title': 'Find\nDoctors',
        'color': AppColors.tealAccent,
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SearchDoctorsScreen(isHumanMode: isHumanMode),
            ),
          );
        },
      },
      {
        'icon': Icons.medical_services_outlined,
        'title': 'Medical\nRecords',
        'color': AppColors.tealAccentLight,
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => isHumanMode 
                  ? const MedicalRecordsScreen()
                  : const PetMedicalRecordsScreen(),
            ),
          );
        },
      },
      {
        'icon': Icons.video_call,
        'title': 'Telemedicine\nChat',
        'color': Color(0xFF60A5FA),
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const TelemedicineChatScreen(),
            ),
          );
        },
      },
      {
        'icon': isHumanMode ? Icons.person : Icons.pets,
        'title': isHumanMode ? 'My\nProfile' : 'Pet\nProfile',
        'color': Color(0xFFF59E0B),
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => isHumanMode
                  ? const HumanProfileScreen()
                  : const PetProfileScreen(),
            ),
          );
        },
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((action) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: _QuickActionCard(
              icon: action['icon'] as IconData,
              title: action['title'] as String,
              color: action['color'] as Color,
              onTap: action['onTap'] as VoidCallback,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHealthTips() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.tealAccent.withValues(alpha: 0.15),
            AppColors.tealAccent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.tealAccent.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.tealAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: AppColors.tealAccent,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health Tip of the Day',
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.tealAccent,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isHumanMode
                      ? 'Stay hydrated! Drink at least 8 glasses of water daily.'
                      : 'Regular grooming keeps your pet healthy and happy.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AppointmentsListScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.graphite,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.tealAccent,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dr. Sarah Johnson',
                          style: AppTextStyles.h4,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Cardiologist',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Tomorrow, 10:00 AM',
                    style: AppTextStyles.bodySmall,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                    ),
                    child: Text(
                      'Confirmed',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Flexible(
                child: Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

