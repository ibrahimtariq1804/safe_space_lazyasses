import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/doctor_card.dart';
import 'doctor_profile_screen.dart';

class SearchDoctorsScreen extends StatefulWidget {
  final bool isHumanMode;

  const SearchDoctorsScreen({Key? key, this.isHumanMode = true})
      : super(key: key);

  @override
  State<SearchDoctorsScreen> createState() => _SearchDoctorsScreenState();
}

class _SearchDoctorsScreenState extends State<SearchDoctorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSpecialization = 'All';

  final List<String> _specializations = [
    'All',
    'Cardiologist',
    'Dermatologist',
    'Pediatrician',
    'Neurologist',
    'Dentist',
  ];

  final List<String> _vetSpecializations = [
    'All',
    'General Veterinarian',
    'Exotic Animal Vet',
    'Emergency Vet',
    'Surgery Specialist',
  ];

  List<Doctor> _getDoctors() {
    if (widget.isHumanMode) {
      return [
        Doctor(
          id: '1',
          name: 'Dr. Sarah Johnson',
          specialization: 'Cardiologist',
          imageUrl: '',
          rating: 4.8,
          experience: 12,
          clinicLocation: 'City Medical Center, Downtown',
          about:
              'Experienced cardiologist specializing in heart disease prevention and treatment.',
          availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
        ),
        Doctor(
          id: '2',
          name: 'Dr. Michael Chen',
          specialization: 'Dermatologist',
          imageUrl: '',
          rating: 4.9,
          experience: 8,
          clinicLocation: 'Skin Care Clinic, Northside',
          about:
              'Board-certified dermatologist with expertise in skin conditions and cosmetic procedures.',
          availableDays: ['Mon', 'Wed', 'Fri', 'Sat'],
        ),
        Doctor(
          id: '3',
          name: 'Dr. Emily Rodriguez',
          specialization: 'Pediatrician',
          imageUrl: '',
          rating: 4.7,
          experience: 15,
          clinicLocation: 'Children\'s Hospital, Central',
          about:
              'Dedicated pediatrician providing comprehensive care for children of all ages.',
          availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
        ),
      ];
    } else {
      return [
        Doctor(
          id: '4',
          name: 'Dr. Robert Wilson',
          specialization: 'General Veterinarian',
          imageUrl: '',
          rating: 4.9,
          experience: 10,
          clinicLocation: 'Pet Care Clinic, Eastside',
          about:
              'Compassionate veterinarian with a passion for all animals.',
          availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
        ),
        Doctor(
          id: '5',
          name: 'Dr. Lisa Anderson',
          specialization: 'Exotic Animal Vet',
          imageUrl: '',
          rating: 4.8,
          experience: 7,
          clinicLocation: 'Exotic Pet Hospital, Westside',
          about:
              'Specialized care for reptiles, birds, and exotic mammals.',
          availableDays: ['Tue', 'Wed', 'Thu', 'Sat'],
        ),
      ];
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doctors = _getDoctors();
    final specializations =
        widget.isHumanMode ? _specializations : _vetSpecializations;

    return Scaffold(
      body: Column(
        children: [
          // Gradient Header
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
                        widget.isHumanMode ? 'Find Doctors' : 'Find Veterinarians',
                        style: AppTextStyles.h2.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Browse and book appointments',
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
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: TextField(
              controller: _searchController,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search by name or specialization...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textTertiary,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.filter_list,
                    color: AppColors.tealAccent,
                  ),
                  onPressed: () {
                    _showFilterBottomSheet(context, specializations);
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),

          // Specialization Chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: specializations.length,
              itemBuilder: (context, index) {
                final spec = specializations[index];
                final isSelected = _selectedSpecialization == spec;

                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(spec),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedSpecialization = spec;
                      });
                    },
                    backgroundColor: AppColors.cardBackground,
                    selectedColor: AppColors.tealAccent.withValues(alpha: 0.2),
                    labelStyle: AppTextStyles.bodySmall.copyWith(
                      color: isSelected
                          ? AppColors.tealAccent
                          : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.tealAccent
                          : AppColors.inputBorder,
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Doctors List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctors[index];

                // Apply filters
                if (_selectedSpecialization != 'All' &&
                    doctor.specialization != _selectedSpecialization) {
                  return const SizedBox.shrink();
                }

                if (_searchController.text.isNotEmpty &&
                    !doctor.name
                        .toLowerCase()
                        .contains(_searchController.text.toLowerCase()) &&
                    !doctor.specialization
                        .toLowerCase()
                        .contains(_searchController.text.toLowerCase())) {
                  return const SizedBox.shrink();
                }

                return DoctorCard(
                  doctor: doctor,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DoctorProfileScreen(doctor: doctor),
                      ),
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

  void _showFilterBottomSheet(
      BuildContext context, List<String> specializations) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.graphite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filter by Specialization',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: AppSpacing.lg),
              ...specializations.map((spec) {
                return RadioListTile<String>(
                  title: Text(spec, style: AppTextStyles.bodyMedium),
                  value: spec,
                  groupValue: _selectedSpecialization,
                  activeColor: AppColors.tealAccent,
                  onChanged: (value) {
                    setState(() {
                      _selectedSpecialization = value!;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}

