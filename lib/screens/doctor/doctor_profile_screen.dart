import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_text_styles.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/doctor_profile.dart';
import '../../widgets/custom_button.dart';
import 'doctor_edit_profile_screen.dart';
import '../splash_screen.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({Key? key}) : super(key: key);

  Future<void> _handleSignOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text(
          'Sign Out',
          style: AppTextStyles.h3,
        ),
        content: Text(
          'Are you sure you want to sign out?',
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
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        final authService = context.read<AuthService>();
        await authService.signOut();
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const SplashScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error signing out: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
        ),
        body: const Center(child: Text('Please log in')),
      );
    }

    return StreamBuilder<DoctorProfile?>(
      stream: firestoreService.getDoctorProfileStream(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('My Profile')),
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.tealAccent),
            ),
          );
        }

        final profile = snapshot.data;

        if (profile == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('My Profile')),
            body: const Center(child: Text('Profile not found')),
          );
        }

        return _buildProfileContent(context, profile);
      },
    );
  }

  Widget _buildProfileContent(BuildContext context, DoctorProfile profile) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DoctorEditProfileScreen(profile: profile),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Container(
              width: double.infinity,
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
              child: Column(
                children: [
                  // Avatar
                  Container(
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
                      Icons.medical_services,
                      size: 60,
                      color: AppColors.tealAccent,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Name
                  Text(
                    'Dr. ${profile.name}',
                    style: AppTextStyles.h1.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Specialization
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.tealAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Text(
                      profile.specialization,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.tealAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatItem('${profile.experience}+', 'Years Exp.'),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.inputBorder,
                        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      ),
                      _buildStatItem('${profile.rating}', 'Rating'),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.inputBorder,
                        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      ),
                      _buildStatItem('${profile.totalPatients}', 'Patients'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Contact Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Contact Information', style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.lg),
                  _InfoCard(
                    items: [
                      {'label': 'Email', 'value': profile.email},
                      {'label': 'Phone', 'value': profile.phone.isNotEmpty ? profile.phone : 'Not provided'},
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Professional Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Professional Details', style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.lg),
                  _InfoCard(
                    items: [
                      {'label': 'License Number', 'value': profile.licenseNumber},
                      {'label': 'Experience', 'value': '${profile.experience} years'},
                      {'label': 'Specialization', 'value': profile.specialization},
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Clinic Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Clinic Information', style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.lg),
                  _InfoCard(
                    items: [
                      {'label': 'Clinic Name', 'value': profile.clinicName.isNotEmpty ? profile.clinicName : 'Not provided'},
                      {'label': 'Address', 'value': profile.clinicAddress.isNotEmpty ? profile.clinicAddress : 'Not provided'},
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // About Section
            if (profile.about != null && profile.about!.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('About', style: AppTextStyles.h3),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Text(
                        profile.about!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],

            // Availability
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Availability', style: AppTextStyles.h3),
                  const SizedBox(height: AppSpacing.lg),
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
                            color: profile.isAvailable
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Icon(
                            profile.isAvailable ? Icons.check_circle : Icons.cancel,
                            color: profile.isAvailable ? AppColors.success : AppColors.error,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.isAvailable ? 'Available for Appointments' : 'Not Available',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                profile.availableDays.join(', '),
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
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Sign Out Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: CustomButton(
                text: 'Sign Out',
                onPressed: () => _handleSignOut(context),
                isOutlined: true,
                icon: Icons.logout,
              ),
            ),

            const SizedBox(height: 120), // Extra padding to avoid navbar overlap
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h2.copyWith(
            color: AppColors.tealAccent,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Map<String, String>> items;

  const _InfoCard({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['label']!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        item['value']!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                if (index < items.length - 1) ...[
                  const SizedBox(height: AppSpacing.md),
                  const Divider(),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

