import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';

class PetMedicalRecordsScreen extends StatefulWidget {
  const PetMedicalRecordsScreen({Key? key}) : super(key: key);

  @override
  State<PetMedicalRecordsScreen> createState() =>
      _PetMedicalRecordsScreenState();
}

class _PetMedicalRecordsScreenState extends State<PetMedicalRecordsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
              AppSpacing.md,
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
            child: Column(
              children: [
                Row(
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
                            'Pet Medical Records',
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Complete pet health history',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.tealAccent,
                  labelColor: AppColors.tealAccent,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'All Records'),
                    Tab(text: 'Medications'),
                    Tab(text: 'Vaccinations'),
                    Tab(text: 'Conditions'),
                  ],
                ),
              ],
            ),
          ),
          // Body Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllRecordsTab(),
                _buildMedicationsTab(),
                _buildVaccinationsTab(),
                _buildConditionsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllRecordsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RecordCard(
            icon: Icons.local_hospital,
            title: 'Annual Wellness Check',
            date: 'Nov 2, 2024',
            doctor: 'Dr. Emily Parker',
            type: 'Checkup',
            color: AppColors.success,
            details:
                'Complete physical exam. Weight: 28kg. All vital signs normal. Teeth slightly worn.',
          ),
          const SizedBox(height: AppSpacing.md),
          _RecordCard(
            icon: Icons.vaccines,
            title: 'Rabies Vaccination',
            date: 'Oct 10, 2024',
            doctor: 'Dr. Emily Parker',
            type: 'Vaccination',
            color: Color(0xFF60A5FA),
            details: '3-year rabies vaccine administered. Next due October 2027.',
          ),
          const SizedBox(height: AppSpacing.md),
          _RecordCard(
            icon: Icons.pets,
            title: 'Dental Cleaning',
            date: 'Sep 5, 2024',
            doctor: 'Dr. James Wilson',
            type: 'Procedure',
            color: Color(0xFFF59E0B),
            details:
                'Professional dental cleaning under anesthesia. Two teeth extracted.',
          ),
          const SizedBox(height: AppSpacing.md),
          _RecordCard(
            icon: Icons.biotech,
            title: 'Heartworm Test',
            date: 'Aug 18, 2024',
            doctor: 'Dr. Emily Parker',
            type: 'Lab Test',
            color: AppColors.error,
            details: 'Heartworm test negative. Continue monthly prevention.',
          ),
          const SizedBox(height: AppSpacing.md),
          _RecordCard(
            icon: Icons.medical_services,
            title: 'Flea & Tick Treatment',
            date: 'Jul 30, 2024',
            doctor: 'Dr. Emily Parker',
            type: 'Treatment',
            color: Color(0xFF60A5FA),
            details: 'Topical flea and tick prevention applied. Effective for 30 days.',
          ),
          const SizedBox(height: AppSpacing.md),
          _RecordCard(
            icon: Icons.medication,
            title: 'Allergy Treatment Started',
            date: 'Jun 15, 2024',
            doctor: 'Dr. Emily Parker',
            type: 'Treatment',
            color: AppColors.tealAccent,
            details:
                'Started Apoquel for skin allergies. Monitor for side effects.',
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Medications',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.lg),
          _MedicationDetailCard(
            name: 'Apoquel',
            dosage: '16mg',
            frequency: 'Twice daily',
            prescribedBy: 'Dr. Emily Parker',
            prescribedDate: 'Jun 15, 2024',
            purpose: 'Allergy relief and skin condition management',
            color: AppColors.tealAccent,
          ),
          const SizedBox(height: AppSpacing.md),
          _MedicationDetailCard(
            name: 'Heartgard Plus',
            dosage: 'Monthly chewable',
            frequency: 'Once monthly',
            prescribedBy: 'Dr. Emily Parker',
            prescribedDate: 'Mar 10, 2024',
            purpose: 'Heartworm prevention and intestinal parasite control',
            color: AppColors.error,
          ),
          const SizedBox(height: AppSpacing.md),
          _MedicationDetailCard(
            name: 'Fish Oil Supplement',
            dosage: '1000mg',
            frequency: 'Once daily with food',
            prescribedBy: 'Dr. Emily Parker',
            prescribedDate: 'Jan 8, 2024',
            purpose: 'Joint health and coat condition',
            color: Color(0xFF60A5FA),
          ),
          const SizedBox(height: AppSpacing.md),
          _MedicationDetailCard(
            name: 'Glucosamine Complex',
            dosage: '500mg',
            frequency: 'Twice daily',
            prescribedBy: 'Dr. Emily Parker',
            prescribedDate: 'Dec 1, 2023',
            purpose: 'Arthritis and joint pain management',
            color: Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vaccination History',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.lg),
          _VaccinationDetailCard(
            vaccine: 'Rabies',
            date: 'Oct 10, 2024',
            nextDue: 'Oct 2027',
            status: 'Current',
            batchNumber: 'RAB24-7856',
          ),
          const SizedBox(height: AppSpacing.md),
          _VaccinationDetailCard(
            vaccine: 'DHPP (Distemper)',
            date: 'Mar 15, 2024',
            nextDue: 'Mar 2027',
            status: 'Current',
            batchNumber: 'DHPP24-3421',
          ),
          const SizedBox(height: AppSpacing.md),
          _VaccinationDetailCard(
            vaccine: 'Bordetella',
            date: 'Jan 8, 2024',
            nextDue: 'Dec 15, 2024',
            status: 'Due soon',
            batchNumber: 'BORD24-1198',
          ),
          const SizedBox(height: AppSpacing.md),
          _VaccinationDetailCard(
            vaccine: 'Lyme Disease',
            date: 'Apr 22, 2024',
            nextDue: 'Apr 2025',
            status: 'Current',
            batchNumber: 'LYME24-5567',
          ),
          const SizedBox(height: AppSpacing.md),
          _VaccinationDetailCard(
            vaccine: 'Leptospirosis',
            date: 'Apr 22, 2024',
            nextDue: 'Apr 2025',
            status: 'Current',
            batchNumber: 'LEPTO24-8834',
          ),
        ],
      ),
    );
  }

  Widget _buildConditionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Allergies',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.lg),
          _ConditionCard(
            title: 'Chicken Protein Allergy',
            severity: 'Moderate',
            diagnosedDate: 'Jun 2024',
            notes:
                'Causes skin irritation and digestive issues. Switched to fish-based diet.',
            color: AppColors.error,
          ),
          const SizedBox(height: AppSpacing.md),
          _ConditionCard(
            title: 'Grass Pollen Sensitivity',
            severity: 'Mild',
            diagnosedDate: 'Summer 2023',
            notes: 'Seasonal allergy causing paw licking and scratching. Manageable with Apoquel.',
            color: Color(0xFFF59E0B),
          ),
          const SizedBox(height: AppSpacing.md),
          _ConditionCard(
            title: 'Dust Mite Allergy',
            severity: 'Mild',
            diagnosedDate: 'Apr 2023',
            notes:
                'Causes occasional sneezing. Regular bedding washing recommended.',
            color: Color(0xFFF59E0B),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            'Health Conditions',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.lg),
          _ConditionCard(
            title: 'Arthritis',
            severity: 'Managed',
            diagnosedDate: 'Dec 2023',
            notes:
                'Age-related arthritis in hips and knees. Managed with supplements and pain medication as needed.',
            color: AppColors.tealAccent,
          ),
          const SizedBox(height: AppSpacing.md),
          _ConditionCard(
            title: 'Atopic Dermatitis',
            severity: 'Controlled',
            diagnosedDate: 'Jun 2024',
            notes:
                'Chronic skin condition causing itching and redness. Well controlled with Apoquel.',
            color: AppColors.tealAccent,
          ),
          const SizedBox(height: AppSpacing.md),
          _ConditionCard(
            title: 'Hip Dysplasia',
            severity: 'Mild',
            diagnosedDate: 'Nov 2022',
            notes:
                'Mild hip dysplasia. Managed with weight control, exercise modification, and joint supplements.',
            color: Color(0xFF60A5FA),
          ),
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String date;
  final String doctor;
  final String type;
  final Color color;
  final String details;

  const _RecordCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.date,
    required this.doctor,
    required this.type,
    required this.color,
    required this.details,
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
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.h4,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Text(
                              type,
                              style: AppTextStyles.caption.copyWith(
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              details,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
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
                  date,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Icon(
                  Icons.person,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  doctor,
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

class _MedicationDetailCard extends StatelessWidget {
  final String name;
  final String dosage;
  final String frequency;
  final String prescribedBy;
  final String prescribedDate;
  final String purpose;
  final Color color;

  const _MedicationDetailCard({
    Key? key,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.prescribedBy,
    required this.prescribedDate,
    required this.purpose,
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
                    Icons.medication_liquid_rounded,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    name,
                    style: AppTextStyles.h4,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    'Active',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoRow(label: 'Dosage', value: dosage),
            _InfoRow(label: 'Frequency', value: frequency),
            _InfoRow(label: 'Purpose', value: purpose),
            _InfoRow(label: 'Prescribed by', value: prescribedBy),
            _InfoRow(label: 'Prescribed on', value: prescribedDate),
          ],
        ),
      ),
    );
  }
}

