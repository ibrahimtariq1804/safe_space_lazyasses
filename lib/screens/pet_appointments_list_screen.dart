import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/appointment.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'appointment_detail_screen.dart';

class PetAppointmentsListScreen extends StatefulWidget {
  const PetAppointmentsListScreen({Key? key}) : super(key: key);

  @override
  State<PetAppointmentsListScreen> createState() => _PetAppointmentsListScreenState();
}

class _PetAppointmentsListScreenState extends State<PetAppointmentsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'upcoming';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _selectedFilter = 'upcoming';
            break;
          case 1:
            _selectedFilter = 'pending';
            break;
          case 2:
            _selectedFilter = 'completed';
            break;
          case 3:
            _selectedFilter = 'cancelled';
            break;
        }
      });
    });
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
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Appointments'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.tealAccent,
          labelColor: AppColors.tealAccent,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: user == null
          ? const Center(child: Text('Please log in'))
          : StreamBuilder<List<Appointment>>(
              stream: firestoreService.getUserAppointmentsStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.tealAccent),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                // Filter ONLY pet appointments (doctorType == 'pet')
                final petAppointments = snapshot.data!
                    .where((apt) => apt.doctorType == 'pet')
                    .toList();

                if (petAppointments.isEmpty) {
                  return _buildEmptyState();
                }

                final filteredAppointments = _getFilteredAppointments(petAppointments);

                if (filteredAppointments.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: filteredAppointments.length,
                  itemBuilder: (context, index) {
                    final appointment = filteredAppointments[index];
                    return _AppointmentCard(
                      appointment: appointment,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AppointmentDetailScreen(appointment: appointment),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  List<Appointment> _getFilteredAppointments(List<Appointment> appointments) {
    switch (_selectedFilter) {
      case 'upcoming':
        return appointments
            .where((apt) =>
                apt.status == AppointmentStatus.confirmed &&
                apt.dateTime.isAfter(DateTime.now()))
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
      case 'pending':
        return appointments
            .where((apt) => apt.status == AppointmentStatus.pending)
            .toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
      case 'completed':
        return appointments
            .where((apt) => apt.status == AppointmentStatus.completed)
            .toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
      case 'cancelled':
        return appointments
            .where((apt) =>
                apt.status == AppointmentStatus.cancelled ||
                apt.status == AppointmentStatus.rejected)
            .toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
      default:
        return appointments;
    }
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;
    switch (_selectedFilter) {
      case 'upcoming':
        message = 'No upcoming vet visits';
        icon = Icons.calendar_today_outlined;
        break;
      case 'pending':
        message = 'No pending appointments';
        icon = Icons.hourglass_empty;
        break;
      case 'completed':
        message = 'No completed visits yet';
        icon = Icons.check_circle_outline;
        break;
      case 'cancelled':
        message = 'No cancelled appointments';
        icon = Icons.cancel_outlined;
        break;
      default:
        message = 'No appointments found';
        icon = Icons.pets;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            message,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Book an appointment with a veterinarian',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onTap;

  const _AppointmentCard({
    required this.appointment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: _getStatusColor().withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.tealAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: const Icon(
                    Icons.pets,
                    color: AppColors.tealAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.doctorName,
                        style: AppTextStyles.h4,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        appointment.doctorSpecialization,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.inputBorder),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  DateFormat('EEEE, MMM d, y').format(appointment.dateTime),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  DateFormat('h:mm a').format(appointment.dateTime),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        _getStatusText(),
        style: AppTextStyles.caption.copyWith(
          color: _getStatusColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (appointment.status) {
      case AppointmentStatus.confirmed:
        return AppColors.success;
      case AppointmentStatus.pending:
        return const Color(0xFFF59E0B);
      case AppointmentStatus.completed:
        return AppColors.tealAccent;
      case AppointmentStatus.cancelled:
        return AppColors.error;
      case AppointmentStatus.rejected:
        return AppColors.error;
      case AppointmentStatus.delayed:
        return const Color(0xFFF59E0B);
    }
  }

  String _getStatusText() {
    switch (appointment.status) {
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.rejected:
        return 'Rejected';
      case AppointmentStatus.delayed:
        return 'Delayed';
    }
  }
}

