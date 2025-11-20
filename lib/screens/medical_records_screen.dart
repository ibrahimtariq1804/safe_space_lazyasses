import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({Key? key}) : super(key: key);

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen>
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
                            'Medical Records',
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Complete health history',
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
                    Tab(text: 'Immunizations'),
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
                _buildImmunizationsTab(),
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
            icon: Icons.description,
            title: 'Annual Health Checkup',
            date: 'Oct 15, 2024',
            doctor: 'Dr. Sarah Johnson',
            type: 'General Checkup',
            color: AppColors.success,
            details: 'Comprehensive annual physical examination. All vitals normal.',
          ),
          const SizedBox(height: AppSpacing.md),
          _RecordCard(
            icon: Icons.biotech,
            title: 'Blood Test Results',
            date: 'Sep 28, 2024',
            doctor: 'Lab Report',
            type: 'Laboratory',
            color: AppColors.error,
            details: 'Complete blood count, lipid panel, and glucose levels checked.',
          ),
          const SizedBox(height: AppSpacing.md),
          _RecordCard(
            icon: Icons.medication,
            title: 'Prescription - Metformin',
            date: 'Sep 10, 2024',
            doctor: 'Dr. Michael Chen',
            type: 'Prescription',
            color: Color(0xFFF59E0B),
            details: '500mg twice daily for diabetes management.',
          ),
          const SizedBox(height: AppSpacing.md),
          _RecordCard(
            icon: Icons.favorite,
            title: 'ECG Test',
            date: 'Aug 22, 2024',
            doctor: 'Dr. Sarah Johnson',
            type: 'Diagnostic',
            color: AppColors.error,
            details: 'Electrocardiogram showed normal sinus rhythm.',
          ),
          const SizedBox(height: AppSpacing.md),
          _RecordCard(
            icon: Icons.vaccines,
            title: 'Flu Vaccination',
            date: 'Aug 5, 2024',
            doctor: 'Dr. Lisa Brown',
            type: 'Immunization',
            color: Color(0xFF60A5FA),
            details: 'Annual influenza vaccine administered.',
          ),
          const SizedBox(height: AppSpacing.md),
          _RecordCard(
            icon: Icons.medical_services,
            title: 'Blood Pressure Monitoring',
            date: 'Jul 18, 2024',
            doctor: 'Dr. Sarah Johnson',
            type: 'Follow-up',
            color: AppColors.tealAccent,
            details: 'BP: 128/82 mmHg. Within acceptable range.',
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
            name: 'Metformin',
            dosage: '500mg',
            frequency: 'Twice daily',
            prescribedBy: 'Dr. Michael Chen',
            prescribedDate: 'Sep 10, 2024',
            purpose: 'Type 2 Diabetes management',
            color: AppColors.tealAccent,
          ),
          const SizedBox(height: AppSpacing.md),
          _MedicationDetailCard(
            name: 'Lisinopril',
            dosage: '10mg',
            frequency: 'Once daily',
            prescribedBy: 'Dr. Sarah Johnson',
            prescribedDate: 'Jun 5, 2024',
            purpose: 'Blood pressure control',
            color: Color(0xFF60A5FA),
          ),
          const SizedBox(height: AppSpacing.md),
          _MedicationDetailCard(
            name: 'Vitamin D3',
            dosage: '2000 IU',
            frequency: 'Once daily',
            prescribedBy: 'Dr. Sarah Johnson',
            prescribedDate: 'Mar 12, 2024',
            purpose: 'Vitamin D deficiency',
            color: Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Widget _buildImmunizationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Immunization History',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.lg),
          _ImmunizationDetailCard(
            vaccine: 'Influenza (Flu)',
            date: 'Aug 5, 2024',
            nextDue: 'Aug 2025',
            status: 'Up to date',
            batchNumber: 'FLU24-8765',
          ),
          const SizedBox(height: AppSpacing.md),
          _ImmunizationDetailCard(
            vaccine: 'Tetanus-Diphtheria',
            date: 'Jan 12, 2023',
            nextDue: 'Jan 2033',
            status: 'Up to date',
            batchNumber: 'TD23-4521',
          ),
          const SizedBox(height: AppSpacing.md),
          _ImmunizationDetailCard(
            vaccine: 'COVID-19 Booster',
            date: 'Mar 20, 2024',
            nextDue: 'Mar 2025',
            status: 'Up to date',
            batchNumber: 'CV24-9012',
          ),
          const SizedBox(height: AppSpacing.md),
          _ImmunizationDetailCard(
            vaccine: 'Hepatitis B',
            date: 'May 8, 2020',
            nextDue: 'Lifetime',
            status: 'Complete',
            batchNumber: 'HB20-3344',
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
            title: 'Penicillin Allergy',
            severity: 'Severe',
            diagnosedDate: 'Jan 2015',
            notes: 'Causes severe allergic reaction. Avoid all penicillin-based antibiotics.',
            color: AppColors.error,
          ),
          const SizedBox(height: AppSpacing.md),
          _ConditionCard(
            title: 'Peanut Allergy',
            severity: 'Moderate',
            diagnosedDate: 'Childhood',
            notes: 'Causes hives and swelling. Carry EpiPen at all times.',
            color: AppColors.error,
          ),
          const SizedBox(height: AppSpacing.md),
          _ConditionCard(
            title: 'Latex Sensitivity',
            severity: 'Mild',
            diagnosedDate: 'Mar 2018',
            notes: 'Contact dermatitis. Use latex-free gloves.',
            color: Color(0xFFF59E0B),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Text(
            'Chronic Conditions',
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: AppSpacing.lg),
          _ConditionCard(
            title: 'Type 2 Diabetes',
            severity: 'Controlled',
            diagnosedDate: 'Sep 2022',
            notes: 'Managed with Metformin and diet. Regular monitoring required.',
            color: AppColors.tealAccent,
          ),
          const SizedBox(height: AppSpacing.md),
          _ConditionCard(
            title: 'Hypertension',
            severity: 'Controlled',
            diagnosedDate: 'Jun 2021',
            notes: 'Treated with Lisinopril. Blood pressure regularly monitored.',
            color: AppColors.tealAccent,
          ),
          const SizedBox(height: AppSpacing.md),
          _ConditionCard(
            title: 'Asthma',
            severity: 'Mild Intermittent',
            diagnosedDate: 'Childhood',
            notes: 'Exercise-induced. Rescue inhaler as needed.',
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
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
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
                    Icons.medication_rounded,
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

class _ImmunizationDetailCard extends StatelessWidget {
  final String vaccine;
  final String date;
  final String nextDue;
  final String status;
  final String batchNumber;

  const _ImmunizationDetailCard({
    Key? key,
    required this.vaccine,
    required this.date,
    required this.nextDue,
    required this.status,
    required this.batchNumber,
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
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    Icons.vaccines_rounded,
                    color: AppColors.success,
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
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    status,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
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

