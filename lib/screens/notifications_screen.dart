import 'package:flutter/material.dart';
import '../models/user_profile.dart' as models;
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  List<models.Notification> _getSampleNotifications() {
    return [
      models.Notification(
        id: '1',
        title: 'Appointment Reminder',
        message: 'Your appointment with Dr. Sarah Johnson is tomorrow at 10:00 AM',
        dateTime: DateTime.now().subtract(const Duration(hours: 2)),
        type: models.NotificationType.appointment,
        isRead: false,
      ),
      models.Notification(
        id: '2',
        title: 'Health Tip',
        message: 'Stay hydrated! Drink at least 8 glasses of water daily for optimal health.',
        dateTime: DateTime.now().subtract(const Duration(hours: 5)),
        type: models.NotificationType.healthTip,
        isRead: false,
      ),
      models.Notification(
        id: '3',
        title: 'Vaccination Reminder',
        message: 'Max\'s Bordetella vaccine is due in 30 days. Book an appointment soon!',
        dateTime: DateTime.now().subtract(const Duration(hours: 8)),
        type: models.NotificationType.reminder,
        isRead: true,
      ),
      models.Notification(
        id: '4',
        title: 'New Message',
        message: 'Dr. Sarah Johnson sent you a message regarding your recent consultation.',
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
        type: models.NotificationType.message,
        isRead: true,
      ),
      models.Notification(
        id: '5',
        title: 'Appointment Confirmed',
        message: 'Your appointment has been confirmed for Nov 20, 2025 at 2:30 PM.',
        dateTime: DateTime.now().subtract(const Duration(days: 2)),
        type: models.NotificationType.appointment,
        isRead: true,
      ),
      models.Notification(
        id: '6',
        title: 'Lab Results Ready',
        message: 'Your recent lab test results are now available. View them in Medical Records.',
        dateTime: DateTime.now().subtract(const Duration(days: 3)),
        type: models.NotificationType.reminder,
        isRead: true,
      ),
    ];
  }

  IconData _getIconForType(models.NotificationType type) {
    switch (type) {
      case models.NotificationType.appointment:
        return Icons.calendar_today;
      case models.NotificationType.reminder:
        return Icons.alarm;
      case models.NotificationType.healthTip:
        return Icons.lightbulb_outline;
      case models.NotificationType.message:
        return Icons.message;
    }
  }

  Color _getColorForType(models.NotificationType type) {
    switch (type) {
      case models.NotificationType.appointment:
        return AppColors.tealAccent;
      case models.NotificationType.reminder:
        return AppColors.warning;
      case models.NotificationType.healthTip:
        return Color(0xFF60A5FA);
      case models.NotificationType.message:
        return AppColors.success;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _getSampleNotifications();
    final unreadCount = notifications.where((n) => !n.isRead).length;

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
                        'Notifications',
                        style: AppTextStyles.h2.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        unreadCount > 0
                            ? '$unreadCount unread notification${unreadCount > 1 ? 's' : ''}'
                            : 'All caught up!',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (unreadCount > 0)
                  TextButton(
                    onPressed: () {
                      // TODO: Mark all as read
                    },
                    child: Text(
                      'Clear',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.tealAccent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Body
          Expanded(
            child: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'No notifications',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'You\'re all caught up!',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                if (unreadCount > 0)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.tealAccent.withValues(alpha: 0.1),
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.tealAccent.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    child: Text(
                      '$unreadCount new notification${unreadCount > 1 ? 's' : ''}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.tealAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _NotificationItem(
                        notification: notification,
                        icon: _getIconForType(notification.type),
                        color: _getColorForType(notification.type),
                        timeAgo: _getTimeAgo(notification.dateTime),
                        onTap: () {
                          // TODO: Handle notification tap
                        },
                        onDismiss: () {
                          // TODO: Handle notification dismiss
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final models.Notification notification;
  final IconData icon;
  final Color color;
  final String timeAgo;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationItem({
    Key? key,
    required this.notification,
    required this.icon,
    required this.color,
    required this.timeAgo,
    required this.onTap,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onDismiss();
      },
      background: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xxl),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          color: notification.isRead
              ? Colors.transparent
              : AppColors.tealAccent.withValues(alpha: 0.05),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
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
              const SizedBox(width: AppSpacing.lg),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTextStyles.h4.copyWith(
                              fontSize: 16,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.tealAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      notification.message,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      timeAgo,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
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

