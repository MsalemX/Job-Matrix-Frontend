import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../models/notification_model.dart';
import '../../providers/language_provider.dart';

class NotificationsDialog extends StatefulWidget {
  const NotificationsDialog({super.key});

  @override
  State<NotificationsDialog> createState() => _NotificationsDialogState();
}

class _NotificationsDialogState extends State<NotificationsDialog> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final notifications = await ApiService.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    // Optimistic Update: instantly update UI
    setState(() {
      _notifications = _notifications.map((n) {
        if (n.id == notification.id) {
          return NotificationModel(
            id: n.id,
            userId: n.userId,
            title: n.title,
            content: n.content,
            type: n.type,
            isRead: true,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();
    });

    final success = await ApiService.markNotificationAsRead(notification.id);
    if (!success && mounted) {
      // Revert if API call fails
      setState(() {
        _notifications = _notifications.map((n) {
          if (n.id == notification.id) {
            return NotificationModel(
              id: n.id,
              userId: n.userId,
              title: n.title,
              content: n.content,
              type: n.type,
              isRead: false,
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList();
      });
    }
  }

  Future<void> _markAllAsRead() async {
    // Save original state for reversion if needed
    final originalNotifications = List<NotificationModel>.from(_notifications);

    // Optimistic Update: instantly update UI
    setState(() {
      _notifications = _notifications.map((n) {
        return NotificationModel(
          id: n.id,
          userId: n.userId,
          title: n.title,
          content: n.content,
          type: n.type,
          isRead: true,
          createdAt: n.createdAt,
        );
      }).toList();
    });

    final success = await ApiService.markAllNotificationsAsRead();
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<LanguageProvider>(context, listen: false).isArabic
                  ? 'تم تحديد جميع الإشعارات كمقروءة'
                  : 'All notifications marked as read',
            ),
          ),
        );
      }
    } else {
      // Revert if API call fails
      if (mounted) {
        setState(() {
          _notifications = originalNotifications;
        });
      }
    }
  }

  Future<void> _deleteNotification(int id) async {
    final success = await ApiService.deleteNotification(id);
    if (success && mounted) {
      setState(() {
        _notifications.removeWhere((n) => n.id == id);
      });
    }
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'join_request':
        return Icons.person_add_alt_1_rounded;
      case 'request_approved':
        return Icons.check_circle_outline_rounded;
      case 'request_rejected':
        return Icons.highlight_off_rounded;
      case 'project_added':
        return Icons.group_add_rounded;
      case 'project_joined':
        return Icons.group_rounded;
      case 'task_assigned':
        return Icons.assignment_turned_in_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'join_request':
        return Colors.blue;
      case 'request_approved':
        return Colors.green;
      case 'request_rejected':
        return Colors.red;
      case 'project_added':
        return Colors.purple;
      case 'project_joined':
        return Colors.teal;
      case 'task_assigned':
        return Colors.orange;
      default:
        return const Color(0xFF23393E);
    }
  }

  String _formatTime(DateTime? date, bool isArabic) {
    if (date == null) return '';
    final difference = DateTime.now().difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays >= 1) {
      return isArabic
          ? 'قبل ${difference.inDays} يوم'
          : '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return isArabic
          ? 'قبل ${difference.inHours} ساعة'
          : '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return isArabic
          ? 'قبل ${difference.inMinutes} دقيقة'
          : '${difference.inMinutes}m ago';
    } else {
      return isArabic ? 'الآن' : 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    final isAr = lang.isArabic;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: Container(
        width: 450,
        height: 550,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Dialog Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications_outlined, color: Colors.grey.shade700, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      isAr ? 'الإشعارات' : 'Notifications',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (_notifications.any((n) => !n.isRead))
                      TextButton.icon(
                        onPressed: _markAllAsRead,
                        icon: const Icon(Icons.done_all, size: 16),
                        label: Text(
                          isAr ? 'تحديد الكل كمقروء' : 'Mark all read',
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF23393E),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),

            // Notification List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF23393E)),
                      ),
                    )
                  : _notifications.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.notifications_none_rounded,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isAr ? 'لا توجد إشعارات حالياً' : 'No notifications yet',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: _notifications.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final notification = _notifications[index];
                            final icon = _getIconForType(notification.type);
                            final color = _getColorForType(notification.type);

                            return InkWell(
                              onTap: () {
                                if (!notification.isRead) {
                                  _markAsRead(notification);
                                }
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                color: notification.isRead
                                    ? Colors.transparent
                                    : Colors.blue.withOpacity(0.04),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Notification Icon with badge indicating read state
                                    Stack(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(icon, color: color, size: 20),
                                        ),
                                        if (!notification.isRead)
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),

                                    // Content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            notification.title,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: notification.isRead
                                                  ? FontWeight.w600
                                                  : FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            notification.content,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            _formatTime(notification.createdAt, isAr),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                          if (notification.type.startsWith('project_invited_')) ...[
                                            const SizedBox(height: 8),
                                            ElevatedButton(
                                              onPressed: () {
                                                final projectIdStr = notification.type.replaceFirst('project_invited_', '');
                                                final projectId = int.tryParse(projectIdStr);
                                                if (projectId != null) {
                                                  Navigator.of(context).pop();
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/project_details',
                                                    arguments: projectId,
                                                  );
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF23393E),
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                                minimumSize: const Size(0, 24),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                              ),
                                              child: Text(
                                                isAr ? 'عرض المشروع' : 'View Project',
                                                style: const TextStyle(fontSize: 10),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // Actions: Mark as Read & Delete
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (!notification.isRead)
                                          IconButton(
                                            icon: const Icon(Icons.mark_email_read_outlined, size: 16),
                                            color: const Color(0xFF23393E),
                                            tooltip: isAr ? 'تحديد كمقروء' : 'Mark as read',
                                            onPressed: () => _markAsRead(notification),
                                            splashRadius: 16,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        const SizedBox(height: 8),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline_rounded, size: 16),
                                          color: Colors.red.shade300,
                                          tooltip: isAr ? 'حذف الإشعار' : 'Delete',
                                          onPressed: () => _deleteNotification(notification.id),
                                          splashRadius: 16,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

void showNotificationsDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => const NotificationsDialog(),
  );
}
