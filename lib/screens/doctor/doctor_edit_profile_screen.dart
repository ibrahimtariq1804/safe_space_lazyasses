import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/doctor_profile.dart';
import '../splash_screen.dart';

class DoctorEditProfileScreen extends StatefulWidget {
  final DoctorProfile profile;

  const DoctorEditProfileScreen({Key? key, required this.profile}) : super(key: key);

  @override
  State<DoctorEditProfileScreen> createState() => _DoctorEditProfileScreenState();
}

class _DoctorEditProfileScreenState extends State<DoctorEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _experienceController;
  late TextEditingController _clinicNameController;
  late TextEditingController _clinicAddressController;
  late TextEditingController _aboutController;
  
  late String _selectedSpecialization;
  late bool _isAvailable;
  bool _isLoading = false;

  final List<String> _specializations = [
    'General Physician',
    'Cardiologist',
    'Dermatologist',
    'Endocrinologist',
    'Gastroenterologist',
    'Neurologist',
    'Oncologist',
    'Ophthalmologist',
    'Orthopedic',
    'Pediatrician',
    'Psychiatrist',
    'Pulmonologist',
    'Radiologist',
    'Rheumatologist',
    'Urologist',
    'Veterinarian',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _experienceController = TextEditingController(text: widget.profile.experience.toString());
    _clinicNameController = TextEditingController(text: widget.profile.clinicName);
    _clinicAddressController = TextEditingController(text: widget.profile.clinicAddress);
    _aboutController = TextEditingController(text: widget.profile.about ?? '');
    _selectedSpecialization = widget.profile.specialization;
    _isAvailable = widget.profile.isAvailable;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    _clinicNameController.dispose();
    _clinicAddressController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final firestoreService = context.read<FirestoreService>();
        
        final updatedProfile = widget.profile.copyWith(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          specialization: _selectedSpecialization,
          experience: int.tryParse(_experienceController.text.trim()) ?? widget.profile.experience,
          clinicName: _clinicNameController.text.trim(),
          clinicAddress: _clinicAddressController.text.trim(),
          about: _aboutController.text.trim(),
          isAvailable: _isAvailable,
          updatedAt: DateTime.now(),
        );

        await firestoreService.updateDoctorProfile(widget.profile.id, updatedProfile);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.tealAccent),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Edit Profile', style: AppTextStyles.h3),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personal Info Section
              Text('Personal Information', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.lg),
              
              CustomTextField(
                label: 'Full Name',
                hint: 'Enter your full name',
                prefixIcon: Icons.person_outline,
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              
              CustomTextField(
                label: 'Phone Number',
                hint: 'Enter your phone number',
                prefixIcon: Icons.phone_outlined,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
              ),
              
              const SizedBox(height: AppSpacing.xxxl),
              
              // Professional Info Section
              Text('Professional Information', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.lg),
              
              // Specialization Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Specialization',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.inputBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSpecialization,
                        isExpanded: true,
                        dropdownColor: AppColors.cardBackground,
                        style: AppTextStyles.bodyMedium,
                        items: _specializations.map((spec) {
                          return DropdownMenuItem(
                            value: spec,
                            child: Text(spec),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedSpecialization = value);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              
              CustomTextField(
                label: 'Years of Experience',
                hint: 'Enter years of experience',
                prefixIcon: Icons.work_outline,
                controller: _experienceController,
                keyboardType: TextInputType.number,
              ),
              
              const SizedBox(height: AppSpacing.xxxl),
              
              // Clinic Info Section
              Text('Clinic Information', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.lg),
              
              CustomTextField(
                label: 'Clinic/Hospital Name',
                hint: 'Enter clinic name',
                prefixIcon: Icons.local_hospital_outlined,
                controller: _clinicNameController,
              ),
              const SizedBox(height: AppSpacing.lg),
              
              CustomTextField(
                label: 'Clinic Address',
                hint: 'Enter clinic address',
                prefixIcon: Icons.location_on_outlined,
                controller: _clinicAddressController,
                maxLines: 2,
              ),
              
              const SizedBox(height: AppSpacing.xxxl),
              
              // About Section
              Text('About', style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.lg),
              
              CustomTextField(
                label: 'About You',
                hint: 'Write a brief description about yourself',
                controller: _aboutController,
                maxLines: 4,
              ),
              
              const SizedBox(height: AppSpacing.xxxl),
              
              // Availability Toggle
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
                        color: _isAvailable
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Icon(
                        _isAvailable ? Icons.check_circle : Icons.cancel,
                        color: _isAvailable ? AppColors.success : AppColors.error,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Available for Appointments',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _isAvailable
                                ? 'Patients can book appointments with you'
                                : 'You are not accepting new appointments',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isAvailable,
                      onChanged: (value) {
                        setState(() => _isAvailable = value);
                      },
                      activeColor: AppColors.success,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpacing.xxxl),
              
              // Save Button
              CustomButton(
                text: 'Save Changes',
                onPressed: _saveProfile,
                isLoading: _isLoading,
                icon: Icons.save,
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Sign Out Button
              CustomButton(
                text: 'Sign Out',
                onPressed: () => _handleSignOut(context),
                isOutlined: true,
                icon: Icons.logout,
              ),
              
              const SizedBox(height: 120), // Extra padding to avoid navbar overlap
            ],
          ),
        ),
      ),
    );
  }

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
              style: AppTextStyles.button.copyWith(
                color: AppColors.textSecondary,
              ),
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

    if (confirm == true && mounted) {
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
}

