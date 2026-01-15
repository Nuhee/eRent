import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:erent_desktop/main.dart';
import 'package:erent_desktop/providers/user_provider.dart';
import 'package:erent_desktop/screens/city_list_screen.dart';
import 'package:erent_desktop/screens/review_list_screen.dart';
import 'package:erent_desktop/screens/users_list_screen.dart';
import 'package:erent_desktop/screens/brand_list_screen.dart';
import 'package:erent_desktop/screens/car_list_screen.dart';
import 'package:erent_desktop/screens/reservation_list_screen.dart';
import 'package:erent_desktop/screens/reservation_type_list_screen.dart';
import 'package:erent_desktop/screens/parking_spot_type_list_screen.dart';
import 'package:erent_desktop/screens/parking_zone_list_screen.dart';
import 'package:erent_desktop/screens/parking_watch_screen.dart';
import 'package:erent_desktop/screens/business_report_screen.dart';

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
                  color: const Color(0xFF8B6F47).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.menu_rounded,
                color: Color(0xFF8B6F47),
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
          // Profile moved to drawer header
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
    const gradientColors = [
      Color(0xFF1A1A1A),
      Color(0xFF2D2D2D),
      Color(0xFF3A3A3A),
    ];

    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 16, right: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(6, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(child: _buildFocusedNav(context)),
          _buildDrawerFooter(context),
        ],
      ),
    );
  }

 

