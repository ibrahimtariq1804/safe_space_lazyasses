import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_spacing.dart';
import '../utils/app_text_styles.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isClearing = false;

  IconData _getIconForType(String type) {
    switch (type) {
      case 'appointment':
        return Icons.calendar_today;
      case 'reminder':
        return Icons.alarm;
      case 'health_tip':
        return Icons.lightbulb_outline;
      case 'message':
        return Icons.message;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'appointment':
        return AppColors.tealAccent;
      case 'reminder':
        return AppColors.warning;
      case 'health_tip':
        return const Color(0xFF60A5FA);
      case 'message':
        return AppColors.success;
      default:
        return AppColors.tealAccent;
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

  Future<void> _clearAllNotifications(String userId) async {
    setState(() => _isClearing = true);
    try {
      final firestoreService = context.read<FirestoreService>();
      await firestoreService.clearAllNotifications(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications cleared'),
            backgroundColor: AppColors.success,
          ),
        );
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
      if (mounted) setState(() => _isClearing = false);
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    try {
      final firestoreService = context.read<FirestoreService>();
      await firestoreService.deleteNotification(notificationId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _markAsRead(String notificationId, bool isRead) async {
    if (isRead) return; // Already read
    try {
      final firestoreService = context.read<FirestoreService>();
      await firestoreService.markNotificationAsRead(notificationId);
    } catch (e) {
      // Silent fail for mark as read
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final firestoreService = context.read<FirestoreService>();
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(child: Text('Please log in to view notifications')),
      );
    }

    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.getNotificationsStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading notifications',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
              ),
            );
          }

          final notifications = snapshot.data ?? [];
          final unreadCount = notifications.where((n) => n['isRead'] == false).length;

          return Column(
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
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
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
                      if (notifications.isNotEmpty)
                        TextButton(
                          onPressed: _isClearing ? null : () => _clearAllNotifications(userId),
                          child: _isClearing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  'Clear',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.tealAccent,
                                  ),
                                ),
                        ),
                    ],
                  ),
                ),
              ),

              // Body
              Expanded(
                child: notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
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
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          final notificationId = notification['id'] as String;
                          final title = notification['title'] as String? ?? 'Notification';
                          final message = notification['message'] as String? ?? '';
                          final type = notification['type'] as String? ?? 'general';
                          final isRead = notification['isRead'] as bool? ?? false;
                          final createdAt = (notification['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

                          return Dismissible(
                            key: Key(notificationId),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {
                              _deleteNotification(notificationId);
                            },
                            background: Container(
                              margin: const EdgeInsets.only(bottom: AppSpacing.md),
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              ),
                              alignment: Alignment.centerRight,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            child: InkWell(
                              onTap: () => _markAsRead(notificationId, isRead),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                decoration: BoxDecoration(
                                  color: isRead 
                                      ? AppColors.cardBackground 
                                      : AppColors.tealAccent.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                  border: Border.all(
                                    color: isRead 
                                        ? Colors.transparent 
                                        : AppColors.tealAccent.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                  boxShadow: isRead
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: AppColors.tealAccent.withValues(alpha: 0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(AppSpacing.sm),
                                      decoration: BoxDecoration(
                                        color: _getColorForType(type).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                      ),
                                      child: Icon(
                                        _getIconForType(type),
                                        color: _getColorForType(type),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  title,
                                                  style: AppTextStyles.h4.copyWith(
                                                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              if (!isRead)
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
                                            message,
                                            style: AppTextStyles.bodyMedium.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: AppSpacing.sm),
                                          Text(
                                            _getTimeAgo(createdAt),
                                            style: AppTextStyles.bodySmall.copyWith(
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
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
