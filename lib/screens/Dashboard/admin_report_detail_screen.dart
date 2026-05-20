import 'package:flutter/material.dart';
import 'package:job_matrix_forntend/providers/language_provider.dart';
import 'package:job_matrix_forntend/screens/Dashboard/admin_project_detail_screen.dart';
import 'package:job_matrix_forntend/screens/Profile/user_profile_screen.dart';
import '../../services/api_service.dart';
import 'package:job_matrix_forntend/widgets/admin_top_nav.dart';
import 'package:provider/provider.dart';

class AdminReportDetailScreen extends StatefulWidget {
  final int reportId;
  final dynamic initialData;

  const AdminReportDetailScreen({
    super.key,
    required this.reportId,
    this.initialData,
  });

  @override
  State<AdminReportDetailScreen> createState() =>
      _AdminReportDetailScreenState();
}

class _AdminReportDetailScreenState extends State<AdminReportDetailScreen> {
  dynamic _report;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _report = widget.initialData;
      _isLoading = false;
    } else {
      _loadDetails();
    }
  }

  Future<void> _loadDetails() async {
    setState(() => _isLoading = true);
    try {
      final details = await ApiService.getAdminReportDetails(widget.reportId);
      if (mounted) {
        setState(() {
          _report = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading report details: $e')),
        );
      }
    }
  }

  Future<void> _handleReport(String action) async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final noteController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFD9DEDC),
        title: Text(
          action == 'resolve'
              ? langProvider.translate('approve_report')
              : langProvider.translate('reject_report'),
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
                  : langProvider.translate('reject_report'),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final result = await ApiService.resolveReport(
        widget.reportId,
        action,
        noteController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));
        Navigator.pop(context, true);
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
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Color(0xFF33423E),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                Text(
                                  langProvider.translate('report_details'),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF33423E),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            _buildMainCard(langProvider),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(LanguageProvider langProvider) {
    final reporter = _report['reporter'] ?? {};
    final type = _report['reportable_type']?.split('\\').last ?? 'Unknown';
    final target = _report['reportable'] ?? {};
    final targetName = target['name'] ?? target['username'] ?? 'Unknown';

    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF423333).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${langProvider.translate('report_about')} $type',
                  style: const TextStyle(
                    color: Color(0xFF423333),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '${langProvider.translate('report_date')}: ${_report['created_at']?.split('T')?.first ?? 'N/A'}',
                style: const TextStyle(color: Color(0xFF7A8B86), fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _buildInfoRow(
            langProvider.translate('reported_target'),
            targetName,
            onTap: () {
              if (type == 'Project') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AdminProjectDetailScreen(projectId: target['id']),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserProfileScreen(userId: target['id']),
                  ),
                );
              }
            },
          ),
          const Divider(height: 48, color: Color(0xFFECECEC)),
          _buildInfoRow(
            langProvider.translate('reporter'),
            reporter['name'] ?? 'Unknown',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserProfileScreen(userId: reporter['id']),
                ),
              );
            },
          ),
          if (type == 'Project' && target['owner'] != null) ...[
            const Divider(height: 48, color: Color(0xFFECECEC)),
            _buildInfoRow(
              langProvider.translate('project_manager'),
              target['owner']['name'] ?? 'Unknown',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        UserProfileScreen(userId: target['owner']['id']),
                  ),
                );
              },
            ),
          ],
          const Divider(height: 48, color: Color(0xFFECECEC)),
          Text(
            langProvider.translate('reason'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF33423E),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFECECEC)),
            ),
            child: Text(
              _report['reason'] ?? '',
              style: const TextStyle(
                color: Color(0xFF33423E),
                height: 1.8,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () => _handleReport('dismiss'),
                icon: const Icon(Icons.close),
                label: Text(langProvider.translate('dismiss_report')),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  foregroundColor: const Color(0xFF7A8B86),
                  side: const BorderSide(color: Color(0xFF7A8B86)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              ElevatedButton.icon(
                onPressed: () => _handleReport('resolve'),
                icon: const Icon(Icons.delete_forever),
                label: Text(langProvider.translate('take_action_delete')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF423333),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {VoidCallback? onTap}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 200,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF7A8B86), fontSize: 16),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: onTap,
            child: Text(
              value,
              style: TextStyle(
                color: onTap != null
                    ? const Color(0xFF33423E)
                    : const Color(0xFF33423E),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                decoration: onTap != null ? TextDecoration.underline : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
