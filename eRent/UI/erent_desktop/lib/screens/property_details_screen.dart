import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:erent_desktop/layouts/master_screen.dart';
import 'package:erent_desktop/model/property.dart';
import 'package:erent_desktop/model/property_image.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailsScreen({super.key, required this.property});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  int _currentImageIndex = 0;
  int _currentInfoCardIndex = 0;
  late PageController _pageController;
  late PageController _infoCardController;
  late List<PropertyImage> _sortedImages;
  final Map<int, Uint8List> _imageCache = {};

  @override
  void initState() {
    super.initState();
    // Sort images: cover first, then by display order, then by creation date
    _sortedImages = List.from(widget.property.images);
    _sortedImages.sort((a, b) {
      if (a.isCover && !b.isCover) return -1;
      if (!a.isCover && b.isCover) return 1;
      if (a.displayOrder != null && b.displayOrder != null) {
        return a.displayOrder!.compareTo(b.displayOrder!);
      }
      if (a.displayOrder != null) return -1;
      if (b.displayOrder != null) return 1;
      return a.createdAt.compareTo(b.createdAt);
    });
    
    // Pre-decode and cache all images
    for (var image in _sortedImages) {
      if (image.imageData.isNotEmpty) {
        try {
          _imageCache[image.id] = base64Decode(image.imageData);
        } catch (e) {
          // If decoding fails, cache will remain empty for this image
        }
      }
    }
    
    // Find cover image index
    _currentImageIndex = _sortedImages.indexWhere((img) => img.isCover);
    if (_currentImageIndex == -1) _currentImageIndex = 0;
    
    _pageController = PageController(initialPage: _currentImageIndex);
    _infoCardController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _infoCardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Property Details',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                _buildHeaderCard(),
                const SizedBox(height: 16),
                // Two Column Layout: Images and Info Cards
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Image Carousel
                    if (_sortedImages.isNotEmpty) ...[
                      Expanded(
                        flex: 1,
                        child: _buildImageCarousel(),
                      ),
                      const SizedBox(width: 16),
                    ],
                    // Right Column: Info Card Carousel
                    Expanded(
                      flex: 1,
                      child: _buildInfoCardCarousel(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF5B9BD5),
                  Color(0xFF7AB8CC),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5B9BD5).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.home_rounded,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          // Title and Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.property.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.property.cityName}, ${widget.property.propertyTypeName}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: widget.property.isActive
                  ? const Color(0xFF5B9BD5).withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.property.isActive
                    ? const Color(0xFF5B9BD5).withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.property.isActive ? Icons.check_circle : Icons.cancel,
                  color: widget.property.isActive
                      ? const Color(0xFF5B9BD5)
                      : Colors.grey[600],
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.property.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: widget.property.isActive
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

  Widget _buildImageCarousel() {
    return Container(
      height: 445,
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
      child: Stack(
        children: [
          // Image Display Area
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: _sortedImages.length,
            itemBuilder: (context, index) {
              final image = _sortedImages[index];
              final cachedImage = _imageCache[image.id];
              return Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: cachedImage != null
                      ? Image.memory(
                          cachedImage,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          cacheWidth: null,
                          cacheHeight: null,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder();
                          },
                        )
                      : _buildImagePlaceholder(),
                ),
              );
            },
          ),
          // Circular navigation for images
          if (_sortedImages.length > 1)
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left swipe area
                  GestureDetector(
                    onTap: () {
                      final newIndex = _currentImageIndex == 0 
                          ? _sortedImages.length - 1 
                          : _currentImageIndex - 1;
                      _pageController.animateToPage(
                        newIndex,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: 80,
                      color: Colors.transparent,
                    ),
                  ),
                  // Right swipe area
                  GestureDetector(
                    onTap: () {
                      final newIndex = _currentImageIndex == _sortedImages.length - 1 
                          ? 0 
                          : _currentImageIndex + 1;
                      _pageController.animateToPage(
                        newIndex,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      width: 80,
                      color: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          // Cover Badge (top right)
          if (_sortedImages[_currentImageIndex].isCover)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Cover',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Navigation and Indicators (bottom overlay)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Previous Button (circular)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        final newIndex = _currentImageIndex == 0 
                            ? _sortedImages.length - 1 
                            : _currentImageIndex - 1;
                        _pageController.animateToPage(
                          newIndex,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Image Indicators
                  ...List.generate(
                    _sortedImages.length,
                    (index) => GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: _currentImageIndex == index ? 24 : 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: _currentImageIndex == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Next Button (circular)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        final newIndex = _currentImageIndex == _sortedImages.length - 1 
                            ? 0 
                            : _currentImageIndex + 1;
                        _pageController.animateToPage(
                          newIndex,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'No image available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCardCarousel() {
    final List<Map<String, dynamic>> infoCards = [
      {
        'title': 'Property Details',
        'icon': Icons.info_outline_rounded,
        'children': [
          _buildInfoRow(
            label: 'Title',
            value: widget.property.title,
            icon: Icons.title_outlined,
          ),
          const SizedBox(height: 16),
          if (widget.property.description != null && widget.property.description!.isNotEmpty) ...[
            _buildInfoRow(
              label: 'Description',
              value: widget.property.description!,
              icon: Icons.description_outlined,
              isMultiline: true,
            ),
            const SizedBox(height: 16),
          ],
          _buildInfoRow(
            label: 'Property Type',
            value: widget.property.propertyTypeName,
            icon: Icons.category_outlined,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            label: 'City',
            value: widget.property.cityName,
            icon: Icons.location_city_outlined,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            label: 'Address',
            value: widget.property.address ?? 'N/A',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            label: 'Landlord',
            value: widget.property.landlordName,
            icon: Icons.person_outline,
          ),
        ],
      },
      {
        'title': 'Specifications',
        'icon': Icons.home_work_outlined,
        'children': [
          _buildInfoRow(
            label: 'Bedrooms',
            value: widget.property.bedrooms.toString(),
            icon: Icons.bed_outlined,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            label: 'Bathrooms',
            value: widget.property.bathrooms.toString(),
            icon: Icons.bathroom_outlined,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            label: 'Area',
            value: '${widget.property.area.toStringAsFixed(2)} m²',
            icon: Icons.square_foot_outlined,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            label: 'Price per Month',
            value: '€${widget.property.pricePerMonth.toStringAsFixed(2)}',
            icon: Icons.attach_money_outlined,
          ),
          if (widget.property.allowDailyRental && widget.property.pricePerDay != null) ...[
            const SizedBox(height: 16),
            _buildInfoRow(
              label: 'Price per Day',
              value: '€${widget.property.pricePerDay!.toStringAsFixed(2)}',
              icon: Icons.calendar_today_outlined,
            ),
          ],
        ],
      },
      {
        'title': 'Status & Amenities',
        'icon': Icons.verified_outlined,
        'children': [
          _buildInfoRow(
            label: 'Status',
            value: widget.property.isActive ? 'Active' : 'Inactive',
            icon: widget.property.isActive
                ? Icons.check_circle_outline
                : Icons.cancel_outlined,
            valueColor: widget.property.isActive
                ? const Color(0xFF5B9BD5)
                : Colors.grey[600],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            label: 'Daily Rental',
            value: widget.property.allowDailyRental ? 'Allowed' : 'Not Allowed',
            icon: Icons.event_available_outlined,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            label: 'Created At',
            value: _formatDate(widget.property.createdAt),
            icon: Icons.calendar_today_outlined,
          ),
          if (widget.property.updatedAt != null) ...[
            const SizedBox(height: 16),
            _buildInfoRow(
              label: 'Updated At',
              value: _formatDate(widget.property.updatedAt!),
              icon: Icons.update_outlined,
            ),
          ],
          if (widget.property.amenities.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildAmenitiesSection(),
          ],
        ],
      },
    ];

    return Container(
      height: 445,
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
      child: Stack(
        children: [
          // Info Card Display Area
          PageView.builder(
            controller: _infoCardController,
            onPageChanged: (index) {
              setState(() {
                _currentInfoCardIndex = index;
              });
            },
            itemCount: infoCards.length,
            itemBuilder: (context, index) {
              final card = infoCards[index];
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildDetailCard(
                  title: card['title'] as String,
                  icon: card['icon'] as IconData,
                  children: card['children'] as List<Widget>,
                ),
              );
            },
          ),
          // Navigation and Indicators (bottom overlay)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Previous Button (circular)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        final newIndex = _currentInfoCardIndex == 0 
                            ? infoCards.length - 1 
                            : _currentInfoCardIndex - 1;
                        _infoCardController.animateToPage(
                          newIndex,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Card Indicators
                  ...List.generate(
                    infoCards.length,
                    (index) => GestureDetector(
                      onTap: () {
                        _infoCardController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: _currentInfoCardIndex == index ? 24 : 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: _currentInfoCardIndex == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Next Button (circular)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        final newIndex = _currentInfoCardIndex == infoCards.length - 1 
                            ? 0 
                            : _currentInfoCardIndex + 1;
                        _infoCardController.animateToPage(
                          newIndex,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B9BD5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF5B9BD5),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
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

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
    bool isMultiline = false,
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
                maxLines: isMultiline ? null : 2,
                overflow: isMultiline ? null : TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.star_outlined,
              size: 20,
              color: const Color(0xFF5B9BD5),
            ),
            const SizedBox(width: 12),
            Text(
              'Amenities',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.property.amenities.map((amenity) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF5B9BD5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF5B9BD5).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 14,
                    color: const Color(0xFF5B9BD5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    amenity.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
