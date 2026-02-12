import 'package:flutter/material.dart';
import 'package:erent_desktop/layouts/master_screen.dart';
import 'package:erent_desktop/model/rent.dart';

class RentDetailsScreen extends StatelessWidget {
  final Rent rent;

  const RentDetailsScreen({super.key, required this.rent});

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Rent Details',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                _buildHeaderCard(),
                const SizedBox(height: 24),
                // Information Cards
                _buildInfoCards(),
              ],
            ),
          ),
        ),
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
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF5B9BD5),
                  Color(0xFF7AB8CC),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5B9BD5).withOpacity(0.3),
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
                  'Rent Information',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  rent.propertyTitle.isNotEmpty ? rent.propertyTitle : 'N/A',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: rent.isActive
                  ? const Color(0xFF5B9BD5).withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: rent.isActive
                    ? const Color(0xFF5B9BD5).withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  rent.isActive ? Icons.check_circle : Icons.cancel,
                  color: rent.isActive
                      ? const Color(0xFF5B9BD5)
                      : Colors.grey[600],
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  rent.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: rent.isActive
                        ? const Color(0xFF5B9BD5)
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                value: rent.propertyTitle.isNotEmpty ? rent.propertyTitle : 'N/A',
                icon: Icons.home_outlined,
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                label: 'User',
                value: rent.userName.isNotEmpty ? rent.userName : 'N/A',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                label: 'Start Date',
                value: _formatDate(rent.startDate),
                icon: Icons.calendar_today_outlined,
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                label: 'End Date',
                value: _formatDate(rent.endDate),
                icon: Icons.event_outlined,
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                label: 'Rental Type',
                value: rent.isDailyRental ? 'Daily' : 'Monthly',
                icon: Icons.event_available_outlined,
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                label: 'Total Price',
                value: '€${rent.totalPrice.toStringAsFixed(2)}',
                icon: Icons.attach_money_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Status Information Card
        Expanded(
          child: _buildDetailCard(
            title: 'Status Information',
            icon: Icons.verified_outlined,
            children: [
              _buildRentStatusRow(),
              const SizedBox(height: 20),
              _buildInfoRow(
                label: 'Status',
                value: rent.isActive ? 'Active' : 'Inactive',
                icon: rent.isActive
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                valueColor: rent.isActive
                    ? const Color(0xFF5B9BD5)
                    : Colors.grey[600],
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                label: 'Created At',
                value: _formatDateTime(rent.createdAt),
                icon: Icons.calendar_today_outlined,
              ),
              if (rent.updatedAt != null) ...[
                const SizedBox(height: 20),
                _buildInfoRow(
                  label: 'Updated At',
                  value: _formatDateTime(rent.updatedAt!),
                  icon: Icons.update_outlined,
                ),
              ],
            ],
          ),
        ),
      ],
    );
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
                  color: const Color(0xFF5B9BD5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF5B9BD5),
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
          color: const Color(0xFF5B9BD5),
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
    Color statusColor;
    IconData statusIcon;

    switch (rent.rentStatusName.toLowerCase()) {
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          statusIcon,
          size: 20,
          color: const Color(0xFF5B9BD5),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      rent.rentStatusName,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