Widget _buildDrawerHeader() {
  final user = UserProvider.currentUser;
  final double radius = 28;
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

  return Container(
    padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF8B6F47).withOpacity(0.2),
          const Color(0xFF8B6F47).withOpacity(0.1),
        ],
      ),
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(28),
      ),
    ),
    child: Row(
      children: [
        ClipOval(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF8B6F47).withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF8B6F47).withOpacity(0.4),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: radius,
              backgroundColor: const Color(0xFF8B6F47),
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? Text(
                      _getUserInitials(user?.firstName, user?.lastName),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user != null
                    ? '${user.firstName} ${user.lastName}'
                    : 'Guest',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                user?.username ?? 'Admin',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B6F47).withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF8B6F47).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.verified_user,
                      size: 14,
                      color: Color(0xFF8B6F47),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Administrator',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8B6F47),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


  Widget _buildFocusedNav(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Parking Section
            _buildSectionHeader('Parking Section'),
            const SizedBox(height: 8),
            _modernDrawerTile(
              context,
              icon: Icons.watch_later_outlined,
              activeIcon: Icons.watch_later,
              label: 'Live Parking Watch',
              screen: const ParkingWatchScreen(),
            ),
            const SizedBox(height: 5),
            _modernDrawerTile(
              context,
              icon: Icons.assessment_outlined,
              activeIcon: Icons.assessment,
              label: 'Business Report',
              screen: const BusinessReportScreen(),
            ),
            const SizedBox(height: 5),
            _modernDrawerTile(
              context,
              icon: Icons.location_on_outlined,
              activeIcon: Icons.location_on,
              label: 'Parking Zones',
              screen: const ParkingZoneListScreen(),
            ),
            const SizedBox(height: 5),
            _modernDrawerTile(
              context,
              icon: Icons.local_parking_outlined,
              activeIcon: Icons.local_parking,
              label: 'Parking Spot Types',
              screen: const ParkingSpotTypeListScreen(),
            ),
            const SizedBox(height: 5),
            _modernDrawerTile(
              context,
              icon: Icons.event_note_outlined,
              activeIcon: Icons.event_note,
              label: 'Reservations',
              screen: const ReservationListScreen(),
            ),
            const SizedBox(height: 5),
            _modernDrawerTile(
              context,
              icon: Icons.event_available_outlined,
              activeIcon: Icons.event_available,
              label: 'Reservation Types',
              screen: const ReservationTypeListScreen(),
            ),
            const SizedBox(height: 5),
            _modernDrawerTile(
              context,
              icon: Icons.directions_car_outlined,
              activeIcon: Icons.directions_car,
              label: 'Cars',
              screen: const CarListScreen(),
            ),
            const SizedBox(height: 5),
            _modernDrawerTile(
              context,
              icon: Icons.branding_watermark_outlined,
              activeIcon: Icons.branding_watermark,
              label: 'Brands',
              screen: const BrandListScreen(),
            ),
            const SizedBox(height: 5),
            
            // User Section
            _buildSectionHeader('User Section'),
            const SizedBox(height: 8),
            _modernDrawerTile(
              context,
              icon: Icons.people_outlined,
              activeIcon: Icons.people_rounded,
              label: 'Users',
              screen: const UsersListScreen(),
            ),
            const SizedBox(height: 5),
            
            // Reviews tile (no section header)
            _modernDrawerTile(
              context,
              icon: Icons.rate_review_outlined,
              activeIcon: Icons.rate_review,
              label: 'Reviews',
              screen: ReviewListScreen(),
            ),
            const SizedBox(height: 5),
            
            // Cities tile (no section header)
            _modernDrawerTile(
              context,
              icon: Icons.location_city_outlined,
              activeIcon: Icons.location_city_rounded,
              label: 'Cities',
              screen: CityListScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(28),
        ),
        color: Colors.black.withOpacity(0.08),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(
            color: Colors.white.withOpacity(0.18),
            thickness: 1,
          ),
          const SizedBox(height: 12),
          _modernLogoutTile(context),
        ],
      ),
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

  if (label == 'Live Parking Watch') {
    isSelected = currentRoute == 'ParkingWatchScreen';
  } else if (label == 'Business Report') {
    isSelected = currentRoute == 'BusinessReportScreen';
  } else if (label == 'Cities') {
    isSelected =
        currentRoute == 'CityListScreen' ||
        currentRoute == 'CityDetailsScreen' ||
        currentRoute == 'CityEditScreen';
  } else if (label == 'Reviews') {
    isSelected =
        currentRoute == 'ReviewListScreen' ||
        currentRoute == 'ReviewDetailsScreen';
  } else if (label == 'Users') {
    isSelected =
        currentRoute == 'UsersListScreen' ||
        currentRoute == 'UsersDetailsScreen' ||
        currentRoute == 'UsersEditScreen';
  } else if (label == 'Parking Zones') {
    isSelected =
        currentRoute == 'ParkingZoneListScreen' ||
        currentRoute == 'ParkingZoneAddEditScreen' ||
        currentRoute == 'ParkingSpotListScreen' ||
        currentRoute == 'ParkingSpotEditScreen';
  } else if (label == 'Parking Spot Types') {
    isSelected =
        currentRoute == 'ParkingSpotTypeListScreen' ||
        currentRoute == 'ParkingSpotTypeDetailsScreen' ||
        currentRoute == 'ParkingSpotTypeEditScreen';
  } else if (label == 'Reservations') {
    isSelected =
        currentRoute == 'ReservationListScreen' ||
        currentRoute == 'ReservationDetailsScreen';
  } else if (label == 'Reservation Types') {
    isSelected =
        currentRoute == 'ReservationTypeListScreen' ||
        currentRoute == 'ReservationTypeDetailsScreen' ||
        currentRoute == 'ReservationTypeEditScreen';
  } else if (label == 'Cars') {
    isSelected =
        currentRoute == 'CarListScreen' ||
        currentRoute == 'CarDetailsScreen' ||
        currentRoute == 'CarEditScreen';
  } else if (label == 'Brands') {
    isSelected =
        currentRoute == 'BrandListScreen' ||
        currentRoute == 'BrandDetailsScreen' ||
        currentRoute == 'BrandEditScreen';
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
                ? const Color(0xFF8B6F47).withOpacity(0.25)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(color: const Color(0xFF8B6F47).withOpacity(0.5), width: 1.5)
                : null,
          ),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey(isSelected),
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B6F47).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF8B6F47),
                    size: 12,
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
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          _showLogoutDialog(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF8B6F47).withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF8B6F47).withOpacity(0.3), width: 1),
          ),
          child: const Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.white, size: 22),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Icon(Icons.exit_to_app_rounded, color: Colors.white, size: 18),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFF8B6F47)),
            SizedBox(width: 12),
            Text('Confirm Logout'),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout from your account?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
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
              backgroundColor: const Color(0xFF8B6F47),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      );
    },
  );
}
