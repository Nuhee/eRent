import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erent_mobile/providers/user_provider.dart';
import 'package:erent_mobile/providers/notification_provider.dart';
import 'package:erent_mobile/screens/home_screen.dart';
import 'package:erent_mobile/screens/chat_list_screen.dart';
import 'package:erent_mobile/screens/rents_list_screen.dart';
import 'package:erent_mobile/screens/expenses_screen.dart';
import 'package:erent_mobile/screens/profile_screen.dart';
import 'package:erent_mobile/screens/notifications_screen.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key, required this.child, required this.title});
  final Widget child;
  final String title;

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  int _unreadNotifications = 0;
  Timer? _notificationTimer;
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _pageTitles = [
    'Home',
    'Chat',
    'Rents',
    'Expenses',
    'Profile',
  ];

  final List<IconData> _pageIcons = [
    Icons.home_rounded,
    Icons.chat_bubble_rounded,
    Icons.home_work_rounded,
    Icons.receipt_long_rounded,
    Icons.person_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadUnreadCount();
    _notificationTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadUnreadCount(),
    );
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUnreadCount() async {
    final user = UserProvider.currentUser;
    if (user == null) return;
    try {
      final provider = Provider.of<NotificationProvider>(context, listen: false);
      final count = await provider.getUnreadCount(user.id);
      if (mounted && count != _unreadNotifications) {
        setState(() => _unreadNotifications = count);
      }
    } catch (_) {}
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
    UserProvider.currentUser = null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFF5B9BD5)),
            SizedBox(width: 12),
            Text(
              "Logout",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          "Are you sure you want to logout?",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
            child: const Text("Cancel"),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5B9BD5), Color(0xFF7AB8CC)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                "Logout",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = UserProvider.currentUser;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Modern Header with Blue Gradient
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF5B9BD5),
                  Color(0xFF7AB8CC),
                  Color(0xFF5B9BD5),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5B9BD5).withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Row(
                  children: [
                    // Profile Picture or Icon
                    _buildHeaderIcon(),
                    const SizedBox(width: 16),
                    // Title and Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _pageTitles[_selectedIndex],
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (user != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              user.firstName.isNotEmpty ? user.firstName : 'Welcome',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Notification Bell
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotificationsScreen(),
                              ),
                            );
                            _loadUnreadCount();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Icon(
                                  Icons.notifications_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                if (_unreadNotifications > 0)
                                  Positioned(
                                    right: -6,
                                    top: -6,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE53E3E),
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 18,
                                        minHeight: 18,
                                      ),
                                      child: Text(
                                        _unreadNotifications > 99
                                            ? '99+'
                                            : _unreadNotifications.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Logout Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _handleLogout,
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.logout_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Page Content
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const BouncingScrollPhysics(),
                children: const [
                  HomeScreen(),
                  ChatListScreen(),
                  RentsListScreen(),
                  ExpensesScreen(),
                  ProfileScreen(),
                ],
              ),
            ),
          ),

          // Modern Bottom Navigation Bar - Fixed overflow
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Container(
                height: 68,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBottomNavItem(0),
                    _buildBottomNavItem(1),
                    _buildBottomNavItem(2),
                    _buildBottomNavItem(3),
                    _buildBottomNavItem(4),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Icon(
        _pageIcons[_selectedIndex],
        color: Colors.white,
        size: 26,
      ),
    );
  }

  Widget _buildBottomNavItem(int index) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF5B9BD5).withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF5B9BD5)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _pageIcons[index],
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 20,
                ),
              ),
              const SizedBox(height: 3),
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF5B9BD5)
                        : Colors.grey[600],
                  ),
                  child: Text(
                    _pageTitles[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
