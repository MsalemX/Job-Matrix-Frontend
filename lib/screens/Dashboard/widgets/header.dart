import 'package:flutter/material.dart';
import '../../Projects/widgets/create_project_dialog.dart';
import '../../../models/user_model.dart';
import '../../../services/api_service.dart';
import '../../Profile/profile_screen.dart';
import '../../Profile/edit_profile_screen.dart';
import '../../widgets/notifications_dialog.dart';

class Header extends StatefulWidget {
  final String title;
  final bool showCreateButton;
  final bool showEditProfileButton;
  final VoidCallback? onProjectCreated;
  final Function(String)? onSearch;

  const Header({
    super.key,
    this.title = 'Dashboard',
    this.showCreateButton = true,
    this.showEditProfileButton = false,
    this.onProjectCreated,
    this.onSearch,
  });

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  User? _user;
  int _unreadNotificationsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadNotifications();
  }

  Future<void> _loadUser() async {
    final user = await ApiService.getMyProfile();
    if (mounted) {
      setState(() => _user = user);
    }
  }

  Future<void> _loadNotifications() async {
    final notifications = await ApiService.getNotifications();
    final unread = notifications.where((n) => !n.isRead).length;
    if (mounted) {
      setState(() => _unreadNotificationsCount = unread);
    }
  }

  void _openNotifications() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const NotificationsDialog(),
    ).then((_) {
      _loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 24),
          // Search Bar
          Container(
            width: 300,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextField(
              onSubmitted: widget.onSearch,
              decoration: const InputDecoration(
                hintText: 'Search projects or tasks...',
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const Spacer(),
          // Create Project Button
          if (widget.showCreateButton)
            ElevatedButton.icon(
              onPressed: () {
                CreateProjectDialog.show(
                  context,
                  onProjectCreated: widget.onProjectCreated,
                );
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create Project'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF23393E),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          // Edit Profile Button
          if (widget.showEditProfileButton)
            ElevatedButton.icon(
              onPressed: () {
                if (_user != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(user: _user!),
                    ),
                  ).then((value) {
                    if (value == true) {
                      _loadUser();
                      if (widget.onProjectCreated != null) {
                        widget.onProjectCreated!();
                      }
                    }
                  });
                }
              },
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF23393E),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          const SizedBox(width: 16),
          // Notifications Button
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: Icon(
                  _unreadNotificationsCount > 0
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_none_rounded,
                  color: _unreadNotificationsCount > 0
                      ? const Color(0xFF23393E)
                      : Colors.black54,
                  size: 22,
                ),
                onPressed: _openNotifications,
                tooltip: 'Notifications',
                splashRadius: 20,
              ),
              if (_unreadNotificationsCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_unreadNotificationsCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 24),
          // User Profile (dynamic)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _user?.name ?? 'Loading...',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _user?.username.toLowerCase() ?? '',
                        style: const TextStyle(
                          color: Colors.black45,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  _buildAvatar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final imageUrl = _user?.profile?.profileImage;
    final name = _user?.name ?? '';
    final fallback = CircleAvatar(
      radius: 18,
      backgroundColor: const Color(0xFF23393E),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => fallback,
        ),
      );
    }

    return fallback;
  }
}
