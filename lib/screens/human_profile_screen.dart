import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_profile.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import 'edit_human_profile_screen.dart';
import 'appointments_list_screen.dart';
import 'medical_records_screen.dart';

class HumanProfileScreen extends StatelessWidget {
  const HumanProfileScreen({Key? key}) : super(key: key);

  UserProfile _getSampleProfile() {
    return UserProfile(
      id: '1',
      name: 'John Doe',
      email: 'john.doe@email.com',
      phone: '+1 234 567 8900',
      dateOfBirth: DateTime(1990, 5, 15),
      bloodGroup: 'O+',
      address: '123 Healthcare St, Medical City, MC 12345',
      medicalConditions: ['Hypertension', 'Diabetes Type 2'],
      allergies: ['Penicillin', 'Peanuts'],
      emergencyContact: 'Jane Doe',
      emergencyContactPhone: '+1 234 567 8901',
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _getSampleProfile();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EditHumanProfileScreen(profile: profile),
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
            // Profile Header Card
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
                      Icons.person,
                      size: 60,
                      color: AppColors.tealAccent,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Name
                  Text(
                    profile.name,
                    style: AppTextStyles.h1.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Email
                  Text(
                    profile.email,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Personal Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Information',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _InfoCard(
                    items: [
                      {'label': 'Phone', 'value': profile.phone},
                      {
                        'label': 'Date of Birth',
                        'value': DateFormat('MMM d, yyyy')
                            .format(profile.dateOfBirth)
                      },
                      {'label': 'Blood Group', 'value': profile.bloodGroup},
                      {'label': 'Address', 'value': profile.address},
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Medical Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Medical Information',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Medical Conditions
                  _MedicalInfoCard(
                    title: 'Medical Conditions',
                    icon: Icons.medical_services,
                    items: profile.medicalConditions,
                    color: AppColors.error,
                  ),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Allergies
                  _MedicalInfoCard(
                    title: 'Allergies',
                    icon: Icons.warning_amber_rounded,
                    items: profile.allergies,
                    color: AppColors.warning,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Emergency Contact
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emergency Contact',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _InfoCard(
                    items: [
                      {'label': 'Name', 'value': profile.emergencyContact},
                      {
                        'label': 'Phone',
                        'value': profile.emergencyContactPhone
                      },
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Health Overview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Health Overview',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: _HealthStatCard(
                          icon: Icons.favorite,
                          label: 'Heart Rate',
                          value: '72',
                          unit: 'bpm',
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _HealthStatCard(
                          icon: Icons.monitor_weight,
                          label: 'Weight',
                          value: '75',
                          unit: 'kg',
                          color: AppColors.tealAccent,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _HealthStatCard(
                          icon: Icons.thermostat,
                          label: 'Temp',
                          value: '36.6',
                          unit: '°C',
                          color: Color(0xFF60A5FA),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Medical Records
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Medical Records',
                        style: AppTextStyles.h3,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MedicalRecordsScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'View All',
                          style: TextStyle(color: AppColors.tealAccent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _MedicalRecordItem(
                    icon: Icons.description,
                    title: 'Annual Health Checkup',
                    date: 'Oct 15, 2024',
                    doctor: 'Dr. Sarah Johnson',
                    type: 'General Checkup',
                    color: AppColors.success,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _MedicalRecordItem(
                    icon: Icons.biotech,
                    title: 'Blood Test Results',
                    date: 'Sep 28, 2024',
                    doctor: 'Lab Report',
                    type: 'Laboratory',
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _MedicalRecordItem(
                    icon: Icons.medication,
                    title: 'Prescription - Metformin',
                    date: 'Sep 10, 2024',
                    doctor: 'Dr. Michael Chen',
                    type: 'Prescription',
                    color: Color(0xFFF59E0B),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Allergies & Conditions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Allergies',
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _InfoChip(
                          icon: Icons.warning_amber_rounded,
                          label: 'Penicillin',
                          color: AppColors.error,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _InfoChip(
                          icon: Icons.warning_amber_rounded,
                          label: 'Peanuts',
                          color: AppColors.error,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _InfoChip(
                          icon: Icons.warning_amber_rounded,
                          label: 'Latex',
                          color: AppColors.error,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chronic Conditions',
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _InfoChip(
                          icon: Icons.medical_information,
                          label: 'Type 2 Diabetes',
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _InfoChip(
                          icon: Icons.medical_information,
                          label: 'Hypertension',
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _InfoChip(
                          icon: Icons.medical_information,
                          label: 'Asthma',
                          color: Color(0xFFF59E0B),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Quick Actions - Redesigned
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
                  _ImprovedActionCard(
                    icon: Icons.calendar_month,
                    title: 'My Appointments',
                    subtitle: 'View & manage your bookings',
                          color: AppColors.tealAccent,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AppointmentsListScreen(),
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: AppSpacing.md),
                  _ImprovedActionCard(
                    icon: Icons.download,
                    title: 'Download Reports',
                    subtitle: 'Access your medical documents',
                          color: Color(0xFF60A5FA),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                          content: Text('Download feature coming soon!'),
                                backgroundColor: AppColors.tealAccent,
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: AppSpacing.md),
                  _ImprovedActionCard(
                    icon: Icons.local_hospital,
                    title: 'Find Nearby Clinics',
                    subtitle: 'Locate healthcare facilities',
                          color: Color(0xFFF59E0B),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                          content: Text('Clinic finder coming soon!'),
                                backgroundColor: AppColors.tealAccent,
                              ),
                            );
                          },
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

class _MedicalInfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;
  final Color color;

  const _MedicalInfoCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.items,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  title,
                  style: AppTextStyles.h4,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: items.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    item,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _HealthStatCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
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
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: AppTextStyles.h3.copyWith(
                    color: color,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  unit,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicalRecordItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String date;
  final String doctor;
  final String type;
  final Color color;

  const _MedicalRecordItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.date,
    required this.doctor,
    required this.type,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening $title'),
              backgroundColor: AppColors.tealAccent,
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
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
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.h4.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      doctor,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                    ),
                    child: Text(
                      type,
                      style: AppTextStyles.caption.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    date,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
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

class _ImprovedActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ImprovedActionCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.h4.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: AppSpacing.xs),
              Text(
                      subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textTertiary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

