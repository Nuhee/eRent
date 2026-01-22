import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:erent_landlord_desktop/layouts/master_screen.dart';
import 'package:erent_landlord_desktop/model/property.dart';
import 'package:erent_landlord_desktop/model/property_type.dart';
import 'package:erent_landlord_desktop/model/city.dart';
import 'package:erent_landlord_desktop/model/amenity.dart';
import 'package:erent_landlord_desktop/providers/property_provider.dart';
import 'package:erent_landlord_desktop/providers/property_type_provider.dart';
import 'package:erent_landlord_desktop/providers/city_provider.dart';
import 'package:erent_landlord_desktop/providers/amenity_provider.dart';
import 'package:erent_landlord_desktop/providers/property_image_provider.dart';
import 'package:erent_landlord_desktop/providers/user_provider.dart';
import 'package:erent_landlord_desktop/utils/map_location_picker.dart';

class PropertyEditScreen extends StatefulWidget {
  final Property? property;

  const PropertyEditScreen({super.key, this.property});

  @override
  State<PropertyEditScreen> createState() => _PropertyEditScreenState();
}

class _PropertyEditScreenState extends State<PropertyEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoadingData = true;
  String? _loadError;

  // Form controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _pricePerMonthController = TextEditingController();
  final TextEditingController _pricePerDayController = TextEditingController();
  final TextEditingController _bedroomsController = TextEditingController();
  final TextEditingController _bathroomsController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Form state
  bool _allowDailyRental = false;
  bool _isActive = true;
  int? _selectedPropertyTypeId;
  int? _selectedCityId;
  List<int> _selectedAmenityIds = [];
  
  // Location - defaults to Sarajevo, Bosnia
  LatLng _selectedLocation = LatLng(
    MapLocationPicker.defaultLatitude,
    MapLocationPicker.defaultLongitude,
  );

  // Data lists
  List<PropertyType> _propertyTypes = [];
  List<City> _cities = [];
  List<Amenity> _amenities = [];

  // Images
  List<_ImageItem> _images = [];
  int? _coverImageIndex;

  bool get _isEditing => widget.property != null;

  @override
  void initState() {
    super.initState();
    // Set default values
    _bedroomsController.text = '0';
    _bathroomsController.text = '0';
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingData = true;
      _loadError = null;
    });

    try {
      print('Loading data for property edit screen...');
      
      final propertyTypeProvider = context.read<PropertyTypeProvider>();
      final cityProvider = context.read<CityProvider>();
      final amenityProvider = context.read<AmenityProvider>();

      // Load all required data in parallel
      final results = await Future.wait([
        propertyTypeProvider.get(filter: {'isActive': true, 'retrieveAll': true}),
        cityProvider.get(filter: {'isActive': true, 'retrieveAll': true}),
        amenityProvider.get(filter: {'isActive': true, 'retrieveAll': true}),
      ]);

      final propertyTypesResult = results[0];
      final citiesResult = results[1];
      final amenitiesResult = results[2];

      print('Loaded ${propertyTypesResult.items?.length ?? 0} property types');
      print('Loaded ${citiesResult.items?.length ?? 0} cities');
      print('Loaded ${amenitiesResult.items?.length ?? 0} amenities');

      if (!mounted) return;

      setState(() {
        _propertyTypes = (propertyTypesResult.items ?? []).cast<PropertyType>();
        _cities = (citiesResult.items ?? []).cast<City>();
        _amenities = (amenitiesResult.items ?? []).cast<Amenity>();
      });

      // If editing, populate form with existing data
      if (_isEditing) {
        _populateFormFromProperty();
      }
      
      print('Data loading completed successfully');
    } catch (e, stackTrace) {
      print('Error loading data: $e');
      print('Stack trace: $stackTrace');
      
      if (!mounted) return;
      
      setState(() {
        _loadError = e.toString();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load data: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  void _populateFormFromProperty() {
    final property = widget.property!;
    print('Populating form from property: ${property.title}');
    
    _titleController.text = property.title;
    _descriptionController.text = property.description ?? '';
    _pricePerMonthController.text = property.pricePerMonth.toString();
    _pricePerDayController.text = property.pricePerDay?.toString() ?? '';
    _bedroomsController.text = property.bedrooms.toString();
    _bathroomsController.text = property.bathrooms.toString();
    _areaController.text = property.area.toString();
    _addressController.text = property.address ?? '';
    _selectedLocation = LatLng(property.latitude, property.longitude);
    _allowDailyRental = property.allowDailyRental;
    _isActive = property.isActive;
    _selectedPropertyTypeId = property.propertyTypeId;
    _selectedCityId = property.cityId;
    _selectedAmenityIds = property.amenities.map((a) => a.id).toList();

    print('Selected amenity IDs: $_selectedAmenityIds');

    // Load existing images
    _images.clear();
    _coverImageIndex = null;
    
    for (int i = 0; i < property.images.length; i++) {
      final img = property.images[i];
      try {
        _images.add(_ImageItem(
          id: img.id,
          data: base64Decode(img.imageData),
          isExisting: true,
        ));
        if (img.isCover) {
          _coverImageIndex = i;
        }
      } catch (e) {
        print('Error decoding image ${img.id}: $e');
      }
    }
    
    if (_coverImageIndex == null && _images.isNotEmpty) {
      _coverImageIndex = 0;
    }
    
    print('Loaded ${_images.length} images, cover index: $_coverImageIndex');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pricePerMonthController.dispose();
    _pricePerDayController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );

      if (result != null) {
        setState(() {
          for (var file in result.files) {
            if (file.bytes != null) {
              _images.add(_ImageItem(
                data: file.bytes!,
                isExisting: false,
              ));
            }
          }
          if (_coverImageIndex == null && _images.isNotEmpty) {
            _coverImageIndex = 0;
          }
        });
      }
    } catch (e) {
      print('Error picking images: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick images: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      if (_coverImageIndex == index) {
        _coverImageIndex = _images.isNotEmpty ? 0 : null;
      } else if (_coverImageIndex != null && _coverImageIndex! > index) {
        _coverImageIndex = _coverImageIndex! - 1;
      }
    });
  }

  void _setCoverImage(int index) {
    setState(() {
      _coverImageIndex = index;
    });
  }

  Future<void> _saveProperty() async {
    print('Save property called');
    
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    if (_selectedPropertyTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a property type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a city'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final landlordId = UserProvider.currentUser?.id;
    if (landlordId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not logged in. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final propertyProvider = context.read<PropertyProvider>();
      final propertyImageProvider = context.read<PropertyImageProvider>();

      // Parse numeric values
      final pricePerMonth = double.tryParse(_pricePerMonthController.text) ?? 0;
      final pricePerDay = _allowDailyRental && _pricePerDayController.text.isNotEmpty
          ? double.tryParse(_pricePerDayController.text)
          : null;
      final bedrooms = int.tryParse(_bedroomsController.text) ?? 0;
      final bathrooms = int.tryParse(_bathroomsController.text) ?? 0;
      final area = double.tryParse(_areaController.text) ?? 0;

      // Prepare request - ensure amenityIds is always a list
      final request = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'pricePerMonth': pricePerMonth,
        'pricePerDay': pricePerDay,
        'allowDailyRental': _allowDailyRental,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'area': area,
        'propertyTypeId': _selectedPropertyTypeId,
        'cityId': _selectedCityId,
        'landlordId': landlordId,
        'address': _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        'latitude': _selectedLocation.latitude,
        'longitude': _selectedLocation.longitude,
        'isActive': _isActive,
        'amenityIds': _selectedAmenityIds,
      };

      print('Sending request: $request');

      Property savedProperty;
      if (_isEditing) {
        print('Updating property ${widget.property!.id}');
        savedProperty = await propertyProvider.update(widget.property!.id, request);
        print('Property updated successfully');
      } else {
        print('Creating new property');
        savedProperty = await propertyProvider.insert(request);
        print('Property created with ID: ${savedProperty.id}');
      }

      // Handle images
      if (_isEditing) {
        // Delete removed existing images
        final existingImageIds = widget.property!.images.map((i) => i.id).toSet();
        final currentExistingIds = _images
            .where((i) => i.isExisting && i.id != null)
            .map((i) => i.id!)
            .toSet();
        final idsToDelete = existingImageIds.difference(currentExistingIds);
        
        print('Deleting ${idsToDelete.length} images');
        for (var id in idsToDelete) {
          try {
            await propertyImageProvider.delete(id);
          } catch (e) {
            print('Error deleting image $id: $e');
          }
        }
      }

      // Upload new images
      print('Uploading ${_images.where((i) => !i.isExisting).length} new images');
      for (int i = 0; i < _images.length; i++) {
        final img = _images[i];
        if (!img.isExisting) {
          try {
            await propertyImageProvider.insert({
              'propertyId': savedProperty.id,
              'imageData': base64Encode(img.data),
              'displayOrder': i,
              'isCover': i == _coverImageIndex,
              'isActive': true,
            });
          } catch (e) {
            print('Error uploading image: $e');
          }
        } else if (img.id != null) {
          // Update existing image cover status if needed
          final originalImage = widget.property?.images.firstWhere(
            (x) => x.id == img.id,
            orElse: () => widget.property!.images.first,
          );
          if (originalImage != null && originalImage.isCover != (i == _coverImageIndex)) {
            try {
              await propertyImageProvider.update(img.id!, {
                'propertyId': savedProperty.id,
                'imageData': base64Encode(img.data),
                'displayOrder': i,
                'isCover': i == _coverImageIndex,
                'isActive': true,
              });
            } catch (e) {
              print('Error updating image cover status: $e');
            }
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(_isEditing
                    ? 'Property updated successfully'
                    : 'Property created successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e, stackTrace) {
      print('Error saving property: $e');
      print('Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save property: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: _isEditing ? 'Edit Property' : 'Add Property',
      showBackButton: true,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoadingData) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFFFB84D)),
            SizedBox(height: 16),
            Text('Loading data...'),
          ],
        ),
      );
    }

    if (_loadError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Failed to load data',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              _loadError!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB84D),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildBasicInfoCard(),
                          const SizedBox(height: 16),
                          _buildPricingCard(),
                          const SizedBox(height: 16),
                          _buildSpecificationsCard(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          _buildLocationCard(),
                          const SizedBox(height: 16),
                          _buildAmenitiesCard(),
                          const SizedBox(height: 16),
                          _buildImagesCard(),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
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
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFB84D), Color(0xFFFFA366)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.home_rounded, size: 28, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Edit Property' : 'Add New Property',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isEditing
                      ? 'Update the details of your property'
                      : 'Fill in the details to list your property',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Status',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  color: _isActive
                      ? const Color(0xFFFFB84D).withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: _isActive,
                      onChanged: (value) => setState(() => _isActive = value),
                      activeColor: const Color(0xFFFFB84D),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Text(
                        _isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _isActive
                              ? const Color(0xFFFFB84D)
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
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
                child: Icon(icon, color: const Color(0xFFFFB84D), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return _buildCard(
      title: 'Basic Information',
      icon: Icons.info_outline_rounded,
      children: [
        _buildTextField(
          controller: _titleController,
          label: 'Title *',
          hint: 'Enter property title',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Title is required';
            }
            if (value.length > 200) {
              return 'Title must be less than 200 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _descriptionController,
          label: 'Description',
          hint: 'Enter property description',
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          value: _selectedPropertyTypeId,
          decoration: InputDecoration(
            labelText: 'Property Type *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFFB84D), width: 2),
            ),
          ),
          items: _propertyTypes
              .map((pt) => DropdownMenuItem<int>(value: pt.id, child: Text(pt.name)))
              .toList(),
          onChanged: (value) => setState(() => _selectedPropertyTypeId = value),
          validator: (value) => value == null ? 'Please select a property type' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          value: _selectedCityId,
          decoration: InputDecoration(
            labelText: 'City *',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFFB84D), width: 2),
            ),
          ),
          items: _cities
              .map((c) => DropdownMenuItem<int>(
                    value: c.id,
                    child: Text('${c.name}, ${c.countryName}'),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _selectedCityId = value),
          validator: (value) => value == null ? 'Please select a city' : null,
        ),
      ],
    );
  }

  Widget _buildPricingCard() {
    return _buildCard(
      title: 'Pricing',
      icon: Icons.attach_money_rounded,
      children: [
        _buildTextField(
          controller: _pricePerMonthController,
          label: 'Price per Month (€) *',
          hint: 'Enter monthly price',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Price per month is required';
            }
            final price = double.tryParse(value);
            if (price == null || price <= 0) {
              return 'Please enter a valid price greater than 0';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Allow Daily Rental'),
          subtitle: Text(
            _allowDailyRental ? 'Tenants can rent per day' : 'Only monthly rentals',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          value: _allowDailyRental,
          onChanged: (value) => setState(() => _allowDailyRental = value),
          activeColor: const Color(0xFFFFB84D),
          contentPadding: EdgeInsets.zero,
        ),
        if (_allowDailyRental) ...[
          const SizedBox(height: 16),
          _buildTextField(
            controller: _pricePerDayController,
            label: 'Price per Day (€) *',
            hint: 'Enter daily price',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
            validator: (value) {
              if (_allowDailyRental) {
                if (value == null || value.isEmpty) {
                  return 'Price per day is required when daily rental is allowed';
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return 'Please enter a valid price greater than 0';
                }
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSpecificationsCard() {
    return _buildCard(
      title: 'Specifications',
      icon: Icons.home_work_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _bedroomsController,
                label: 'Bedrooms *',
                hint: '0',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final num = int.tryParse(value);
                  if (num == null || num < 0) return 'Invalid';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _bathroomsController,
                label: 'Bathrooms *',
                hint: '0',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final num = int.tryParse(value);
                  if (num == null || num < 0) return 'Invalid';
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _areaController,
          label: 'Area (m²) *',
          hint: 'Enter area in square meters',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
          validator: (value) {
            if (value == null || value.isEmpty) return 'Area is required';
            final area = double.tryParse(value);
            if (area == null || area <= 0) return 'Please enter a valid area greater than 0';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationCard() {
    return _buildCard(
      title: 'Location',
      icon: Icons.location_on_outlined,
      children: [
        _buildTextField(
          controller: _addressController,
          label: 'Address',
          hint: 'Enter street address',
        ),
        const SizedBox(height: 16),
        // Map location picker
        MapLocationPicker(
          initialLatitude: _selectedLocation.latitude,
          initialLongitude: _selectedLocation.longitude,
          height: 300,
          showCoordinatesInput: false,
          onLocationChanged: (location) {
            setState(() {
              _selectedLocation = location;
            });
            print('Location changed: ${location.latitude}, ${location.longitude}');
          },
        ),
      ],
    );
  }

  Widget _buildAmenitiesCard() {
    return _buildCard(
      title: 'Amenities (${_selectedAmenityIds.length} selected)',
      icon: Icons.star_outline_rounded,
      children: [
        if (_amenities.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('No amenities available', style: TextStyle(color: Colors.grey[600])),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _amenities.map((amenity) {
              final isSelected = _selectedAmenityIds.contains(amenity.id);
              return FilterChip(
                label: Text(amenity.name),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedAmenityIds.add(amenity.id);
                    } else {
                      _selectedAmenityIds.remove(amenity.id);
                    }
                  });
                  print('Amenities selected: $_selectedAmenityIds');
                },
                selectedColor: const Color(0xFFFFB84D).withOpacity(0.2),
                checkmarkColor: const Color(0xFFFFB84D),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFFFFB84D) : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFFFFB84D) : Colors.grey.withOpacity(0.3),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildImagesCard() {
    return _buildCard(
      title: 'Images (${_images.length})',
      icon: Icons.image_outlined,
      children: [
        ElevatedButton.icon(
          onPressed: _pickImages,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: const Text('Add Images'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFB84D),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),
        if (_images.isEmpty)
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text('No images added', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(_images.length, (index) {
              final img = _images[index];
              final isCover = index == _coverImageIndex;
              return Stack(
                children: [
                  Container(
                    width: 120,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCover ? const Color(0xFFFFB84D) : Colors.grey.withOpacity(0.2),
                        width: isCover ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        img.data,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: Icon(Icons.broken_image, color: Colors.grey[400]),
                          );
                        },
                      ),
                    ),
                  ),
                  if (isCover)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB84D),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Cover',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Row(
                      children: [
                        if (!isCover)
                          _buildImageActionButton(
                            icon: Icons.star_outline,
                            color: Colors.blue,
                            onTap: () => _setCoverImage(index),
                            tooltip: 'Set as cover',
                          ),
                        const SizedBox(width: 4),
                        _buildImageActionButton(
                          icon: Icons.close,
                          color: Colors.red,
                          onTap: () => _removeImage(index),
                          tooltip: 'Remove',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
      ],
    );
  }

  Widget _buildImageActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 14),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            side: BorderSide(color: Colors.grey[400]!),
          ),
          child: Text('Cancel', style: TextStyle(color: Colors.grey[700])),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveProperty,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFB84D),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_isEditing ? Icons.save_outlined : Icons.add_rounded),
                    const SizedBox(width: 8),
                    Text(_isEditing ? 'Save Changes' : 'Create Property'),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFFB84D), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _ImageItem {
  final int? id;
  final Uint8List data;
  final bool isExisting;

  _ImageItem({this.id, required this.data, required this.isExisting});
}
