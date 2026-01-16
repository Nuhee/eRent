import 'package:flutter/material.dart';
import 'package:erent_desktop/layouts/master_screen.dart';
import 'package:erent_desktop/model/property.dart';
import 'package:erent_desktop/model/search_result.dart';
import 'package:erent_desktop/providers/property_provider.dart';
import 'package:erent_desktop/screens/property_details_screen.dart';
import 'package:erent_desktop/utils/base_pagination.dart';
import 'package:erent_desktop/utils/base_table.dart';
import 'package:erent_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';

class PropertyListScreen extends StatefulWidget {
  const PropertyListScreen({super.key});

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  late PropertyProvider propertyProvider;

  final TextEditingController titleController = TextEditingController();
  bool? selectedIsActive;

  SearchResult<Property>? properties;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 10, 20, 50];

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;

    final filter = {
      if (titleController.text.isNotEmpty) 'title': titleController.text,
      if (selectedIsActive != null) 'isActive': selectedIsActive,
      'page': pageToFetch,
      'pageSize': pageSizeToUse,
      'includeTotalCount': true,
    };

    final result = await propertyProvider.get(filter: filter);
    setState(() {
      properties = result;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      propertyProvider = context.read<PropertyProvider>();
      await _performSearch(page: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Properties Management',
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
              controller: titleController,
              onSubmitted: (_) => _performSearch(page: 0),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DropdownButtonFormField<bool?>(
              decoration: customTextFieldDecoration(
                'Status',
                prefixIcon: Icons.verified_outlined,
              ),
              value: selectedIsActive,
              items: const [
                DropdownMenuItem<bool?>(value: null, child: Text('All')),
                DropdownMenuItem<bool>(value: true, child: Text('Active')),
                DropdownMenuItem<bool>(value: false, child: Text('Inactive')),
              ],
              onChanged: (bool? value) {
                setState(() {
                  selectedIsActive = value;
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
              titleController.clear();
              setState(() {
                selectedIsActive = null;
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
        properties == null || properties!.items == null || properties!.items!.isEmpty;
    final int totalCount = properties?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;

    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTable(
            icon: Icons.home_outlined,
            title: 'Properties',
            width: 1400,
            height: 423,
            columnWidths: const [
              300, // Title
              150, // Property Type
              150, // City
              150, // Landlord
              120, // Price/Month
              120, // Status
              150, // Actions
            ],
            columns: const [
              DataColumn(
                label: Text(
                  'Title',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Property Type',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'City',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Landlord',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Price/Month',
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
                : properties!.items!
                      .map(
                        (e) => DataRow(
                          cells: [
                            DataCell(
                              Text(
                                e.title.isNotEmpty ? e.title : 'N/A',
                                style: const TextStyle(fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DataCell(
                              Text(
                                e.propertyTypeName.isNotEmpty ? e.propertyTypeName : 'N/A',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            DataCell(
                              Text(
                                e.cityName.isNotEmpty ? e.cityName : 'N/A',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            DataCell(
                              Text(
                                e.landlordName.isNotEmpty ? e.landlordName : 'N/A',
                                style: const TextStyle(fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DataCell(
                              Text(
                                '${e.pricePerMonth.toStringAsFixed(2)} BAM',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    e.isActive
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: e.isActive
                                        ? const Color(0xFF5B9BD5)
                                        : Colors.grey[400],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    e.isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: e.isActive
                                          ? const Color(0xFF5B9BD5)
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
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
                                                  PropertyDetailsScreen(property: e),
                                              settings: const RouteSettings(
                                                name: 'PropertyDetailsScreen',
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
            emptyIcon: Icons.home,
            emptyText: 'No properties found.',
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
}
