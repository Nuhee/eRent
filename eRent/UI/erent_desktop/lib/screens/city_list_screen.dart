import 'package:flutter/material.dart';
import 'package:erent_desktop/layouts/master_screen.dart';
import 'package:erent_desktop/model/city.dart';
import 'package:erent_desktop/model/country.dart';
import 'package:erent_desktop/model/search_result.dart';
import 'package:erent_desktop/providers/city_provider.dart';
import 'package:erent_desktop/providers/country_provider.dart';
import 'package:erent_desktop/screens/city_details_screen.dart';
import 'package:erent_desktop/screens/city_edit_screen.dart';
import 'package:erent_desktop/utils/base_table.dart';
import 'package:erent_desktop/utils/base_pagination.dart';
import 'package:erent_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';

class CityListScreen extends StatefulWidget {
  const CityListScreen({super.key});

  @override
  State<CityListScreen> createState() => _CityListScreenState();
}

class _CityListScreenState extends State<CityListScreen> {
  late CityProvider cityProvider;
  late CountryProvider countryProvider;
  TextEditingController nameController = TextEditingController();
  int? selectedCountryId;
  List<Country>? countries;

  SearchResult<City>? cities;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];

  // Load countries for dropdown
  Future<void> _loadCountries() async {
    try {
      final result = await countryProvider.get(filter: {
        'isActive': true,
        'retrieveAll': true,
      });
      setState(() {
        countries = result.items;
      });
    } catch (e) {
      debugPrint('Error loading countries: $e');
    }
  }

  // Search for cities with ENTER key, not only when button is clicked
  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;
    final filter = {
      if (nameController.text.isNotEmpty) 'name': nameController.text,
      if (selectedCountryId != null) 'countryId': selectedCountryId,
      'page': pageToFetch,
      'pageSize': pageSizeToUse,
      'includeTotalCount': true, // Ensure backend returns total count
    };
    debugPrint(filter.toString());
    var cities = await cityProvider.get(filter: filter);
    debugPrint(cities.items?.firstOrNull?.name);
    setState(() {
      this.cities = cities;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  // Toggle city active status
  Future<void> _toggleCityStatus(City city) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              city.isActive ? Icons.warning_amber_rounded : Icons.check_circle_outline,
              color: city.isActive ? Colors.orange : const Color(0xFF5B9BD5),
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              city.isActive ? "Deactivate City?" : "Activate City?",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          city.isActive
              ? "Are you sure you want to deactivate '${city.name}'? This will make it unavailable for selection."
              : "Are you sure you want to activate '${city.name}'? This will make it available for selection.",
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: city.isActive ? Colors.red : const Color(0xFF5B9BD5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(city.isActive ? "Deactivate" : "Activate"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Show loading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    city.isActive
                        ? "Deactivating ${city.name}..."
                        : "Activating ${city.name}...",
                  ),
                ],
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Update city status
        final updateRequest = {
          'name': city.name,
          'countryId': city.countryId,
          'isActive': !city.isActive,
        };

        await cityProvider.update(city.id, updateRequest);

        // Refresh the list
        await _performSearch();

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    city.isActive ? Icons.block : Icons.check_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    city.isActive
                        ? "${city.name} has been deactivated"
                        : "${city.name} has been activated",
                  ),
                ],
              ),
              backgroundColor: city.isActive ? Colors.red : Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Failed to update city status: ${e.toString()}",
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Delay to ensure context is available for Provider
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      cityProvider = context.read<CityProvider>();
      countryProvider = context.read<CountryProvider>();

      await _loadCountries();
      await _performSearch(page: 0);
    });
  }

 

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "City Administration",
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
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: customTextFieldDecoration(
                "Name",
                prefixIcon: Icons.search,
              ),
              controller: nameController,
              onSubmitted: (value) => _performSearch(),
            ),
          ),
          const SizedBox(width: 12),
          // Country dropdown
          Container(
            width: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: DropdownButtonFormField<int?>(
              value: selectedCountryId,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.flag_outlined, size: 20),
                hintText: "All Countries",
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text("All Countries"),
                ),
                ...?countries?.map((country) => DropdownMenuItem<int?>(
                      value: country.id,
                      child: Text(country.name),
                    )),
              ],
              onChanged: (value) {
                setState(() {
                  selectedCountryId = value;
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CityEditScreen(),
                  settings: const RouteSettings(name: 'CityEditScreen'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B9BD5),
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
                Icon(Icons.add_rounded, size: 18),
                SizedBox(width: 8),
                Text(
                  'Add City',
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
        cities == null || cities!.items == null || cities!.items!.isEmpty;
    final int totalCount = cities?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;
    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTable(
            icon: Icons.location_city_outlined,
            title: "Cities",
            width: 800,
            height: 423,
            columnWidths: [
              200, // Name
              200, // Country
              120, // Status
              280, // Actions
            ],
            columns: const [
              DataColumn(
                label: Text(
                  "Name",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  "Country",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  "Status",
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
                : cities!.items!
                      .map(
                        (e) => DataRow(
                          cells: [
                            DataCell(
                              Text(e.name, style: const TextStyle(fontSize: 15)),
                            ),
                            DataCell(
                              Text(
                                e.countryName.isNotEmpty ? e.countryName : 'N/A',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: e.countryName.isNotEmpty 
                                      ? Colors.grey[800] 
                                      : Colors.grey[500],
                                ),
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
                                              builder: (context) => CityDetailsScreen(city: e),
                                              settings: const RouteSettings(
                                                name: 'CityDetailsScreen',
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
                                  const SizedBox(width: 8),
                                  // Edit Button
                                  Tooltip(
                                    message: "Edit",
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CityEditScreen(city: e),
                                              settings: const RouteSettings(
                                                name: 'CityEditScreen',
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.orange.withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.edit_outlined,
                                            color: Colors.orange,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Activate/Deactivate Button
                                  Tooltip(
                                    message: e.isActive ? "Deactivate" : "Activate",
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () async {
                                          await _toggleCityStatus(e);
                                        },
                                        child: Container(
                                          width: 36,
                                          height: 36,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: e.isActive
                                                ? Colors.red.withOpacity(0.1)
                                                : Colors.green.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: e.isActive
                                                  ? Colors.red.withOpacity(0.3)
                                                  : Colors.green.withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Icon(
                                            e.isActive
                                                ? Icons.block_outlined
                                                : Icons.check_circle_outline,
                                            color: e.isActive
                                                ? Colors.red
                                                : Colors.green,
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
            emptyIcon: Icons.location_city,
            emptyText: "No cities found.",
            emptySubtext: "Try adjusting your search or add a new city.",
          ),
          SizedBox(height: 30),
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
