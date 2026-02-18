import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../Auth/login_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFC7CDCA,
      ), // Light greyish-green background
      body: Column(
        children: [
          _buildTopNav(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'System Overview',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF33423E),
                    ),
                  ),
                  const Text(
                    'Real-time performance metrics and recent administrative activity.',
                    style: TextStyle(color: Color(0xFF7A8B86)),
                  ),
                  const SizedBox(height: 48),
                  _buildOverviewCards(),
                  const SizedBox(height: 48),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildRecentProjects()),
                      const SizedBox(width: 40),
                      Expanded(child: _buildNewUsers()),
                    ],
                  ),
                  const SizedBox(height: 80),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      color: const Color(0xFF33423E), // Dark teal
      child: Row(
        children: [
          const Icon(Icons.grid_view_sharp, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          const Text(
            'Job Matrix',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 24),
          _buildSearchField(),
          const Spacer(),
          _buildNavItem('Dashboard', isActive: true),
          _buildNavItem('Users'),
          _buildNavItem('Projects'),
          _buildNavItem('Reports'),
          const SizedBox(width: 24),
          ElevatedButton(
            onPressed: () async {
              await ApiService.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF423333), // Reddish-dark button
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text('Logout'),
          ),
          const SizedBox(width: 24),
          const CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage('assets/images/team/team_1.jpg'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      width: 240,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF455551),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search resources...',
          hintStyle: TextStyle(color: Color(0xFF7A8B86), fontSize: 13),
          prefixIcon: Icon(Icons.search, color: Color(0xFF7A8B86), size: 18),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
        style: TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }

  Widget _buildNavItem(String title, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.white : const Color(0xFF7A8B86),
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('TOTAL PROJECTS', '128', Icons.folder_open),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildStatCard('TOTAL USERS', '2,540', Icons.people_outline),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF33423E), // Dark teal
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF7A8B86),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: const Color(0xFF7A8B86), size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentProjects() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Projects',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF33423E),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View All',
                style: TextStyle(color: Color(0xFF7A8B86)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFD9DEDC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildProjectItem('Apollo E-commerce Platform', 'Oct 28, 2023'),
              const Divider(height: 1, color: Color(0xFFC7CDCA)),
              _buildProjectItem('Cybersecurity Audit 2024', 'Oct 26, 2023'),
              const Divider(height: 1, color: Color(0xFFC7CDCA)),
              _buildProjectItem('Neural Network Training API', 'Oct 24, 2023'),
              const Divider(height: 1, color: Color(0xFFC7CDCA)),
              _buildProjectItem('Global Logistics Dashboard', 'Oct 22, 2023'),
              const Divider(height: 1, color: Color(0xFFC7CDCA)),
              _buildProjectItem('Legacy Database Migration', 'Oct 19, 2023'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProjectItem(String title, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF33423E),
            ),
          ),
          Text(
            date,
            style: const TextStyle(color: Color(0xFF7A8B86), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildNewUsers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'New Users',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF33423E),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View All',
                style: TextStyle(color: Color(0xFF7A8B86)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFD9DEDC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildUserItem('Sarah Jenkins', 'Oct 29, 2023'),
              const Divider(height: 1, color: Color(0xFFC7CDCA)),
              _buildUserItem('David Chen', 'Oct 27, 2023'),
              const Divider(height: 1, color: Color(0xFFC7CDCA)),
              _buildUserItem('Michael Scott', 'Oct 25, 2023'),
              const Divider(height: 1, color: Color(0xFFC7CDCA)),
              _buildUserItem('Elena Gilbert', 'Oct 23, 2023'),
              const Divider(height: 1, color: Color(0xFFC7CDCA)),
              _buildUserItem('Jordan Henderson', 'Oct 21, 2023'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserItem(String name, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFC7CDCA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person, color: Color(0xFF33423E), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF33423E),
              ),
            ),
          ),
          Text(
            date,
            style: const TextStyle(color: Color(0xFF7A8B86), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return const Column(
      children: [
        Divider(height: 1, color: Color(0xFF7A8B86)),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2026 Job Matrix. Confidential Access Only.',
                style: TextStyle(color: Color(0xFF7A8B86), fontSize: 13),
              ),
              Row(
                children: [
                  Text(
                    'Server Status: Online',
                    style: TextStyle(
                      color: Color(0xFF33423E),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'V1.0',
                    style: TextStyle(color: Color(0xFF7A8B86), fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
