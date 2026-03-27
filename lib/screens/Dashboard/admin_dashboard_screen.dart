import 'package:flutter/material.dart';
import 'package:job_matrix_forntend/services/api_service.dart';
import 'package:job_matrix_forntend/screens/Auth/login_screen.dart';
import 'package:job_matrix_forntend/models/user_model.dart';
import 'package:job_matrix_forntend/models/project_model.dart';
import 'package:job_matrix_forntend/screens/Dashboard/admin_profile_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  List<User> _users = [];
  List<ProjectModel> _projects = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService.adminGetUsers(),
        ApiService.adminGetAllProjects(),
      ]);

      if (mounted) {
        setState(() {
          _users = results[0] as List<User>;
          _projects = results[1] as List<ProjectModel>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading dashboard: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC7CDCA),
      body: Column(
        children: [
          _buildTopNav(context),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchDashboardData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
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
          ),
        ],
      ),
    );
  }

  Widget _buildTopNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      color: const Color(0xFF33423E),
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
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF423333),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text('Logout'),
          ),
          const SizedBox(width: 24),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminProfileScreen(),
                ),
              );
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
          child: _buildStatCard(
            'TOTAL PROJECTS',
            _projects.length.toString(),
            Icons.folder_open,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildStatCard(
            'TOTAL USERS',
            _users.length.toString(),
            Icons.people_outline,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF33423E),
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
    // Show last 5 projects
    final recentProjects = _projects.reversed.take(5).toList();

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
          child: recentProjects.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No projects found')),
                )
              : Column(
                  children: [
                    for (var i = 0; i < recentProjects.length; i++) ...[
                      _buildProjectItem(
                        recentProjects[i].name,
                        _formatDate(recentProjects[i].createdAt),
                      ),
                      if (i < recentProjects.length - 1)
                        const Divider(height: 1, color: Color(0xFFC7CDCA)),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildProjectItem(String title, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF33423E),
              ),
              overflow: TextOverflow.ellipsis,
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
    // Show last 5 users
    final newUsers = _users.reversed.take(5).toList();

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
          child: newUsers.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('No users found')),
                )
              : Column(
                  children: [
                    for (var i = 0; i < newUsers.length; i++) ...[
                      _buildUserItem(
                        newUsers[i].name,
                        'New User', // You could use createdAt if available on User model
                      ),
                      if (i < newUsers.length - 1)
                        const Divider(height: 1, color: Color(0xFFC7CDCA)),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildUserItem(String name, String subtitle) {
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
            subtitle,
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
