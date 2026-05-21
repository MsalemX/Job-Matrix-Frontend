import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import 'widgets/sidebar.dart';
import 'widgets/header.dart';
import 'widgets/dashboard_card.dart';
import '../Projects/widgets/create_project_dialog.dart';
import '../../services/api_service.dart';
import '../../models/user_model.dart';
import '../../models/project_model.dart';
import '../../models/task_model.dart';
import '../Projects/projects_screen.dart';
import '../Projects/project_detail_screen.dart';
import '../Tasks/tasks_screen.dart';

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
      ApiService.getMyTasks(),
    ]);

    final user = results[0] as User?;
    List<ProjectModel> projects = (results[1] ?? []) as List<ProjectModel>;
    final tasks = (results[2] ?? []) as List<TaskModel>;

    // Filter projects to only show user-created ones
    if (user != null) {
      projects = projects.where((p) => p.userId == user.id).toList();
    }

    if (mounted) {
      setState(() {
        _user = user;
        _projects = projects;
        _tasks = tasks;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

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
                                '${languageProvider.translate('welcome_back')}, ${_user?.name ?? (languageProvider.isArabic ? 'مستخدم' : 'User')}',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '${languageProvider.translate('welcome_sub_prefix')}${_projects.length} ${languageProvider.translate(_projects.length == 1 ? 'projects_stat' : 'projects_stat_plural')}${languageProvider.translate('and')}${_tasks.length} ${languageProvider.translate(_tasks.length == 1 ? 'tasks_stat' : 'tasks_stat_plural')}.',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 48),

                              // --- My Projects Section ---
                              _buildSectionHeader(
                                languageProvider.translate('my_projects'),
                                onViewAll: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ProjectsScreen(),
                                    ),
                                  );
                                },
                                action: Row(
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: _showInviteLinkDialog,
                                      icon: const Icon(Icons.link, size: 16),
                                      label: Text(languageProvider.translate('join_via_link')),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color(0xFF23393E),
                                        side: const BorderSide(color: Color(0xFF23393E)),
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    ElevatedButton.icon(
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
                                      label: Text(languageProvider.translate('explore_public_projects')),
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
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildProjectsRow(),

                              const SizedBox(height: 48),

                              // --- My Tasks Section ---
                              _buildSectionHeader(
                                languageProvider.translate('my_tasks'),
                                onViewAll: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const TasksScreen(),
                                    ),
                                  );
                                },
                              ),
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
    final languageProvider = Provider.of<LanguageProvider>(context);
    if (_projects.isEmpty) {
      return _buildEmptyState(
        icon: Icons.folder_open_outlined,
        title: languageProvider.translate('no_projects_yet'),
        subtitle: languageProvider.translate('create_first_project_started'),
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
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProjectDetailScreen(projectId: project.id),
                      ),
                    );
                  },
                  child: DashboardCard(
                    width: 320,
                    height: 280,
                    title: project.name,
                    subtitle: project.description.isNotEmpty
                        ? project.description
                        : languageProvider.translate('no_description'),
                    status: project.visibility == 'public'
                        ? languageProvider.translate('public')
                        : languageProvider.translate('private'),
                    progress: 0.0,
                    icon: icons[iconIndex],
                    images: project.participants
                        .map((p) => p.user?.profile?.profileImage)
                        .where((img) => img != null && img.isNotEmpty)
                        .cast<String>()
                        .toList(),
                    timeLeft: '${project.participants.length} ${languageProvider.translate('members')}',
                  ),
                ),
              ),
            );
          }),
          _buildCreateNewCard(width: 320, height: 280),
        ],
      ),
    );
  }

  Widget _buildTasksRow() {
    final languageProvider = Provider.of<LanguageProvider>(context);
    if (_tasks.isEmpty) {
      return _buildEmptyState(
        icon: Icons.assignment_outlined,
        title: languageProvider.translate('no_tasks_yet'),
        subtitle: languageProvider.translate('tasks_appear_join_projects'),
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
          
          String statusText = languageProvider.translate('in_progress');
          if (task.status == 'completed' || task.status == 'done') {
            statusText = languageProvider.translate('completed');
          } else if (task.status == 'todo') {
            statusText = languageProvider.translate('todo');
          }

          return Padding(
            padding: const EdgeInsets.only(right: 24),
            child: DashboardCard(
              width: 320,
              height: 280,
              title: task.name,
              subtitle: task.description.isNotEmpty
                  ? task.description
                  : languageProvider.translate('no_description'),
              status: statusText,
              progress: isCompleted ? 1.0 : 0.5,
              showProgress: false,
              icon: isCompleted
                  ? Icons.check_circle
                  : Icons.assignment_outlined,
              timeLeft: statusText,
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
    final languageProvider = Provider.of<LanguageProvider>(context);
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
              label: Text(languageProvider.translate('start_new_project')),
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
    final languageProvider = Provider.of<LanguageProvider>(context);
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
              child: Text(
                languageProvider.translate('view_all'),
                style: const TextStyle(
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
    final languageProvider = Provider.of<LanguageProvider>(context);
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
              Text(
                languageProvider.translate('start_new_project'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                languageProvider.translate('need_help_invite_team'),
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInviteLinkDialog() {
    final controller = TextEditingController();
    bool isJoining = false;
    String? errorMsg;

    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(150),
      builder: (context) {
        final languageProvider = Provider.of<LanguageProvider>(context);
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Icon(Icons.link, color: Color(0xFF23393E)),
                  const SizedBox(width: 12),
                  Text(languageProvider.translate('join_via_invite_title'),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageProvider.translate('paste_invite_code'),
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: languageProvider.translate('paste_invite_placeholder'),
                      prefixIcon: const Icon(Icons.content_paste, size: 20),
                      errorText: errorMsg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF23393E),
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    onSubmitted: (_) {
                      // Allow pressing Enter to submit
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(languageProvider.translate('cancel'),
                      style: const TextStyle(color: Colors.black54)),
                ),
                ElevatedButton.icon(
                  onPressed: isJoining
                      ? null
                      : () async {
                           final code = controller.text.trim().split('/').last;
                           if (code.isEmpty) return;

                           setState(() {
                             isJoining = true;
                             errorMsg = null;
                           });

                           // Preview project by invite link to verify validity
                           final project =
                               await ApiService.getProjectByInviteLink(code);

                           if (project == null) {
                             setState(() {
                               isJoining = false;
                               errorMsg = languageProvider.translate('invalid_invite_code');
                             });
                             return;
                           }

                           setState(() => isJoining = false);

                           if (context.mounted) {
                             Navigator.pop(context); // close dialog
                             // Navigate directly to project details with the invite code
                             Navigator.push(
                               context,
                               MaterialPageRoute(
                                 builder: (_) => ProjectDetailScreen(
                                   projectId: project.id,
                                   inviteCode: code,
                                 ),
                               ),
                             );
                           }
                         },
                  icon: isJoining
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                               strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.arrow_forward, size: 18),
                  label: Text(isJoining
                      ? languageProvider.translate('loading_btn')
                      : languageProvider.translate('view_project')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF23393E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

}
