import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/language_provider.dart';
import '../screens/Auth/login_screen.dart';
import '../screens/Dashboard/admin_dashboard_screen.dart';
import '../screens/Dashboard/admin_users_screen.dart';
import '../screens/Dashboard/admin_projects_screen.dart';
import '../screens/Dashboard/admin_reports_screen.dart';
import '../screens/Dashboard/admin_profile_screen.dart';

class AdminTopNav extends StatelessWidget {
  final String activeItem;

  const AdminTopNav({super.key, required this.activeItem});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      color: const Color(0xFF33423E),
      child: Row(
        children: [
          const Icon(Icons.grid_view_sharp, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              if (activeItem != 'Dashboard') {
                 Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
              }
            },
            child: const Text(
              'Job Matrix',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          _buildNavItem(context, langProvider.translate('dashboard'), isActive: activeItem == 'Dashboard', onTap: () {
            if (activeItem != 'Dashboard') {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
            }
          }),
          _buildNavItem(context, langProvider.translate('users'), isActive: activeItem == 'Users', onTap: () {
            if (activeItem != 'Users') {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminUsersScreen()));
            }
          }),
          _buildNavItem(context, langProvider.translate('projects'), isActive: activeItem == 'Projects', onTap: () {
            if (activeItem != 'Projects') {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminProjectsScreen()));
            }
          }),
          _buildNavItem(context, langProvider.translate('reports'), isActive: activeItem == 'Reports', onTap: () {
            if (activeItem != 'Reports') {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminReportsScreen()));
            }
          }),
          const SizedBox(width: 24),
          // Language Switch Button
          TextButton.icon(
            onPressed: () => langProvider.toggleLanguage(),
            icon: const Icon(Icons.language, color: Colors.white, size: 20),
            label: Text(
              langProvider.isArabic ? 'English' : 'العربية',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 24),
          ElevatedButton(
            onPressed: () async {
              await ApiService.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF423333),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            child: Text(langProvider.translate('logout')),
          ),
          const SizedBox(width: 24),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminProfileScreen()));
            },
            child: const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/images/team/team_1.jpg'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String title, {bool isActive = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onTap,
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF7A8B86),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
