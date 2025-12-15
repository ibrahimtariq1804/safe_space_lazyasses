import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'splash_screen.dart';

class EditHumanProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditHumanProfileScreen({Key? key, required this.profile})
      : super(key: key);

  @override
  State<EditHumanProfileScreen> createState() => _EditHumanProfileScreenState();
}

class _EditHumanProfileScreenState extends State<EditHumanProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _addressController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _emergencyPhoneController;
  late DateTime _selectedDate;
  bool _isSaving = false;
  
  // Lists for allergies and conditions
  late List<String> _allergies;
  late List<String> _medicalConditions;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _bloodGroupController =
        TextEditingController(text: widget.profile.bloodGroup);
    _addressController = TextEditingController(text: widget.profile.address);
    _emergencyContactController =
        TextEditingController(text: widget.profile.emergencyContact);
    _emergencyPhoneController =
        TextEditingController(text: widget.profile.emergencyContactPhone ?? '');
    _selectedDate = widget.profile.dateOfBirth ?? DateTime.now();
    
    // Initialize lists from profile
    _allergies = List.from(widget.profile.allergies);
    _medicalConditions = List.from(widget.profile.medicalConditions);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bloodGroupController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  void _addAllergy() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Allergy'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter allergy name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    
    if (result != null && result.trim().isNotEmpty) {
      setState(() => _allergies.add(result.trim()));
    }
  }

  void _removeAllergy(int index) {
    setState(() => _allergies.removeAt(index));
  }

  void _addMedicalCondition() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Medical Condition'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter condition name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    
    if (result != null && result.trim().isNotEmpty) {
      setState(() => _medicalConditions.add(result.trim()));
    }
  }

  void _removeMedicalCondition(int index) {
    setState(() => _medicalConditions.removeAt(index));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.tealAccent,
              onPrimary: AppColors.deepCharcoal,
              surface: AppColors.graphite,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      final authService = context.read<AuthService>();
      final firestoreService = context.read<FirestoreService>();
      final userId = authService.currentUser?.uid;

      if (userId == null) {
        throw 'User not logged in';
      }

      // Create updated profile
      final updatedProfile = widget.profile.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        dateOfBirth: _selectedDate,
        bloodGroup: _bloodGroupController.text.trim(),
        address: _addressController.text.trim(),
        emergencyContact: _emergencyContactController.text.trim(),
        emergencyContactPhone: _emergencyPhoneController.text.trim(),
        allergies: _allergies,
        medicalConditions: _medicalConditions,
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await firestoreService.updateUserProfile(userId, updatedProfile);

      // Update display name in Firebase Auth if name changed
      if (widget.profile.name != updatedProfile.name) {
        await authService.currentUser?.updateDisplayName(updatedProfile.name);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
                        'Edit Profile',
                        style: AppTextStyles.h2.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Update your personal information',
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
              // Profile Picture
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
                        Icons.person,
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

              // Personal Information
              Text(
                'Personal Information',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: AppSpacing.lg),

              CustomTextField(
                label: 'Full Name',
                controller: _nameController,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: AppSpacing.lg),

              CustomTextField(
                label: 'Email',
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: AppSpacing.lg),

              CustomTextField(
                label: 'Phone',
                controller: _phoneController,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Date of Birth
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.lg,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date of Birth',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM d, yyyy').format(_selectedDate),
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.edit_outlined,
                        color: AppColors.tealAccent,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              CustomTextField(
                label: 'Blood Group',
                controller: _bloodGroupController,
                prefixIcon: Icons.bloodtype,
              ),
              const SizedBox(height: AppSpacing.lg),

              CustomTextField(
                label: 'Address',
                controller: _addressController,
                prefixIcon: Icons.location_on_outlined,
                maxLines: 3,
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
                controller: TextEditingController(text: 'Penicillin, Peanuts, Latex'),
                prefixIcon: Icons.warning_amber_rounded,
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.lg),

              CustomTextField(
                label: 'Chronic Conditions (comma separated)',
                controller: TextEditingController(text: 'Type 2 Diabetes, Hypertension, Asthma'),
                prefixIcon: Icons.medical_information,
                maxLines: 2,
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Emergency Contact
              Text(
                'Emergency Contact',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: AppSpacing.lg),

              CustomTextField(
                label: 'Contact Name',
                controller: _emergencyContactController,
                prefixIcon: Icons.person_add_outlined,
              ),
              const SizedBox(height: AppSpacing.lg),

              CustomTextField(
                label: 'Contact Phone',
                controller: _emergencyPhoneController,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Allergies Section
              Text(
                'Allergies',
                style: AppTextStyles.h3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._allergies.asMap().entries.map(
                    (entry) => Chip(
                      label: Text(entry.value),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => _removeAllergy(entry.key),
                      backgroundColor: AppColors.tealAccent.withOpacity(0.2),
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  ),
                  ActionChip(
                    label: const Text('+ Add Allergy'),
                    onPressed: _addAllergy,
                    backgroundColor: AppColors.tealAccent,
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Medical Conditions Section
              Text(
                'Medical Conditions',
                style: AppTextStyles.h3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._medicalConditions.asMap().entries.map(
                    (entry) => Chip(
                      label: Text(entry.value),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => _removeMedicalCondition(entry.key),
                      backgroundColor: AppColors.error.withOpacity(0.2),
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  ),
                  ActionChip(
                    label: const Text('+ Add Condition'),
                    onPressed: _addMedicalCondition,
                    backgroundColor: AppColors.error.withOpacity(0.7),
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Save Button
              CustomButton(
                text: 'Save Changes',
                onPressed: _saveProfile,
                isLoading: _isSaving,
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
          ),
        ],
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

