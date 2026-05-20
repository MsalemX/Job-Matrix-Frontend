import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../Projects/project_detail_screen.dart';
import '../Auth/login_screen.dart';
import '../../models/project_model.dart';

/// Screen that handles invite link routing.
/// When a user navigates to /invite/{code}, this screen displays a preview
/// of the project, allowing them to click a button to join.
class InviteHandlerScreen extends StatefulWidget {
  final String inviteCode;

  const InviteHandlerScreen({super.key, required this.inviteCode});

  @override
  State<InviteHandlerScreen> createState() => _InviteHandlerScreenState();
}

class _InviteHandlerScreenState extends State<InviteHandlerScreen> {
  String _status =
      'loading'; // loading, preview, joining, success, error, login_required
  String _message = '';
  ProjectModel? _project;
  final bool _isAlreadyMember = false;

  @override
  void initState() {
    super.initState();
    _loadProjectPreview();
  }

  Future<void> _loadProjectPreview() async {
    // 1. Check if user is logged in
    final token = await ApiService.getToken();
    if (token == null || token.isEmpty) {
      setState(() {
        _status = 'login_required';
        _message = 'Please log in first to view and join this project.';
      });
      return;
    }

    // 2. Fetch project details
    final project = await ApiService.getProjectByInviteLink(widget.inviteCode);
    if (project == null) {
      setState(() {
        _status = 'error';
        _message = 'Invalid or expired invite link.';
      });
      return;
    }

    // 3. Check if user is already a member
    final profile = await ApiService.getMyProfile();
    bool isMember = false;
    if (profile != null) {
      isMember =
          project.participants.any((p) => p.userId == profile.id) ||
          project.userId == profile.id;
    }

    if (mounted) {
      // Direct navigation to Project Detail Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectDetailScreen(
            projectId: project.id,
            inviteCode: isMember ? null : widget.inviteCode,
          ),
        ),
      );
    }
  }

  Future<void> _handleJoin() async {
    if (_project == null) return;

    if (_isAlreadyMember) {
      // Direct redirect if already a member
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectDetailScreen(projectId: _project!.id),
        ),
      );
      return;
    }

    setState(() {
      _status = 'joining';
    });

    final joined = await ApiService.joinProjectWithInviteLink(
      widget.inviteCode,
    );

    if (mounted) {
      if (joined) {
        setState(() {
          _status = 'success';
          _message = 'Successfully joined "${_project!.name}"!';
        });

        // Brief delay before redirecting
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ProjectDetailScreen(projectId: _project!.id),
              ),
            );
          }
        });
      } else {
        setState(() {
          _status = 'error';
          _message = 'Failed to join the project. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 480,
            constraints: const BoxConstraints(maxWidth: 480),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_status == 'loading') ...[
                    const CircularProgressIndicator(color: Color(0xFF23393E)),
                    const SizedBox(height: 24),
                    const Text(
                      'Fetching invitation details...',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (_status == 'joining') ...[
                    const CircularProgressIndicator(color: Color(0xFF23393E)),
                    const SizedBox(height: 24),
                    const Text(
                      'Joining project...',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  if (_status == 'success') ...[
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 56,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF23393E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Opening project detail...',
                      style: TextStyle(color: Colors.black38, fontSize: 13),
                    ),
                  ],
                  if (_status == 'error') ...[
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 56,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF23393E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Go to Dashboard',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                  if (_status == 'login_required') ...[
                    const Icon(
                      Icons.lock_outline,
                      color: Colors.orange,
                      size: 56,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF23393E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Log In to Continue',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                  if (_status == 'preview' && _project != null) ...[
                    // Custom Premium Project Icon / Card Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFF23393E),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.group_work_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'PROJECT INVITATION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black38,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _project!.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF23393E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_project!.description.isNotEmpty) ...[
                      Text(
                        _project!.description,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    const Divider(height: 1),
                    const SizedBox(height: 20),

                    // Owner Details
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 18,
                          color: Colors.black45,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Created by:',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        const Spacer(),
                        Text(
                          _project!.owner?.name ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF23393E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Members Count
                    Row(
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 18,
                          color: Colors.black45,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Team members:',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF23393E).withAlpha(15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_project!.participants.length} members',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF23393E),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () =>
                                  Navigator.pushReplacementNamed(context, '/'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black54,
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Decline',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _handleJoin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF23393E),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                _isAlreadyMember
                                    ? 'Open Project'
                                    : 'Accept & Join',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
