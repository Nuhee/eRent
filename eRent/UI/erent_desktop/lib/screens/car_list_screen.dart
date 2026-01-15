import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:erent_desktop/layouts/master_screen.dart';
import 'package:erent_desktop/model/car.dart';
import 'package:erent_desktop/model/search_result.dart';
import 'package:erent_desktop/providers/car_provider.dart';
import 'package:erent_desktop/screens/car_details_screen.dart';
import 'package:erent_desktop/screens/car_edit_screen.dart';
import 'package:erent_desktop/utils/base_table.dart';
import 'package:erent_desktop/utils/base_pagination.dart';
import 'package:erent_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';

class CarListScreen extends StatefulWidget {
  const CarListScreen({super.key});

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  late CarProvider carProvider;
  TextEditingController brandModelController = TextEditingController();
  TextEditingController licensePlateController = TextEditingController();

  SearchResult<Car>? cars;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;
    final filter = {
      if (brandModelController.text.isNotEmpty) 'brandModel': brandModelController.text,
      if (licensePlateController.text.isNotEmpty) 'licensePlate': licensePlateController.text,
      'page': pageToFetch,
      'pageSize': pageSizeToUse,
      'includeTotalCount': true,
    };
    var carsResult = await carProvider.get(filter: filter);
    setState(() {
      this.cars = carsResult;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  Future<void> _deactivateCar(Car car) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Car'),
        content: Text(
          'Are you sure you want to deactivate ${car.brandName} ${car.model} (${car.licensePlate})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Get current car data
      var currentCar = await carProvider.getById(car.id);
      if (currentCar == null) {
        throw Exception('Car not found');
      }

      // Prepare update request with isActive = false
      var request = {
        'brandId': currentCar.brandId,
        'colorId': currentCar.colorId,
        'userId': currentCar.userId,
        'model': currentCar.model,
        'licensePlate': currentCar.licensePlate,
        'yearOfManufacture': currentCar.yearOfManufacture,
        'isActive': false, // Deactivate
        'picture': currentCar.picture,
      };

      await carProvider.update(car.id, request);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Car deactivated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
        // Refresh the list
        await _performSearch();
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      carProvider = context.read<CarProvider>();
      await _performSearch(page: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Cars Management",
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
                "Brand / Model",
                prefixIcon: Icons.search,
              ),
              controller: brandModelController,
              onSubmitted: (value) => _performSearch(page: 0),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: customTextFieldDecoration(
                "License Plate",
                prefixIcon: Icons.directions_car,
              ),
              controller: licensePlateController,
              onSubmitted: (value) => _performSearch(page: 0),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _performSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D2D2D),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              shadowColor: const Color(0xFF2D2D2D).withOpacity(0.3),
            ).copyWith(
              elevation: WidgetStateProperty.all(4),
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
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final isEmpty =
        cars == null || cars!.items == null || cars!.items!.isEmpty;
    final int totalCount = cars?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage =
        _currentPage >= totalPages - 1 || totalPages == 0;
    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTable(
            icon: Icons.directions_car_outlined,
            title: "Cars",
            width: 1400,
            height: 423,
            columnWidths: const [
              70, // Brand Logo
              80, // Picture
              210, // Car (Brand + Model)
              120, // Color
              130, // License Plate
              160, // Client (User)
              80, // Active
              240, // Actions
            ],
            imageColumnIndices: const {0, 1}, // Brand Logo and Picture columns
            columns: const [
              DataColumn(
                label: Text(
                  "Brand",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  "Picture",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  "Car",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  "Color",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  "License Plate",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  "Client",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  "Active",
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
                : cars!.items!
                    .map(
                      (e) => DataRow(
                        cells: [
                          DataCell(
                            _buildBrandLogo(e.brandLogo),
                          ),
                          DataCell(
                            _buildCarPicture(e.picture),
                          ),
                          DataCell(
                            Text(
                              '${e.brandName} ${e.model}',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _parseColor(e.colorHexCode),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(e.colorName, style: const TextStyle(fontSize: 15)),
                              ],
                            ),
                          ),
                          DataCell(
                            Text(e.licensePlate, style: const TextStyle(fontSize: 15)),
                          ),
                          DataCell(
                            Text(e.userFullName, style: const TextStyle(fontSize: 15)),
                          ),
                               DataCell(
                            Icon(
                              e.isActive
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: e.isActive ? Colors.green : Colors.red,
                              size: 20,
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CarDetailsScreen(car: e),
                                            settings: const RouteSettings(
                                              name: 'CarDetailsScreen',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 38,
                                        height: 38,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF8B6F47),
                                              Color(0xFF6B5434),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF8B6F47).withOpacity(0.3),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.info_outline_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                CarEditScreen(car: e),
                                            settings: const RouteSettings(
                                              name: 'CarEditScreen',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 38,
                                        height: 38,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF8B6F47),
                                              Color(0xFF6B5434),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF8B6F47).withOpacity(0.3),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.build_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () => _deactivateCar(e),
                                      child: Container(
                                        width: 38,
                                        height: 38,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFFD32F2F), // Red
                                              Color(0xFFB71C1C), // Darker red
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFD32F2F).withOpacity(0.35),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.white,
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
            emptyIcon: Icons.directions_car,
            emptyText: "No cars found.",
            emptySubtext: "Try adjusting your search criteria.",
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

  Widget _buildBrandLogo(String? logoBase64) {
    if (logoBase64 != null && logoBase64.isNotEmpty) {
      try {
        final sanitized = logoBase64.replaceAll(
          RegExp(r'^data:image/[^;]+;base64,'),
          '',
        );
        final bytes = base64Decode(sanitized);
        return Container(
          width: 35,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.branding_watermark,
                  size: 30,
                  color: Colors.grey,
                );
              },
            ),
          ),
        );
      } catch (_) {
        return const Icon(
          Icons.branding_watermark,
          size: 30,
          color: Colors.grey,
        );
      }
    }
    return const Icon(
      Icons.branding_watermark,
      size: 30,
      color: Colors.grey,
    );
  }

  Widget _buildCarPicture(String? pictureBase64) {
    if (pictureBase64 != null && pictureBase64.isNotEmpty) {
      try {
        final sanitized = pictureBase64.replaceAll(
          RegExp(r'^data:image/[^;]+;base64,'),
          '',
        );
        final bytes = base64Decode(sanitized);
        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.directions_car,
                  size: 30,
                  color: Colors.grey,
                );
              },
            ),
          ),
        );
      } catch (_) {
        return const Icon(
          Icons.directions_car,
          size: 30,
          color: Colors.grey,
        );
      }
    }
    return const Icon(
      Icons.directions_car,
      size: 30,
      color: Colors.grey,
    );
  }

  Color _parseColor(String hexCode) {
    try {
      return Color(int.parse(hexCode.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.grey;
    }
  }
}

