import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:erent_desktop/layouts/master_screen.dart';
import 'package:erent_desktop/model/viewing_appointment.dart';

class ViewingDetailsScreen extends StatelessWidget {
  final ViewingAppointment viewing;

  const ViewingDetailsScreen({super.key, required this.viewing});

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Viewing Appointment Details',
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
              Icons.calendar_today_rounded,
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
                  'Viewing Appointment Information',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  viewing.propertyTitle.isNotEmpty ? viewing.propertyTitle : 'N/A',
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
          _buildStatusBadge(viewing.statusName, viewing.status),
        ],
      ),
    );
  }

  Widget _buildInfoCards() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Appointment Details Card
        Expanded(
          child: _buildDetailCard(
            title: 'Appointment Details',
            icon: Icons.info_outline_rounded,
            children: [
              _buildInfoRow(
                label: 'Property',
                value: viewing.propertyTitle.isNotEmpty ? viewing.propertyTitle : 'N/A',
                icon: Icons.home_outlined,
              ),
              if (viewing.propertyAddress.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildInfoRow(
                  label: 'Property Address',
                  value: viewing.propertyAddress,
                  icon: Icons.location_on_outlined,
                ),
              ],
              const SizedBox(height: 20),
              _buildInfoRow(
                label: 'Tenant',
                value: viewing.tenantName.isNotEmpty ? viewing.tenantName : 'N/A',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                label: 'Appointment Date',
                value: _formatDateTime(viewing.appointmentDate),
                icon: Icons.calendar_today_outlined,
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                label: 'End Time',
                value: _formatDateTime(viewing.endTime),
                icon: Icons.event_outlined,
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                label: 'Duration',
                value: _calculateDuration(viewing.appointmentDate, viewing.endTime),
                icon: Icons.access_time_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Status & Notes Card
        Expanded(
          child: _buildDetailCard(
            title: 'Status & Notes',
            icon: Icons.verified_outlined,
            children: [
              _buildStatusRow(),
              const SizedBox(height: 20),
              _buildInfoRow(
                label: 'Created At',
                value: _formatDateTime(viewing.createdAt),
                icon: Icons.calendar_today_outlined,
              ),
              if (viewing.updatedAt != null) ...[
                const SizedBox(height: 20),
                _buildInfoRow(
                  label: 'Updated At',
                  value: _formatDateTime(viewing.updatedAt!),
                  icon: Icons.update_outlined,
                ),
              ],
              if (viewing.tenantNote != null && viewing.tenantNote!.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildNoteRow(
                  label: 'Tenant Note',
                  value: viewing.tenantNote!,
                  icon: Icons.note_outlined,
                ),
              ],
              if (viewing.landlordNote != null && viewing.landlordNote!.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildNoteRow(
                  label: 'Landlord Note',
                  value: viewing.landlordNote!,
                  icon: Icons.note_add_outlined,
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

  Widget _buildNoteRow({
    required String label,
    required String value,
    required IconData icon,
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, int statusCode) {
    Color statusColor;
    IconData statusIcon;

    switch (statusCode) {
      case 0: // Pending
        statusColor = Colors.orange;
        statusIcon = Icons.pending_outlined;
        break;
      case 1: // Approved
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        break;
      case 2: // Rejected
        statusColor = Colors.red[700]!;
        statusIcon = Icons.close_outlined;
        break;
      case 3: // Cancelled
        statusColor = Colors.grey;
        statusIcon = Icons.cancel_outlined;
        break;
      case 4: // Completed
        statusColor = const Color(0xFF5B9BD5);
        statusIcon = Icons.done_all_outlined;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

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
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    Color statusColor;
    IconData statusIcon;

    switch (viewing.status) {
      case 0: // Pending
        statusColor = Colors.orange;
        statusIcon = Icons.pending_outlined;
        break;
      case 1: // Approved
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        break;
      case 2: // Rejected
        statusColor = Colors.red[700]!;
        statusIcon = Icons.close_outlined;
        break;
      case 3: // Cancelled
        statusColor = Colors.grey;
        statusIcon = Icons.cancel_outlined;
        break;
      case 4: // Completed
        statusColor = const Color(0xFF5B9BD5);
        statusIcon = Icons.done_all_outlined;
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
                'Status',
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
                      viewing.statusName,
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

  String _formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  String _calculateDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0 && minutes > 0) {
      return '$hours hour${hours > 1 ? 's' : ''} $minutes minute${minutes > 1 ? 's' : ''}';
    } else if (hours > 0) {
      return '$hours hour${hours > 1 ? 's' : ''}';
    } else {
      return '$minutes minute${minutes > 1 ? 's' : ''}';
    }
  }
}
