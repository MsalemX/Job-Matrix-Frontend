import 'package:flutter/material.dart';
import 'widgets/sidebar.dart';
import 'widgets/header.dart';
import 'widgets/dashboard_card.dart';
import '../Projects/widgets/create_project_dialog.dart';
import '../../services/api_service.dart';
import '../../models/user_model.dart';
import '../../models/project_model.dart';
import '../../models/task_model.dart';
import '../Projects/projects_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  User? _user;
  List<ProjectModel> _projects = [];
  List<TaskModel> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final results = await Future.wait([
      ApiService.getMyProfile(),
      ApiService.getMyProjects(),
    ]);

    final user = results[0] as User?;
    final projects = results[1] as List<ProjectModel>;

    // Load tasks from all projects
    List<TaskModel> allTasks = [];
    for (final project in projects) {
      final sections = await ApiService.getSections(project.id);
      for (final section in sections) {
        allTasks.addAll(section.tasks);
      }
    }

    if (mounted) {
      setState(() {
        _user = user;
        _projects = projects;
        _tasks = allTasks;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Subtle light gray background
      body: Row(
        children: [
          const Sidebar(currentRoute: 'dashboard'),
          Expanded(
            child: Column(
              children: [
                Header(onProjectCreated: _loadData),
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
                              Text(
                                'Welcome back, ${_user?.name ?? 'User'}',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                'You have ${_projects.length} project${_projects.length != 1 ? 's' : ''} and ${_tasks.length} task${_tasks.length != 1 ? 's' : ''}.',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 48),

                              // --- My Projects Section ---
                              _buildSectionHeader(
                                'My Projects',
                                onViewAll: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ProjectsScreen(),
                                    ),
                                  );
                                },
                                action: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ProjectsScreen(
                                          filterVisibility: 'public',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.explore_outlined,
                                    size: 16,
                                  ),
                                  label: const Text('Explore Public Projects'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF23393E),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildProjectsRow(),

                              const SizedBox(height: 48),

                              // --- My Tasks Section ---
                              _buildSectionHeader('My Tasks'),
                              const SizedBox(height: 20),
                              _buildTasksRow(),
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

  Widget _buildProjectsRow() {
    if (_projects.isEmpty) {
      return _buildEmptyState(
        icon: Icons.folder_open_outlined,
        title: 'No projects yet',
        subtitle: 'Create your first project to get started!',
      );
    }

    final List<IconData> icons = [
      Icons.rocket_launch,
      Icons.phone_android,
      Icons.assignment,
      Icons.code,
      Icons.api,
      Icons.campaign,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._projects.map((project) {
            final iconIndex = project.id % icons.length;
            return Padding(
              padding: const EdgeInsets.only(right: 24),
              child: DashboardCard(
                width: 320,
                height: 280,
                title: project.name,
                subtitle: project.description.isNotEmpty
                    ? project.description
                    : 'No description',
                status: project.visibility == 'public' ? 'Public' : 'Private',
                progress: 0.0,
                icon: icons[iconIndex],
                timeLeft: '${project.participants.length} members',
              ),
            );
          }),
          _buildCreateNewCard(width: 320, height: 280),
        ],
      ),
    );
  }

  Widget _buildTasksRow() {
    if (_tasks.isEmpty) {
      return _buildEmptyState(
        icon: Icons.assignment_outlined,
        title: 'No tasks yet',
        subtitle: 'Tasks will appear here when you join projects.',
        showCreateButton: false,
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _tasks.map((task) {
          final isCompleted =
              task.status == 'completed' || task.status == 'done';
          return Padding(
            padding: const EdgeInsets.only(right: 24),
            child: DashboardCard(
              width: 320,
              height: 280,
              title: task.name,
              subtitle: task.description.isNotEmpty
                  ? task.description
                  : 'No description',
              status: isCompleted ? 'Completed' : 'In Progress',
              progress: isCompleted ? 1.0 : 0.5,
              icon: isCompleted
                  ? Icons.check_circle
                  : Icons.assignment_outlined,
              timeLeft: task.status,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    bool showCreateButton = true,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Colors.black38),
          ),
          if (showCreateButton) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => CreateProjectDialog.show(
                context,
                onProjectCreated: _loadData,
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create Project'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF23393E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    VoidCallback? onViewAll,
    Widget? action,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.stars, color: Color(0xFF23393E), size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF23393E),
              ),
            ),
          ],
        ),
        Row(
          children: [
            if (action != null) action,
            if (action != null) const SizedBox(width: 16),
            TextButton(
              onPressed: onViewAll ?? () {},
              child: const Text(
                'View All',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCreateNewCard({double width = 300, double height = 260}) {
    return GestureDetector(
      onTap: () =>
          CreateProjectDialog.show(context, onProjectCreated: _loadData),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.black54, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                'Start New Project',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Text(
                'Need help? Invite your team',
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
