import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/pet.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'edit_pet_profile_screen.dart';
import 'pet_appointments_list_screen.dart';
import 'pet_medical_records_screen.dart';
import 'splash_screen.dart';

class PetProfileScreen extends StatelessWidget {
  const PetProfileScreen({Key? key}) : super(key: key);

  void _handleSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
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
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: AppTextStyles.button.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authService = context.read<AuthService>();
      await authService.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SplashScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final user = authService.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pet Profile')),
        body: const Center(child: Text('Please log in')),
      );
    }

    return StreamBuilder<Pet?>(
      stream: firestoreService.getPetProfileStream(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Pet Profile')),
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.tealAccent),
            ),
          );
        }

        // No pet profile exists - show create form
        if (!snapshot.hasData || snapshot.data == null) {
          return _buildNoPetProfile(context, user.uid);
        }

        final pet = snapshot.data!;
        return _buildPetProfileContent(context, pet);
      },
    );
  }

  Widget _buildNoPetProfile(BuildContext context, String userId) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleSignOut(context),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.graphite,
                  border: Border.all(
                    color: AppColors.tealAccent.withValues(alpha: 0.5),
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.pets,
                  size: 60,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'No Pet Profile Yet',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Add your furry friend\'s information to get started with pet healthcare services.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CreatePetProfileScreen(userId: userId),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Pet Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tealAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.lg,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetProfileContent(BuildContext context, Pet pet) {
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
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleSignOut(context),
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
                    child: pet.imageUrl.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              pet.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.pets,
                                size: 60,
                                color: AppColors.tealAccent,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.pets,
                            size: 60,
                            color: AppColors.tealAccent,
                          ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    pet.name,
                    style: AppTextStyles.h1,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${pet.breed} • ${pet.species}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Pet Details
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Info Card
                  _buildInfoCard(
                    title: 'Basic Information',
                    children: [
                      _buildInfoRow('Age', '${pet.age} years'),
                      if (pet.gender != null)
                        _buildInfoRow('Gender', pet.gender!),
                      if (pet.weight != null)
                        _buildInfoRow('Weight', '${pet.weight} kg'),
                      if (pet.dateOfBirth != null)
                        _buildInfoRow(
                          'Date of Birth',
                          DateFormat('MMM d, y').format(pet.dateOfBirth!),
                        ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Medical Info
                  if (pet.medicalConditions != null && pet.medicalConditions!.isNotEmpty)
                    _buildInfoCard(
                      title: 'Medical Conditions',
                      children: pet.medicalConditions!
                          .map((condition) => _buildChip(condition))
                          .toList(),
                      isChips: true,
                    ),

                  if (pet.allergies != null && pet.allergies!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _buildInfoCard(
                      title: 'Allergies',
                      children: pet.allergies!
                          .map((allergy) => _buildChip(allergy, isWarning: true))
                          .toList(),
                      isChips: true,
                    ),
                  ],

                  const SizedBox(height: AppSpacing.lg),

                  // Vaccination Records
                  if (pet.vaccinations.isNotEmpty)
                    _buildVaccinationCard(pet.vaccinations),

                  const SizedBox(height: AppSpacing.lg),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildActionCard(
                    icon: Icons.calendar_today,
                    title: 'View Appointments',
                    subtitle: 'Check your pet\'s vet visits',
                    color: AppColors.tealAccent,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PetAppointmentsListScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildActionCard(
                    icon: Icons.folder_outlined,
                    title: 'Medical Records',
                    subtitle: 'View pet health history',
                    color: const Color(0xFF8B5CF6),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PetMedicalRecordsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
    bool isChips = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.inputBorder.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: AppSpacing.md),
          if (isChips)
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: children,
            )
          else
            ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String text, {bool isWarning = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isWarning
            ? AppColors.error.withValues(alpha: 0.2)
            : AppColors.tealAccent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: isWarning ? AppColors.error : AppColors.tealAccent,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildVaccinationCard(List<VaccinationRecord> vaccinations) {
    final completed = vaccinations.where((v) => v.completed).length;
    final total = vaccinations.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.inputBorder.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vaccinations',
                style: AppTextStyles.h4,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tealAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  '$completed/$total',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.tealAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...vaccinations.map((v) => _buildVaccinationRow(v)),
        ],
      ),
    );
  }

  Widget _buildVaccinationRow(VaccinationRecord vaccination) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            vaccination.completed ? Icons.check_circle : Icons.schedule,
            size: 20,
            color: vaccination.completed ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vaccination.name,
                  style: AppTextStyles.bodyMedium,
                ),
                Text(
                  DateFormat('MMM d, y').format(vaccination.date),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: vaccination.completed
                  ? AppColors.success.withValues(alpha: 0.2)
                  : const Color(0xFFF59E0B).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Text(
              vaccination.completed ? 'Done' : 'Pending',
              style: AppTextStyles.caption.copyWith(
                color: vaccination.completed ? AppColors.success : const Color(0xFFF59E0B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.h4),
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
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// Create Pet Profile Screen
class CreatePetProfileScreen extends StatefulWidget {
  final String userId;

  const CreatePetProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<CreatePetProfileScreen> createState() => _CreatePetProfileScreenState();
}

class _CreatePetProfileScreenState extends State<CreatePetProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  
  String _species = 'Dog';
  String _gender = 'Male';
  bool _isLoading = false;

  final List<String> _speciesOptions = ['Dog', 'Cat', 'Bird', 'Rabbit', 'Hamster', 'Fish', 'Other'];
  final List<String> _genderOptions = ['Male', 'Female'];

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final firestoreService = context.read<FirestoreService>();

      final pet = Pet(
        id: '',
        name: _nameController.text.trim(),
        species: _species,
        breed: _breedController.text.trim(),
        age: int.tryParse(_ageController.text) ?? 0,
        imageUrl: '',
        vaccinations: [],
        ownerId: widget.userId,
        gender: _gender,
        weight: double.tryParse(_weightController.text),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await firestoreService.createPetProfile(pet);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pet profile created successfully!'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Pet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet Avatar
              Center(
                child: Container(
                  width: 100,
                  height: 100,
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
                    size: 50,
                    color: AppColors.tealAccent,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Pet Name',
                  prefixIcon: Icon(Icons.pets),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your pet\'s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Species Dropdown
              DropdownButtonFormField<String>(
                value: _species,
                decoration: const InputDecoration(
                  labelText: 'Species',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _speciesOptions.map((species) {
                  return DropdownMenuItem(value: species, child: Text(species));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _species = value);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Breed
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(
                  labelText: 'Breed',
                  prefixIcon: Icon(Icons.pets_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the breed';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Gender Dropdown
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.male),
                ),
                items: _genderOptions.map((gender) {
                  return DropdownMenuItem(value: gender, child: Text(gender));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _gender = value);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Age and Weight Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age (years)',
                        prefixIcon: Icon(Icons.cake),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        prefixIcon: Icon(Icons.monitor_weight),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tealAccent,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Pet Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
