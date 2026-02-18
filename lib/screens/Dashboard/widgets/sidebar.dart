import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: const Color(0xFF23393E), // Dark sidebar color from screenshot
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
            Icons.dashboard_outlined,
            'Dashboard',
            isSelected: true,
          ),
          _buildNavItem(Icons.folder_open_outlined, 'Projects'),
          _buildNavItem(Icons.assignment_outlined, 'Tasks'),
          _buildNavItem(Icons.calendar_month_outlined, 'Calender'),

          const Spacer(),

          // Bottom Items
          _buildNavItem(Icons.settings_outlined, 'Settings'),
          _buildNavItem(Icons.help_outline, 'Help Center', isFullWidth: true),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label, {
    bool isSelected = false,
    bool isFullWidth = false,
  }) {
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
          leading: Icon(icon, color: Colors.white70, size: 20),
          title: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          onTap: () {},
        ),
      ),
    );
  }
}
