import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:erent_mobile/model/rent.dart';
import 'package:erent_mobile/providers/rent_provider.dart';
import 'package:erent_mobile/providers/property_provider.dart';
import 'package:erent_mobile/providers/review_provider.dart';
import 'package:erent_mobile/providers/user_provider.dart';
import 'package:erent_mobile/model/review.dart';
import 'package:erent_mobile/screens/stripe_payment_screen.dart';
import 'package:erent_mobile/screens/rent_review_screen.dart';
import 'package:provider/provider.dart';

class RentDetailsScreen extends StatefulWidget {
  final int rentId;

  const RentDetailsScreen({super.key, required this.rentId});

  @override
  State<RentDetailsScreen> createState() => _RentDetailsScreenState();
}

class _RentDetailsScreenState extends State<RentDetailsScreen> {
  late RentProvider rentProvider;
  late PropertyProvider propertyProvider;
  late ReviewProvider reviewProvider;
  Rent? _rent;
  bool _isLoading = true;
  bool _isProcessingAction = false;
  bool _hasReview = false;
  Review? _existingReview;

  @override
  void initState() {
    super.initState();
    rentProvider = Provider.of<RentProvider>(context, listen: false);
    propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    _loadRent();
  }

  Future<void> _loadRent() async {
    setState(() => _isLoading = true);

    try {
      final rent = await rentProvider.getById(widget.rentId);

      if (mounted) {
        setState(() {
          _rent = rent;
          _isLoading = false;
        });
        // Check if review exists for paid rents
        if (_rent != null && _rent!.rentStatusId == 5) {
          _checkForReview();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading rent: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _checkForReview() async {
    if (_rent == null) return;

    try {
      final user = UserProvider.currentUser;
      if (user == null) return;

      final result = await reviewProvider.get(
        filter: {
          'rentId': _rent!.id,
          'userId': user.id,
          'isActive': true,
          'retrieveAll': true,
        },
      );

      if (mounted) {
        setState(() {
          _hasReview = result.items != null && result.items!.isNotEmpty;
          _existingReview = _hasReview ? result.items!.first : null;
        });
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _navigateToReview() async {
    if (_rent == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RentReviewScreen(rent: _rent!),
      ),
    );

    // Refresh review status if review was saved
    if (result == true && mounted) {
      _checkForReview();
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

  Future<void> _cancelRent() async {
    if (_rent == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: Colors.red),
            SizedBox(width: 12),
            Text('Cancel Booking'),
          ],
        ),
        content: const Text(
          'Are you sure you want to cancel this booking?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isProcessingAction = true);

    try {
      await rentProvider.cancel(_rent!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadRent();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling booking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingAction = false);
      }
    }
  }

  Future<void> _payRent() async {
    if (_rent == null) return;

    // Load property details for payment
    try {
      final property = await propertyProvider.getById(_rent!.propertyId);
      
      if (mounted && property != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StripePaymentScreen(
              property: property,
              startDate: _rent!.startDate,
              endDate: _rent!.endDate,
              isDailyRental: _rent!.isDailyRental,
              price: _rent!.totalPrice,
              rentId: _rent!.id,
            ),
          ),
        ).then((_) => _loadRent());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading property: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Booking Details',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B9BD5)),
              ),
            )
          : _rent == null
              ? const Center(
                  child: Text('Rent not found'),
                )
              : Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Card
                          _buildHeaderCard(),
                          const SizedBox(height: 20),
                          // Action Card
                          _buildActionCard(),
                          const SizedBox(height: 20),
                          // Review Card (only for paid rents)
                          if (_rent!.rentStatusId == 5) ...[
                            _buildReviewCard(),
                            const SizedBox(height: 20),
                          ],
                          // Details Card
                          _buildDetailsCard(),
                        ],
                      ),
                    ),
                    if (_isProcessingAction)
                      Container(
                        color: Colors.black26,
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B9BD5)),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildHeaderCard() {
    final statusColor = _getStatusColor(_rent!.rentStatusName);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [statusColor, statusColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request #${_rent!.id}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _rent!.propertyTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: statusColor.withOpacity(0.3),
              ),
            ),
            child: Text(
              _rent!.rentStatusName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard() {
    final statusId = _rent!.rentStatusId;
    List<Widget> actionButtons = [];

    // User actions based on status
    // Pending (1): Can Cancel
    if (statusId == 1) {
      actionButtons.add(
        Expanded(
          child: _buildActionButton(
            label: 'Cancel Booking',
            icon: Icons.cancel_outlined,
            color: Colors.red,
            onPressed: _cancelRent,
          ),
        ),
      );
    }

    // Accepted (4): Can Cancel or Pay
    if (statusId == 4) {
      actionButtons.add(
        Expanded(
          child: _buildActionButton(
            label: 'Pay Now',
            icon: Icons.payment_rounded,
            color: const Color(0xFF5B9BD5),
            onPressed: _payRent,
          ),
        ),
      );
      actionButtons.add(const SizedBox(width: 12));
      actionButtons.add(
        Expanded(
          child: _buildActionButton(
            label: 'Cancel',
            icon: Icons.cancel_outlined,
            color: Colors.red,
            onPressed: _cancelRent,
          ),
        ),
      );
    }

    // Paid (5): Show status message only (review section is separate)
    if (statusId == 5) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
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
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // If no actions available, show a status message
    if (actionButtons.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
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
                  fontSize: 14,
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
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B9BD5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.touch_app_outlined,
                  color: Color(0xFF5B9BD5),
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
          const SizedBox(height: 16),
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
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
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
        return 'This booking has been cancelled. No further actions are available.';
      case 3:
        return 'This booking request has been rejected by the landlord.';
      case 5:
        return 'This booking has been paid and is now active. You can move-in at the start date, for more information contact the landlord via Chat through the app.';
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
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildReviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B9BD5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.rate_review_rounded,
                  color: Color(0xFF5B9BD5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Your Review',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_existingReview != null) ...[
            // Show existing review
            Row(
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return Icon(
                  starIndex <= _existingReview!.rating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  size: 24,
                  color: starIndex <= _existingReview!.rating
                      ? const Color(0xFFFFB84D)
                      : Colors.grey[300],
                );
              }),
            ),
            if (_existingReview!.comment != null && _existingReview!.comment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                _existingReview!.comment!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 6),
                Text(
                  _existingReview!.updatedAt != null
                      ? 'Updated ${DateFormat('MMM dd, yyyy').format(_existingReview!.updatedAt!)}'
                      : 'Posted ${DateFormat('MMM dd, yyyy').format(_existingReview!.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _navigateToReview,
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Edit Review'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF5B9BD5),
                  side: const BorderSide(color: Color(0xFF5B9BD5)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ] else ...[
            // No review yet - show button to write review
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Share your experience',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Help others by writing a review',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _navigateToReview,
                icon: const Icon(Icons.rate_review_rounded, size: 20),
                label: const Text(
                  'Write Review',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B9BD5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          const Text(
            'Booking Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Start Date', DateFormat('MMM dd, yyyy').format(_rent!.startDate)),
          const SizedBox(height: 12),
          _buildInfoRow('End Date', DateFormat('MMM dd, yyyy').format(_rent!.endDate)),
          const SizedBox(height: 12),
          _buildInfoRow('Duration', _rent!.isDailyRental
              ? '${_rent!.endDate.difference(_rent!.startDate).inDays} days'
              : '${_calculateMonths(_rent!.startDate, _rent!.endDate)} months'),
          const SizedBox(height: 12),
          _buildInfoRow('Rental Type', _rent!.isDailyRental ? 'Daily' : 'Monthly'),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Price',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              Text(
                '€${_rent!.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5B9BD5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  int _calculateMonths(DateTime start, DateTime end) {
    int months = 0;
    DateTime current = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);

    while (current.isBefore(endDate)) {
      if (current.month == 12) {
        current = DateTime(current.year + 1, 1, current.day);
      } else {
        current = DateTime(current.year, current.month + 1, current.day);
      }
      months++;
    }

    return months;
  }
}
