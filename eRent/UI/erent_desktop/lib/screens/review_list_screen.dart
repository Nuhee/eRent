import 'package:flutter/material.dart';
import 'package:erent_desktop/layouts/master_screen.dart';
import 'package:erent_desktop/model/review.dart';
import 'package:erent_desktop/model/search_result.dart';
import 'package:erent_desktop/providers/review_provider.dart';
import 'package:erent_desktop/screens/review_details_screen.dart';
import 'package:erent_desktop/utils/base_pagination.dart';
import 'package:erent_desktop/utils/base_table.dart';
import 'package:erent_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';

class ReviewListScreen extends StatefulWidget {
  const ReviewListScreen({super.key});

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  late ReviewProvider reviewProvider;

  final TextEditingController userFullNameController = TextEditingController();
  int? selectedRating;

  SearchResult<Review>? reviews;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 10, 20, 50];

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;

    final filter = {
      if (userFullNameController.text.isNotEmpty) 
        'userFullName': userFullNameController.text,
      if (selectedRating != null) 'rating': selectedRating,
      'page': pageToFetch,
      'pageSize': pageSizeToUse,
      'includeTotalCount': true,
    };

    final result = await reviewProvider.get(filter: filter);
    setState(() {
      reviews = result;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      reviewProvider = context.read<ReviewProvider>();
      await _performSearch(page: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Reviews Management',
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: customTextFieldDecoration(
                    'User Full Name',
                    prefixIcon: Icons.person_search,
                  ),
                  controller: userFullNameController,
                  onSubmitted: (_) => _performSearch(page: 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<int?>(
                  decoration: customTextFieldDecoration(
                    'Rating',
                    prefixIcon: Icons.star,
                  ),
                  value: selectedRating,
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('All Ratings'),
                    ),
                    ...List.generate(5, (index) => index + 1).map(
                      (rating) => DropdownMenuItem<int>(
                        value: rating,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$rating'),
                            const SizedBox(width: 4),
                            ...List.generate(
                              rating,
                              (index) => const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  onChanged: (int? value) {
                    setState(() {
                      selectedRating = value;
                    });
                    _performSearch(page: 0);
                  },
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
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  userFullNameController.clear();
                  setState(() {
                    selectedRating = null;
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
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final isEmpty =
        reviews == null || reviews!.items == null || reviews!.items!.isEmpty;
    final int totalCount = reviews?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;

    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTable(
            icon: Icons.star,
            title: 'Reviews',
            width: 1200,
            height: 423,
            columnWidths: const [
              220, // User
              140, // Rating
              240, // Car
              150, // Parking Spot
              180, // Date
              120, // Actions
            ],
            columns: const [
              DataColumn(
                label: Text(
                  'User',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Rating',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Car',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Parking Spot',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
 
              DataColumn(
                label: Text(
                  'Date',
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
                : reviews!.items!
                      .map(
                        (e) => DataRow(
                          cells: [
                            DataCell(
                              Text(
                                e.userFullName ?? 'N/A',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ...List.generate(
                                    e.rating,
                                    (index) => const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                  ),
                                  ...List.generate(
                                    5 - e.rating,
                                    (index) => Icon(
                                      Icons.star_border,
                                      size: 16,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Text(
                                _formatCarDisplay(e),
                                style: const TextStyle(fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DataCell(
                              Text(
                                e.parkingSpotNumber ?? 'N/A',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                      
                            DataCell(
                              Text(
                                _formatDate(e.createdAt),
                                style: const TextStyle(fontSize: 15),
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
                                                  ReviewDetailsScreen(review: e),
                                              settings: const RouteSettings(
                                                name: 'ReviewDetailsScreen',
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
            emptyIcon: Icons.rate_review,
            emptyText: 'No reviews found.',
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatCarDisplay(Review review) {
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
