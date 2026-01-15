import 'package:flutter/material.dart';
import 'package:erent_desktop/layouts/master_screen.dart';
import 'package:erent_desktop/model/user.dart';
import 'package:erent_desktop/model/search_result.dart';
import 'package:erent_desktop/providers/user_provider.dart';
import 'package:erent_desktop/screens/users_details_screen.dart';
import 'package:erent_desktop/screens/users_edit_screen.dart';
import 'package:erent_desktop/utils/base_pagination.dart';
import 'package:erent_desktop/utils/base_table.dart';
import 'package:erent_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  late UserProvider userProvider;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  int? selectedRoleFilter; // null = All, 1 = Admin, 2 = User

  SearchResult<User>? users;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 10, 20, 50];

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;

    final filter = {
      'username': usernameController.text,
      'email': emailController.text,
      if (selectedRoleFilter != null) 'roleId': selectedRoleFilter, // Only include if not null
      'page': pageToFetch,
      'pageSize': pageSizeToUse,
      'includeTotalCount': true,
    };

    final result = await userProvider.get(filter: filter);
    setState(() {
      users = result;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  Future<void> _toggleUserStatus(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              user.isActive ? Icons.warning_amber_rounded : Icons.check_circle_outline,
              color: user.isActive ? Colors.orange : const Color(0xFF5B9BD5),
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              user.isActive ? "Deactivate User?" : "Activate User?",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          user.isActive
              ? "Are you sure you want to deactivate '${user.firstName} ${user.lastName}'? This will make their account unavailable."
              : "Are you sure you want to activate '${user.firstName} ${user.lastName}'? This will make their account available.",
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
              backgroundColor: user.isActive ? Colors.red : const Color(0xFF5B9BD5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(user.isActive ? "Deactivate" : "Activate"),
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
                    user.isActive
                        ? "Deactivating ${user.firstName} ${user.lastName}..."
                        : "Activating ${user.firstName} ${user.lastName}...",
                  ),
                ],
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Get current user data
        var currentUser = await userProvider.getById(user.id);
        if (currentUser == null) {
          throw Exception('User not found');
        }

        // Extract role IDs from user roles
        var roleIds = currentUser.roles.map((role) => role.id).toList();

        // Prepare update request
        var request = {
          'firstName': currentUser.firstName,
          'lastName': currentUser.lastName,
          'email': currentUser.email,
          'username': currentUser.username,
          'phoneNumber': currentUser.phoneNumber ?? '',
          'isActive': !user.isActive,
          'cityId': currentUser.cityId,
          'genderId': currentUser.genderId,
          'picture': currentUser.picture,
          'roleIds': roleIds,
        };

        await userProvider.update(user.id, request);

        // Refresh the list
        await _performSearch();

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    user.isActive ? Icons.block : Icons.check_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    user.isActive
                        ? "${user.firstName} ${user.lastName} has been deactivated"
                        : "${user.firstName} ${user.lastName} has been activated",
                  ),
                ],
              ),
              backgroundColor: user.isActive ? Colors.red : Colors.green,
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
                      "Failed to update user status: ${e.toString()}",
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
      userProvider = context.read<UserProvider>();
      await _performSearch(page: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: 'Users Management',
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
                    'Username',
                    prefixIcon: Icons.person_search,
                  ),
                  controller: usernameController,
                  onSubmitted: (_) => _performSearch(page: 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: customTextFieldDecoration(
                    'Email',
                    prefixIcon: Icons.email,
                  ),
                  controller: emailController,
                  onSubmitted: (_) => _performSearch(page: 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<int?>(
                  decoration: customTextFieldDecoration(
                    'Role',
                    prefixIcon: Icons.admin_panel_settings,
                  ),
                  value: selectedRoleFilter,
                  items: const [
                    DropdownMenuItem<int?>(value: null, child: Text('All')),
                    DropdownMenuItem<int>(value: 1, child: Text('Admin')),
                    DropdownMenuItem<int>(value: 2, child: Text('User')),
                    DropdownMenuItem<int>(value: 3, child: Text('Landlord')),
                  ],
                  onChanged: (int? newValue) {
                    setState(() {
                      selectedRoleFilter = newValue;
                    });
                    _performSearch(page: 0);
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _performSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                  usernameController.clear();
                  emailController.clear();
                  setState(() {
                    selectedRoleFilter = null;
                  });
                  _performSearch(page: 0);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.grey[800],
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
        users == null || users!.items == null || users!.items!.isEmpty;
    final int totalCount = users?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;

    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTable(
            icon: Icons.people_outlined,
            title: 'Users',
            width: 1200,
            height: 423,
            columnWidths: [
              220,
              125,
              280,
              150,
              120,
              180,
            ], // Name, Username, Email, City, Active, Actions (wider for 3 buttons)
            columns: const [
              DataColumn(
                label: Text(
                  'Name',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Username',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Email',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'City',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              DataColumn(
                label: Text(
                  'Active',
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
                : users!.items!
                      .map(
                        (e) => DataRow(
                          cells: [
                            DataCell(
                              Text(
                                '${e.firstName} ${e.lastName}',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            DataCell(
                              Text(
                                e.username,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            DataCell(
                              Text(
                                e.email,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            DataCell(
                              Text(
                                e.cityName,
                                style: const TextStyle(fontSize: 15),
                              ),
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
                                              builder: (context) => UsersDetailsScreen(user: e),
                                              settings: const RouteSettings(
                                                name: 'UsersDetailsScreen',
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
                                              builder: (context) => UsersEditScreen(user: e),
                                              settings: const RouteSettings(
                                                name: 'UsersEditScreen',
                                              ),
                                            ),
                                          ).then((_) {
                                            // Refresh when coming back from edit
                                            _performSearch();
                                          });
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
                                  // Activate/Deactivate Button
                                  Tooltip(
                                    message: e.isActive ? "Deactivate" : "Activate",
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () => _toggleUserStatus(e),
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
            emptyIcon: Icons.people_outline,
            emptyText: 'No users found.',
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
}
