import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../models/project_model.dart';
import '../../models/task_model.dart';
import '../Dashboard/widgets/sidebar.dart';
import '../Profile/user_profile_screen.dart';
import 'widgets/create_section_dialog.dart';
import 'widgets/create_task_dialog.dart';
import '../Tasks/task_detail_screen.dart';
import '../widgets/report_dialog.dart';

class ProjectDetailScreen extends StatefulWidget {
  final int projectId;
  final String? inviteCode;

  const ProjectDetailScreen({super.key, required this.projectId, this.inviteCode});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  ProjectModel? _project;
  List<SectionModel> _sections = [];
  bool _isAdmin = false;
  bool _isMember = false;
  bool _hasPendingRequest = false;
  List<ParticipantModel> _joinRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjectData();
  }

  Future<void> _loadProjectData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch project + sections + all tasks + membership in parallel
      final results = await Future.wait([
        ApiService.getProject(widget.projectId),
        ApiService.getSections(widget.projectId),
        ApiService.getProjectTasks(widget.projectId),
        ApiService.getProjectMembership(widget.projectId),
      ]);

      if (!mounted) return;

      final project = results[0] as ProjectModel?;
      final sections = (results[1] as List).cast<SectionModel>();
      final allTasks = (results[2] as List).cast<TaskModel>();
      final membership = results[3] as Map<String, dynamic>?;

      // 2. Determine roles and permissions from backend authority
      final bool isAdmin = membership?['is_admin'] ?? false;
      final bool isMember = membership?['is_member'] ?? false;

      // Get current participant info if any
      final participantJson = membership?['participant'];
      ParticipantModel? myParticipant;
      if (participantJson != null) {
        myParticipant = ParticipantModel.fromJson(participantJson);
      }

      final hasPendingRequest = myParticipant?.status == 'pending';

      List<ParticipantModel> joinRequests = [];
      if (isAdmin && project != null) {
        // Collect join requests if current user is admin
        joinRequests = project.participants
            .where((p) => p.status == 'pending')
            .toList();
      }

      // 3. Group tasks by section_id
      final Map<int, List<TaskModel>> tasksBySectionId = {};
      for (final task in allTasks) {
        tasksBySectionId.putIfAbsent(task.sectionId, () => []).add(task);
      }

      // 4. Build sections with their tasks
      final List<SectionModel> sectionsWithTasks = sections.map((section) {
        final tasks = tasksBySectionId[section.id] ?? section.tasks;
        return SectionModel(
          id: section.id,
          projectId: section.projectId,
          name: section.name,
          description: section.description,
          tasks: tasks,
        );
      }).toList();

      setState(() {
        _project = project;
        _sections = sectionsWithTasks;
        _isAdmin = isAdmin;
        _isMember = isMember;
        _hasPendingRequest = hasPendingRequest;
        _joinRequests = joinRequests;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading project details: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          const Sidebar(currentRoute: 'projects'),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF23393E),
                          ),
                        )
                      : _project == null
                      ? const Center(child: Text('Project not found'))
                      : _buildBody(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBreadcrumbs(),
          const SizedBox(height: 8),
          _buildDetailHeader(),
          const SizedBox(height: 32),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Content: Sections & Tasks
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: Column(
                      children: _sections
                          .map((s) => _buildSectionWidget(s))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                // Right Sidebar
                _buildSidebar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbs() {
    return Row(
      children: [
        Text('Projects', style: TextStyle(color: Colors.black38, fontSize: 13)),
        const Icon(Icons.chevron_right, size: 16, color: Colors.black38),
        Text(
          _project?.name ?? '',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _project?.name ?? '',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF23393E),
          ),
        ),
        Row(
          children: [
            if (_isAdmin) ...[
              ElevatedButton.icon(
                onPressed: () {
                  if (_project != null) {
                    CreateSectionDialog.show(
                      context,
                      projectId: _project!.id,
                      onSectionCreated: _loadProjectData,
                    );
                  }
                },
                icon: const Icon(Icons.group_add_outlined, size: 18),
                label: const Text('Add Section'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF23393E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _showRequestsDialog,
                icon: const Icon(Icons.person_add_outlined, size: 18),
                label: Text(
                  'Show Requests ${_joinRequests.isNotEmpty ? "(${_joinRequests.length})" : ""}',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _joinRequests.isNotEmpty
                      ? Colors.orangeAccent
                      : const Color(0xFF23393E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            if (!_isAdmin)
              IconButton(
                onPressed: () {
                  if (_project != null) {
                    showReportDialog(
                      context,
                      _project!.id,
                      'project',
                      _project!.name,
                    );
                  }
                },
                icon: const Icon(Icons.report_problem_outlined, color: Colors.red),
                tooltip: 'Report Project',
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _confirmDeleteSection(int sectionId, String sectionName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withAlpha(150),
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Section',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "$sectionName"? This will also delete all its tasks.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ApiService.deleteSection(
        widget.projectId,
        sectionId,
      );
      if (success && mounted) {
        _loadProjectData();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete section')),
        );
      }
    }
  }

  Widget _buildSectionWidget(SectionModel section) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.dashboard_customize_outlined,
                  color: Color(0xFF23393E),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  section.name.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF23393E),
                    letterSpacing: 1,
                  ),
                ),
                if (_isAdmin) ...[
                  // Add Task button
                  IconButton(
                    onPressed: () {
                      final allTasks = _sections
                          .expand((s) => s.tasks)
                          .toList();
                      CreateTaskDialog.show(
                        context,
                        projectId: widget.projectId,
                        sectionId: section.id,
                        participants: _project?.participants ?? [],
                        existingTasks: allTasks,
                        onTaskCreated: _loadProjectData,
                      );
                    },
                    icon: const Icon(
                      Icons.add_circle_outline,
                      size: 20,
                      color: Color(0xFF23393E),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Add Task',
                  ),
                  const SizedBox(width: 4),
                  // Edit Section button
                  IconButton(
                    onPressed: () {
                      CreateSectionDialog.showEdit(
                        context,
                        projectId: widget.projectId,
                        sectionId: section.id,
                        initialName: section.name,
                        initialDescription: section.description,
                        onSectionUpdated: _loadProjectData,
                      );
                    },
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Colors.black45,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Edit Section',
                  ),
                  const SizedBox(width: 4),
                  // Delete Section button
                  IconButton(
                    onPressed: () =>
                        _confirmDeleteSection(section.id, section.name),
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Delete Section',
                  ),
                ],
                const Spacer(),
                Text(
                  '${section.tasks.length} Tasks',
                  style: const TextStyle(color: Colors.black38, fontSize: 13),
                ),
              ],
            ),
          ),
          if (section.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
              child: Text(
                section.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ),
          const Divider(height: 1),
          // Tasks List
          ...section.tasks.map((t) => _buildTaskItem(t)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildTaskItem(TaskModel task) {
    final isCompleted = task.status == 'completed';

    // Find assigned user from project participants
    final assignedUser = task.assignedTo != null
        ? _project?.participants
              .where((p) => p.userId == task.assignedTo)
              .map((p) => p.user)
              .firstOrNull
        : null;

    final assignedName = assignedUser?.name;
    final isAssigned = assignedName != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Checkbox(
            value: isCompleted,
            onChanged: (v) {},
            activeColor: const Color(0xFF23393E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskDetailScreen(
                      task: task,
                      projectName: _project?.name ?? 'Project',
                    ),
                  ),
                );
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Text(
                  task.name,
                  style: TextStyle(
                    fontSize: 15,
                    color: isCompleted ? Colors.black38 : Colors.black87,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Assigned user info
          if (isAssigned) ...[
            GestureDetector(
              onTap: task.assignedTo != null
                  ? () => navigateToUserProfile(context, task.assignedTo!)
                  : null,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: const Color(0xFF23393E),
                    backgroundImage: assignedUser?.profile?.profileImage != null &&
                            assignedUser!.profile!.profileImage!.isNotEmpty
                        ? NetworkImage(assignedUser.profile!.profileImage!)
                        : null,
                    child: (assignedUser?.profile?.profileImage == null ||
                            assignedUser!.profile!.profileImage!.isEmpty)
                        ? Text(
                            assignedName.isNotEmpty
                                ? assignedName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    assignedName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const Icon(
              Icons.person_off_outlined,
              size: 16,
              color: Colors.black26,
            ),
            const SizedBox(width: 4),
            const Text(
              'Not Assigned',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black38,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (!isAssigned && _isMember && !_isAdmin) ...[
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () => _assignTaskToMe(task),
              icon: const Icon(Icons.add_task, size: 16),
              label: const Text('Assign to Me', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF23393E),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                backgroundColor: const Color(0xFF23393E).withAlpha(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
          if (_isAdmin) ...[
            const SizedBox(width: 8),
            // Edit button
            IconButton(
              onPressed: () {
                final allTasks = _sections.expand((s) => s.tasks).toList();
                CreateTaskDialog.showEdit(
                  context,
                  projectId: widget.projectId,
                  sectionId: task.sectionId,
                  taskId: task.id,
                  initialName: task.name,
                  initialDescription: task.description,
                  initialAssignedTo: task.assignedTo,
                  initialDeadline: task.dueDate,
                  initialPoints: task.points,
                  initialSkills: task.skills,
                  participants: _project?.participants ?? [],
                  existingTasks: allTasks,
                  onTaskUpdated: _loadProjectData,
                );
              },
              icon: const Icon(
                Icons.edit_outlined,
                size: 17,
                color: Colors.black45,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Edit Task',
            ),
            const SizedBox(width: 4),
            // Delete button
            IconButton(
              onPressed: () => _confirmDeleteTask(task.id, task.name),
              icon: const Icon(
                Icons.delete_outline,
                size: 17,
                color: Colors.redAccent,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Delete Task',
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDeleteTask(int taskId, String taskName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withAlpha(150),
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Task',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Are you sure you want to delete "$taskName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black54),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ApiService.deleteTask(widget.projectId, taskId);
      if (success && mounted) {
        _loadProjectData();
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to delete task')));
      }
    }
  }

  Future<void> _assignTaskToMe(TaskModel task) async {
    final success = await ApiService.selfAssignTask(widget.projectId, task.id);

    if (success != null && mounted) {
      _loadProjectData();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Task assigned to you')));
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to assign task')));
    }
  }

  Widget _buildSidebar() {
    return SizedBox(
      width: 350,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSidebarCard(
              title: 'REQUIRED SKILLS',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (_project?.skills ?? ['UI Design', 'Flutter', 'API'])
                    .map((s) => _buildSkillBadge(s))
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),
            _buildSidebarCard(
              title: 'TEAM MEMBERS',
              child: Column(
                children: [
                  ...(_project?.participants ?? [])
                      .where(
                        (p) =>
                            p.status == 'accepted' ||
                            p.status == 'admin' ||
                            p.status == 'owner',
                      )
                      .take(4)
                      .map((p) {
                        final pRole = p.role.toLowerCase();
                        final isParticipantOwner =
                            _project?.userId != null &&
                            p.userId == _project!.userId;
                        final isActuallyAdmin =
                            isParticipantOwner ||
                            pRole == 'admin' ||
                            pRole == 'owner';
                        return _buildMemberItem(
                          p.userId,
                          p.user?.name ?? 'Member',
                          isActuallyAdmin ? 'TEAM ADMIN' : 'TEAM MEMBER',
                          isActuallyAdmin,
                        );
                      }),
                  const SizedBox(height: 16),
                  if (_isAdmin) ...[
                    if (_joinRequests.isNotEmpty) _buildJoinRequestsList(),
                    _buildInviteButton(),
                  ] else if (!_isMember && !_hasPendingRequest)
                    _buildJoinButton()
                  else if (_hasPendingRequest)
                    _buildPendingStatus(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildProgressCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarCard({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
                letterSpacing: 1,
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildSkillBadge(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF23393E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        skill,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildJoinButton() {
    return ElevatedButton.icon(
      onPressed: _handleJoinRequest,
      icon: const Icon(Icons.person_add_outlined, size: 18),
      label: const Text('Join Project'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF23393E),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPendingStatus() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withAlpha(50)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.hourglass_empty, size: 18, color: Colors.orange),
          SizedBox(width: 8),
          Text(
            'Request Pending',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinRequestsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'JOIN REQUESTS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.black38,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        ..._joinRequests.map((req) => _buildRequestItem(req)),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildRequestItem(ParticipantModel req, {VoidCallback? onResolve}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withAlpha(30)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFFCFD8DC),
            backgroundImage: req.user?.profile?.profileImage != null &&
                    req.user!.profile!.profileImage!.isNotEmpty
                ? NetworkImage(req.user!.profile!.profileImage!)
                : null,
            child: (req.user?.profile?.profileImage == null ||
                    req.user!.profile!.profileImage!.isEmpty)
                ? Text(
                    (req.user?.name ?? '?')[0].toUpperCase(),
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              req.user?.name ?? 'Unknown',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            onPressed: () =>
                _handleResolveRequest(req.id, true, onFinish: onResolve),
            icon: const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: () =>
                _handleResolveRequest(req.id, false, onFinish: onResolve),
            icon: const Icon(
              Icons.cancel_outlined,
              color: Colors.redAccent,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Future<void> _handleJoinRequest() async {
    bool success = false;
    if (widget.inviteCode != null && widget.inviteCode!.isNotEmpty) {
      success = await ApiService.joinProjectWithInviteLink(widget.inviteCode!);
    } else {
      success = await ApiService.joinProject(widget.projectId);
    }
    
    if (success && mounted) {
      _loadProjectData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.inviteCode != null ? 'Successfully joined the project!' : 'Join request sent successfully')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to join or send request')),
      );
    }
  }

  Future<void> _handleResolveRequest(
    int participantId,
    bool accept, {
    VoidCallback? onFinish,
  }) async {
    final success = await ApiService.resolveJoinRequest(
      widget.projectId,
      participantId,
      accept,
    );
    if (success) {
      await _loadProjectData();
      if (onFinish != null) onFinish();
    }
  }

  void _showRequestsDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(150),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                const Icon(Icons.person_add_outlined, color: Color(0xFF23393E)),
                const SizedBox(width: 12),
                const Text(
                  'Join Requests',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_joinRequests.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_joinRequests.length} pending',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            content: SizedBox(
              width: 400,
              child: _joinRequests.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text(
                          'No pending requests',
                          style: TextStyle(color: Colors.black38),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _joinRequests
                            .map(
                              (req) => _buildRequestItem(
                                req,
                                onResolve: () => setModalState(() {}),
                              ),
                            )
                            .toList(),
                      ),
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMemberItem(int userId, String name, String role, bool isAdmin) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => navigateToUserProfile(context, userId),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(3),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: isAdmin
                    ? const Color(0xFF23393E)
                    : const Color(0xFFCFD8DC),
                // We need to fetch the participant's profile image
                // Since _project.participants already has User?, we can use that
                backgroundImage: _project?.participants
                            .firstWhere((p) => p.userId == userId)
                            .user
                            ?.profile
                            ?.profileImage !=
                        null
                    ? NetworkImage(_project!.participants
                        .firstWhere((p) => p.userId == userId)
                        .user!
                        .profile!
                        .profileImage!)
                    : null,
                child: (_project?.participants
                            .firstWhere((p) => p.userId == userId)
                            .user
                            ?.profile
                            ?.profileImage ==
                        null)
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      role,
                      style: const TextStyle(
                        color: Colors.black38,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black26, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInviteButton() {
    return GestureDetector(
      onTap: () => _showInviteDialog(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.withAlpha(50),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add, size: 18, color: Colors.black38),
            SizedBox(width: 8),
            Text(
              'Invite Member',
              style: TextStyle(
                color: Colors.black38,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInviteDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(150),
      builder: (ctx) => _InviteMemberDialog(projectId: widget.projectId),
    ).then((_) => _loadProjectData());
  }

  Widget _buildProgressCard() {
    int totalTasks = 0;
    int completedTasks = 0;

    for (var section in _sections) {
      totalTasks += section.tasks.length;
      completedTasks += section.tasks
          .where((t) => t.status == 'completed' || t.progress == 100)
          .length;
    }

    final double progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    final int percentage = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF23393E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OVERALL COMPLETION',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$percentage%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Based on all sections',
                style: TextStyle(color: Colors.white24, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Invite Member Dialog ─────────────────────────────────────────────────────

class _InviteMemberDialog extends StatefulWidget {
  final int projectId;
  const _InviteMemberDialog({required this.projectId});

  @override
  State<_InviteMemberDialog> createState() => _InviteMemberDialogState();
}

class _InviteMemberDialogState extends State<_InviteMemberDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _usernameController = TextEditingController();

  String? _inviteLink;
  bool _loadingLink = true;
  bool _linkCopied = false;

  bool _inviting = false;
  String? _inviteMessage;
  bool _inviteSuccess = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchInviteLink();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _fetchInviteLink() async {
    final link = await ApiService.getInviteLink(widget.projectId);
    if (mounted) {
      setState(() {
        _inviteLink = link ?? 'Link not available';
        _loadingLink = false;
      });
    }
  }

  Future<void> _copyLink() async {
    if (_inviteLink == null || _inviteLink == 'Link not available') return;

    await Clipboard.setData(ClipboardData(text: _inviteLink!));

    setState(() => _linkCopied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _linkCopied = false);
    });
  }

  Future<void> _sendInvite() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) return;

    setState(() {
      _inviting = true;
      _inviteMessage = null;
    });

    final success = await ApiService.inviteMemberByUsername(
      widget.projectId,
      username,
    );

    if (mounted) {
      setState(() {
        _inviting = false;
        _inviteSuccess = success;
        _inviteMessage = success
            ? 'Invitation sent to @$username successfully!'
            : 'Could not find user @$username or invitation failed.';
      });
      if (success) _usernameController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        width: 480,
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 16, 0),
              child: Row(
                children: [
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFF23393E),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_add_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Invite Team Member',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF23393E),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.black38),
                  ),
                ],
              ),
            ),

            // Tab Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: const Color(0xFF23393E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black54,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: '  Invite Link  '),
                    Tab(text: '  By Username  '),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Tab content
            SizedBox(
              height: 180,
              child: TabBarView(
                controller: _tabController,
                children: [_buildLinkTab(), _buildUsernameTab()],
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Anyone with this link can request to join the project.',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          if (_loadingLink)
            const Center(child: CircularProgressIndicator())
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _inviteLink ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _copyLink,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _linkCopied
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 22,
                              key: ValueKey('check'),
                            )
                          : const Icon(
                              Icons.copy_outlined,
                              color: Color(0xFF23393E),
                              size: 22,
                              key: ValueKey('copy'),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          if (_linkCopied)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Link copied!',
                style: TextStyle(color: Colors.green, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUsernameTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Autocomplete<User>(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<User>.empty();
                    }
                    return await ApiService.searchUsers(textEditingValue.text);
                  },
                  displayStringForOption: (User option) => option.username,
                  onSelected: (User selection) {
                    _usernameController.text = selection.username;
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    // Sync controllers so the external "Send" button uses the selected value
                    _usernameController.value = controller.value;
                    controller.addListener(() {
                      _usernameController.text = controller.text;
                    });
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onSubmitted: (_) {
                        onFieldSubmitted();
                        _sendInvite();
                      },
                      decoration: InputDecoration(
                        hintText: 'Search username or email...',
                        prefixIcon: const Icon(Icons.alternate_email, size: 20),
                        prefixText: '',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade200),
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
                        fillColor: Colors.white,
                      ),
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 300,
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final User option = options.elementAt(index);
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 16,
                                  backgroundImage: option.profile?.profileImage != null
                                      ? NetworkImage(option.profile!.profileImage!)
                                      : null,
                                  backgroundColor: const Color(0xFF23393E),
                                  child: option.profile?.profileImage == null
                                      ? Text(
                                          option.username.substring(0, 1).toUpperCase(),
                                          style: const TextStyle(color: Colors.white, fontSize: 10),
                                        )
                                      : null,
                                ),
                                title: Text(option.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                subtitle: Text('@${option.username}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                onTap: () {
                                  onSelected(option);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _inviting ? null : _sendInvite,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF23393E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: _inviting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Send',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
          if (_inviteMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _inviteSuccess
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _inviteSuccess
                      ? Colors.green.shade200
                      : Colors.red.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _inviteSuccess ? Icons.check_circle : Icons.error_outline,
                    color: _inviteSuccess ? Colors.green : Colors.red,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _inviteMessage!,
                      style: TextStyle(
                        fontSize: 13,
                        color: _inviteSuccess
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
