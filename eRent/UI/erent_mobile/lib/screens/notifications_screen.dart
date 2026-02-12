import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:erent_mobile/model/notification.dart';
import 'package:erent_mobile/providers/notification_provider.dart';
import 'package:erent_mobile/providers/user_provider.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late NotificationProvider _provider;
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  int _unreadCount = 0;

  static const Color primaryColor = Color(0xFF5B9BD5);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textMuted = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<NotificationProvider>(context, listen: false);
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final user = UserProvider.currentUser;
      if (user == null) {
        setState(() {
          _notifications = [];
          _isLoading = false;
        });
        return;
      }

      final result = await _provider.get(filter: {
        'userId': user.id,
        'pageSize': 100,
        'includeTotalCount': true,
      });

      final count = await _provider.getUnreadCount(user.id);

      if (mounted) {
        setState(() {
          _notifications = result.items ?? [];
          _unreadCount = count;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _markAsRead(AppNotification notification) async {
    if (notification.isRead) return;
    await _provider.markAsRead(notification.id);
    _loadNotifications();
  }

  Future<void> _markAllAsRead() async {
    final user = UserProvider.currentUser;
    if (user == null) return;
    await _provider.markAllAsRead(user.id);
    _loadNotifications();
  }

  IconData _getTypeIcon(int type) {
    switch (type) {
      case 0: return Icons.add_home_rounded; // RentCreated
      case 1: return Icons.check_circle_rounded; // RentAccepted
      case 2: return Icons.cancel_rounded; // RentRejected
      case 3: return Icons.block_rounded; // RentCancelled
      case 4: return Icons.payment_rounded; // RentPaid
      case 5: return Icons.visibility_rounded; // ViewingCreated
      case 6: return Icons.thumb_up_rounded; // ViewingApproved
      case 7: return Icons.thumb_down_rounded; // ViewingRejected
      case 8: return Icons.event_busy_rounded; // ViewingCancelled
      default: return Icons.notifications_rounded;
    }
  }

  Color _getTypeColor(int type) {
    switch (type) {
      case 0: return const Color(0xFF5B9BD5); // Blue
      case 1: return const Color(0xFF4CAF50); // Green
      case 2: return const Color(0xFFE53E3E); // Red
      case 3: return Colors.grey; // Grey
      case 4: return const Color(0xFF4CAF50); // Green
      case 5: return const Color(0xFF8B5CF6); // Purple
      case 6: return const Color(0xFF4CAF50); // Green
      case 7: return const Color(0xFFE53E3E); // Red
      case 8: return Colors.grey; // Grey
      default: return primaryColor;
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: const Text('Read All'),
              style: TextButton.styleFrom(foregroundColor: primaryColor),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  color: primaryColor,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(_notifications[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    final typeColor = _getTypeColor(notification.type);
    final isUnread = !notification.isRead;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: isUnread ? primaryColor.withOpacity(0.04) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _markAsRead(notification),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUnread ? primaryColor.withOpacity(0.15) : Colors.grey[100]!,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTypeIcon(notification.type),
                    color: typeColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
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
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                                color: textDark,
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 13,
                          color: isUnread ? textDark.withOpacity(0.7) : textMuted,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              notification.typeName,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: typeColor,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.access_time_rounded, size: 12, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(
                            _getTimeAgo(notification.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  size: 42,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Notifications',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You\'re all caught up!\nNotifications about your rents and\nviewings will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
