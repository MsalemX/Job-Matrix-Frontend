import 'package:flutter/material.dart';
import '../Dashboard/widgets/sidebar.dart';
import '../Dashboard/widgets/header.dart';
import '../../services/api_service.dart';
import '../../models/task_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDate = DateTime.now();
  List<TaskModel> _allTasks = [];
  bool _isLoading = true;
  String _activeTeam = 'All Teams';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final projects = await ApiService.getMyProjects();
      List<TaskModel> tasksList = [];
      for (var project in projects) {
        final sections = await ApiService.getSections(project.id);
        for (var section in sections) {
          tasksList.addAll(section.tasks);
        }
      }

      // Mocking some dates for demo to match the screenshot
      final now = DateTime.now();
      List<TaskModel> updatedTasks = [];
      for (int i = 0; i < tasksList.length; i++) {
        final task = tasksList[i];
        DateTime? mockDate;

        // Match screenshot tasks if names match, otherwise spread
        if (task.name.contains('Kickoff')) {
          mockDate = DateTime(2026, 1, 1);
        } else if (task.name.contains('Sprint')) {
          mockDate = DateTime(2026, 1, 2);
        } else if (task.name.contains('Deployment')) {
          mockDate = DateTime(2026, 1, 9);
        } else if (task.name.contains('Deadline')) {
          mockDate = DateTime(2026, 1, 11);
        } else if (task.name.contains('Documentation')) {
          mockDate = DateTime(2026, 1, 17);
        } else {
          // Default mock date for others
          mockDate = DateTime(now.year, now.month, (i % 28) + 1);
        }

        updatedTasks.add(
          TaskModel(
            id: task.id,
            sectionId: task.sectionId,
            name: task.name,
            description: task.description,
            status: task.status,
            dependsOn: task.dependsOn,
            attachments: task.attachments,
            dueDate: task.dueDate ?? mockDate,
            color: task.color,
          ),
        );
      }

      if (mounted) {
        setState(() {
          _allTasks = updatedTasks;
          _isLoading = false;
          // Set focused date to Jan 2026 to match screenshot context if requested
          _focusedDate = DateTime(2026, 1, 1);
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _previousMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
    });
  }

  void _goToToday() {
    setState(() {
      _focusedDate = DateTime.now();
    });
  }

  List<String> _getMonthNames() => [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  int _firstWeekdayOffset(DateTime date) {
    // Current DateTime.weekday returns 1 for Monday, 7 for Sunday.
    // We want 0 for Sunday to 6 for Saturday for the grid.
    final firstDay = DateTime(date.year, date.month, 1);
    return firstDay.weekday % 7;
  }

  List<TaskModel> _getTasksForDay(int year, int month, int day) {
    return _allTasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == year &&
          task.dueDate!.month == month &&
          task.dueDate!.day == day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final monthName = _getMonthNames()[_focusedDate.month];
    final year = _focusedDate.year;

    return Scaffold(
      backgroundColor: const Color(
        0xFFE0E0E0,
      ), // Grey background for the screen
      body: Row(
        children: [
          const Sidebar(currentRoute: 'calendar'),
          Expanded(
            child: Column(
              children: [
                const Header(title: 'Calendar'),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        // Calendar Header (Month navigation and Filters)
                        Row(
                          children: [
                            Text(
                              '$monthName $year',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF23393E),
                              ),
                            ),
                            const SizedBox(width: 24),
                            _buildNavigationControls(),
                            const Spacer(),
                            _buildFilterChips(),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Calendar Grid
                        Expanded(
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _buildCalendarGrid(),
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

  Widget _buildNavigationControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _previousMonth,
            icon: const Icon(Icons.chevron_left, size: 20),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          Container(height: 20, width: 1, color: Colors.grey.shade300),
          TextButton(
            onPressed: _goToToday,
            child: const Text(
              'Today',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Container(height: 20, width: 1, color: Colors.grey.shade300),
          IconButton(
            onPressed: _nextMonth,
            icon: const Icon(Icons.chevron_right, size: 20),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final teams = ['All Teams', 'Design', 'Engineering'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: teams.map((team) {
          final bool isActive = _activeTeam == team;
          return GestureDetector(
            onTap: () => setState(() => _activeTeam = team),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF23393E) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                team,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInWeek = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    final offset = _firstWeekdayOffset(_focusedDate);
    final totalDays = _daysInMonth(_focusedDate);
    final previousMonthDate = DateTime(
      _focusedDate.year,
      _focusedDate.month - 1,
    );
    final daysInPrevMonth = _daysInMonth(previousMonthDate);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Day names header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: daysInWeek
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          // Days grid
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cellWidth = constraints.maxWidth / 7;
                final cellHeight =
                    constraints.maxHeight / 6; // Use 6 rows to be safe

                List<Widget> dayCells = [];

                // Offset cells (from previous month)
                for (int i = offset - 1; i >= 0; i--) {
                  dayCells.add(
                    _buildDayCell(daysInPrevMonth - i, isCurrentMonth: false),
                  );
                }

                // Current month cells
                for (int i = 1; i <= totalDays; i++) {
                  dayCells.add(_buildDayCell(i, isCurrentMonth: true));
                }

                // Remaining cells
                int remaining = 0;
                while (dayCells.length < 42) {
                  // Ensure 6 full rows (6 * 7 = 42 cells)
                  remaining++;
                  dayCells.add(_buildDayCell(remaining, isCurrentMonth: false));
                }

                return GridView.count(
                  crossAxisCount: 7,
                  childAspectRatio: cellWidth / cellHeight,
                  physics: const NeverScrollableScrollPhysics(),
                  children: dayCells,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(int day, {required bool isCurrentMonth}) {
    final tasks = isCurrentMonth
        ? _getTasksForDay(_focusedDate.year, _focusedDate.month, day)
        : <TaskModel>[];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade100, width: 0.5),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            day.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: isCurrentMonth
                  ? const Color(0xFF23393E)
                  : Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: tasks.map((task) => _buildTaskLabel(task)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskLabel(TaskModel task) {
    Color bgColor = const Color(0xFF23393E);
    Color textColor = Colors.white;

    if (task.name.contains('Sprint')) {
      bgColor = const Color(0xFFD1E4FF);
      textColor = const Color(0xFF0D47A1);
    } else if (task.name.contains('Kickoff')) {
      bgColor = const Color(0xFFFFEBD1);
      textColor = const Color(0xFFE65100);
    } else if (task.name.contains('Deployment')) {
      bgColor = const Color(0xFFD1F2D1);
      textColor = const Color(0xFF1B5E20);
    } else if (task.name.contains('Documentation')) {
      bgColor = const Color(0xFFE0E0E0);
      textColor = const Color(0xFF424242);
    } else if (task.name.contains('Deadline')) {
      bgColor = const Color(0xFFFFD1D1);
      textColor = const Color(0xFFB71C1C);
    } else if (task.name.contains('Review')) {
      bgColor = const Color(0xFF2D3E40);
      textColor = Colors.white;
    } else if (task.name.contains('Audit')) {
      bgColor = const Color(0xFFF3E5F5);
      textColor = const Color(0xFF6A1B9A);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (task.name.contains('Deployment'))
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 6),
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50),
                shape: BoxShape.circle,
              ),
            ),
          Expanded(
            child: Text(
              task.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
