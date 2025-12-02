import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pet.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import 'edit_pet_profile_screen.dart';
import 'appointments_list_screen.dart';
import 'pet_medical_records_screen.dart';

class PetProfileScreen extends StatelessWidget {
  const PetProfileScreen({Key? key}) : super(key: key);

  Pet _getSamplePet() {
    return Pet(
      id: '1',
      name: 'Max',
      species: 'Dog',
      breed: 'Golden Retriever',
      age: 3,
      imageUrl: '',
      vaccinations: [
        VaccinationRecord(
          name: 'Rabies Vaccine',
          date: DateTime.now().subtract(const Duration(days: 365)),
          completed: true,
        ),
        VaccinationRecord(
          name: 'Distemper Vaccine',
          date: DateTime.now().subtract(const Duration(days: 180)),
          completed: true,
        ),
        VaccinationRecord(
          name: 'Parvovirus Vaccine',
          date: DateTime.now().subtract(const Duration(days: 90)),
          completed: true,
        ),
        VaccinationRecord(
          name: 'Bordetella Vaccine',
          date: DateTime.now().add(const Duration(days: 30)),
          completed: false,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pet = _getSamplePet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EditPetProfileScreen(pet: pet),
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
            // Pet Header Card
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
                  // Pet Avatar
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
                      Icons.pets,
                      size: 60,
                      color: AppColors.tealAccent,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Pet Name
                  Text(
                    pet.name,
                    style: AppTextStyles.h1.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Pet Details
                  Text(
                    '${pet.breed} • ${pet.age} years old',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Basic Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basic Information',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _InfoCard(
                    items: [
                      {'label': 'Species', 'value': pet.species},
                      {'label': 'Breed', 'value': pet.breed},
                      {'label': 'Age', 'value': '${pet.age} years'},
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Vaccination Timeline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Vaccination Records',
                        style: AppTextStyles.h3,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusXs),
                        ),
                        child: Text(
                          '${pet.vaccinations.where((v) => v.completed).length}/${pet.vaccinations.length} Complete',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Vaccination Timeline
                  ...pet.vaccinations.map((vaccination) {
                    return _VaccinationTimelineItem(
                      vaccination: vaccination,
                      isLast: vaccination == pet.vaccinations.last,
                    );
                  }).toList(),
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
                              builder: (_) => const PetMedicalRecordsScreen(),
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
                  _PetMedicalRecordItem(
                    icon: Icons.local_hospital,
                    title: 'Annual Wellness Check',
                    date: 'Nov 2, 2024',
                    doctor: 'Dr. Emily Parker',
                    type: 'Checkup',
                    color: AppColors.success,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _PetMedicalRecordItem(
                    icon: Icons.vaccines,
                    title: 'Rabies Vaccination',
                    date: 'Oct 10, 2024',
                    doctor: 'Dr. Emily Parker',
                    type: 'Vaccination',
                    color: Color(0xFF60A5FA),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _PetMedicalRecordItem(
                    icon: Icons.pets,
                    title: 'Dental Cleaning',
                    date: 'Sep 5, 2024',
                    doctor: 'Dr. James Wilson',
                    type: 'Procedure',
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
                        _PetInfoChip(
                          icon: Icons.warning_amber_rounded,
                          label: 'Chicken',
                          color: AppColors.error,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _PetInfoChip(
                          icon: Icons.warning_amber_rounded,
                          label: 'Grass pollen',
                          color: AppColors.error,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _PetInfoChip(
                          icon: Icons.warning_amber_rounded,
                          label: 'Dust mites',
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
                          'Health Conditions',
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _PetInfoChip(
                          icon: Icons.medical_information,
                          label: 'Arthritis',
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _PetInfoChip(
                          icon: Icons.medical_information,
                          label: 'Skin allergies',
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _PetInfoChip(
                          icon: Icons.medical_information,
                          label: 'Hip dysplasia',
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
                  _ImprovedPetActionCard(
                    icon: Icons.calendar_month,
                    title: 'Book Vet Appointment',
                    subtitle: 'Schedule a visit with a veterinarian',
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
                  _ImprovedPetActionCard(
                    icon: Icons.shopping_bag,
                    title: 'Pet Supplies Store',
                    subtitle: 'Shop for food, toys, and accessories',
                          color: Color(0xFF60A5FA),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                          content: Text('Pet store coming soon!'),
                                backgroundColor: AppColors.tealAccent,
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: AppSpacing.md),
                  _ImprovedPetActionCard(
                          icon: Icons.notifications_active,
                    title: 'Vaccination Reminders',
                    subtitle: 'Set alerts for upcoming shots',
                          color: Color(0xFFF59E0B),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Reminder feature coming soon!'),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['label']!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      item['value']!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
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

class _VaccinationTimelineItem extends StatelessWidget {
  final VaccinationRecord vaccination;
  final bool isLast;

  const _VaccinationTimelineItem({
    Key? key,
    required this.vaccination,
    required this.isLast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPast = vaccination.date.isBefore(DateTime.now());
    final isUpcoming = !isPast;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: vaccination.completed
                      ? AppColors.success
                      : isUpcoming
                          ? AppColors.warning
                          : AppColors.textTertiary,
                ),
                child: Icon(
                  vaccination.completed
                      ? Icons.check
                      : isUpcoming
                          ? Icons.schedule
                          : Icons.close,
                  color: AppColors.deepCharcoal,
                  size: 14,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.divider,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),

          const SizedBox(width: AppSpacing.lg),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: vaccination.completed
                        ? AppColors.success.withValues(alpha: 0.3)
                        : isUpcoming
                            ? AppColors.warning.withValues(alpha: 0.3)
                            : AppColors.divider,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            vaccination.name,
                            style: AppTextStyles.h4.copyWith(fontSize: 16),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: (vaccination.completed
                                    ? AppColors.success
                                    : isUpcoming
                                        ? AppColors.warning
                                        : AppColors.textTertiary)
                                .withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusXs),
                          ),
                          child: Text(
                            vaccination.completed
                                ? 'Done'
                                : isUpcoming
                                    ? 'Upcoming'
                                    : 'Overdue',
                            style: AppTextStyles.caption.copyWith(
                              color: vaccination.completed
                                  ? AppColors.success
                                  : isUpcoming
                                      ? AppColors.warning
                                      : AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          DateFormat('MMM d, yyyy').format(vaccination.date),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _PetMedicalRecordItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String date;
  final String doctor;
  final String type;
  final Color color;

  const _PetMedicalRecordItem({
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

class _ImprovedPetActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ImprovedPetActionCard({
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

class _PetInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PetInfoChip({
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
