import 'package:flutter/material.dart';
import 'package:job_matrix_forntend/services/api_service.dart';
import 'package:job_matrix_forntend/models/project_model.dart';
import 'package:job_matrix_forntend/screens/Dashboard/admin_project_detail_screen.dart';
import 'package:job_matrix_forntend/providers/language_provider.dart';
import 'package:job_matrix_forntend/widgets/admin_top_nav.dart';
import 'package:provider/provider.dart';

class AdminProjectsScreen extends StatefulWidget {
  const AdminProjectsScreen({super.key});

  @override
  State<AdminProjectsScreen> createState() => _AdminProjectsScreenState();
}

class _AdminProjectsScreenState extends State<AdminProjectsScreen> {
  bool _isLoading = true;
  List<ProjectModel> _projects = [];

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    setState(() => _isLoading = true);
    try {
      final projects = await ApiService.adminGetAllProjects();
      if (mounted) {
        setState(() {
          _projects = projects;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${langProvider.translate('error_loading_projects')}: $e',
            ),
          ),
        );
      }
    }
  }

  Future<void> _deleteProject(ProjectModel project) async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(langProvider.translate('confirm_delete')),
        content: Text(
          '${langProvider.translate('delete_confirm_msg')} (${project.name})',
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
      final success = await ApiService.adminDeleteProject(project.id);
      if (success) {
        await _fetchProjects();
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(langProvider.translate('failed_to_delete_project')),
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
          const AdminTopNav(activeItem: 'Projects'),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchProjects,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            langProvider.translate('manage_projects'),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF33423E),
                            ),
                          ),
                          Text(
                            langProvider.translate('view_manage_projects'),
                            style: const TextStyle(color: Color(0xFF7A8B86)),
                          ),
                          const SizedBox(height: 48),
                          _buildProjectsTable(langProvider),
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

  Widget _buildProjectsTable(LanguageProvider langProvider) {
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
            DataColumn(label: Text(langProvider.translate('projects'))),
            DataColumn(label: Text(langProvider.translate('status'))),
            DataColumn(label: Text(langProvider.translate('created_at'))),
            DataColumn(label: Text(langProvider.translate('actions'))),
          ],
          rows: _projects.map((project) {
            return DataRow(
              cells: [
                DataCell(Text(project.id.toString())),
                DataCell(
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AdminProjectDetailScreen(projectId: project.id),
                        ),
                      ).then((value) {
                        if (value == true) {
                          _fetchProjects();
                        }
                      });
                    },
                    child: Text(
                      project.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        color: Color(0xFF33423E),
                      ),
                    ),
                  ),
                ),
                DataCell(Text(project.visibility)),
                DataCell(
                  Text(
                    project.createdAt != null
                        ? '${project.createdAt!.day}/${project.createdAt!.month}/${project.createdAt!.year}'
                        : 'N/A',
                  ),
                ),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteProject(project),
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
