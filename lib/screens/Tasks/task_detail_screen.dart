import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../models/task_model.dart';
import '../../services/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/ai_service.dart';
import 'dart:convert';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;
  final String projectName;

  const TaskDetailScreen({
    super.key,
    required this.task,
    required this.projectName,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TaskModel _task;
  bool _isUploading = false;
  bool _isCheckingDependencies = false;
  bool _dependenciesCompleted = true;
  List<TaskModel> _pendingDependencies = [];

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _checkDependencies();
  }

  Future<void> _checkDependencies() async {
    if (_task.dependsOn.isEmpty) return;

    setState(() => _isCheckingDependencies = true);
    try {
      final allTasks = await ApiService.getProjectTasks(_task.projectId);
      
      List<TaskModel> pending = [];
      for (var taskId in _task.dependsOn) {
        try {
          final dependentTask = allTasks.firstWhere((t) => t.id == taskId);
          if (dependentTask.status.toLowerCase() != 'completed' && dependentTask.status.toLowerCase() != 'done') {
            pending.add(dependentTask);
          }
        } catch (_) {
          // Task not found
        }
      }

      if (mounted) {
        setState(() {
          _pendingDependencies = pending;
          _dependenciesCompleted = pending.isEmpty;
          _isCheckingDependencies = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isCheckingDependencies = false);
    }
  }

  /// Returns true if the file type is blocked (images, audio, video).
  bool _isBlockedFileType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    const blockedExtensions = {
      // Images
      'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg', 'ico',
      'tiff', 'tif', 'heic', 'heif', 'avif', 'raw', 'cr2', 'nef',
      // Videos
      'mp4', 'mov', 'avi', 'mkv', 'wmv', 'flv', 'webm', 'm4v',
      'mpeg', 'mpg', '3gp', 'ogv', 'ts',
      // Audio
      'mp3', 'wav', 'aac', 'ogg', 'flac', 'm4a', 'wma', 'opus',
      'aiff', 'mid', 'midi', 'amr',
    };
    return blockedExtensions.contains(ext);
  }

  void _showBlockedFileTypeDialog(String fileName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.block, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text(
              'File Type Not Allowed',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: Text(
                '"$fileName" is not a supported file type.\nImages, audio, and video files are not accepted.',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Accepted file types:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            _buildAllowedTypeRow(
              Icons.code,
              'Code files (py, js, dart, java, php…)',
            ),
            _buildAllowedTypeRow(
              Icons.folder_zip_outlined,
              'Archives (zip, rar, tar, 7z…)',
            ),
            _buildAllowedTypeRow(
              Icons.picture_as_pdf_outlined,
              'Documents (pdf, docx, xlsx…)',
            ),
            _buildAllowedTypeRow(
              Icons.text_snippet_outlined,
              'Text files (txt, md, json, csv…)',
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF23393E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Choose Another File'),
          ),
        ],
      ),
    );
  }

  Widget _buildAllowedTypeRow(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.green.shade600),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;

      // Client-side validation: block images, audio, and video files
      if (_isBlockedFileType(file.name)) {
        if (mounted) {
          _showBlockedFileTypeDialog(file.name);
        }
        return;
      }

      final fileBytes = file.bytes;

      if (fileBytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not read file data.')),
          );
        }
        return;
      }

      setState(() => _isUploading = true);

      // AI Validation Step
      String fileContent = '';
      try {
        fileContent = utf8.decode(fileBytes);
      } catch (e) {
        fileContent = '[Binary File: ${file.name}]';
      }

      final aiResult = await AIService.validateTaskFile(
        fileContent: fileContent,
        fileName: file.name,
        taskName: _task.name,
        taskDescription: _task.description,
      );

      if (!aiResult['isValid']) {
        if (mounted) {
          setState(() => _isUploading = false);
          _showAIValidationFeedback(
            aiResult['reason'] ??
                'The file does not match the task requirements.',
            aiResult['suggestions'] ?? [],
          );
        }
        return;
      }

      final uploadResult = await ApiService.uploadTaskAttachment(
        _task.projectId,
        _task.id,
        fileBytes,
        file.name,
      );

      if (uploadResult['success']) {
        // 1. Update backend task status to completed using the member-accessible toggle endpoint
        try {
          // If task isn't already completed/done, toggle it to 'completed'
          if (_task.status.toLowerCase() != 'completed' &&
              _task.status.toLowerCase() != 'done') {
            final updatedTask = await ApiService.toggleTaskStatus(
              _task.projectId,
              _task.id,
            );
            if (updatedTask != null) {
              if (mounted) {
                setState(() {
                  _task = updatedTask;
                });
              }
            }
          }
        } catch (e) {
          print('Backend status toggle failed: $e');
          if (mounted) {
            String errorMessage = e.toString().replaceAll('Exception: ', '');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        }

        // 2. Update local UI state
        if (mounted) {
          setState(() {
            // Force local status 'completed' visually for immediate feedback
            _task = _task.copyWith(status: 'completed');
            _isUploading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task verified and completed!')),
          );
        }

        final data = uploadResult['data'];
        if (data != null && data['task'] != null) {
          if (mounted) {
            setState(() {
              // Ensure we use the latest task data from the upload response if available
              final taskFromUpload = TaskModel.fromJson(data['task']);
              // But keep our local 'completed' status if the toggle worked
              _task = taskFromUpload.copyWith(
                status: _task.status == 'completed'
                    ? 'completed'
                    : taskFromUpload.status,
              );
            });
          }
        }
      } else {
        if (mounted) {
          setState(() => _isUploading = false);
        }
        final data = uploadResult['data'];
        if (uploadResult['status'] == 422 && data != null) {
          if (mounted) {
            _showAIValidationFeedback(
              data['reason'] ?? 'Validation failed.',
              data['suggestions'] ?? [],
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(data?['message'] ?? 'Upload failed.')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showAIValidationFeedback(String reason, List<dynamic> suggestions) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.auto_awesome, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text(
              'AI Validation Rejected',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reason:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(reason, style: const TextStyle(fontSize: 15)),
                  ],
                ),
              ),
              if (suggestions.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'Suggestions for improvement:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF23393E),
                  ),
                ),
                const SizedBox(height: 8),
                ...suggestions.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Icon(
                            Icons.check_circle_outline,
                            size: 14,
                            color: Colors.green.shade600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            s.toString(),
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF23393E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.user;
    final bool isAssignedToMe =
        currentUser != null && _task.assignedTo == currentUser.id;

    final Color primaryColor = const Color(0xFF23393E);
    final Color backgroundColor = const Color(0xFFF4F7F8);
    final Color cardColor = const Color(0xFFD1D1CB);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryColor),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text(
          'Task Details',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {},
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 16,
                          color: primaryColor.withOpacity(0.6),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.projectName,
                          style: TextStyle(
                            color: primaryColor.withOpacity(0.6),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        _buildStatusBadge(_task.status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _task.name,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_task.dueDate != null) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Due ${DateFormat('MMM dd, yyyy').format(_task.dueDate!)}',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionTitle('Description'),
              const SizedBox(height: 12),
              Text(
                _task.description.isEmpty
                    ? 'No description provided.'
                    : _task.description,
                style: TextStyle(
                  color: primaryColor.withOpacity(0.8),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              if (_task.skills.isNotEmpty) ...[
                _buildSectionTitle('Required Skills'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _task.skills
                      .map((skill) => _buildSkillChip(skill))
                      .toList(),
                ),
                const SizedBox(height: 32),
              ],
              if (_task.attachments.isNotEmpty) ...[
                _buildSectionTitle('Attachments'),
                const SizedBox(height: 12),
                ..._task.attachments.map((att) => _buildAttachmentItem(att)),
                const SizedBox(height: 32),
              ],
              if (isAssignedToMe &&
                  _task.status.toLowerCase() != 'completed' &&
                  _task.status.toLowerCase() != 'done') ...[
                const SizedBox(height: 16),
                if (_isCheckingDependencies)
                  const Center(child: CircularProgressIndicator())
                else if (!_dependenciesCompleted)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Cannot upload files yet. This task depends on the following pending tasks:',
                                style: TextStyle(color: Colors.orange.shade900, fontWeight: FontWeight.bold, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ..._pendingDependencies.map((t) => Padding(
                          padding: const EdgeInsets.only(left: 32, bottom: 4),
                          child: Text('• ${t.name}', style: TextStyle(color: Colors.orange.shade900)),
                        )),
                      ],
                    ),
                  )
                else
                  SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: _isUploading ? null : _pickAndUploadFile,
                    icon: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.cloud_upload_outlined,
                            color: Colors.white,
                          ),
                    label: Text(
                      _isUploading ? 'Validating...' : 'Upload Deliverables',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ] else if (_task.status.toLowerCase() == 'completed' ||
                  _task.status.toLowerCase() == 'done' ||
                  _task.attachments.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 12),
                      Text(
                        'Task Completed',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF23393E),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    // If there are attachments, we treat it as COMPLETED for the user's view
    String displayStatus = status;
    if (_task.attachments.isNotEmpty &&
        status.toLowerCase() != 'completed' &&
        status.toLowerCase() != 'done') {
      displayStatus = 'completed';
    }

    Color color;
    switch (displayStatus.toLowerCase()) {
      case 'completed':
      case 'done':
        color = Colors.green;
        break;
      case 'in_progress':
      case 'doing':
        color = Colors.blue;
        break;
      case 'overdue':
        color = Colors.orange;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        displayStatus.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        skill,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF23393E),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAttachmentItem(AttachmentModel attachment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_outlined, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              attachment.fileName,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
