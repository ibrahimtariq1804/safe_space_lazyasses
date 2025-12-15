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

class DoctorSignupScreen extends StatefulWidget {
  const DoctorSignupScreen({Key? key}) : super(key: key);

  @override
  State<DoctorSignupScreen> createState() => _DoctorSignupScreenState();
}

class _DoctorSignupScreenState extends State<DoctorSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();
  final _experienceController = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _clinicAddressController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String _selectedSpecialization = 'General Physician';
  String _doctorType = 'human'; // 'human' or 'pet'
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);
  List<String> _availableDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  int _currentStep = 0;

  final List<String> _allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    _clinicNameController.dispose();
    _clinicAddressController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final authService = context.read<AuthService>();
        final firestoreService = context.read<FirestoreService>();
        
        // Create Firebase Auth account
        final userCredential = await authService.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
        );
        
        if (userCredential?.user == null) {
          throw 'Failed to create account';
        }

        final userId = userCredential!.user!.uid;

        // Create doctor profile
        final doctorProfile = DoctorProfile(
          id: userId,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          specialization: _selectedSpecialization,
          licenseNumber: _licenseController.text.trim(),
          experience: int.tryParse(_experienceController.text.trim()) ?? 0,
          clinicName: _clinicNameController.text.trim(),
          clinicAddress: _clinicAddressController.text.trim(),
          doctorType: _doctorType,
          availableDays: _availableDays,
          startTime: '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
          endTime: '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
          createdAt: DateTime.now(),
        );

        await firestoreService.createDoctorProfile(userId, doctorProfile);
        
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Doctor account created successfully! Please log in.'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 3),
            ),
          );
          // Go back to login screen
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
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
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.tealAccent,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Doctor Registration',
          style: AppTextStyles.h3,
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Stepper(
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 2) {
                setState(() => _currentStep++);
              } else {
                _handleSignup();
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep--);
              }
            },
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: _currentStep == 2 ? 'Create Account' : 'Continue',
                        onPressed: details.onStepContinue!,
                        isLoading: _isLoading,
                      ),
                    ),
                    if (_currentStep > 0) ...[
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: CustomButton(
                          text: 'Back',
                          onPressed: details.onStepCancel!,
                          isOutlined: true,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
            steps: [
              // Step 1: Account Details
              Step(
                title: Text('Account', style: AppTextStyles.h4),
                subtitle: Text('Login credentials', style: AppTextStyles.caption),
                isActive: _currentStep >= 0,
                state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                content: Column(
                  children: [
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
                      label: 'Email Address',
                      hint: 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CustomTextField(
                      label: 'Password',
                      hint: 'Create a password',
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      onSuffixIconPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                      obscureText: _obscurePassword,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    CustomTextField(
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      onSuffixIconPressed: () {
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                      obscureText: _obscureConfirmPassword,
                      controller: _confirmPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              
              // Step 2: Professional Details
              Step(
                title: Text('Professional', style: AppTextStyles.h4),
                subtitle: Text('Your credentials', style: AppTextStyles.caption),
                isActive: _currentStep >= 1,
                state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                content: Column(
                  children: [
                    CustomTextField(
                      label: 'Phone Number',
                      hint: 'Enter your phone number',
                      prefixIcon: Icons.phone_outlined,
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Doctor Type Selector
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Doctor Type',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _doctorType = 'human'),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  decoration: BoxDecoration(
                                    color: _doctorType == 'human'
                                        ? AppColors.tealAccent.withValues(alpha: 0.1)
                                        : AppColors.cardBackground,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                    border: Border.all(
                                      color: _doctorType == 'human'
                                          ? AppColors.tealAccent
                                          : AppColors.inputBorder,
                                      width: _doctorType == 'human' ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        color: _doctorType == 'human'
                                            ? AppColors.tealAccent
                                            : AppColors.textSecondary,
                                        size: 32,
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      Text(
                                        'Human Doctor',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: _doctorType == 'human'
                                              ? AppColors.tealAccent
                                              : AppColors.textSecondary,
                                          fontWeight: _doctorType == 'human'
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() => _doctorType = 'pet'),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                child: Container(
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  decoration: BoxDecoration(
                                    color: _doctorType == 'pet'
                                        ? AppColors.tealAccent.withValues(alpha: 0.1)
                                        : AppColors.cardBackground,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                    border: Border.all(
                                      color: _doctorType == 'pet'
                                          ? AppColors.tealAccent
                                          : AppColors.inputBorder,
                                      width: _doctorType == 'pet' ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.pets,
                                        color: _doctorType == 'pet'
                                            ? AppColors.tealAccent
                                            : AppColors.textSecondary,
                                        size: 32,
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      Text(
                                        'Pet Doctor',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: _doctorType == 'pet'
                                              ? AppColors.tealAccent
                                              : AppColors.textSecondary,
                                          fontWeight: _doctorType == 'pet'
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                      label: 'License Number',
                      hint: 'Enter your medical license number',
                      prefixIcon: Icons.badge_outlined,
                      controller: _licenseController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your license number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    CustomTextField(
                      label: 'Years of Experience',
                      hint: 'Enter years of experience',
                      prefixIcon: Icons.work_outline,
                      controller: _experienceController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your experience';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              
              // Step 3: Clinic Details
              Step(
                title: Text('Clinic', style: AppTextStyles.h4),
                subtitle: Text('Practice location', style: AppTextStyles.caption),
                isActive: _currentStep >= 2,
                state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                content: Column(
                  children: [
                    CustomTextField(
                      label: 'Clinic/Hospital Name',
                      hint: 'Enter clinic or hospital name',
                      prefixIcon: Icons.local_hospital_outlined,
                      controller: _clinicNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter clinic name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    CustomTextField(
                      label: 'Clinic Address',
                      hint: 'Enter complete address',
                      prefixIcon: Icons.location_on_outlined,
                      controller: _clinicAddressController,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter clinic address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Availability Time
                    Text(
                      'Availability Hours',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: _startTime,
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.dark(
                                        primary: AppColors.tealAccent,
                                        surface: AppColors.cardBackground,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (time != null) {
                                setState(() => _startTime = time);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                border: Border.all(color: AppColors.inputBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Start Time',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        color: AppColors.tealAccent,
                                        size: 20,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Text(
                                        _startTime.format(context),
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: _endTime,
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.dark(
                                        primary: AppColors.tealAccent,
                                        surface: AppColors.cardBackground,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (time != null) {
                                setState(() => _endTime = time);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                border: Border.all(color: AppColors.inputBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'End Time',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        color: AppColors.tealAccent,
                                        size: 20,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Text(
                                        _endTime.format(context),
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w600,
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
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Available Days Selection
                    Text(
                      'Available Days',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: _allDays.map((day) {
                        final isSelected = _availableDays.contains(day);
                        return FilterChip(
                          label: Text(day),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _availableDays.add(day);
                              } else {
                                _availableDays.remove(day);
                              }
                            });
                          },
                          backgroundColor: AppColors.cardBackground,
                          selectedColor: AppColors.tealAccent.withValues(alpha: 0.2),
                          checkmarkColor: AppColors.tealAccent,
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
                            width: isSelected ? 2 : 1,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Terms
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.tealAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(
                          color: AppColors.tealAccent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppColors.tealAccent,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'By registering, you agree to our Terms of Service and verify that your medical credentials are accurate.',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
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
      ),
    );
  }
}

