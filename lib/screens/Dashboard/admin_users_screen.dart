import 'package:flutter/material.dart';
import 'package:job_matrix_forntend/services/api_service.dart';
import 'package:job_matrix_forntend/models/user_model.dart';
import 'package:job_matrix_forntend/providers/language_provider.dart';
import 'package:job_matrix_forntend/widgets/admin_top_nav.dart';
import 'package:provider/provider.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  bool _isLoading = true;
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    setState(() => _isLoading = true);
    try {
      final users = await ApiService.adminGetUsers();
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${langProvider.translate('error_loading_users')}: $e',
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteUser(User user) async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(langProvider.translate('confirm_delete')),
        content: Text(
          '${langProvider.translate('delete_confirm_msg')} (${user.name})',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(langProvider.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(langProvider.translate('confirm_and_delete')),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final success = await ApiService.adminDeleteUser(user.id);
      if (success) {
        await _fetchUsers();
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(langProvider.translate('failed_to_delete_user')),
            ),
          );
        }
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
          const AdminTopNav(activeItem: 'Users'),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchUsers,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            langProvider.translate('manage_users'),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF33423E),
                            ),
                          ),
                          Text(
                            langProvider.translate('view_manage_users'),
                            style: const TextStyle(color: Color(0xFF7A8B86)),
                          ),
                          const SizedBox(height: 48),
                          _buildUsersTable(langProvider),
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

  Widget _buildUsersTable(LanguageProvider langProvider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text(langProvider.translate('id'))),
            DataColumn(label: Text(langProvider.translate('name'))),
            DataColumn(label: Text(langProvider.translate('email'))),
            DataColumn(label: Text(langProvider.translate('role'))),
            DataColumn(label: Text(langProvider.translate('actions'))),
          ],
          rows: _users.map((user) {
            return DataRow(
              cells: [
                DataCell(Text(user.id.toString())),
                DataCell(Text(user.name)),
                DataCell(Text(user.email)),
                DataCell(Text(user.role)),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteUser(user),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
