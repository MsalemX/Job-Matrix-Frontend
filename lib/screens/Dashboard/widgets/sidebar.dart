import 'package:flutter/material.dart';
import '../../Calendar/calendar_screen.dart';
import '../../Projects/projects_screen.dart';
import '../../Tasks/tasks_screen.dart';
import '../../Settings/settings_screen.dart';
import '../../HelpCenter/help_center_screen.dart';
import '../user_dashboard_screen.dart';
import '../../Profile/profile_screen.dart';

class Sidebar extends StatelessWidget {
  final String currentRoute;

  const Sidebar({super.key, required this.currentRoute});

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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: const Color(0xFF23393E),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Logo Section
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
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'ENTERPRISE SUITE',
                      style: TextStyle(color: Colors.white60, fontSize: 8),
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
            Icons.assignment_outlined,
            'Tasks',
            route: 'tasks',
          ),
          _buildNavItem(
            context,
            Icons.calendar_month_outlined,
            'Calendar',
            route: 'calendar',
          ),

          const Spacer(),

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
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label, {
    String? route,
    bool isFullWidth = false,
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
          title: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          onTap: () => _navigateTo(context, route ?? ''),
        ),
      ),
    );
  }
}
