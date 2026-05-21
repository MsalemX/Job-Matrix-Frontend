import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../Dashboard/widgets/sidebar.dart';
import '../Dashboard/widgets/header.dart';
import '../../services/api_service.dart';
import '../../models/project_model.dart';
import '../../models/task_model.dart';
import 'project_detail_screen.dart';

class ProjectsScreen extends StatefulWidget {
  final String? filterVisibility;

  const ProjectsScreen({super.key, this.filterVisibility});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
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

      final projects = widget.filterVisibility == 'public'
          ? await ApiService.getPublicProjects()
          : await ApiService.getMyProjects();

      List<ProjectModel> projectList = projects;

      // Filter: only my projects (created by me)
      if (widget.filterVisibility != 'public' && _currentUserId != null) {
        projectList =
            projectList.where((p) => p.userId == _currentUserId).toList();
      }

      final Map<int, List<SectionModel>> sectionMapping = {};

      for (var project in projectList) {
        final sections = await ApiService.getSections(project.id);
        sectionMapping[project.id] = sections;
      }

      if (mounted) {
        setState(() {
          _projects = projectList;
          _projectSections = sectionMapping;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading projects/sections: $e');
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
      final searchResults = widget.filterVisibility == 'public'
          ? await ApiService.searchPublicProjects(query)
          : await ApiService.searchPrivateProjects(query);

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
      print('Error searching projects: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSkillFilter(String skill) async {
    setState(() {
      _isLoading = true;
      _searchQuery = 'Skill: $skill'; // Show the filter in the UI
    });

    try {
      final filteredResults = await ApiService.filterProjectsBySkill(skill);

      final Map<int, List<SectionModel>> sectionMapping = {};
      for (var project in filteredResults) {
        final sections = await ApiService.getSections(project.id);
        sectionMapping[project.id] = sections;
      }

      if (mounted) {
        setState(() {
          _projects = filteredResults;
          _projectSections = sectionMapping;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error filtering by skill: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
    final languageProvider = Provider.of<LanguageProvider>(context);

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
                      ? languageProvider.translate('explore_public_projects')
                      : languageProvider.translate('projects'),
                  showCreateButton:
                      false, // User requested to remove it from here
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
              languageProvider.translate('here_are_projects'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                if (widget.filterVisibility != 'public') ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ProjectsScreen(filterVisibility: 'public'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.explore_outlined, size: 16),
                    label: Text(languageProvider.translate('explore_public')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
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
              Icon(Icons.folder_open, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                languageProvider.translate('no_projects_yet'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                languageProvider.translate('create_first_project_started'),
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
          height: 350,
          margin: const EdgeInsets.only(bottom: 32),
          decoration: BoxDecoration(
            color: const Color(0xFFD1D1CB),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Project Info
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
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        project.description.isNotEmpty
                            ? project.description
                            : languageProvider.translate('no_description'),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${languageProvider.translate('created_at_label')} 1/22/2026',
                      style: const TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      languageProvider.translate('skills_required'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF23393E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: project.skills
                          .take(3)
                          .map(
                            (skill) => GestureDetector(
                              onTap: () => _handleSkillFilter(skill),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF23393E).withAlpha(30),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  skill,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF23393E),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      languageProvider.translate('team_members'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF23393E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ...project.participants.take(3).map(
                              (p) {
                                final imageUrl = p.user?.profile?.profileImage;
                                return Container(
                                  margin: const EdgeInsets.only(right: 6),
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

              // Divider
              Container(width: 1, color: Colors.black.withAlpha(20)),

              // Right Sections List
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
      margin: const EdgeInsets.only(right: 24),
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
