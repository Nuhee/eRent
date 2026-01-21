import 'package:flutter/material.dart';
import 'package:erent_mobile/providers/user_provider.dart';
import 'package:erent_mobile/screens/profile_screen.dart';
import 'package:erent_mobile/screens/home_screen.dart';


class CustomPageViewScrollPhysics extends ScrollPhysics {
  final int currentIndex;

  const CustomPageViewScrollPhysics({
    required this.currentIndex,
    ScrollPhysics? parent,
  }) : super(parent: parent);

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(
      currentIndex: currentIndex,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Prevent swiping from profile (index 2) to logout (index 3)
    if (currentIndex == 3 && value > position.pixels) {
      return value - position.pixels;
    }
    return super.applyBoundaryConditions(position, value);
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    // Prevent swiping from profile (index 2) to logout (index 3)
    if (currentIndex == 2) {
      return false;
    }
    return super.shouldAcceptUserOffset(position);
  }
}

class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key, required this.child, required this.title});
  final Widget child;
  final String title;

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  int _selectedIndex = 0;
  late PageController _pageController;

  final List<String> _pageTitles = [
    'Home',
    'Services',
    'Products',
    'Reviews',
    'Purchases',
    'Profile',
  ];

  final List<IconData> _pageIcons = [
    Icons.home_rounded,
    Icons.spa_rounded,
    Icons.shopping_bag_rounded,
    Icons.rate_review_rounded,
    Icons.shopping_cart_rounded,
    Icons.person_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleLogout() {
    // Clear user data
    UserProvider.currentUser = null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFF2F855A)),
            SizedBox(width: 8),
            Text("Logout"),
          ],
        ),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              // Navigate back to login by popping all routes
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (route) => false);
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF2F855A),
            ),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Modern Header with Green Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF163A2A),
                  const Color(0xFF20523A),
                  const Color(0xFF2F855A),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2F855A).withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    // Logo/Icon - Changes based on selected tab
                    _buildHeaderIcon(),
                    const SizedBox(width: 12),
                    // Title
                    Expanded(
                      child: Text(
                        _pageTitles[_selectedIndex],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    // Logout Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: _handleLogout,
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        tooltip: 'Logout',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Page Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                _onPageChanged(index);
              },
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const HomeScreen(),
                const Placeholder(),
                const Placeholder(),
                const Placeholder(),
                const Placeholder(),
                const ProfileScreen(),
              ],
            ),
          ),

          // Modern Bottom Navigation with Green Theme
          Container(
            height: 85,
            decoration: BoxDecoration(
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              child: Row(
                children: [
                  // Home Tab
                  Expanded(
                    child: _buildNavigationItem(
                      index: 0,
                      icon: Icons.home_rounded,
                      label: 'Home',
                    ),
                  ),
                  // Services Tab
                  Expanded(
                    child: _buildNavigationItem(
                      index: 1,
                      icon: Icons.spa_rounded,
                      label: 'Services',
                    ),
                  ),
                  // Products Tab
                  Expanded(
                    child: _buildNavigationItem(
                      index: 2,
                      icon: Icons.shopping_bag_rounded,
                      label: 'Products',
                    ),
                  ),
                  // Reviews Tab
                  Expanded(
                    child: _buildNavigationItem(
                      index: 3,
                      icon: Icons.rate_review_rounded,
                      label: 'Reviews',
                    ),
                  ),
                  // Purchases Tab
                  Expanded(
                    child: _buildNavigationItem(
                      index: 4,
                      icon: Icons.shopping_cart_rounded,
                      label: 'Purchases',
                    ),
                  ),
                  // Profile Tab
                  Expanded(
                    child: _buildNavigationItem(
                      index: 5,
                      icon: Icons.person_rounded,
                      label: 'Profile',
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

  Widget _buildHeaderIcon() {
    final user = UserProvider.currentUser;
    final isProfilePage = _selectedIndex == 5;

    // Show user profile picture if on profile page and user has picture
    if (isProfilePage && user?.picture != null && user!.picture!.isNotEmpty) {
      ImageProvider? imageProvider = ProfileScreen.getUserImageProvider(user.picture);

      return Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 12,
          backgroundColor: Colors.white.withOpacity(0.2),
          backgroundImage: imageProvider,
          child: imageProvider == null
              ? const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 20,
                )
              : null,
        ),
      );
    }

    // Show icon for other pages
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _pageIcons[_selectedIndex],
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildNavigationItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2F855A).withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2F855A).withOpacity(0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? const Color(0xFF2F855A)
                      : Colors.grey[600],
                  size: 22,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF2F855A)
                      : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
