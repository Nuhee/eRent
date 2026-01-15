import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:erent_desktop/layouts/master_screen.dart';
import 'package:erent_desktop/model/review.dart';

// Brown color scheme matching the app
const Color _brownPrimary = Color(0xFF8B6F47);
const Color _brownDark = Color(0xFF6B5434);

class ReviewDetailsScreen extends StatelessWidget {
  final Review review;

  const ReviewDetailsScreen({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Review Details',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
        child: _buildReviewDetails(context),
      ),
    );
  }

  Widget _buildReviewDetails(BuildContext context) {
    ImageProvider? imageProvider;
    if (review.userPicture != null && review.userPicture!.isNotEmpty) {
      try {
        final sanitized = review.userPicture!.replaceAll(
          RegExp(r'^data:image/[^;]+;base64,'),
          '',
        );
        final bytes = base64Decode(sanitized);
        imageProvider = MemoryImage(bytes);
      } catch (_) {
        imageProvider = null;
      }
    }

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          children: [
            // Hero section with gradient background
            Container(
              height: 280,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _brownPrimary,
                    _brownDark,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _brownPrimary.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Decorative circles
                  Positioned(
                    top: -50,
                    right: -50,
                    child: IgnorePointer(
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -30,
                    child: IgnorePointer(
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            // Rating icon in hero
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.star_rounded,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Review Details',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white70,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      ...List.generate(
                                        review.rating,
                                        (index) => const Icon(
                                          Icons.star_rounded,
                                          color: Colors.amber,
                                          size: 32,
                                        ),
                                      ),
                                      ...List.generate(
                                        5 - review.rating,
                                        (index) => const Icon(
                                          Icons.star_border_rounded,
                                          color: Colors.white70,
                                          size: 32,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        '${review.rating}/5',
                                        style: const TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: -1,
                                          height: 1.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Floating content card
            Transform.translate(
              offset: const Offset(0, -60),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Main info card
                      _buildModernInfoCard(imageProvider),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernInfoCard(ImageProvider? imageProvider) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[50]!,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // User picture
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _brownPrimary,
                      _brownDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _brownPrimary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: imageProvider != null
                      ? Image(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        )
                      : const Icon(
                          Icons.person_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                ),
              ),
              const SizedBox(width: 32),
              // Info section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RATING',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[600],
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ...List.generate(
                          review.rating,
                          (index) => const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 28,
                          ),
                        ),
                        ...List.generate(
                          5 - review.rating,
                          (index) => Icon(
                            Icons.star_border_rounded,
                            color: Colors.grey[400],
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${review.rating} out of 5',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2D2D2D),
                            letterSpacing: -0.3,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Decorative line
                    Container(
                      width: 60,
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            _brownPrimary,
                            _brownDark,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),
          // Review information
          _buildInfoGrid(),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'REVIEW & RESERVATION INFORMATION',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D2D2D),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Icons.person_outline,
                label: 'User',
                value: review.userFullName ?? 'N/A',
                iconColor: _brownPrimary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.email_outlined,
                label: 'Email',
                value: review.userEmail ?? 'N/A',
                iconColor: _brownPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Icons.calendar_today_outlined,
                label: 'Review Date',
                value: _formatDate(review.createdAt),
                iconColor: _brownPrimary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.confirmation_number_outlined,
                label: 'Reservation ID',
                value: '#${review.reservationId}',
                iconColor: _brownPrimary,
              ),
            ),
          ],
        ),
        if (review.carBrandName != null || review.carModel != null || review.carLicensePlate != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.directions_car_outlined,
                  label: 'Car',
                  value: _formatCarDisplay(),
                  iconColor: _brownPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.badge_outlined,
                  label: 'License Plate',
                  value: review.carLicensePlate ?? 'N/A',
                  iconColor: _brownPrimary,
                ),
              ),
            ],
          ),
        ],
        if (review.parkingSpotNumber != null || review.reservationTypeName != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.local_parking_outlined,
                  label: 'Parking Spot',
                  value: review.parkingSpotNumber ?? 'N/A',
                  iconColor: _brownPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.category_outlined,
                  label: 'Reservation Type',
                  value: review.reservationTypeName ?? 'N/A',
                  iconColor: _brownPrimary,
                ),
              ),
            ],
          ),
        ],
        if (review.reservationStartDate != null || review.reservationEndDate != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.play_circle_outline,
                  label: 'Start Date',
                  value: review.reservationStartDate != null
                      ? _formatDate(review.reservationStartDate!)
                      : 'N/A',
                  iconColor: _brownPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.stop_circle_outlined,
                  label: 'End Date',
                  value: review.reservationEndDate != null
                      ? _formatDate(review.reservationEndDate!)
                      : 'N/A',
                  iconColor: _brownPrimary,
                ),
              ),
            ],
          ),
        ],
        if (review.reservationFinalPrice != null) ...[
          const SizedBox(height: 16),
          _buildInfoItem(
            icon: Icons.attach_money_outlined,
            label: 'Final Price',
            value: '\$${review.reservationFinalPrice!.toStringAsFixed(2)}',
            iconColor: _brownPrimary,
          ),
        ],
        if (review.comment != null && review.comment!.isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.amber[50]!,
                  Colors.amber[100]!,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.amber[300]!,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.comment_rounded,
                        color: Colors.amber,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'COMMENT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[700],
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  review.comment!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2D2D2D),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: iconColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D2D2D),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatCarDisplay() {
    final parts = <String>[];
    if (review.carBrandName != null && review.carBrandName!.isNotEmpty) {
      parts.add(review.carBrandName!);
    }
    if (review.carModel != null && review.carModel!.isNotEmpty) {
      parts.add(review.carModel!);
    }
    
    final brandModel = parts.join(' ');
    final licensePlate = review.carLicensePlate;
    
    if (brandModel.isNotEmpty && licensePlate != null && licensePlate.isNotEmpty) {
      return '$brandModel ($licensePlate)';
    } else if (brandModel.isNotEmpty) {
      return brandModel;
    } else if (licensePlate != null && licensePlate.isNotEmpty) {
      return licensePlate;
    }
    return 'N/A';
  }
}
