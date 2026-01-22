import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:erent_mobile/model/rent.dart';
import 'package:erent_mobile/providers/rent_provider.dart';
import 'package:erent_mobile/providers/user_provider.dart';
import 'package:erent_mobile/screens/rent_details_screen.dart';
import 'package:provider/provider.dart';

class RentsListScreen extends StatefulWidget {
  const RentsListScreen({super.key});

  @override
  State<RentsListScreen> createState() => _RentsListScreenState();
}

class _RentsListScreenState extends State<RentsListScreen> with WidgetsBindingObserver {
  late RentProvider rentProvider;
  List<Rent> _rents = [];
  bool _isLoading = true;
  int? _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    rentProvider = Provider.of<RentProvider>(context, listen: false);
    _loadRents();
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
    }
  }

  Future<void> _loadRents() async {
    setState(() => _isLoading = true);

    try {
      final user = UserProvider.currentUser;
      if (user == null) {
        setState(() {
          _rents = [];
          _isLoading = false;
        });
        return;
      }

      final filter = <String, dynamic>{
        'userId': user.id,
        'isActive': true,
        'retrieveAll': true,
      };

      if (_selectedStatusFilter != null) {
        filter['rentStatusId'] = _selectedStatusFilter;
      }

      final result = await rentProvider.get(filter: filter);

      if (mounted) {
        setState(() {
          _rents = result.items ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading rents: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String statusName) {
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
                    const Text(
                      'My Bookings',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Color(0xFF5B9BD5)),
                      onPressed: _loadRents,
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Status Filter
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
              ],
            ),
          ),
          // Rents List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B9BD5)),
                    ),
                  )
                : _rents.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
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
                      ),
          ),
        ],
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
              // Property Title - Full width
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
              // Request ID and Status Tag in a Row
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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _getStatusColor(rent.rentStatusName).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getStatusColor(rent.rentStatusName).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      rent.rentStatusName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(rent.rentStatusName),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey[600]),
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
                  Icon(Icons.attach_money_rounded, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    '€${rent.totalPrice.toStringAsFixed(2)}',
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

  Widget _buildEmptyState() {
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
              child: const Icon(
                Icons.home_work_outlined,
                size: 64,
                color: Color(0xFF5B9BD5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Bookings Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You haven\'t made any booking requests yet.',
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
