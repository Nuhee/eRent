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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              car.isActive ? Icons.warning_amber_rounded : Icons.check_circle_outline,
              color: car.isActive ? Colors.orange : const Color(0xFF5B9BD5),
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              car.isActive ? "Deactivate Car?" : "Activate Car?",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          car.isActive
              ? "Are you sure you want to deactivate '${car.brandName} ${car.model}' (${car.licensePlate})? This will make it unavailable for selection."
              : "Are you sure you want to activate '${car.brandName} ${car.model}' (${car.licensePlate})? This will make it available for selection.",
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
              backgroundColor: car.isActive ? Colors.red : const Color(0xFF5B9BD5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(car.isActive ? "Deactivate" : "Activate"),
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
                    car.isActive
                        ? "Deactivating ${car.brandName} ${car.model}..."
                        : "Activating ${car.brandName} ${car.model}...",
                  ),
                ],
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Get current car data
        var currentCar = await carProvider.getById(car.id);
        if (currentCar == null) {
          throw Exception('Car not found');
        }

        // Prepare update request
        var request = {
          'brandId': currentCar.brandId,
          'colorId': currentCar.colorId,
          'userId': currentCar.userId,
          'model': currentCar.model,
          'licensePlate': currentCar.licensePlate,
          'yearOfManufacture': currentCar.yearOfManufacture,
          'isActive': !car.isActive,
          'picture': currentCar.picture,
        };

        await carProvider.update(car.id, request);

        // Refresh the list
        await _performSearch();

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    car.isActive ? Icons.block : Icons.check_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    car.isActive
                        ? "${car.brandName} ${car.model} has been deactivated"
                        : "${car.brandName} ${car.model} has been activated",
                  ),
                ],
              ),
              backgroundColor: car.isActive ? Colors.red : Colors.green,
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
                      "Failed to update car status: ${e.toString()}",
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
                                            builder: (context) => CarDetailsScreen(car: e),
                                            settings: const RouteSettings(
                                              name: 'CarDetailsScreen',
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
                                            builder: (context) => CarEditScreen(car: e),
                                            settings: const RouteSettings(
                                              name: 'CarEditScreen',
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
                                // Deactivate Button
                                Tooltip(
                                  message: e.isActive ? "Deactivate" : "Activate",
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () => _deactivateCar(e),
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

