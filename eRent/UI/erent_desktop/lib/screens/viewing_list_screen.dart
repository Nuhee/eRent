import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:erent_desktop/layouts/master_screen.dart';
import 'package:erent_desktop/model/viewing_appointment.dart';
import 'package:erent_desktop/model/search_result.dart';
import 'package:erent_desktop/providers/viewing_appointment_provider.dart';
import 'package:erent_desktop/screens/viewing_details_screen.dart';
import 'package:erent_desktop/utils/base_pagination.dart';
import 'package:erent_desktop/utils/base_table.dart';
import 'package:erent_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';

class ViewingListScreen extends StatefulWidget {
  const ViewingListScreen({super.key});

  @override
  State<ViewingListScreen> createState() => _ViewingListScreenState();
}

class _ViewingListScreenState extends State<ViewingListScreen> {
  late ViewingAppointmentProvider viewingProvider;

  final TextEditingController propertyTitleController = TextEditingController();
  final TextEditingController tenantNameController = TextEditingController();
  int? selectedStatus;

  SearchResult<ViewingAppointment>? viewings;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 10, 20, 50];

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;

    final filter = <String, dynamic>{
      if (propertyTitleController.text.isNotEmpty)
        'propertyTitle': propertyTitleController.text,
      if (tenantNameController.text.isNotEmpty) 'tenantName': tenantNameController.text,
      if (selectedStatus != null) 'status': selectedStatus,
      'page': pageToFetch,
      'pageSize': pageSizeToUse,
      'includeTotalCount': true,
    };

    final result = await viewingProvider.get(filter: filter);
    setState(() {
      viewings = result;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      viewingProvider = context.read<ViewingAppointmentProvider>();
      await _performSearch(page: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Viewing Appointments Management',
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
            child: TextField(
              decoration: customTextFieldDecoration(
                'Tenant Name',
                prefixIcon: Icons.person_outline,
              ),
              controller: tenantNameController,
              onSubmitted: (_) => _performSearch(page: 0),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonFormField<int?>(
              decoration: customTextFieldDecoration(
                'Status',
                prefixIcon: Icons.verified_outlined,
              ),
              value: selectedStatus,
              items: const [
                DropdownMenuItem<int?>(value: null, child: Text('All Statuses')),
                DropdownMenuItem<int>(value: 0, child: Text('Pending')),
                DropdownMenuItem<int>(value: 1, child: Text('Approved')),
                DropdownMenuItem<int>(value: 2, child: Text('Rejected')),
                DropdownMenuItem<int>(value: 3, child: Text('Cancelled')),
                DropdownMenuItem<int>(value: 4, child: Text('Completed')),
              ],
              onChanged: (int? value) {
                setState(() {
                  selectedStatus = value;
                });
                _performSearch(page: 0);
              },
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _performSearch,
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
              tenantNameController.clear();
              setState(() {
                selectedStatus = null;
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
        viewings == null || viewings!.items == null || viewings!.items!.isEmpty;
    final int totalCount = viewings?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;

    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTable(
            icon: Icons.calendar_today_outlined,
            title: 'Viewing Appointments',
            width: 1600,
            height: 423,
            columnWidths: const [
              430, // Property Title
              150, // Tenant Name
              150, // Appointment Date
              150, // End Time
              130, // Status
              100, // Actions
            ],
            columns: const [
              DataColumn(
                label: Text(
                  'Property',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Tenant',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Appointment Date',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'End Time',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Actions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
            rows: isEmpty
                ? []
                : viewings!.items!
                      .map(
                        (e) => DataRow(
                          cells: [
                            DataCell(
                              Text(
                                e.propertyTitle.isNotEmpty ? e.propertyTitle : 'N/A',
                                style: const TextStyle(fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DataCell(
                              Text(
                                e.tenantName.isNotEmpty ? e.tenantName : 'N/A',
                                style: const TextStyle(fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DataCell(
                              Text(
                                _formatDateTime(e.appointmentDate),
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            DataCell(
                              Text(
                                _formatDateTime(e.endTime),
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            DataCell(
                              _buildStatusBadge(e.statusName, e.status),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // View Details Button
                                  Tooltip(
                                    message: "View Details",
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ViewingDetailsScreen(viewing: e),
                                              settings: const RouteSettings(
                                                name: 'ViewingDetailsScreen',
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF5B9BD5).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: const Color(0xFF5B9BD5).withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.visibility_outlined,
                                            color: Color(0xFF5B9BD5),
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
            emptyIcon: Icons.calendar_today,
            emptyText: 'No viewing appointments found.',
            emptySubtext: 'Try adjusting your search criteria.',
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            size: 14,
            color: statusColor,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }
}
