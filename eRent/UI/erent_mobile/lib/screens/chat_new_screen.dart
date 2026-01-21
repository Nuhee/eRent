import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:erent_mobile/model/user.dart';
import 'package:erent_mobile/providers/user_provider.dart';
import 'package:erent_mobile/screens/chat_conversation_screen.dart';
import 'package:provider/provider.dart';

class ChatNewScreen extends StatefulWidget {
  const ChatNewScreen({super.key});

  @override
  State<ChatNewScreen> createState() => _ChatNewScreenState();
}

class _ChatNewScreenState extends State<ChatNewScreen> {
  late UserProvider userProvider;
  final TextEditingController _searchController = TextEditingController();
  
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;

  User? get currentUser => UserProvider.currentUser;

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);

    try {
      // Get all users except admins and current user
      final result = await userProvider.get(filter: {
        'isActive': true,
        'retrieveAll': true,
      });

      if (mounted) {
        final users = result.items ?? [];
        // Filter out current user and admins (assuming admin role id is 1)
        final filteredUsers = users.where((user) {
          // Exclude current user
          if (user.id == currentUser?.id) return false;
          // Exclude admins (assuming admin role has name 'Admin' or id 1)
          final isAdmin = user.roles.any((role) => 
            role.name.toLowerCase() == 'admin' || role.id == 1);
          return !isAdmin;
        }).toList();

        setState(() {
          _users = filteredUsers;
          _filteredUsers = filteredUsers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterUsers(String query) {
    if (query.isEmpty) {
      setState(() => _filteredUsers = _users);
    } else {
      final lowerQuery = query.toLowerCase();
      setState(() {
        _filteredUsers = _users.where((user) {
          return user.firstName.toLowerCase().contains(lowerQuery) ||
              user.lastName.toLowerCase().contains(lowerQuery) ||
              user.username.toLowerCase().contains(lowerQuery);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'New Message',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5B9BD5)),
                    ),
                  )
                : _filteredUsers.isEmpty
                    ? _buildEmptyState()
                    : _buildUsersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _filterUsers,
          decoration: InputDecoration(
            hintText: 'Search users by name or username...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400]),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded, color: Colors.grey[400]),
                    onPressed: () {
                      _searchController.clear();
                      _filterUsers('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
          ),
        ),
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
                _searchController.text.isNotEmpty
                    ? Icons.search_off_rounded
                    : Icons.people_outline_rounded,
                size: 56,
                color: const Color(0xFF5B9BD5).withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _searchController.text.isNotEmpty
                  ? 'No users found'
                  : 'No users available',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isNotEmpty
                  ? 'Try a different search term'
                  : 'No other users to chat with at the moment',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredUsers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return _buildUserTile(user);
      },
    );
  }

  Widget _buildUserTile(User user) {
    ImageProvider? imageProvider;
    if (user.picture != null && user.picture!.isNotEmpty) {
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

    // Check user role to display
    String roleDisplay = 'User';
    if (user.roles.isNotEmpty) {
      final role = user.roles.first;
      if (role.name.toLowerCase() == 'landlord') {
        roleDisplay = 'Landlord';
      } else if (role.name.toLowerCase() == 'tenant' || role.name.toLowerCase() == 'user') {
        roleDisplay = 'Tenant';
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatConversationScreen(
                otherUserId: user.id,
                otherUserName: '${user.firstName} ${user.lastName}',
                otherUserPicture: user.picture,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF5B9BD5).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFF5B9BD5).withOpacity(0.1),
                  backgroundImage: imageProvider,
                  child: imageProvider == null
                      ? Text(
                          _getInitials(user.firstName, user.lastName),
                          style: const TextStyle(
                            color: Color(0xFF5B9BD5),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${user.firstName} ${user.lastName}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: roleDisplay == 'Landlord'
                                ? const Color(0xFF5B9BD5).withOpacity(0.1)
                                : Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            roleDisplay,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: roleDisplay == 'Landlord'
                                  ? const Color(0xFF5B9BD5)
                                  : Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.alternate_email, size: 14, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            user.username,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B9BD5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFF5B9BD5),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String firstName, String lastName) {
    final f = firstName.trim();
    final l = lastName.trim();
    if (f.isEmpty && l.isEmpty) return 'U';
    final a = f.isNotEmpty ? f[0] : '';
    final b = l.isNotEmpty ? l[0] : '';
    return (a + b).toUpperCase();
  }
}
