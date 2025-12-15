import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/appointment.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'search_doctors_screen.dart';
import 'chat_inbox_screen.dart';
import 'pet_appointments_list_screen.dart';
import 'pet_medical_records_screen.dart';
import 'pet_profile_screen.dart';
import 'splash_screen.dart';

class PetHomeScreen extends StatefulWidget {
  const PetHomeScreen({super.key});

  @override
  State<PetHomeScreen> createState() => _PetHomeScreenState();
}

class _PetHomeScreenState extends State<PetHomeScreen> {
  Future<bool> _onWillPop() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text(
          'Exit App',
          style: AppTextStyles.h3.copyWith(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to exit the application?',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
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
              backgroundColor: AppColors.tealAccent,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _handleSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text('Sign Out', style: AppTextStyles.h3.copyWith(color: Colors.white)),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: AppTextStyles.button.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authService = context.read<AuthService>();
      await authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SplashScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
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
                
                // For Your Pet Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'For Your Pet',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildPetHealthTips(),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xxxl),
                
                // Upcoming Pet Appointments
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
                              'Upcoming Vet Visits',
                              style: AppTextStyles.h3,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PetAppointmentsListScreen(),
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
                      const SizedBox(height: AppSpacing.md),
                      _buildUpcomingAppointments(),
                    ],
                  ),
                ),
                
                // Extra padding at bottom for navbar
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final authService = context.read<AuthService>();
    final user = authService.currentUser;
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.tealAccent.withValues(alpha: 0.15),
            AppColors.deepCharcoal,
          ],
        ),
      ),
      child: Row(
        children: [
          // Pet Avatar
          Container(
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
            child: const Icon(
              Icons.pets,
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
                  'Pet Healthcare',
                  style: AppTextStyles.h2.copyWith(fontSize: 22),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  user?.email ?? 'Care for your furry friend',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _handleSignOut,
            icon: const Icon(
              Icons.logout,
              color: AppColors.textSecondary,
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
        'label': 'Find Vet',
        'color': AppColors.tealAccent,
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const SearchDoctorsScreen(isHumanMode: false),
            ),
          );
        },
      },
      {
        'icon': Icons.folder_outlined,
        'label': 'Records',
        'color': const Color(0xFF8B5CF6),
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const PetMedicalRecordsScreen(),
            ),
          );
        },
      },
      {
        'icon': Icons.chat_bubble_outline,
        'label': 'Message',
        'color': const Color(0xFF10B981),
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ChatInboxScreen(isHumanMode: false),
            ),
          );
        },
      },
      {
        'icon': Icons.pets,
        'label': 'Pet Profile',
        'color': const Color(0xFFF59E0B),
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const PetProfileScreen(),
            ),
          );
        },
      },
    ];

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: actions.map((action) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - AppSpacing.xxl * 2 - AppSpacing.md * 3) / 4,
          child: _QuickActionButton(
            icon: action['icon'] as IconData,
            label: action['label'] as String,
            color: action['color'] as Color,
            onTap: action['onTap'] as VoidCallback,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPetHealthTips() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF10B981).withValues(alpha: 0.15),
            AppColors.cardBackground,
          ],
        ),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Pet Care Tip',
                style: AppTextStyles.h4.copyWith(
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Regular vet check-ups help catch health issues early. Schedule annual wellness exams for your pet!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final user = authService.currentUser;

    if (user == null) {
      return _buildNoAppointmentsCard();
    }

    return StreamBuilder<List<Appointment>>(
      stream: firestoreService.getUserAppointmentsStream(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.tealAccent),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildNoAppointmentsCard();
        }

        // Filter ONLY pet appointments (doctorType == 'pet')
        final petAppointments = snapshot.data!
            .where((apt) => 
                apt.doctorType == 'pet' &&
                apt.status == AppointmentStatus.confirmed &&
                apt.dateTime.isAfter(DateTime.now()))
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

        if (petAppointments.isEmpty) {
          return _buildNoAppointmentsCard();
        }

        // Show only the next upcoming appointment
        final nextAppointment = petAppointments.first;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            color: AppColors.cardBackground,
            border: Border.all(
              color: AppColors.tealAccent.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.tealAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: const Icon(
                  Icons.pets,
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
                      nextAppointment.doctorName,
                      style: AppTextStyles.h4,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      nextAppointment.doctorSpecialization,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppColors.tealAccent,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          DateFormat('MMM d, y').format(nextAppointment.dateTime),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.tealAccent,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.tealAccent,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          DateFormat('h:mm a').format(nextAppointment.dateTime),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.tealAccent,
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
      },
    );
  }

  Widget _buildNoAppointmentsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        color: AppColors.cardBackground,
        border: Border.all(
          color: AppColors.inputBorder.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 48,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No upcoming vet visits',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Book an appointment with a veterinarian',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

