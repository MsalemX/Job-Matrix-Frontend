import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../services/api_service.dart';
import '../../../models/project_model.dart';
import '../../../models/task_model.dart';
import '../../../providers/language_provider.dart';

class CreateTaskDialog extends StatefulWidget {
  final int projectId;
  final int sectionId;
  final List<ParticipantModel> participants;
  final List<TaskModel> existingTasks;
  final VoidCallback? onTaskCreated;
  // Edit mode
  final int? taskId;
  final String? initialName;
  final String? initialDescription;
  final int? initialAssignedTo;
  final DateTime? initialDeadline;
  final int? initialPoints;
  final List<String>? initialSkills;

  const CreateTaskDialog({
    super.key,
    required this.projectId,
    required this.sectionId,
    required this.participants,
    required this.existingTasks,
    this.onTaskCreated,
    this.taskId,
    this.initialName,
    this.initialDescription,
    this.initialAssignedTo,
    this.initialDeadline,
    this.initialPoints,
    this.initialSkills,
  });

  bool get isEditMode => taskId != null;

  static void show(
    BuildContext context, {
    required int projectId,
    required int sectionId,
    required List<ParticipantModel> participants,
    required List<TaskModel> existingTasks,
    VoidCallback? onTaskCreated,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(150),
      builder: (context) => CreateTaskDialog(
        projectId: projectId,
        sectionId: sectionId,
        participants: participants,
        existingTasks: existingTasks,
        onTaskCreated: onTaskCreated,
      ),
    );
  }

  static void showEdit(
    BuildContext context, {
    required int projectId,
    required int sectionId,
    required int taskId,
    required String initialName,
    required String initialDescription,
    required int? initialAssignedTo,
    required DateTime? initialDeadline,
    required int initialPoints,
    required List<String> initialSkills,
    required List<ParticipantModel> participants,
    required List<TaskModel> existingTasks,
    VoidCallback? onTaskUpdated,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(150),
      builder: (context) => CreateTaskDialog(
        projectId: projectId,
        sectionId: sectionId,
        taskId: taskId,
        initialName: initialName,
        initialDescription: initialDescription,
        initialAssignedTo: initialAssignedTo,
        initialDeadline: initialDeadline,
        initialPoints: initialPoints,
        initialSkills: initialSkills,
        participants: participants,
        existingTasks: existingTasks,
        onTaskCreated: onTaskUpdated,
      ),
    );
  }

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _pointsController;
  final _skillController = TextEditingController();

  DateTime? _selectedDeadline;
  int? _selectedAssigneeId;
  late List<String> _skills;
  final List<int> _dependencies = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _descriptionController = TextEditingController(
      text: widget.initialDescription ?? '',
    );
    _pointsController = TextEditingController(
      text: (widget.initialPoints ?? 0).toString(),
    );
    _selectedDeadline = widget.initialDeadline;
    _selectedAssigneeId = widget.initialAssignedTo;
    _skills = List<String>.from(widget.initialSkills ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    const points = 10;
    if (name.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final taskData = {
        'name': name,
        'description': description,
        'section_id': widget.sectionId,
        'points': points,
        'assigned_to': _selectedAssigneeId,
        'deadline': _selectedDeadline?.toIso8601String(),
        'skills': _skills,
        'depends_on': _dependencies,
      };

      bool success;
      if (widget.isEditMode) {
        final result = await ApiService.updateTask(
          widget.projectId,
          widget.taskId!,
          taskData,
        );
        success = result != null;
      } else {
        final result = await ApiService.createTask(widget.projectId, taskData);
        success = result != null;
      }

      if (success) {
        if (mounted) {
          widget.onTaskCreated?.call();
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isEditMode
                    ? 'Failed to update task'
                    : 'Failed to create task',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.isEditMode;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Task' : 'Create New Task',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF23393E),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: Colors.black38,
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIdentityCard(),
                    const SizedBox(height: 24),
                    _buildDetailsCard(),
                    const SizedBox(height: 32),
                    _buildActionButton(isEdit),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardLabel('TASK IDENTITY'),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: _inputDecoration(
              'Task Name',
              Icons.assignment_outlined,
              'e.g., UI Refinement',
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _descriptionController,
            maxLines: 2,
            decoration: _inputDecoration(
              'Description',
              Icons.description_outlined,
              'Detailed task description...',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardLabel('TASK DETAILS'),
          const SizedBox(height: 24),
          _buildDatePicker(),
          const SizedBox(height: 20),
          _buildAssigneeDropdown(),
          const SizedBox(height: 20),
          _buildSkillsInput(),
          const SizedBox(height: 20),
          _buildDependenciesPicker(),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDeadline ?? DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) setState(() => _selectedDeadline = picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: Colors.black54,
            ),
            const SizedBox(width: 12),
            Text(
              _selectedDeadline == null
                  ? 'Deadline'
                  : DateFormat('MMM dd, yyyy').format(_selectedDeadline!),
              style: TextStyle(
                color: _selectedDeadline == null
                    ? Colors.black38
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssigneeDropdown() {
    final isArabic = Provider.of<LanguageProvider>(context, listen: false).isArabic;
    return DropdownButtonFormField<int?>(
      value: _selectedAssigneeId,
      decoration: _inputDecoration(
        isArabic ? 'توكيل المهمة إلى' : 'Assign To',
        Icons.person_outline,
        isArabic ? 'اختر عضواً من الفريق' : 'Select team member',
      ),
      items: [
        DropdownMenuItem<int?>(
          value: null,
          child: Text(isArabic ? 'لا أحد (غير معين)' : 'No one (Unassigned)'),
        ),
        ...widget.participants.map((p) {
          return DropdownMenuItem<int?>(
            value: p.userId,
            child: Text(p.user?.name ?? 'Unknown User'),
          );
        }),
      ],
      onChanged: (val) => setState(() => _selectedAssigneeId = val),
    );
  }

  Widget _buildSkillsInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _skillController,
          onSubmitted: (_) => _addSkill(),
          decoration: _inputDecoration(
            'Required Skills',
            Icons.architecture_outlined,
            'e.g., Flutter',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFF23393E)),
              onPressed: _addSkill,
            ),
          ),
        ),
        if (_skills.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _skills
                .map(
                  (s) => Chip(
                    label: Text(
                      s,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    backgroundColor: const Color(0xFF23393E),
                    deleteIcon: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white,
                    ),
                    onDeleted: () => setState(() => _skills.remove(s)),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildDependenciesPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCardLabel('DEPENDS ON'),
        const SizedBox(height: 12),
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: widget.existingTasks.length,
            itemBuilder: (context, index) {
              final task = widget.existingTasks[index];
              final isSelected = _dependencies.contains(task.id);
              return CheckboxListTile(
                value: isSelected,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(task.name, style: const TextStyle(fontSize: 13)),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _dependencies.add(task.id);
                    } else {
                      _dependencies.remove(task.id);
                    }
                  });
                },
                activeColor: const Color(0xFF23393E),
                dense: true,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(bool isEdit) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF23393E),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                isEdit ? 'Save Changes' : 'Create Task',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Text _buildCardLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.black38,
        letterSpacing: 1,
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon,
    String hint, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF23393E), width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}
