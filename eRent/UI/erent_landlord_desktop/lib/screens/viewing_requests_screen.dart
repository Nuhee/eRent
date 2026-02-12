import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:erent_landlord_desktop/layouts/master_screen.dart';
import 'package:erent_landlord_desktop/model/viewing_appointment.dart';
import 'package:erent_landlord_desktop/model/search_result.dart';
import 'package:erent_landlord_desktop/providers/viewing_appointment_provider.dart';
import 'package:erent_landlord_desktop/providers/user_provider.dart';
import 'package:erent_landlord_desktop/utils/base_pagination.dart';
import 'package:provider/provider.dart';

class ViewingRequestsScreen extends StatefulWidget {
  const ViewingRequestsScreen({super.key});

  @override
  State<ViewingRequestsScreen> createState() => _ViewingRequestsScreenState();
}

class _ViewingRequestsScreenState extends State<ViewingRequestsScreen> {
  late ViewingAppointmentProvider viewingProvider;

  SearchResult<ViewingAppointment>? _result;
  int _currentPage = 0;
  int _pageSize = 10;
  final List<int> _pageSizeOptions = [5, 10, 20, 50];
  bool _isLoading = false;
  int? _selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      viewingProvider = context.read<ViewingAppointmentProvider>();
      await _loadData();
    });
  }

  Future<void> _loadData({int? page, int? pageSize}) async {
    setState(() => _isLoading = true);

    final landlordId = UserProvider.currentUser?.id;
    if (landlordId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final pageToFetch = page ?? _currentPage;
    final pageSizeToUse = pageSize ?? _pageSize;

    final filter = <String, dynamic>{
      'landlordId': landlordId,
      'page': pageToFetch,
      'pageSize': pageSizeToUse,
      'includeTotalCount': true,
    };

    if (_selectedStatus != null) {
      filter['status'] = _selectedStatus;
    }

    try {
      final result = await viewingProvider.get(filter: filter);
      if (mounted) {
        setState(() {
          _result = result;
          _currentPage = pageToFetch;
          if (pageSize != null) _pageSize = pageSize;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading viewing requests: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 0:
        return const Color(0xFFFFB84D); // Pending
      case 1:
        return const Color(0xFF4CAF50); // Approved
      case 2:
        return Colors.red; // Rejected
      case 3:
        return Colors.grey; // Cancelled
      case 4:
        return const Color(0xFF5B9BD5); // Completed
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(int status) {
    switch (status) {
      case 0:
        return Icons.schedule_rounded;
      case 1:
        return Icons.check_circle_rounded;
      case 2:
        return Icons.cancel_rounded;
      case 3:
        return Icons.block_rounded;
      case 4:
        return Icons.task_alt_rounded;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Viewing Requests',
      child: Column(
        children: [
          _buildFilters(),
          const SizedBox(height: 16),
          _buildStats(),
          const SizedBox(height: 16),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
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
      child: Row(
        children: [
          const Icon(Icons.filter_list_rounded,
              color: Color(0xFFFFB84D), size: 20),
          const SizedBox(width: 12),
          const Text(
            'Filter by Status:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(width: 16),
          _buildFilterChip('All', null),
          const SizedBox(width: 8),
          _buildFilterChip('Pending', 0),
          const SizedBox(width: 8),
          _buildFilterChip('Approved', 1),
          const SizedBox(width: 8),
          _buildFilterChip('Rejected', 2),
          const SizedBox(width: 8),
          _buildFilterChip('Cancelled', 3),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFFFFB84D)),
            onPressed: () => _loadData(page: 0),
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int? status) {
    final isSelected = _selectedStatus == status;
    final color = status != null ? _getStatusColor(status) : const Color(0xFFFFB84D);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = selected ? status : null;
        });
        _loadData(page: 0);
      },
      selectedColor: color.withOpacity(0.15),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        fontSize: 13,
      ),
      side: BorderSide(
        color: isSelected ? color : Colors.grey[300]!,
        width: isSelected ? 1.5 : 1,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildStats() {
    final items = _result?.items ?? [];
    final pendingCount = items.where((v) => v.status == 0).length;
    final approvedCount = items.where((v) => v.status == 1).length;
    final totalCount = _result?.totalCount ?? items.length;

    return Row(
      children: [
        _buildStatCard(
          'Total Requests',
          totalCount.toString(),
          Icons.calendar_view_month_rounded,
          const Color(0xFFFFB84D),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Pending',
          pendingCount.toString(),
          Icons.schedule_rounded,
          const Color(0xFFFFB84D),
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Approved',
          approvedCount.toString(),
          Icons.check_circle_rounded,
          const Color(0xFF4CAF50),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB84D)),
        ),
      );
    }

    final items = _result?.items ?? [];

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB84D).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                size: 48,
                color: Color(0xFFFFB84D),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Viewing Requests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No viewing requests have been submitted for your properties yet.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Container(
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Table header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        _tableHeader('Property', flex: 3),
                        _tableHeader('Tenant', flex: 2),
                        _tableHeader('Date & Time', flex: 3),
                        _tableHeader('Status', flex: 2),
                        _tableHeader('Actions', flex: 3),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  ...items.map((v) => _buildRow(v)),
                ],
              ),
            ),
          ),
          // Pagination
          Builder(
            builder: (context) {
              final totalCount = _result?.totalCount ?? 0;
              final totalPages = totalCount > 0 ? (totalCount / _pageSize).ceil() : 1;
              final isFirstPage = _currentPage == 0;
              final isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
                ),
                child: BasePagination(
                  currentPage: _currentPage,
                  totalPages: totalPages,
                  onPrevious: isFirstPage
                      ? null
                      : () => _loadData(page: _currentPage - 1),
                  onNext: isLastPage
                      ? null
                      : () => _loadData(page: _currentPage + 1),
                  showPageSizeSelector: true,
                  pageSize: _pageSize,
                  pageSizeOptions: _pageSizeOptions,
                  onPageSizeChanged: (newSize) {
                    if (newSize != null && newSize != _pageSize) {
                      _loadData(page: 0, pageSize: newSize);
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.grey[700],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildRow(ViewingAppointment viewing) {
    final statusColor = _getStatusColor(viewing.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
      ),
      child: Row(
        children: [
          // Property
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  viewing.propertyTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (viewing.propertyAddress.isNotEmpty)
                  Text(
                    viewing.propertyAddress,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          // Tenant
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFFFFB84D).withOpacity(0.15),
                  child: Text(
                    viewing.tenantName.isNotEmpty
                        ? viewing.tenantName[0].toUpperCase()
                        : 'T',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFB84D),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    viewing.tenantName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Date & Time
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEE, MMM d, y')
                      .format(viewing.appointmentDate),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  '${DateFormat('HH:mm').format(viewing.appointmentDate)} - ${DateFormat('HH:mm').format(viewing.endTime)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                if (viewing.tenantNote != null && viewing.tenantNote!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.note_outlined,
                            size: 12, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            viewing.tenantNote!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Status
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getStatusIcon(viewing.status),
                          size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        viewing.statusName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Expanded(
            flex: 3,
            child: viewing.status == 0
                ? Row(
                    children: [
                      _actionButton(
                        label: 'Approve',
                        icon: Icons.check_rounded,
                        color: const Color(0xFF4CAF50),
                        onTap: () => _handleApprove(viewing),
                      ),
                      const SizedBox(width: 8),
                      _actionButton(
                        label: 'Reject',
                        icon: Icons.close_rounded,
                        color: Colors.red,
                        onTap: () => _handleReject(viewing),
                      ),
                    ],
                  )
                : viewing.landlordNote != null &&
                        viewing.landlordNote!.isNotEmpty
                    ? Row(
                        children: [
                          Icon(Icons.reply_rounded,
                              size: 14, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              viewing.landlordNote!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        '\u2014',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleApprove(ViewingAppointment viewing) async {
    final noteController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF4CAF50), size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              'Approve Viewing',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Approve viewing for "${viewing.propertyTitle}" by ${viewing.tenantName}?',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              '${DateFormat('EEE, MMM d, y').format(viewing.appointmentDate)} \u2022 ${DateFormat('HH:mm').format(viewing.appointmentDate)} - ${DateFormat('HH:mm').format(viewing.endTime)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5B9BD5),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Add a note (optional)',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.check_rounded, size: 16),
            label: const Text('Approve'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await viewingProvider.approve(viewing.id,
            landlordNote: noteController.text.trim().isNotEmpty
                ? noteController.text.trim()
                : null);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Viewing approved successfully!'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to approve: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleReject(ViewingAppointment viewing) async {
    final noteController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.cancel_rounded,
                  color: Colors.red, size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              'Reject Viewing',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reject viewing for "${viewing.propertyTitle}" by ${viewing.tenantName}?',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Reason for rejection (optional)',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.close_rounded, size: 16),
            label: const Text('Reject'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await viewingProvider.reject(viewing.id,
            landlordNote: noteController.text.trim().isNotEmpty
                ? noteController.text.trim()
                : null);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Viewing rejected.'),
              backgroundColor: Colors.orange,
            ),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reject: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
