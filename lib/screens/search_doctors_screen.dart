import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/doctor.dart';
import '../models/doctor_profile.dart';
import '../services/firestore_service.dart';
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
    'General Physician',
    'Cardiologist',
    'Dermatologist',
    'Pediatrician',
    'Neurologist',
    'Orthopedic',
    'Psychiatrist',
  ];

  final List<String> _vetSpecializations = [
    'All',
    'General Veterinarian',
    'Exotic Animal Vet',
    'Emergency Vet',
    'Surgery Specialist',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DoctorProfile> _filterDoctors(List<DoctorProfile> doctors) {
    return doctors.where((doctor) {
      // Filter by specialization
      if (_selectedSpecialization != 'All' &&
          doctor.specialization != _selectedSpecialization) {
        return false;
      }

      // Filter by search text
      if (_searchController.text.isNotEmpty) {
        final searchLower = _searchController.text.toLowerCase();
        return doctor.name.toLowerCase().contains(searchLower) ||
            doctor.specialization.toLowerCase().contains(searchLower) ||
            doctor.clinicName.toLowerCase().contains(searchLower);
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = context.read<FirestoreService>();
    final specializations = widget.isHumanMode ? _specializations : _vetSpecializations;
    final doctorType = widget.isHumanMode ? 'human' : 'pet';

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

          // Doctors List from Firestore
          Expanded(
            child: StreamBuilder<List<DoctorProfile>>(
              stream: firestoreService.getDoctorsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.tealAccent),
                  );
                }

                if (snapshot.hasError) {
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

                var allDoctors = snapshot.data ?? [];
                
                // Filter by doctor type (human/pet)
                allDoctors = allDoctors.where((doc) => doc.doctorType == doctorType).toList();
                
                // Apply search and specialization filters
                final filteredDoctors = _filterDoctors(allDoctors);

                if (filteredDoctors.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.isHumanMode ? Icons.person_search : Icons.pets,
                          size: 80,
                          color: AppColors.textTertiary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'No doctors found',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Try adjusting your filters',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: filteredDoctors.length,
                  itemBuilder: (context, index) {
                    final doctorProfile = filteredDoctors[index];
                    
                    // Convert DoctorProfile to Doctor model for compatibility
                    final doctor = Doctor(
                      id: doctorProfile.id,
                      name: doctorProfile.name,
                      specialization: doctorProfile.specialization,
                      imageUrl: doctorProfile.photoUrl ?? '',
                      rating: doctorProfile.rating,
                      experience: doctorProfile.experience,
                      clinicLocation: '${doctorProfile.clinicName}, ${doctorProfile.clinicAddress}',
                      about: doctorProfile.about ?? 'Experienced ${doctorProfile.specialization}',
                      availableDays: doctorProfile.availableDays,
                      isAvailable: doctorProfile.isAvailable,
                    );

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

