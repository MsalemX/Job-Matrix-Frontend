import 'package:flutter/material.dart';
import 'package:job_matrix_forntend/screens/Profile/user_profile_screen.dart';
import '../../services/api_service.dart';
import '../../models/project_model.dart';
import 'package:job_matrix_forntend/providers/language_provider.dart';
import 'package:job_matrix_forntend/widgets/admin_top_nav.dart';
import 'package:provider/provider.dart';

class AdminProjectDetailScreen extends StatefulWidget {
  final int projectId;

  const AdminProjectDetailScreen({super.key, required this.projectId});

  @override
  State<AdminProjectDetailScreen> createState() =>
      _AdminProjectDetailScreenState();
}

class _AdminProjectDetailScreenState extends State<AdminProjectDetailScreen> {
  ProjectModel? _project;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjectDetails();
  }

  Future<void> _loadProjectDetails() async {
    setState(() => _isLoading = true);
    try {
      final project = await ApiService.getProject(widget.projectId);
      if (mounted) {
        setState(() {
          _project = project;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading project details: $e')),
        );
      }
    }
  }

  Future<void> _deleteProject() async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFD9DEDC),
        title: Text(
          langProvider.translate('confirm_delete'),
          style: const TextStyle(
            color: Color(0xFF33423E),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          langProvider.translate('delete_confirm_msg'),
          style: const TextStyle(color: Color(0xFF33423E)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              langProvider.translate('cancel'),
              style: const TextStyle(color: Color(0xFF7A8B86)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF423333),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(langProvider.translate('take_action_delete')),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await ApiService.adminDeleteProject(widget.projectId);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(langProvider.translate('project_deleted_success')),
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete project')),
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
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF33423E)),
                  )
                : _project == null
                ? const Center(child: Text('Project not found'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Color(0xFF33423E),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                Text(
                                  langProvider.translate(
                                    'project_details_admin',
                                  ),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF33423E),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            _buildDetailCard(langProvider),
                            const SizedBox(height: 40),
                            _buildSectionsList(langProvider),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionsList(LanguageProvider langProvider) {
    if (_project!.sections.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            langProvider.translate('no_sections_found'),
            style: const TextStyle(color: Color(0xFF7A8B86), fontSize: 16),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          langProvider.translate('sections_and_tasks'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF33423E),
          ),
        ),
        const SizedBox(height: 24),
        ..._project!.sections.map(
          (section) => _buildSectionItem(section, langProvider),
        ),
      ],
    );
  }

  Widget _buildSectionItem(dynamic section, LanguageProvider langProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF33423E).withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  section.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF33423E),
                  ),
                ),
                Text(
                  '${section.tasks.length} ${langProvider.translate('tasks_count')}',
                  style: const TextStyle(
                    color: Color(0xFF7A8B86),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (section.tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                langProvider.translate('no_tasks'),
                style: const TextStyle(color: Color(0xFF7A8B86)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: section.tasks.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFECECEC)),
              itemBuilder: (context, index) {
                final task = section.tasks[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  leading: Icon(
                    task.status == 'completed'
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: task.status == 'completed'
                        ? Colors.green
                        : const Color(0xFF7A8B86),
                  ),
                  title: Text(
                    task.name,
                    style: TextStyle(
                      color: const Color(0xFF33423E),
                      decoration: task.status == 'completed'
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(task.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      task.status,
                      style: TextStyle(
                        color: _getStatusColor(task.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return const Color(0xFF7A8B86);
    }
  }

  Widget _buildDetailCard(LanguageProvider langProvider) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _project!.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF33423E),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF33423E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _project!.visibility.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF33423E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _buildInfoGrid(langProvider),
          const Divider(height: 64, color: Color(0xFFECECEC)),
          Text(
            langProvider.translate('description'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF33423E),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _project!.description,
            style: const TextStyle(
              color: Color(0xFF33423E),
              height: 1.8,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _deleteProject,
                icon: const Icon(Icons.delete_forever),
                label: Text(langProvider.translate('delete_project_system')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF423333),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(LanguageProvider langProvider) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 3,
      crossAxisSpacing: 40,
      mainAxisSpacing: 20,
      children: [
        _buildInfoItem(
          'Owner:',
          _project!.owner?.name ?? 'Unknown',
          onTap: () {
            if (_project!.owner?.id != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      UserProfileScreen(userId: _project!.owner!.id),
                ),
              );
            }
          },
        ),
        _buildInfoItem('Status:', _project!.visibility),
        _buildInfoItem(
          'Created At:',
          _project!.createdAt != null
              ? '${_project!.createdAt!.day}/${_project!.createdAt!.month}/${_project!.createdAt!.year}'
              : 'N/A',
        ),
        _buildInfoItem(
          'Participants:',
          '${_project!.participants.length} members',
        ),
        _buildInfoItem(
          'Tasks:',
          '${_project!.sections.fold(0, (sum, section) => sum + section.tasks.length)} tasks',
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, {VoidCallback? onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF7A8B86), fontSize: 14),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          child: Text(
            value,
            style: TextStyle(
              color: const Color(0xFF33423E),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              decoration: onTap != null ? TextDecoration.underline : null,
            ),
          ),
        ),
      ],
    );
  }
}
