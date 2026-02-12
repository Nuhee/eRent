import 'package:flutter/material.dart';
import 'package:erent_landlord_desktop/layouts/master_screen.dart';
import 'package:erent_landlord_desktop/model/rent.dart';
import 'package:erent_landlord_desktop/providers/rent_provider.dart';
import 'package:provider/provider.dart';

class RentDetailsScreen extends StatefulWidget {
  final Rent rent;

  const RentDetailsScreen({super.key, required this.rent});

  @override
  State<RentDetailsScreen> createState() => _RentDetailsScreenState();
}

class _RentDetailsScreenState extends State<RentDetailsScreen> {
  late RentProvider rentProvider;
  late Rent _currentRent;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentRent = widget.rent;
    rentProvider = context.read<RentProvider>();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Rent Details',
      showBackButton: true,
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    _buildHeaderCard(),
                    const SizedBox(height: 24),
                    // Action Buttons Card (for landlord actions)
                    _buildActionCard(),
                    const SizedBox(height: 24),
                    // Information Cards
                    _buildInfoCards(),
                  ],
                ),
              ),
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
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getStatusColor(_currentRent.rentStatusName),
                  _getStatusColor(_currentRent.rentStatusName).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _getStatusColor(_currentRent.rentStatusName)
                      .withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 24),
          // Title and Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rent Request #${_currentRent.id}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentRent.propertyTitle.isNotEmpty
                      ? _currentRent.propertyTitle
                      : 'N/A',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Tenant: ${_currentRent.userName.isNotEmpty ? _currentRent.userName : 'N/A'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Status Badge
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final status = _currentRent.rentStatusName;
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
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
            color: statusColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard() {
    final statusId = _currentRent.rentStatusId;
    List<Widget> actionButtons = [];

    // Landlord actions based on status
    // Pending (1): Can Accept or Reject
    if (statusId == 1) {
      actionButtons.add(
        _buildActionButton(
          label: 'Accept Request',
          icon: Icons.check_circle_outline,
          color: Colors.green,
          onPressed: () => _showConfirmationDialog(
            title: 'Accept Rent Request',
            message:
                'Are you sure you want to accept this rent request?\n\nThe tenant will be notified and can proceed with payment.',
            confirmText: 'Accept',
            confirmColor: Colors.green,
            onConfirm: _acceptRent,
          ),
        ),
      );
      actionButtons.add(const SizedBox(width: 16));
      actionButtons.add(
        _buildActionButton(
          label: 'Reject Request',
          icon: Icons.cancel_outlined,
          color: Colors.red[700]!,
          onPressed: () => _showConfirmationDialog(
            title: 'Reject Rent Request',
            message:
                'Are you sure you want to reject this rent request?\n\nThis action cannot be undone.',
            confirmText: 'Reject',
            confirmColor: Colors.red[700]!,
            onConfirm: _rejectRent,
          ),
        ),
      );
    }

    // Accepted (4): Can Cancel
    if (statusId == 4) {
      actionButtons.add(
        _buildActionButton(
          label: 'Cancel Rent',
          icon: Icons.close_outlined,
          color: Colors.red,
          onPressed: () => _showConfirmationDialog(
            title: 'Cancel Rent',
            message:
                'Are you sure you want to cancel this accepted rent?\n\nThe tenant will be notified of this cancellation.',
            confirmText: 'Cancel Rent',
            confirmColor: Colors.red,
            onConfirm: _cancelRent,
          ),
        ),
      );
    }

    // If no actions available, show a status message
    if (actionButtons.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _getStatusMessageIcon(statusId),
              color: Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _getStatusMessage(statusId),
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB84D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.touch_app_outlined,
                  color: Color(0xFFFFB84D),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Available Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: actionButtons,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
    );
  }

  String _getStatusMessage(int statusId) {
    switch (statusId) {
      case 2:
        return 'This rent has been cancelled. No further actions are available.';
      case 3:
        return 'This rent request has been rejected. No further actions are available.';
      case 5:
        return 'This rent has been paid and is now active. The property is rented for the specified period.';
      default:
        return 'No actions available for this status.';
    }
  }

  IconData _getStatusMessageIcon(int statusId) {
    switch (statusId) {
      case 2:
        return Icons.cancel_outlined;
      case 3:
        return Icons.block_outlined;
      case 5:
        return Icons.check_circle_outlined;
      default:
        return Icons.info_outlined;
    }
  }

  Widget _buildInfoCards() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rent Details Card
        Expanded(
          child: _buildDetailCard(
            title: 'Rent Details',
            icon: Icons.info_outline_rounded,
            children: [
              _buildInfoRow(
                label: 'Property',
                value: _currentRent.propertyTitle.isNotEmpty
                    ? _currentRent.propertyTitle
                    : 'N/A',
                icon: Icons.home_outlined,
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                label: 'Tenant',
                value: _currentRent.userName.isNotEmpty
                    ? _currentRent.userName
                    : 'N/A',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                label: 'Start Date',
                value: _formatDate(_currentRent.startDate),
                icon: Icons.calendar_today_outlined,
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                label: 'End Date',
                value: _formatDate(_currentRent.endDate),
                icon: Icons.event_outlined,
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                label: 'Duration',
                value: _calculateDuration(),
                icon: Icons.timer_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Payment & Status Information Card
        Expanded(
          child: _buildDetailCard(
            title: 'Payment & Status',
            icon: Icons.payment_outlined,
            children: [
              _buildInfoRow(
                label: 'Rental Type',
                value: _currentRent.isDailyRental ? 'Daily Rental' : 'Monthly Rental',
                icon: Icons.event_available_outlined,
                valueColor: _currentRent.isDailyRental ? Colors.blue : Colors.green,
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                label: 'Total Price',
                value: '€${_currentRent.totalPrice.toStringAsFixed(2)}',
                icon: Icons.attach_money_outlined,
                valueColor: const Color(0xFFFFB84D),
              ),
              const SizedBox(height: 20),
              _buildRentStatusRow(),
              const SizedBox(height: 20),
              _buildInfoRow(
                label: 'Request Date',
                value: _formatDateTime(_currentRent.createdAt),
                icon: Icons.calendar_today_outlined,
              ),
              if (_currentRent.updatedAt != null) ...[
                const SizedBox(height: 20),
                _buildInfoRow(
                  label: 'Last Updated',
                  value: _formatDateTime(_currentRent.updatedAt!),
                  icon: Icons.update_outlined,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _calculateDuration() {
    final days = _currentRent.endDate.difference(_currentRent.startDate).inDays;
    if (_currentRent.isDailyRental) {
      return '$days ${days == 1 ? 'day' : 'days'}';
    } else {
      final months = (days / 30).ceil();
      return '$months ${months == 1 ? 'month' : 'months'} ($days days)';
    }
  }

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB84D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFFFB84D),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFFFFB84D),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRentStatusRow() {
    final statusColor = _getStatusColor(_currentRent.rentStatusName);
    final statusIcon = _getStatusIcon(_currentRent.rentStatusName);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.verified_outlined,
          size: 20,
          color: Color(0xFFFFB84D),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rent Status',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
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
                      size: 18,
                      color: statusColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _currentRent.rentStatusName,
                      style: TextStyle(
                        fontSize: 15,
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
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'rejected':
        return Colors.red[700]!;
      case 'accepted':
        return Colors.blue;
      case 'paid':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending_outlined;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'rejected':
        return Icons.close_outlined;
      case 'accepted':
        return Icons.check_circle_outline;
      case 'paid':
        return Icons.payment_outlined;
      default:
        return Icons.help_outline;
    }
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

  Future<void> _acceptRent() async {
    setState(() => _isLoading = true);
    try {
      final result = await rentProvider.accept(_currentRent.id);
      if (result != null) {
        setState(() => _currentRent = result);
        _showSnackBar('Rent request accepted successfully!', Colors.green);
      }
    } catch (e) {
      _showSnackBar('Failed to accept rent: ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _rejectRent() async {
    setState(() => _isLoading = true);
    try {
      final result = await rentProvider.reject(_currentRent.id);
      if (result != null) {
        setState(() => _currentRent = result);
        _showSnackBar('Rent request rejected.', Colors.orange);
      }
    } catch (e) {
      _showSnackBar('Failed to reject rent: ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelRent() async {
    setState(() => _isLoading = true);
    try {
      final result = await rentProvider.cancel(_currentRent.id);
      if (result != null) {
        setState(() => _currentRent = result);
        _showSnackBar('Rent cancelled successfully.', Colors.orange);
      }
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
