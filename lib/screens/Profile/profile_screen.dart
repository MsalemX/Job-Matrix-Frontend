import 'package:flutter/material.dart';
import '../Dashboard/widgets/sidebar.dart';
import '../Dashboard/widgets/header.dart';
import '../../services/api_service.dart';
import '../../models/user_model.dart';
import '../../models/task_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  List<TaskModel> _assignedTasks = [];
  List<TaskModel> _completedTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = await ApiService.getMyProfile();
    final allTasks = await ApiService.getMyTasks();
    if (mounted) {
      setState(() {
        _user = user;
        _assignedTasks = allTasks
            .where((t) => t.status != 'completed')
            .toList();
        _completedTasks = allTasks
            .where((t) => t.status == 'completed')
            .toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          const Sidebar(currentRoute: 'profile'),
          Expanded(
            child: Column(
              children: [
                Header(
                  title: 'Profile',
                  showCreateButton: false,
                  showEditProfileButton: true,
                  onProjectCreated: _loadData,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileHeader(),
                        const SizedBox(height: 32),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column (Bio & Skills)
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  _buildBioCard(),
                                  const SizedBox(height: 24),
                                  _buildSkillsCard(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 32),
                            // Right Column (Tasks)
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  _buildTasksSection(
                                    'Assigned Tasks',
                                    _assignedTasks,
                                    'Active',
                                  ),
                                  const SizedBox(height: 32),
                                  _buildTasksSection(
                                    'Completed Tasks',
                                    _completedTasks,
                                    'Finished',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF23393E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Background accents (concentric circles simplified)
          Positioned(
            right: -100,
            top: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Row(
              children: [
                // Avatar with white border
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.white,
                    backgroundImage: _user?.profile?.profileImage != null
                        ? NetworkImage(_user!.profile!.profileImage!)
                        : null,
                    child: _user?.profile?.profileImage == null
                        ? const Icon(Icons.person, size: 80, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _user?.name ?? 'Mohammed Salem',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _user?.username.toUpperCase() ?? 'USERNAME',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          _buildHeaderBadge(
                            Icons.email_outlined,
                            _user?.email ?? 'bnwbsalm9@gmail.com',
                          ),
                          const SizedBox(width: 16),
                          _buildHeaderBadge(
                            Icons.location_on_outlined,
                            'Yemen-Mukalla',
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.amber.withAlpha(40),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.amber.withAlpha(80)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: Colors.amber, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  '${_user?.profile?.points ?? 0} pts',
                                  style: const TextStyle(
                                      color: Colors.amber,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildBioCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFCDD0CB), // Grayish-green background from design
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment_ind_outlined, size: 24),
              SizedBox(width: 12),
              Text(
                'Biography',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _user?.profile?.bio ??
                'Results-oriented Senior Project Manager with over 10 years of experience in leading cross-functional teams to deliver high-impact software solutions. Specialized in Agile methodologies, resource optimization, and strategic product roadmapping.',
            style: const TextStyle(
              fontSize: 14,
              height: 1.8,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFCDD0CB),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology_outlined, size: 24),
              SizedBox(width: 12),
              Text(
                'Skills',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (_user?.profile?.skills ?? []).isEmpty
                ? [
                    const Text(
                      'No skills added yet',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ]
                : (_user?.profile?.skills ?? [])
                      .map((skill) => _buildSkillBadge(skill, isSelected: true))
                      .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillBadge(
    String label, {
    bool isSelected = false,
    bool isSecondary = false,
  }) {
    Color bg = const Color(0xFFB0B3AF);
    Color text = Colors.black87;

    if (isSelected) {
      bg = const Color(0xFF23393E);
      text = Colors.white;
    } else if (isSecondary) {
      bg = const Color(0xFF2D3E33).withAlpha(180); // Darker green/black
      text = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTasksSection(String title, List<TaskModel> tasks, String badge) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.assignment_turned_in_outlined, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${tasks.length} $badge',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (tasks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: const Color(0xFFCDD0CB),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 48,
                  color: Colors.black26,
                ),
                SizedBox(height: 16),
                Text(
                  'No tasks yet',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          ...tasks.map(
            (task) => _buildTaskCard(task, task.status != 'completed'),
          ),
      ],
    );
  }

  Widget _buildTaskCard(TaskModel task, bool showProgress) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFCDD0CB),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF23393E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.rocket_launch_outlined,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'STATUS: ${task.status.toUpperCase().replaceAll('_', ' ')}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          if (showProgress) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'STATUS',
                  style: TextStyle(fontSize: 10, color: Colors.black38),
                ),
                Text(
                  task.status.toUpperCase().replaceAll('_', ' '),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'PROGRESS',
                  style: TextStyle(fontSize: 10, color: Colors.black38),
                ),
                Text(
                  '${task.progress}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ] else
            const Icon(Icons.check_circle, color: Color(0xFF23393E)),
        ],
      ),
    );
  }
}
