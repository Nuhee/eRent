import 'package:flutter/material.dart';
import 'package:erent_landlord_desktop/layouts/master_screen.dart';
import 'package:erent_landlord_desktop/model/rent.dart';
import 'package:erent_landlord_desktop/model/search_result.dart';
import 'package:erent_landlord_desktop/providers/rent_provider.dart';
import 'package:erent_landlord_desktop/providers/user_provider.dart';
import 'package:erent_landlord_desktop/screens/rent_details_screen.dart';
import 'package:erent_landlord_desktop/utils/base_pagination.dart';
import 'package:erent_landlord_desktop/utils/base_table.dart';
import 'package:erent_landlord_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';

class RentListScreen extends StatefulWidget {
  const RentListScreen({super.key});

  @override
  State<RentListScreen> createState() => _RentListScreenState();
}

class _RentListScreenState extends State<RentListScreen> {
  late RentProvider rentProvider;

  final TextEditingController propertyTitleController = TextEditingController();
  int? selectedRentStatusId;

  SearchResult<Rent>? rents;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 10, 20, 50];
  bool _isLoading = false;

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;

    // Get landlord's rents by filtering by landlordId
    final landlordId = UserProvider.currentUser?.id;
    if (landlordId == null) return;

    final filter = {
      if (propertyTitleController.text.isNotEmpty)
        'propertyTitle': propertyTitleController.text,
      if (selectedRentStatusId != null) 'rentStatusId': selectedRentStatusId,
      'landlordId': landlordId, // Filter by landlord's properties
      'page': pageToFetch,
      'pageSize': pageSizeToUse,
      'includeTotalCount': true,
    };

    final result = await rentProvider.get(filter: filter);
    setState(() {
      rents = result;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      rentProvider = context.read<RentProvider>();
      await _performSearch(page: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'My Rent Requests',
      child: Center(
        child: Column(
          children: [
            _buildSearch(),
            Expanded(child: _buildResultView()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: customTextFieldDecoration(
                'Property Title',
                prefixIcon: Icons.home_outlined,
              ),
              controller: propertyTitleController,
              onSubmitted: (_) => _performSearch(page: 0),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonFormField<int?>(
              decoration: customTextFieldDecoration(
                'Rent Status',
                prefixIcon: Icons.verified_outlined,
              ),
              value: selectedRentStatusId,
              items: const [
                DropdownMenuItem<int?>(value: null, child: Text('All Statuses')),
                DropdownMenuItem<int>(value: 1, child: Text('Pending')),
                DropdownMenuItem<int>(value: 2, child: Text('Cancelled')),
                DropdownMenuItem<int>(value: 3, child: Text('Rejected')),
                DropdownMenuItem<int>(value: 4, child: Text('Accepted')),
                DropdownMenuItem<int>(value: 5, child: Text('Paid')),
              ],
              onChanged: (int? value) {
                setState(() {
                  selectedRentStatusId = value;
                });
                _performSearch(page: 0);
              },
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _performSearch(page: 0),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[800],
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_rounded, size: 18),
                SizedBox(width: 8),
                Text(
                  "Search",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              propertyTitleController.clear();
              setState(() {
                selectedRentStatusId = null;
              });
              _performSearch(page: 0);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              foregroundColor: const Color(0xFF2D2D2D),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.clear_rounded, size: 18),
                SizedBox(width: 8),
                Text(
                  "Clear",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final isEmpty =
        rents == null || rents!.items == null || rents!.items!.isEmpty;
    final int totalCount = rents?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              BaseTable(
                icon: Icons.receipt_long_outlined,
                title: 'Rent Requests',
                width: 1400,
                height: 423,
                columnWidths: const [
                  180, // Property Title
                  140, // Tenant Name
                  120, // Start Date
                  120, // End Date
                  95, // Rental Type
                  130, // Total Price
                  120, // Rent Status
                  220, // Actions
                ],
                columns: const [
                  DataColumn(
                    label: Text(
                      'Property',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Tenant',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Start',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'End',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Type',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Price',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Status',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Actions',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ],
                rows: isEmpty
                    ? []
                    : rents!.items!
                        .map(
                          (e) => DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  e.propertyTitle.isNotEmpty
                                      ? e.propertyTitle
                                      : 'N/A',
                                  style: const TextStyle(fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DataCell(
                                Text(
                                  e.userName.isNotEmpty ? e.userName : 'N/A',
                                  style: const TextStyle(fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DataCell(
                                Text(
                                  _formatDate(e.startDate),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              DataCell(
                                Text(
                                  _formatDate(e.endDate),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              DataCell(
                                _buildRentalTypeBadge(e.isDailyRental),
                              ),
                              DataCell(
                                Text(
                                  '€${e.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                              ),
                              DataCell(
                                _buildRentStatusBadge(e.rentStatusName),
                              ),
                              DataCell(
                                _buildActionButtons(e),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                emptyIcon: Icons.receipt_long,
                emptyText: 'No rent requests found.',
                emptySubtext: 'Rent requests from tenants will appear here.',
              ),
              const SizedBox(height: 30),
              BasePagination(
                currentPage: _currentPage,
                totalPages: totalPages,
                onPrevious: isFirstPage
                    ? null
                    : () => _performSearch(page: _currentPage - 1),
                onNext: isLastPage
                    ? null
                    : () => _performSearch(page: _currentPage + 1),
                showPageSizeSelector: true,
                pageSize: _pageSize,
                pageSizeOptions: _pageSizeOptions,
                onPageSizeChanged: (newSize) {
                  if (newSize != null && newSize != _pageSize) {
                    _performSearch(page: 0, pageSize: newSize);
                  }
                },
              ),
            ],
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB84D)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRentalTypeBadge(bool isDailyRental) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDailyRental
            ? Colors.blue.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDailyRental
              ? Colors.blue.withOpacity(0.3)
              : Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        isDailyRental ? 'Daily' : 'Monthly',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDailyRental ? Colors.blue[700] : Colors.green[700],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Rent rent) {
    final statusId = rent.rentStatusId;
    final List<Widget> buttons = [];

    // View Details Button (always available)
    buttons.add(
      _buildActionButton(
        tooltip: "View Details",
        icon: Icons.visibility_outlined,
        color: const Color(0xFF5B9BD5),
        onTap: () => _navigateToDetails(rent),
      ),
    );

    // Landlord actions based on status
    // Pending (1): Can Accept or Reject
    if (statusId == 1) {
      buttons.add(const SizedBox(width: 6));
      buttons.add(
        _buildActionButton(
          tooltip: "Accept Request",
          icon: Icons.check_circle_outline,
          color: Colors.green,
          onTap: () => _showConfirmationDialog(
            title: 'Accept Rent Request',
            message:
                'Are you sure you want to accept this rent request for "${rent.propertyTitle}"?',
            confirmText: 'Accept',
            confirmColor: Colors.green,
            onConfirm: () => _acceptRent(rent),
          ),
        ),
      );
      buttons.add(const SizedBox(width: 6));
      buttons.add(
        _buildActionButton(
          tooltip: "Reject Request",
          icon: Icons.cancel_outlined,
          color: Colors.red[700]!,
          onTap: () => _showConfirmationDialog(
            title: 'Reject Rent Request',
            message:
                'Are you sure you want to reject this rent request for "${rent.propertyTitle}"?',
            confirmText: 'Reject',
            confirmColor: Colors.red[700]!,
            onConfirm: () => _rejectRent(rent),
          ),
        ),
      );
    }

    // Accepted (4): Can Cancel
    if (statusId == 4) {
      buttons.add(const SizedBox(width: 6));
      buttons.add(
        _buildActionButton(
          tooltip: "Cancel Rent",
          icon: Icons.close_outlined,
          color: Colors.red,
          onTap: () => _showConfirmationDialog(
            title: 'Cancel Rent',
            message:
                'Are you sure you want to cancel this accepted rent for "${rent.propertyTitle}"?',
            confirmText: 'Cancel Rent',
            confirmColor: Colors.red,
            onConfirm: () => _cancelRent(rent),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: buttons,
    );
  }

  Widget _buildActionButton({
    required String tooltip,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToDetails(Rent rent) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RentDetailsScreen(rent: rent),
        settings: const RouteSettings(name: 'RentDetailsScreen'),
      ),
    ).then((_) {
      // Refresh list when returning from details
      _performSearch();
    });
  }

  void _showConfirmationDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  Future<void> _acceptRent(Rent rent) async {
    setState(() => _isLoading = true);
    try {
      await rentProvider.accept(rent.id);
      _showSnackBar('Rent request accepted successfully!', Colors.green);
      await _performSearch();
    } catch (e) {
      _showSnackBar('Failed to accept rent: ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _rejectRent(Rent rent) async {
    setState(() => _isLoading = true);
    try {
      await rentProvider.reject(rent.id);
      _showSnackBar('Rent request rejected.', Colors.orange);
      await _performSearch();
    } catch (e) {
      _showSnackBar('Failed to reject rent: ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelRent(Rent rent) async {
    setState(() => _isLoading = true);
    try {
      await rentProvider.cancel(rent.id);
      _showSnackBar('Rent cancelled successfully.', Colors.orange);
      await _performSearch();
    } catch (e) {
      _showSnackBar('Failed to cancel rent: ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildRentStatusBadge(String status) {
    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.pending_outlined;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusIcon = Icons.cancel_outlined;
        break;
      case 'rejected':
        statusColor = Colors.red[700]!;
        statusIcon = Icons.close_outlined;
        break;
      case 'accepted':
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'paid':
        statusColor = Colors.green;
        statusIcon = Icons.payment_outlined;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 12,
            color: statusColor,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
