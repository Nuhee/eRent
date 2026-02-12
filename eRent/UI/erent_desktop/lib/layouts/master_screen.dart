import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:erent_desktop/main.dart';
import 'package:erent_desktop/providers/user_provider.dart';
import 'package:erent_desktop/screens/country_list_screen.dart';
import 'package:erent_desktop/screens/city_list_screen.dart';
import 'package:erent_desktop/screens/review_list_screen.dart';
import 'package:erent_desktop/screens/users_list_screen.dart';
import 'package:erent_desktop/screens/property_type_list_screen.dart';
import 'package:erent_desktop/screens/amenity_list_screen.dart';
import 'package:erent_desktop/screens/property_list_screen.dart';
import 'package:erent_desktop/screens/rent_list_screen.dart';
import 'package:erent_desktop/screens/viewing_list_screen.dart';
import 'package:erent_desktop/screens/analytics_screen.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({
    super.key,
    required this.child,
    required this.title,
    this.showBackButton = false,
  });
  final Widget child;
  final String title;
  final bool showBackButton;

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  String _getUserInitials(String? firstName, String? lastName) {
    final f = (firstName ?? '').trim();
    final l = (lastName ?? '').trim();
    if (f.isEmpty && l.isEmpty) return 'U';
    final a = f.isNotEmpty ? f[0] : '';
    final b = l.isNotEmpty ? l[0] : '';
    return (a + b).toUpperCase();
  }

  // Profile overlay removed - profile is now in drawer header

  @override
  Widget build(BuildContext context) {
    final user = UserProvider.currentUser;
    ImageProvider? imageProvider;
    
    if (user?.picture != null && user!.picture!.isNotEmpty) {
      try {
        final sanitized = user.picture!.replaceAll(
          RegExp(r'^data:image/[^;]+;base64,'),
          '',
        );
        final bytes = base64Decode(sanitized);
        imageProvider = MemoryImage(bytes);
      } catch (_) {
        imageProvider = null;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.grey.withOpacity(0.1),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF5B9BD5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.menu_rounded,
                color: Color(0xFF5B9BD5),
                size: 20,
              ),
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
              _animationController?.forward();
            },
          ),
        ),
        title: Row(
          children: [
            if (widget.showBackButton) ...[
              Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF374151),
                    size: 18,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Profile Info in Header
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      user != null
                          ? '${user.firstName} ${user.lastName}'
                          : 'Guest',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B9BD5).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Administrator',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF5B9BD5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF5B9BD5).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF5B9BD5),
                    backgroundImage: imageProvider,
                    child: imageProvider == null
                        ? Text(
                            _getUserInitials(user?.firstName, user?.lastName),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        width: 280,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: _slideAnimation != null
            ? AnimatedBuilder(
                animation: _slideAnimation!,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_slideAnimation!.value * 280, 0),
                    child: _buildDrawerContent(),
                  );
                },
              )
            : _buildDrawerContent(),
      ),
      body: Container(margin: const EdgeInsets.all(16), child: widget.child),
    );
  }

  Widget _buildDrawerContent() {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 16, right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Simple header with logo/title
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF5B9BD5),
                  Color(0xFF7AB8CC),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.dashboard_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Navigation',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildFocusedNav(context)),
          _buildDrawerFooter(context),
        ],
      ),
    );
  }


  Widget _buildFocusedNav(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Analytics Section (First as requested)
            _buildSectionHeader('Analytics & Reports', Icons.analytics_outlined),
            const SizedBox(height: 8),
            _modernDrawerTile(
              context,
              icon: Icons.analytics_outlined,
              activeIcon: Icons.analytics_rounded,
              label: 'Business Analytics',
              screen: const AnalyticsScreen(),
            ),
            const SizedBox(height: 20),
            
            // Core Business Section
            _buildSectionHeader('Core Business', Icons.business_outlined),
            const SizedBox(height: 8),
            _modernDrawerTile(
              context,
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Properties',
              screen: const PropertyListScreen(),
            ),
            const SizedBox(height: 5),
            _modernDrawerTile(
              context,
              icon: Icons.receipt_long_outlined,
              activeIcon: Icons.receipt_long_rounded,
              label: 'Rents',
              screen: const RentListScreen(),
            ),
            const SizedBox(height: 5),
            _modernDrawerTile(
              context,
              icon: Icons.calendar_today_outlined,
              activeIcon: Icons.calendar_today_rounded,
              label: 'Viewing Appointments',
              screen: const ViewingListScreen(),
            ),
            const SizedBox(height: 5),
            _modernDrawerTile(
              context,
              icon: Icons.rate_review_outlined,
              activeIcon: Icons.rate_review,
              label: 'Reviews',
              screen: ReviewListScreen(),
            ),
            const SizedBox(height: 20),
            
            // Configuration Section
            _buildSectionHeader('Configuration', Icons.settings_outlined),
            const SizedBox(height: 8),
            _modernDrawerTile(
              context,
              icon: Icons.flag_outlined,
              activeIcon: Icons.flag_rounded,
              label: 'Countries',
              screen: CountryListScreen(),
            ),
            const SizedBox(height: 5),
            _modernDrawerTile(
              context,
              icon: Icons.location_city_outlined,
              activeIcon: Icons.location_city_rounded,
              label: 'Cities',
              screen: CityListScreen(),
            ),
            const SizedBox(height: 5),
            _modernDrawerTile(
              context,
              icon: Icons.category_outlined,
              activeIcon: Icons.category,
              label: 'Property Types',
              screen: const PropertyTypeListScreen(),
            ),
            const SizedBox(height: 5),
            _modernDrawerTile(
              context,
              icon: Icons.star_outlined,
              activeIcon: Icons.star,
              label: 'Amenities',
              screen: const AmenityListScreen(),
            ),
            const SizedBox(height: 20),
            
            // User Management Section
            _buildSectionHeader('User Management', Icons.people_outlined),
            const SizedBox(height: 8),
            _modernDrawerTile(
              context,
              icon: Icons.people_outlined,
              activeIcon: Icons.people_rounded,
              label: 'Users',
              screen: const UsersListScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF5B9BD5).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 14,
              color: const Color(0xFF5B9BD5),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: _modernLogoutTile(context),
    );
  }
}



