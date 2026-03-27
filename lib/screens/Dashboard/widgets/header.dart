import 'package:flutter/material.dart';
import '../../Projects/widgets/create_project_dialog.dart';
import '../../../models/user_model.dart';
import '../../../services/api_service.dart';
import '../../Profile/profile_screen.dart';
import '../../Profile/edit_profile_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await ApiService.getMyProfile();
    if (mounted) {
      setState(() => _user = user);
    }
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

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(imageUrl),
        backgroundColor: const Color(0xFF90A4AE),
        onBackgroundImageError: (_, __) {},
      );
    }

    // Fallback: initials or icon
    final name = _user?.name ?? '';
    if (name.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundColor: const Color(0xFF23393E),
        child: Text(
          name[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );
    }

    return const CircleAvatar(
      radius: 18,
      backgroundColor: Color(0xFF90A4AE),
      child: Icon(Icons.person, color: Colors.white, size: 20),
    );
  }
}
