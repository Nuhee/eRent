import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:erent_mobile/model/rent.dart';
import 'package:erent_mobile/model/viewing_appointment.dart';
import 'package:erent_mobile/providers/rent_provider.dart';
import 'package:erent_mobile/providers/viewing_appointment_provider.dart';
import 'package:erent_mobile/providers/user_provider.dart';
import 'package:erent_mobile/screens/rent_details_screen.dart';
import 'package:provider/provider.dart';

class RentsListScreen extends StatefulWidget {
  const RentsListScreen({super.key});

  @override
  State<RentsListScreen> createState() => _RentsListScreenState();
}

class _RentsListScreenState extends State<RentsListScreen>
    with WidgetsBindingObserver {
  late RentProvider rentProvider;
  late ViewingAppointmentProvider viewingProvider;

  List<Rent> _rents = [];
  List<ViewingAppointment> _viewings = [];
  bool _isLoadingRents = true;
  bool _isLoadingViewings = true;
  int? _selectedStatusFilter;
  int _selectedTab = 0; // 0 = Rentals, 1 = Viewings

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    rentProvider = Provider.of<RentProvider>(context, listen: false);
    viewingProvider =
        Provider.of<ViewingAppointmentProvider>(context, listen: false);
    _loadRents();
    _loadViewings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadRents();
      _loadViewings();
    }
  }

  Future<void> _loadRents() async {
    setState(() => _isLoadingRents = true);

    try {
      final user = UserProvider.currentUser;
      if (user == null) {
        setState(() {
          _rents = [];
          _isLoadingRents = false;
        });
        return;
      }

      final filter = <String, dynamic>{
        'userId': user.id,
        'isActive': true,
        'retrieveAll': true,
      };

      if (_selectedTab == 0 && _selectedStatusFilter != null) {
        filter['rentStatusId'] = _selectedStatusFilter;
      }

      final result = await rentProvider.get(filter: filter);

      if (mounted) {
        setState(() {
          _rents = result.items ?? [];
          _isLoadingRents = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRents = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading rents: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadViewings() async {
    setState(() => _isLoadingViewings = true);

    try {
      final user = UserProvider.currentUser;
      if (user == null) {
        setState(() {
          _viewings = [];
          _isLoadingViewings = false;
        });
        return;
      }

      final filter = <String, dynamic>{
        'tenantId': user.id,
        'retrieveAll': true,
      };

      if (_selectedTab == 1 && _selectedStatusFilter != null) {
        filter['status'] = _selectedStatusFilter;
      }

      final result = await viewingProvider.get(filter: filter);

      if (mounted) {
        setState(() {
          _viewings = result.items ?? [];
          _isLoadingViewings = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingViewings = false);
      }
    }
  }

  Color _getRentStatusColor(String statusName) {
    switch (statusName.toLowerCase()) {
      case 'pending':
        return const Color(0xFFFFB84D);
      case 'accepted':
        return Colors.green;
      case 'paid':
        return const Color(0xFF5B9BD5);
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _getViewingStatusColor(int status) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      _selectedTab == 0 ? 'My Bookings' : 'My Viewings',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded,
                          color: Color(0xFF5B9BD5)),
                      onPressed: () {
                        if (_selectedTab == 0) {
                          _loadRents();
                        } else {
                          _loadViewings();
                        }
                      },
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Tab Selector
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTab = 0;
                              _selectedStatusFilter = null;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedTab == 0
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: _selectedTab == 0
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.home_work_rounded,
                                  size: 16,
                                  color: _selectedTab == 0
                                      ? const Color(0xFF5B9BD5)
                                      : Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Rentals',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: _selectedTab == 0
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: _selectedTab == 0
                                        ? const Color(0xFF5B9BD5)
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTab = 1;
                              _selectedStatusFilter = null;
                            });
                            _loadViewings();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _selectedTab == 1
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: _selectedTab == 1
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 16,
                                  color: _selectedTab == 1
                                      ? const Color(0xFF5B9BD5)
                                      : Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Viewings',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: _selectedTab == 1
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: _selectedTab == 1
                                        ? const Color(0xFF5B9BD5)
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Status Filter
                if (_selectedTab == 0)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStatusChip('All', null),
                        const SizedBox(width: 8),
                        _buildStatusChip('Pending', 1),
                        const SizedBox(width: 8),
                        _buildStatusChip('Accepted', 4),
                        const SizedBox(width: 8),
                        _buildStatusChip('Paid', 5),
                        const SizedBox(width: 8),
                        _buildStatusChip('Rejected', 3),
                        const SizedBox(width: 8),
                        _buildStatusChip('Cancelled', 2),
                      ],
                    ),
                  ),
                if (_selectedTab == 1)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildViewingStatusChip('All', null),
                        const SizedBox(width: 8),
                        _buildViewingStatusChip('Pending', 0),
                        const SizedBox(width: 8),
                        _buildViewingStatusChip('Approved', 1),
                        const SizedBox(width: 8),
                        _buildViewingStatusChip('Rejected', 2),
                        const SizedBox(width: 8),
                        _buildViewingStatusChip('Cancelled', 3),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _selectedTab == 0
                ? _buildRentsList()
                : _buildViewingsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRentsList() {
    if (_isLoadingRents) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B9BD5)),
        ),
      );
    }

    if (_rents.isEmpty) {
      return _buildEmptyState(
        icon: Icons.home_work_outlined,
        title: 'No Bookings Found',
        subtitle: 'You haven\'t made any booking requests yet.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRents,
      color: const Color(0xFF5B9BD5),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _rents.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildRentCard(_rents[index]);
        },
      ),
    );
  }

  Widget _buildViewingsList() {
    if (_isLoadingViewings) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B9BD5)),
        ),
      );
    }

    if (_viewings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.calendar_today_outlined,
        title: 'No Viewings Found',
        subtitle: 'You haven\'t scheduled any property viewings yet.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadViewings,
      color: const Color(0xFF5B9BD5),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _viewings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildViewingCard(_viewings[index]);
        },
      ),
    );
  }

  Widget _buildStatusChip(String label, int? statusId) {
    final isSelected = _selectedStatusFilter == statusId;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatusFilter = selected ? statusId : null;
        });
        _loadRents();
      },
      selectedColor: const Color(0xFF5B9BD5).withOpacity(0.2),
      checkmarkColor: const Color(0xFF5B9BD5),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF5B9BD5) : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFF5B9BD5) : Colors.grey[300]!,
        width: isSelected ? 1.5 : 1,
      ),
    );
  }

  Widget _buildViewingStatusChip(String label, int? status) {
    final isSelected = _selectedStatusFilter == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatusFilter = selected ? status : null;
        });
        _loadViewings();
      },
      selectedColor: const Color(0xFF5B9BD5).withOpacity(0.2),
      checkmarkColor: const Color(0xFF5B9BD5),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF5B9BD5) : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFF5B9BD5) : Colors.grey[300]!,
        width: isSelected ? 1.5 : 1,
      ),
    );
  }

  Widget _buildRentCard(Rent rent) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RentDetailsScreen(rentId: rent.id),
            ),
          ).then((_) => _loadRents());
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rent.propertyTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Request #${rent.id}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _getRentStatusColor(rent.rentStatusName)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getRentStatusColor(rent.rentStatusName)
                            .withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      rent.rentStatusName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getRentStatusColor(rent.rentStatusName),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    '${DateFormat('MMM dd, yyyy').format(rent.startDate)} - ${DateFormat('MMM dd, yyyy').format(rent.endDate)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.attach_money_rounded,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    '\u20AC${rent.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5B9BD5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    rent.isDailyRental ? '(Daily)' : '(Monthly)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
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

  Widget _buildViewingCard(ViewingAppointment viewing) {
    final statusColor = _getViewingStatusColor(viewing.status);
    final canCancel = viewing.status == 0 || viewing.status == 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property title and status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  viewing.propertyTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  viewing.statusName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Date and time
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B9BD5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: Color(0xFF5B9BD5),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEEE, MMM d, y')
                        .format(viewing.appointmentDate),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${DateFormat('HH:mm').format(viewing.appointmentDate)} - ${DateFormat('HH:mm').format(viewing.endTime)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Address
          if (viewing.propertyAddress.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 16, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    viewing.propertyAddress,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          // Tenant note
          if (viewing.tenantNote != null &&
              viewing.tenantNote!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note_outlined, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      viewing.tenantNote!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Landlord note
          if (viewing.landlordNote != null &&
              viewing.landlordNote!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: statusColor.withOpacity(0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.reply_rounded, size: 14, color: statusColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Landlord: ${viewing.landlordNote!}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Cancel button
          if (canCancel) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _cancelViewing(viewing),
                icon: const Icon(Icons.cancel_outlined,
                    size: 16, color: Colors.red),
                label: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.red, width: 0.5),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _cancelViewing(ViewingAppointment viewing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Viewing'),
        content: Text(
            'Are you sure you want to cancel the viewing for "${viewing.propertyTitle}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await viewingProvider.cancel(viewing.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Viewing cancelled successfully'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
          _loadViewings();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to cancel: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF5B9BD5).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: const Color(0xFF5B9BD5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
