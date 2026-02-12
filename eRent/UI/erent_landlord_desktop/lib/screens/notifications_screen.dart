import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:erent_landlord_desktop/model/notification.dart';
import 'package:erent_landlord_desktop/providers/notification_provider.dart';
import 'package:erent_landlord_desktop/providers/user_provider.dart';
import 'package:erent_landlord_desktop/layouts/master_screen.dart';
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
  String _selectedFilter = 'all'; // all, unread, rent, viewing

  static const Color accentColor = Color(0xFFFFB84D);
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

      final filter = <String, dynamic>{
        'userId': user.id,
        'pageSize': 200,
        'includeTotalCount': true,
      };

      if (_selectedFilter == 'unread') {
        filter['isRead'] = false;
      } else if (_selectedFilter == 'rent') {
        filter['referenceType'] = 'Rent';
      } else if (_selectedFilter == 'viewing') {
        filter['referenceType'] = 'ViewingAppointment';
      }

      final result = await _provider.get(filter: filter);
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
      case 0: return Icons.add_home_rounded;
      case 1: return Icons.check_circle_rounded;
      case 2: return Icons.cancel_rounded;
      case 3: return Icons.block_rounded;
      case 4: return Icons.payment_rounded;
      case 5: return Icons.visibility_rounded;
      case 6: return Icons.thumb_up_rounded;
      case 7: return Icons.thumb_down_rounded;
      case 8: return Icons.event_busy_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getTypeColor(int type) {
    switch (type) {
      case 0: return const Color(0xFF5B9BD5);
      case 1: return const Color(0xFF4CAF50);
      case 2: return const Color(0xFFE53E3E);
      case 3: return Colors.grey;
      case 4: return const Color(0xFF4CAF50);
      case 5: return const Color(0xFF8B5CF6);
      case 6: return const Color(0xFF4CAF50);
      case 7: return const Color(0xFFE53E3E);
      case 8: return Colors.grey;
      default: return accentColor;
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
    return MasterScreen(
      title: 'Notifications',
      child: Column(
        children: [
          // Header bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.notifications_rounded, color: accentColor, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notifications',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark),
                        ),
                        Text(
                          '$_unreadCount unread notification${_unreadCount == 1 ? '' : 's'}',
                          style: const TextStyle(fontSize: 13, color: textMuted),
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (_unreadCount > 0)
                      ElevatedButton.icon(
                        onPressed: _markAllAsRead,
                        icon: const Icon(Icons.done_all_rounded, size: 18),
                        label: const Text('Mark All Read'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: accentColor),
                      onPressed: _loadNotifications,
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Filters
                Row(
                  children: [
                    _buildFilterChip('All', 'all', Icons.list_rounded),
                    const SizedBox(width: 8),
                    _buildFilterChip('Unread', 'unread', Icons.circle_notifications_rounded),
                    const SizedBox(width: 8),
                    _buildFilterChip('Rents', 'rent', Icons.home_work_rounded),
                    const SizedBox(width: 8),
                    _buildFilterChip('Viewings', 'viewing', Icons.visibility_rounded),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: accentColor))
                : _notifications.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          return _buildNotificationTile(_notifications[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _selectedFilter == value;
    return InkWell(
      onTap: () {
        setState(() => _selectedFilter = value);
        _loadNotifications();
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentColor : Colors.grey[300]!,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: isSelected ? accentColor : textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? accentColor : textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationTile(AppNotification notification) {
    final typeColor = _getTypeColor(notification.type);
    final isUnread = !notification.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isUnread ? accentColor.withOpacity(0.04) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () => _markAsRead(notification),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isUnread ? accentColor.withOpacity(0.15) : Colors.grey[100]!,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getTypeIcon(notification.type), color: typeColor, size: 22),
                ),
                const SizedBox(width: 14),
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
                          Text(
                            _getTimeAgo(notification.createdAt),
                            style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
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
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          notification.typeName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: typeColor,
                          ),
                        ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_rounded, size: 42, color: accentColor),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Notifications',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!\nNotifications about your properties\nwill appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500], height: 1.5),
          ),
        ],
      ),
    );
  }
}
