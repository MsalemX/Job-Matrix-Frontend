import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'package:job_matrix_forntend/providers/language_provider.dart';
import 'package:job_matrix_forntend/widgets/admin_top_nav.dart';
import 'package:provider/provider.dart';
import 'admin_report_detail_screen.dart';
import 'admin_project_detail_screen.dart';
import '../Profile/user_profile_screen.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  List<dynamic> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    try {
      final reports = await ApiService.getAdminReports();
      if (mounted) {
        setState(() {
          _reports = reports;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading reports: $e')));
      }
    }
  }

  Future<void> _handleReport(int reportId, String action) async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final noteController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFD9DEDC),
        title: Text(
          action == 'resolve'
              ? langProvider.translate('approve_report')
              : langProvider.translate('dismiss_report'),
          style: const TextStyle(
            color: Color(0xFF33423E),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              action == 'resolve'
                  ? langProvider.translate('confirm_approve_report')
                  : langProvider.translate('confirm_dismiss_report'),
              style: const TextStyle(color: Color(0xFF33423E)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                hintText: langProvider.translate('add_note_optional'),
                hintStyle: const TextStyle(color: Color(0xFF7A8B86)),
                filled: true,
                fillColor: Colors.white.withAlpha(50),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              langProvider.translate('cancel'),
              style: const TextStyle(color: Color(0xFF7A8B86)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'resolve'
                  ? const Color(0xFF423333)
                  : const Color(0xFF7A8B86),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(
              action == 'resolve'
                  ? langProvider.translate('confirm_and_delete')
                  : langProvider.translate('dismiss'),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final result = await ApiService.resolveReport(
        reportId,
        action,
        noteController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));
        _loadReports();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFC7CDCA),
      body: Column(
        children: [
          const AdminTopNav(activeItem: 'Reports'),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF33423E)),
                  )
                : RefreshIndicator(
                    onRefresh: _loadReports,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            langProvider.translate('system_reports'),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF33423E),
                            ),
                          ),
                          Text(
                            langProvider.translate('view_manage_reports'),
                            style: const TextStyle(color: Color(0xFF7A8B86)),
                          ),
                          const SizedBox(height: 48),
                          if (_reports.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(80.0),
                                child: Text(
                                  langProvider.translate(
                                    'no_reports_available',
                                  ),
                                  style: const TextStyle(
                                    color: Color(0xFF7A8B86),
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _reports.length,
                              itemBuilder: (context, index) {
                                return _buildReportCard(_reports[index]);
                              },
                            ),
                          const SizedBox(height: 80),
                          _buildFooter(langProvider),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(dynamic report) {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final reporter = report['reporter'] ?? {};
    final type = report['reportable_type']?.split('\\').last ?? 'Unknown';
    final target = report['reportable'] ?? {};
    final targetName = target['name'] ?? target['username'] ?? 'Unknown';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminReportDetailScreen(
              reportId: report['id'],
              initialData: report,
            ),
          ),
        ).then((value) {
          if (value == true) {
            _loadReports();
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFFD9DEDC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF423333),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${langProvider.translate('report_about')} $type',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () {
                        if (type == 'Project' && target['id'] != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminProjectDetailScreen(
                                projectId: target['id'],
                              ),
                            ),
                          );
                        } else if (type == 'User' && target['id'] != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UserProfileScreen(userId: target['id']),
                            ),
                          );
                        }
                      },
                      child: Text(
                        targetName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF33423E),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    if (reporter['id'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserProfileScreen(userId: reporter['id']),
                        ),
                      );
                    }
                  },
                  child: Text(
                    '${langProvider.translate('reporter')}: ${reporter['name'] ?? 'Unknown'}',
                    style: const TextStyle(
                      color: Color(0xFF7A8B86),
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            if (type == 'Project' && target['owner'] != null) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  if (target['owner']['id'] != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            UserProfileScreen(userId: target['owner']['id']),
                      ),
                    );
                  }
                },
                child: Text(
                  '${langProvider.translate('project_manager')}: ${target['owner']['name'] ?? 'Unknown'}',
                  style: const TextStyle(
                    color: Color(0xFF7A8B86),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              '${langProvider.translate('reason')}:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF33423E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              report['reason'] ?? '',
              style: const TextStyle(
                color: Color(0xFF33423E),
                height: 1.6,
                fontSize: 15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _handleReport(report['id'], 'dismiss'),
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF7A8B86),
                    size: 18,
                  ),
                  label: Text(
                    langProvider.translate('dismiss'),
                    style: const TextStyle(color: Color(0xFF7A8B86)),
                  ),
                ),
                const SizedBox(width: 24),
                ElevatedButton.icon(
                  onPressed: () => _handleReport(report['id'], 'resolve'),
                  icon: const Icon(Icons.delete_forever, size: 18),
                  label: Text(langProvider.translate('take_action_delete')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF423333),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(LanguageProvider langProvider) {
    return Column(
      children: [
        const Divider(height: 1, color: Color(0xFF7A8B86)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '© 2026 Job Matrix. Confidential Access Only.',
                style: TextStyle(color: Color(0xFF7A8B86), fontSize: 13),
              ),
              Row(
                children: [
                  Text(
                    '${langProvider.translate('server_status')}: ${langProvider.translate('online')}',
                    style: const TextStyle(
                      color: Color(0xFF33423E),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'V1.0',
                    style: TextStyle(color: Color(0xFF7A8B86), fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