Widget _modernDrawerTile(
  BuildContext context, {
  required IconData icon,
  required IconData activeIcon,
  required String label,
  required Widget screen,
}) {
  final currentRoute = ModalRoute.of(context)?.settings.name;
  final screenRoute = screen.runtimeType.toString();

  // Get the current screen type from the route
  bool isSelected = false;

  if (label == 'Cities') {
    isSelected =
        currentRoute == 'CityListScreen' ||
        currentRoute == 'CityDetailsScreen' ||
        currentRoute == 'CityEditScreen';
  } else if (label == 'Reviews') {
    isSelected =
        currentRoute == 'ReviewListScreen' ||
        currentRoute == 'ReviewDetailsScreen';
  } else if (label == 'Countries') {
    isSelected =
        currentRoute == 'CountryListScreen' ||
        currentRoute == 'CountryDetailsScreen' ||
        currentRoute == 'CountryEditScreen';
  } else if (label == 'Users') {
    isSelected =
        currentRoute == 'UsersListScreen' ||
        currentRoute == 'UsersDetailsScreen' ||
        currentRoute == 'UsersEditScreen';
  } else if (label == 'Property Types') {
    isSelected =
        currentRoute == 'PropertyTypeListScreen' ||
        currentRoute == 'PropertyTypeDetailsScreen' ||
        currentRoute == 'PropertyTypeEditScreen';
  } else if (label == 'Amenities') {
    isSelected =
        currentRoute == 'AmenityListScreen' ||
        currentRoute == 'AmenityDetailsScreen' ||
        currentRoute == 'AmenityEditScreen';
  } else if (label == 'Properties') {
    isSelected =
        currentRoute == 'PropertyListScreen' ||
        currentRoute == 'PropertyDetailsScreen';
  } else if (label == 'Rents') {
    isSelected =
        currentRoute == 'RentListScreen' ||
        currentRoute == 'RentDetailsScreen';
  } else if (label == 'Business Analytics') {
    isSelected = currentRoute == 'AnalyticsScreen';
  }

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 2),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => screen,
              settings: RouteSettings(name: screenRoute),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF5B9BD5).withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: const Color(0xFF5B9BD5).withOpacity(0.3),
                    width: 1,
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF5B9BD5).withOpacity(0.15)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected
                      ? const Color(0xFF5B9BD5)
                      : Colors.grey[700],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF1F2937)
                        : Colors.grey[700],
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF5B9BD5),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _modernLogoutTile(BuildContext context) {
  return Container(
    width: double.infinity,
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showLogoutDialog(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.red, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red, size: 24),
            SizedBox(width: 12),
            Text(
              'Confirm Logout',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout from your account?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      );
    },
  );
}
