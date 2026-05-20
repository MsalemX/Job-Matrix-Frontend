import 'package:flutter/material.dart';
import 'package:job_matrix_forntend/services/api_service.dart';
import 'package:job_matrix_forntend/models/user_model.dart';
import 'package:job_matrix_forntend/models/project_model.dart';
import 'package:job_matrix_forntend/providers/language_provider.dart';
import 'package:job_matrix_forntend/widgets/admin_top_nav.dart';
import 'package:provider/provider.dart';

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
    final langProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFC7CDCA),
      body: Column(
        children: [
          const AdminTopNav(activeItem: 'Dashboard'),
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
                          Text(
                            langProvider.translate('system_overview'),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF33423E),
                            ),
                          ),
                          Text(
                            langProvider.translate('real_time_metrics'),
                            style: const TextStyle(color: Color(0xFF7A8B86)),
                          ),
                          const SizedBox(height: 48),
                          _buildOverviewCards(langProvider),
                          const SizedBox(height: 48),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildRecentProjects(langProvider),
                              ),
                              const SizedBox(width: 40),
                              Expanded(child: _buildNewUsers(langProvider)),
                            ],
                          ),
                          const SizedBox(height: 80),
                          _buildFooter(langProvider),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCards(LanguageProvider langProvider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            langProvider.translate('total_projects'),
            _projects.length.toString(),
            Icons.folder_open,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildStatCard(
            langProvider.translate('total_users'),
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

  Widget _buildRecentProjects(LanguageProvider langProvider) {
    // Show last 5 projects
    final recentProjects = _projects.reversed.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              langProvider.translate('recent_projects'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF33423E),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                langProvider.translate('view_all'),
                style: const TextStyle(color: Color(0xFF7A8B86)),
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

  Widget _buildNewUsers(LanguageProvider langProvider) {
    // Show last 5 users
    final newUsers = _users.reversed.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              langProvider.translate('new_users'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF33423E),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                langProvider.translate('view_all'),
                style: const TextStyle(color: Color(0xFF7A8B86)),
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

  Widget _buildFooter(LanguageProvider langProvider) {
    return Column(
      children: [
        const Divider(height: 1, color: Color(0xFF7A8B86)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '© 2026 Job Matrix. Confidential Access Only.',
                style: TextStyle(color: Color(0xFF7A8B86), fontSize: 13),
              ),
              Row(
                children: [
                  Text(
                    '${langProvider.translate('server_status')}: ${langProvider.translate('online')}',
                    style: const TextStyle(
                      color: Color(0xFF33423E),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
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
