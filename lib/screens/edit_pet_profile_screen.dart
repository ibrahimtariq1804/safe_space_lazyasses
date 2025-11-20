import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pet.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';

class EditPetProfileScreen extends StatefulWidget {
  final Pet pet;

  const EditPetProfileScreen({Key? key, required this.pet}) : super(key: key);

  @override
  State<EditPetProfileScreen> createState() => _EditPetProfileScreenState();
}

class _EditPetProfileScreenState extends State<EditPetProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _speciesController;
  late TextEditingController _breedController;
  late TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet.name);
    _speciesController = TextEditingController(text: widget.pet.species);
    _breedController = TextEditingController(text: widget.pet.breed);
    _ageController = TextEditingController(text: widget.pet.age.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                        'Edit Pet Profile',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Update your pet\'s information',
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
          // Body Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              // Pet Picture
              Center(
                child: Stack(
                  children: [
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
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.tealAccent,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            color: AppColors.deepCharcoal,
                            size: 20,
                          ),
                          onPressed: () {
                            // TODO: Implement image picker
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Pet Information
              Text(
                'Pet Information',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: AppSpacing.lg),

              CustomTextField(
                label: 'Pet Name',
                controller: _nameController,
                prefixIcon: Icons.pets,
              ),
              const SizedBox(height: AppSpacing.lg),

              CustomTextField(
                label: 'Species',
                controller: _speciesController,
                prefixIcon: Icons.category_outlined,
              ),
              const SizedBox(height: AppSpacing.lg),

              CustomTextField(
                label: 'Breed',
                controller: _breedController,
                prefixIcon: Icons.info_outline,
              ),
              const SizedBox(height: AppSpacing.lg),

              CustomTextField(
                label: 'Age (years)',
                controller: _ageController,
                prefixIcon: Icons.cake_outlined,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Medical Information
              Text(
                'Medical Information',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: AppSpacing.lg),

              CustomTextField(
                label: 'Allergies (comma separated)',
                controller: TextEditingController(text: 'Chicken, Grass pollen, Dust mites'),
                prefixIcon: Icons.warning_amber_rounded,
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.lg),

              CustomTextField(
                label: 'Health Conditions (comma separated)',
                controller: TextEditingController(text: 'Arthritis, Skin allergies, Hip dysplasia'),
                prefixIcon: Icons.medical_information,
                maxLines: 2,
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Vaccination Management
              Text(
                'Vaccinations',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: AppSpacing.lg),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      ...widget.pet.vaccinations.map((vaccination) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            vaccination.completed
                                ? Icons.check_circle
                                : Icons.schedule,
                            color: vaccination.completed
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                          title: Text(
                            vaccination.name,
                            style: AppTextStyles.bodyMedium,
                          ),
                          subtitle: Text(
                            DateFormat('MMM d, yyyy').format(vaccination.date),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: AppColors.tealAccent,
                            ),
                            onPressed: () {
                              // TODO: Edit vaccination
                            },
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: AppSpacing.md),
                      TextButton.icon(
                        onPressed: () {
                          // TODO: Add new vaccination
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Vaccination'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.tealAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Save Button
              CustomButton(
                text: 'Save Changes',
                onPressed: () {
                  // TODO: Implement save functionality
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pet profile updated successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
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

