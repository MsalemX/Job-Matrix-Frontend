import 'package:flutter/material.dart';
import '../../../models/task_model.dart';

class TaskListItem extends StatelessWidget {
  final TaskModel task;
  final String projectName;

  const TaskListItem({
    super.key,
    required this.task,
    required this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted =
        task.status == 'completed' || task.status == 'done';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(
          0xFFD1D1CB,
        ), // Matching the screenshot's greyish card color
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          // Completion Indicator
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? const Color(0xFF23393E) : Colors.transparent,
              border: Border.all(color: Colors.black26, width: 2),
            ),
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 24),

          // Task Details
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF23393E),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.folder_outlined,
                      size: 16,
                      color: Colors.black45,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      projectName,
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Project Name (Label)
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PROJECT NAME',
                  style: TextStyle(
                    color: Colors.black38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  projectName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF23393E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Due Date
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DUE DATE',
                  style: TextStyle(
                    color: Colors.black38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Color(0xFF23393E),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Oct 24, 2023', // Placeholder for now as TaskModel might not have dueDate yet
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF23393E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Assignees
          SizedBox(
            width: 80,
            child: Stack(
              children: [
                _buildAvatar(0),
                Positioned(left: 20, child: _buildAvatar(1)),
              ],
            ),
          ),

          // Menu
          const Icon(Icons.more_vert, color: Colors.black26),
        ],
      ),
    );
  }

  Widget _buildAvatar(int index) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const CircleAvatar(
        radius: 16,
        backgroundImage: AssetImage('assets/team/Mohammed Salem Alhanshi.jpg'),
      ),
    );
  }
}
