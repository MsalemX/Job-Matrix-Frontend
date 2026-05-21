import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/language_provider.dart';
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
    final langProvider = Provider.of<LanguageProvider>(context);
    final isAr = langProvider.isArabic;
    String tr(String en, String ar) => isAr ? ar : en;

    String displayTitle = widget.title;
    if (widget.title == 'Dashboard') {
      displayTitle = tr('Dashboard', 'لوحة التحكم');
    } else if (widget.title == 'Calendar') {
      displayTitle = tr('Calendar', 'التقويم');
    } else if (widget.title == 'Conversations') {
      displayTitle = tr('Conversations', 'المحادثات');
    } else if (widget.title == 'Help Center') {
      displayTitle = tr('Help Center', 'مركز المساعدة');
    } else if (widget.title == 'Profile') {
      displayTitle = tr('Profile', 'الملف الشخصي');
    } else if (widget.title == 'Edit Profile') {
      displayTitle = tr('Edit Profile', 'تعديل الملف الشخصي');
    } else if (widget.title == 'User Profile') {
      displayTitle = tr('User Profile', 'ملف المستخدم');
    } else if (widget.title == 'Joined Projects') {
      displayTitle = tr('Joined Projects', 'المشاريع المشتركة');
    } else if (widget.title == 'Projects') {
      displayTitle = tr('Projects', 'المشاريع');
    } else if (widget.title == 'Tasks') {
      displayTitle = tr('Tasks', 'المهام');
    } else if (widget.title == 'Settings') {
      displayTitle = tr('Settings', 'الإعدادات');
    } else if (widget.title == 'System Overview') {
      displayTitle = tr('System Overview', 'نظرة عامة على النظام');
    } else if (widget.title == 'Manage Users') {
      displayTitle = tr('Manage Users', 'إدارة المستخدمين');
    } else if (widget.title == 'Manage Projects') {
      displayTitle = tr('Manage Projects', 'إدارة المشاريع');
    } else if (widget.title == 'System Reports') {
      displayTitle = tr('System Reports', 'بلاغات النظام');
    } else if (widget.title == 'Report Details') {
      displayTitle = tr('Report Details', 'تفاصيل البلاغ');
    } else if (widget.title == 'Project Details (Admin)') {
      displayTitle = tr('Project Details (Admin)', 'تفاصيل المشروع (أدمن)');
    } else if (widget.title == 'Account Settings') {
      displayTitle = tr('Account Settings', 'إعدادات الحساب');
    }

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
            displayTitle,
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
              decoration: InputDecoration(
                hintText: tr('Search projects or tasks...', 'البحث عن المشاريع أو المهام...'),
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
              label: Text(tr('Create Project', 'إنشاء مشروع')),
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
              label: Text(tr('Edit Profile', 'تعديل الملف الشخصي')),
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
                tooltip: tr('Notifications', 'الإشعارات'),
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
                        _user?.name ?? tr('Loading...', 'جاري التحميل...'),
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