class _VaccinationDetailCard extends StatelessWidget {
  final String vaccine;
  final String date;
  final String nextDue;
  final String status;
  final String batchNumber;

  const _VaccinationDetailCard({
    Key? key,
    required this.vaccine,
    required this.date,
    required this.nextDue,
    required this.status,
    required this.batchNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDueSoon = status == 'Due soon';
    final Color statusColor =
        isDueSoon ? Color(0xFFF59E0B) : AppColors.success;

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
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    Icons.vaccines_rounded,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    vaccine,
                    style: AppTextStyles.h4,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    status,
                    style: AppTextStyles.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoRow(label: 'Last dose', value: date),
            _InfoRow(label: 'Next due', value: nextDue),
            _InfoRow(label: 'Batch number', value: batchNumber),
          ],
        ),
      ),
    );
  }
}

class _ConditionCard extends StatelessWidget {
  final String title;
  final String severity;
  final String diagnosedDate;
  final String notes;
  final Color color;

  const _ConditionCard({
    Key? key,
    required this.title,
    required this.severity,
    required this.diagnosedDate,
    required this.notes,
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
                    Icons.warning_amber_rounded,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.h4,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    severity,
                    style: AppTextStyles.caption.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _InfoRow(label: 'Diagnosed', value: diagnosedDate),
            const SizedBox(height: AppSpacing.sm),
            Text(
              notes,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

