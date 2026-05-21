import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../Dashboard/widgets/sidebar.dart';
import '../Dashboard/widgets/header.dart';
import 'widgets/task_list_item.dart';
import '../../services/api_service.dart';
import '../../models/task_model.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int _activeTab = 0; // 0 for In Progress, 1 for Completed
  List<TaskModel> _allTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final tasks = await ApiService.getMyTasks();

      if (mounted) {
        setState(() {
          _allTasks = tasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      print('Error loading tasks: $e');
    }
  }

  String _getProjectName(TaskModel task) {
    return task.projectName ?? "Project";
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isAr = languageProvider.isArabic;
    String tr(String en, String ar) => isAr ? ar : en;

    int inProgressCount = 0;
    int completedCount = 0;
    List<TaskModel> filteredTasks = [];

    if (!_isLoading) {
      inProgressCount = _allTasks
          .where((t) => t.status != 'completed' && t.status != 'done' && t.status != 'COMPLETED')
          .length;
      completedCount = _allTasks
          .where((t) => t.status == 'completed' || t.status == 'done' || t.status == 'COMPLETED')
          .length;

      filteredTasks = _allTasks.where((task) {
        final bool isCompleted =
            task.status == 'completed' || task.status == 'done' || task.status == 'COMPLETED';
        return _activeTab == 0 ? !isCompleted : isCompleted;
      }).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      body: Row(
        children: [
          const Sidebar(currentRoute: 'tasks'),
          Expanded(
            child: Column(
              children: [
                const Header(title: 'Tasks'),
                Expanded(
                  child: Column(
                    children: [
                      // Tabs
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildTab(tr('In Progress', 'قيد التنفيذ'), inProgressCount, 0),
                            const SizedBox(width: 32),
                            _buildTab(tr('Completed', 'مكتملة'), completedCount, 1),
                          ],
                        ),
                      ),

                      // Sort and Filters Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 20,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    tr('Sort by: ', 'ترتيب حسب: '),
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    tr('Due Date', 'تاريخ الاستحقاق'),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down, size: 18),
                                ],
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.filter_list,
                              color: Colors.black45,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              tr('Filters Applied: All Projects', 'الفلاتر المطبقة: جميع المشاريع'),
                              style: const TextStyle(
                                color: Colors.black45,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Tasks List or Loading/Empty State
                      Expanded(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF23393E),
                                ),
                              )
                            : filteredTasks.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 0,
                                ),
                                itemCount: filteredTasks.length,
                                itemBuilder: (context, index) {
                                  final task = filteredTasks[index];
                                  return TaskListItem(
                                    task: task,
                                    projectName: _getProjectName(task),
                                    onRefresh: _loadData,
                                  );
                                },
                              ),
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

  Widget _buildEmptyState() {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final isAr = languageProvider.isArabic;
    String tr(String en, String ar) => isAr ? ar : en;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            _activeTab == 0
                ? tr('No tasks in progress', 'لا توجد مهام قيد التنفيذ')
                : tr('No completed tasks', 'لا توجد مهام مكتملة'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tr('Tasks will appear here when they are assigned to projects.',
               'ستظهر المهام هنا عند إسنادها إلى المشاريع.'),
            style: const TextStyle(color: Colors.black38),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int count, int index) {
    final bool isActive = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFF23393E) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? Colors.black : Colors.black45,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black45,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
