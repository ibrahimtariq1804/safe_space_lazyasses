import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_text_styles.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/appointment.dart';
import 'doctor_appointment_detail_screen.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<DoctorAppointmentsScreen> createState() => _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen>
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
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Appointments')),
        body: const Center(child: Text('Please log in')),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appointments',
                    style: AppTextStyles.h2.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Manage your patient appointments',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Tab Bar
            Container(
              color: AppColors.cardBackground,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.tealAccent,
                labelColor: AppColors.tealAccent,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
                unselectedLabelStyle: AppTextStyles.bodySmall,
                tabs: const [
                  Tab(text: 'Pending'),
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Completed'),
                  Tab(text: 'All'),
                ],
              ),
            ),
            
            // Tab Content
            Expanded(
              child: StreamBuilder<List<Appointment>>(
                stream: firestoreService.getDoctorAppointmentsStream(userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.tealAccent),
                    );
                  }

                  final allAppointments = snapshot.data ?? [];
                  final now = DateTime.now();

                  // Filter appointments for each tab
                  final pending = allAppointments
                      .where((a) => a.status == AppointmentStatus.pending)
                      .toList();
                  final upcoming = allAppointments
                      .where((a) =>
                          a.status == AppointmentStatus.confirmed &&
                          a.dateTime.isAfter(now))
                      .toList();
                  final completed = allAppointments
                      .where((a) => a.status == AppointmentStatus.completed)
                      .toList();

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAppointmentList(context, pending, 'pending'),
                      _buildAppointmentList(context, upcoming, 'upcoming'),
                      _buildAppointmentList(context, completed, 'completed'),
                      _buildAppointmentList(context, allAppointments, 'all'),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentList(
    BuildContext context,
    List<Appointment> appointments,
    String type,
  ) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyIcon(type),
              size: 80,
              color: AppColors.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              _getEmptyMessage(type),
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        return _buildAppointmentCard(context, appointments[index]);
      },
    );
  }

  IconData _getEmptyIcon(String type) {
    switch (type) {
      case 'pending':
        return Icons.pending_actions;
      case 'upcoming':
        return Icons.event_available;
      case 'completed':
        return Icons.check_circle_outline;
      default:
        return Icons.calendar_today;
    }
  }

  String _getEmptyMessage(String type) {
    switch (type) {
      case 'pending':
        return 'No pending requests';
      case 'upcoming':
        return 'No upcoming appointments';
      case 'completed':
        return 'No completed appointments';
      default:
        return 'No appointments';
    }
  }

  Widget _buildAppointmentCard(BuildContext context, Appointment appointment) {
    Color statusColor;
    String statusText;

    switch (appointment.status) {
      case AppointmentStatus.pending:
        statusColor = AppColors.warning;
        statusText = 'Pending';
        break;
      case AppointmentStatus.confirmed:
        statusColor = AppColors.tealAccent;
        statusText = 'Confirmed';
        break;
      case AppointmentStatus.completed:
        statusColor = AppColors.success;
        statusText = 'Completed';
        break;
      case AppointmentStatus.cancelled:
        statusColor = AppColors.textTertiary;
        statusText = 'Cancelled';
        break;
      case AppointmentStatus.rejected:
        statusColor = AppColors.error;
        statusText = 'Rejected';
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusText = 'Unknown';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DoctorAppointmentDetailScreen(appointment: appointment),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Row(
                children: [
                  // Patient Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Icon(
                      Icons.person,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  // Patient Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.patientName,
                          style: AppTextStyles.h4,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          appointment.symptoms.isNotEmpty
                              ? appointment.symptoms
                              : 'General Consultation',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    DateFormat('MMM d, yyyy').format(appointment.dateTime),
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    DateFormat('h:mm a').format(appointment.dateTime),
                    style: AppTextStyles.bodySmall,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                    ),
                    child: Text(
                      statusText,
                      style: AppTextStyles.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
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

