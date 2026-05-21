import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../Dashboard/widgets/sidebar.dart';
import '../Dashboard/widgets/header.dart';
import '../../services/api_service.dart';
import '../../models/project_model.dart';
import '../../models/task_model.dart';
import 'project_detail_screen.dart';

class JoinedProjectsScreen extends StatefulWidget {
  const JoinedProjectsScreen({super.key});

  @override
  State<JoinedProjectsScreen> createState() => _JoinedProjectsScreenState();
}

class _JoinedProjectsScreenState extends State<JoinedProjectsScreen> {
  List<ProjectModel> _projects = [];
  Map<int, List<SectionModel>> _projectSections = {};
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    try {
      if (_currentUserId == null) {
        final profile = await ApiService.getMyProfile();
        _currentUserId = profile?.id;
      }

      final projects = await ApiService.getJoinedProjects();

      // Filter: only projects where I am NOT the owner/creator
      List<ProjectModel> filteredProjects = projects;
      if (_currentUserId != null) {
        filteredProjects =
            projects.where((p) => p.userId != _currentUserId).toList();
      }

      final Map<int, List<SectionModel>> sectionMapping = {};

      for (var project in filteredProjects) {
        final sections = await ApiService.getSections(project.id);
        sectionMapping[project.id] = sections;
      }

      if (mounted) {
        setState(() {
          _projects = filteredProjects;
          _projectSections = sectionMapping;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading joined projects: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) {
      _searchQuery = '';
      _loadProjects();
      return;
    }

    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });

    try {
      final searchResults = await ApiService.searchJoinedProjects(query);

      final Map<int, List<SectionModel>> sectionMapping = {};
      for (var project in searchResults) {
        final sections = await ApiService.getSections(project.id);
        sectionMapping[project.id] = sections;
      }

      if (mounted) {
        setState(() {
          _projects = searchResults;
          _projectSections = sectionMapping;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error searching joined projects: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<ProjectModel> _getFilteredProjects() {
    if (_isLoading) return [];

    if (_searchQuery.isEmpty) return _projects;

    return _projects
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
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          const Sidebar(currentRoute: 'joined_projects'),
          Expanded(
            child: Column(
              children: [
                Header(
                  title: languageProvider.translate('projects_joined_title'),
                  showCreateButton: false,
                  onProjectCreated: _loadProjects,
                  onSearch: _handleSearch,
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
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              languageProvider.translate('projects_joined_title'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list, size: 16),
                  label: Text(languageProvider.translate('filter')),
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
                  label: Text(languageProvider.translate('sort')),
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
      ],
    );
  }

  Widget _buildProjectsGrid() {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final projects = _getFilteredProjects();

    if (projects.isEmpty && !_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 80),
          child: Column(
            children: [
              Icon(
                Icons.group_work_outlined,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                languageProvider.translate('no_joined_projects'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                languageProvider.translate('projects_joined_sub'),
                style: const TextStyle(color: Colors.black38),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: projects.map((project) => _buildProjectRow(project)).toList(),
    );
  }

  Widget _buildProjectRow(ProjectModel project) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final sections = _projectSections[project.id] ?? [];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProjectDetailScreen(projectId: project.id),
          ),
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          height: 300,
          margin: const EdgeInsets.only(bottom: 32),
          decoration: BoxDecoration(
            color: const Color(0xFFD1D1CB),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 300,
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF23393E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Text(
                        project.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      languageProvider.translate('member_since_today'),
                      style: const TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      languageProvider.translate('team_members'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF23393E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ...project.participants.take(3).map(
                              (p) {
                                final imageUrl = p.user?.profile?.profileImage;
                                return Container(
                                  margin: const EdgeInsetsDirectional.only(end: 6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 14,
                                    backgroundColor: const Color(0xFF90A4AE),
                                    backgroundImage: (imageUrl != null &&
                                            imageUrl.isNotEmpty)
                                        ? NetworkImage(imageUrl)
                                        : null,
                                    child: (imageUrl == null ||
                                            imageUrl.isEmpty)
                                        ? Text(
                                            p.user?.name.isNotEmpty == true
                                                ? p.user!.name[0].toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                );
                              },
                            ),
                        if (project.participants.length > 3)
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.white70,
                            child: Text(
                              '+${project.participants.length - 3}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(width: 1, color: Colors.black.withAlpha(20)),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: sections
                        .take(3)
                        .map((section) => _buildSectionCard(section))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(SectionModel section) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Container(
      width: 240,
      height: 240,
      margin: const EdgeInsetsDirectional.only(end: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(50),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF23393E),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            section.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF23393E),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            languageProvider.isArabic
                ? 'إدارة المكونات الأساسية وجداول التسليم للقسم...'
                : 'Managing core components and delivery timelines...',
            style: const TextStyle(fontSize: 12, color: Colors.black45, height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionStat(
                languageProvider.translate('team_count_stat'),
                '${section.tasks.length}',
              ),
              _buildSectionStat(
                languageProvider.translate('tasks_count_stat'),
                '${section.tasks.length}/24',
              ),
              _buildSectionStat(
                languageProvider.translate('deadline_stat'),
                languageProvider.translate('today'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            color: Colors.black38,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF23393E),
          ),
        ),
      ],
    );
  }
}
