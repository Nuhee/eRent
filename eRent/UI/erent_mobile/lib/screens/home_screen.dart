import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:erent_mobile/model/property.dart';
import 'package:erent_mobile/model/city.dart';
import 'package:erent_mobile/model/property_type.dart';
import 'package:erent_mobile/providers/property_provider.dart';
import 'package:erent_mobile/providers/city_provider.dart';
import 'package:erent_mobile/providers/property_type_provider.dart';
import 'package:erent_mobile/screens/property_details_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PropertyProvider propertyProvider;
  late CityProvider cityProvider;
  late PropertyTypeProvider propertyTypeProvider;

  List<Property> _properties = [];
  List<City> _cities = [];
  List<PropertyType> _propertyTypes = [];
  bool _isLoading = true;

  // Filter state
  String _searchQuery = '';
  int? _selectedCityId;
  int? _selectedPropertyTypeId;
  double? _minPrice;
  double? _maxPrice;
  int? _minBedrooms;
  bool _showFilters = false;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _minBedroomsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    cityProvider = Provider.of<CityProvider>(context, listen: false);
    propertyTypeProvider = Provider.of<PropertyTypeProvider>(context, listen: false);
    _loadFilters();
    _loadProperties();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minBedroomsController.dispose();
    super.dispose();
  }

  Future<void> _loadFilters() async {
    try {
      final citiesResult = await cityProvider.get(filter: {'isActive': true, 'retrieveAll': true});
      final propertyTypesResult = await propertyTypeProvider.get(filter: {'isActive': true, 'retrieveAll': true});

      if (mounted) {
        setState(() {
          _cities = citiesResult.items ?? [];
          _propertyTypes = propertyTypesResult.items ?? [];
        });
      }
    } catch (e) {
      // Silently fail - filters are optional
    }
  }

  Future<void> _loadProperties() async {
    setState(() => _isLoading = true);

    try {
      final filter = <String, dynamic>{
        'isActive': true,
        'retrieveAll': false,
        'page': 0,
        'pageSize': 20,
      };

      if (_searchQuery.isNotEmpty) {
        filter['title'] = _searchQuery;
      }
      if (_selectedCityId != null) {
        filter['cityId'] = _selectedCityId;
      }
      if (_selectedPropertyTypeId != null) {
        filter['propertyTypeId'] = _selectedPropertyTypeId;
      }
      if (_minPrice != null) {
        filter['minPricePerMonth'] = _minPrice;
      }
      if (_maxPrice != null) {
        filter['maxPricePerMonth'] = _maxPrice;
      }
      if (_minBedrooms != null) {
        filter['minBedrooms'] = _minBedrooms;
      }

      final result = await propertyProvider.get(filter: filter);

      if (mounted) {
        setState(() {
          _properties = result.items ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading properties: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCityId = null;
      _selectedPropertyTypeId = null;
      _minPrice = null;
      _maxPrice = null;
      _minBedrooms = null;
      _searchController.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      _minBedroomsController.clear();
    });
    _loadProperties();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          // Search and Filter Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    onSubmitted: (_) => _loadProperties(),
                    decoration: InputDecoration(
                      hintText: 'Search properties...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400]),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear_rounded, color: Colors.grey[400]),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                                _loadProperties();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Filter Toggle and Apply Button
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() => _showFilters = !_showFilters);
                        },
                        icon: Icon(
                          _showFilters ? Icons.filter_list : Icons.tune_rounded,
                          size: 18,
                        ),
                        label: const Text('Filters'),
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
                    const SizedBox(width: 12),
                    if (_selectedCityId != null ||
                        _selectedPropertyTypeId != null ||
                        _minPrice != null ||
                        _maxPrice != null ||
                        _minBedrooms != null)
                      OutlinedButton(
                        onPressed: _clearFilters,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Clear'),
                      ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5B9BD5), Color(0xFF7AB8CC)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: _loadProperties,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Search',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Filters Panel
                if (_showFilters) ...[
                  const SizedBox(height: 16),
                  _buildFiltersPanel(),
                ],
              ],
            ),
          ),

          // Properties List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B9BD5)),
                    ),
                  )
                : _properties.isEmpty
                    ? _buildEmptyState()
                    : _buildPropertiesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Properties',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          // City Filter
          DropdownButtonFormField<int>(
            value: _selectedCityId,
            decoration: InputDecoration(
              labelText: 'City',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: [
              const DropdownMenuItem<int>(value: null, child: Text('All Cities')),
              ..._cities.map((city) => DropdownMenuItem<int>(
                    value: city.id,
                    child: Text(city.name),
                  )),
            ],
            onChanged: (value) {
              setState(() => _selectedCityId = value);
            },
          ),
          const SizedBox(height: 16),
          // Property Type Filter
          DropdownButtonFormField<int>(
            value: _selectedPropertyTypeId,
            decoration: InputDecoration(
              labelText: 'Property Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: [
              const DropdownMenuItem<int>(value: null, child: Text('All Types')),
              ..._propertyTypes.map((type) => DropdownMenuItem<int>(
                    value: type.id,
                    child: Text(type.name),
                  )),
            ],
            onChanged: (value) {
              setState(() => _selectedPropertyTypeId = value);
            },
          ),
          const SizedBox(height: 16),
          // Price Range
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Min Price',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    _minPrice = value.isEmpty ? null : double.tryParse(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _maxPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Max Price',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    _maxPrice = value.isEmpty ? null : double.tryParse(value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Bedrooms
          TextField(
            controller: _minBedroomsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Min Bedrooms',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              _minBedrooms = value.isEmpty ? null : int.tryParse(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF5B9BD5).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.home_outlined,
                size: 56,
                color: const Color(0xFF5B9BD5).withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No properties found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertiesList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _properties.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final property = _properties[index];
        return _buildPropertyCard(property);
      },
    );
  }

  Widget _buildPropertyCard(Property property) {
    // Get cover image or first image
    final coverImage = property.images.isNotEmpty
        ? property.images.firstWhere(
            (img) => img.isCover,
            orElse: () => property.images.first,
          )
        : null;

    ImageProvider? imageProvider;
    if (coverImage != null && coverImage.imageData.isNotEmpty) {
      try {
        final bytes = base64Decode(coverImage.imageData);
        imageProvider = MemoryImage(bytes);
      } catch (_) {
        imageProvider = null;
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PropertyDetailsScreen(propertyId: property.id),
            ),
          );
        },
        child: Container(
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
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Stack(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: imageProvider != null
                          ? Image(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              Icons.home_rounded,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                    ),
                    // Price Badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5B9BD5), Color(0xFF7AB8CC)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '\$${property.pricePerMonth.toStringAsFixed(0)}/mo',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      property.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Location
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${property.cityName}${property.address != null ? ', ${property.address}' : ''}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Property Details
                    Row(
                      children: [
                        _buildDetailChip(
                          icon: Icons.bed_rounded,
                          label: '${property.bedrooms} Bed',
                        ),
                        const SizedBox(width: 12),
                        _buildDetailChip(
                          icon: Icons.bathtub_rounded,
                          label: '${property.bathrooms} Bath',
                        ),
                        const SizedBox(width: 12),
                        _buildDetailChip(
                          icon: Icons.square_foot_rounded,
                          label: '${property.area.toStringAsFixed(0)} m²',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Property Type
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B9BD5).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        property.propertyTypeName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5B9BD5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
