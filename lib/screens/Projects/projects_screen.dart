import 'package:flutter/material.dart';
import '../Dashboard/widgets/sidebar.dart';
import '../Dashboard/widgets/header.dart';
import 'widgets/create_project_dialog.dart';
import '../../services/api_service.dart';
import '../../models/project_model.dart';

class ProjectsScreen extends StatefulWidget {
  final String? filterVisibility;

  const ProjectsScreen({super.key, this.filterVisibility});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List<ProjectModel> _projects = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    final projects = await ApiService.getMyProjects();
    if (mounted) {
      setState(() {
        _projects = projects;
        _isLoading = false;
      });
    }
  }

  List<ProjectModel> _getFilteredProjects() {
    if (_isLoading) return [];

    List<ProjectModel> filtered = _projects;

    // Apply visibility filter if provided
    if (widget.filterVisibility != null) {
      filtered = filtered
          .where(
            (p) =>
                p.visibility.toLowerCase() ==
                widget.filterVisibility!.toLowerCase(),
          )
          .toList();
    }

    if (_searchQuery.isEmpty) return filtered;

    return filtered
        .where(
          (p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.description.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          const Sidebar(currentRoute: 'projects'),
          Expanded(
            child: Column(
              children: [
                Header(
                  title: widget.filterVisibility == 'public'
                      ? 'Public Projects'
                      : 'Projects',
                  showCreateButton:
                      false, // User requested to remove it from here
                  onProjectCreated: _loadProjects,
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF23393E),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSubHeader(),
                              const SizedBox(height: 24),
                              _buildProjectsGrid(),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Here are your projects',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => CreateProjectDialog.show(
                    context,
                    onProjectCreated: _loadProjects,
                  ),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Create Project'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF23393E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list, size: 16),
                  label: const Text('Filter'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.sort, size: 16),
                  label: const Text('Sort'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Search Bar
        Container(
          height: 40,
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: const InputDecoration(
              hintText: 'Search projects...',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
              prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectsGrid() {
    final projects = _getFilteredProjects();

    if (projects.isEmpty && !_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 80),
          child: Column(
            children: [
              Icon(Icons.folder_open, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text(
                'No projects yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create your first project to get started!',
                style: TextStyle(color: Colors.black38),
              ),
            ],
          ),
        ),
      );
    }

    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: projects.map((project) => _buildProjectCard(project)).toList(),
    );
  }

  Widget _buildProjectCard(ProjectModel project) {
    final List<IconData> icons = [
      Icons.assignment_outlined,
      Icons.chat_bubble_outline,
      Icons.build_outlined,
      Icons.rocket_launch_outlined,
      Icons.code,
      Icons.analytics_outlined,
    ];
    final iconIndex = project.id % icons.length;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Navigate to project detail (future)
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 280,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon + Visibility Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF23393E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icons[iconIndex],
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: project.visibility == 'public'
                          ? const Color(0xFFE8F5E9)
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      project.visibility.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: project.visibility == 'public'
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Title
              Text(
                project.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                project.description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  height: 1.5,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              // Divider
              Divider(color: Colors.grey.shade200, height: 1),
              const SizedBox(height: 12),
              // Stats Row
              Row(
                children: [
                  _buildStat(
                    Icons.people_outline,
                    '${project.participants.length}',
                    'TEAM',
                  ),
                  const SizedBox(width: 16),
                  _buildStat(
                    Icons.layers_outlined,
                    '${project.skills.length}',
                    'SKILLS',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Team Avatars
              Row(
                children: [
                  ...List.generate(
                    project.participants.length > 3
                        ? 3
                        : project.participants.length,
                    (index) => Container(
                      margin: const EdgeInsets.only(right: 4),
                      child: const CircleAvatar(
                        radius: 14,
                        backgroundColor: Color(0xFF90A4AE),
                        child: Icon(
                          Icons.person,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (project.participants.length > 3)
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.grey.shade200,
                      child: Text(
                        '+${project.participants.length - 3}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.black54),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.black38)),
      ],
    );
  }
}
