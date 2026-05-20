import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_matrix_forntend/services/api_service.dart';
import '../../Calendar/calendar_screen.dart';
import '../../Projects/projects_screen.dart';
import '../../Projects/joined_projects_screen.dart';
import '../../Tasks/tasks_screen.dart';
import '../../Settings/settings_screen.dart';
import '../../HelpCenter/help_center_screen.dart';
import '../../Conversations/conversations_screen.dart';
import '../user_dashboard_screen.dart';
import '../../Profile/profile_screen.dart';
import '../../Auth/login_screen.dart';
import '../admin_reports_screen.dart';

class Sidebar extends StatelessWidget {
  final String currentRoute;
  final int? manualUnreadCount;

  const Sidebar({
    super.key,
    required this.currentRoute,
    this.manualUnreadCount,
  });

  void _navigateTo(BuildContext context, String route) {
    if (route == currentRoute) return;

    Widget target;
    switch (route) {
      case 'dashboard':
        target = const UserDashboardScreen();
        break;
      case 'projects':
        target = const ProjectsScreen();
        break;
      case 'joined_projects':
        target = const JoinedProjectsScreen();
        break;
      case 'tasks':
        target = const TasksScreen();
        break;
      case 'calendar':
        target = const CalendarScreen();
        break;
      case 'settings':
        target = const SettingsScreen();
        break;
      case 'help':
        target = const HelpCenterScreen();
        break;
      case 'profile':
        target = const ProfileScreen();
        break;
      case 'conversations':
        target = const ConversationsScreen();
        break;
      case 'admin_reports':
        target = const AdminReportsScreen();
        break;
      default:
        target = const UserDashboardScreen(); // Fallback
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => target,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await ApiService.saveToken('');
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  String _getTodayFormatted() {
    return DateFormat('EEE, MMM dd').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: const Color(0xFF23393E),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 48, bottom: 20),
              child: Column(
                children: [
                  // Logo Section
                  //
                  //
                  //
                  //
                  //
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF90A4AE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'JS',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Job Matrix',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              'ENTERPRISE SUITE',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Navigation Items
                  _buildNavItem(
                    context,
                    Icons.dashboard_outlined,
                    'Dashboard',
                    route: 'dashboard',
                  ),
                  _buildNavItem(
                    context,
                    Icons.folder_open_outlined,
                    'Projects',
                    route: 'projects',
                  ),
                  _buildNavItem(
                    context,
                    Icons.group_work_outlined,
                    'Joined Projects',
                    route: 'joined_projects',
                  ),
                  _buildNavItem(
                    context,
                    Icons.assignment_outlined,
                    'Tasks',
                    route: 'tasks',
                  ),
                  _buildNavItem(
                    context,
                    Icons.calendar_month_outlined,
                    'Calendar',
                    route: 'calendar',
                    subtitle: _getTodayFormatted(),
                  ),
                  FutureBuilder<int>(
                    future: manualUnreadCount != null
                        ? Future.value(manualUnreadCount)
                        : ApiService.getUnreadConversationsCount(),
                    builder: (context, snapshot) {
                      final count = snapshot.data ?? 0;
                      return _buildNavItem(
                        context,
                        Icons.chat_bubble_outline,
                        'Conversations',
                        route: 'conversations',
                        badgeCount: count > 0 ? count : null,
                      );
                    },
                  ),

                  // Admin Section
                  FutureBuilder(
                    future: ApiService.getMyProfile(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.data?.role == 'system_admin') {
                        return Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Divider(color: Colors.white12),
                            ),
                            _buildNavItem(
                              context,
                              Icons.admin_panel_settings_outlined,
                              'Admin Reports',
                              route: 'admin_reports',
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 40), // Replaced Spacer with fixed gap
                  // Bottom Items
                  _buildNavItem(
                    context,
                    Icons.settings_outlined,
                    'Settings',
                    route: 'settings',
                  ),
                  _buildNavItem(
                    context,
                    Icons.help_outline,
                    'Help Center',
                    route: 'help',
                    isFullWidth: true,
                  ),
                  _buildNavItem(
                    context,
                    Icons.logout,
                    'Logout',
                    onTap: () => _logout(context),
                    isFullWidth: true,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label, {
    String? route,
    String? subtitle,
    bool isFullWidth = false,
    VoidCallback? onTap,
    int? badgeCount,
  }) {
    final bool isSelected = route != null && route == currentRoute;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isFullWidth ? 12 : 16,
        vertical: 4,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withAlpha(20) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          dense: true,
          leading: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white70,
            size: 20,
          ),
          title: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isSelected ? Colors.white70 : Colors.white38,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
              if (badgeCount != null && badgeCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE57373),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          onTap: onTap ?? () => _navigateTo(context, route ?? ''),
        ),
      ),
    );
  }
}
