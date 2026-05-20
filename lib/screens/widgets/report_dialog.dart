import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ReportDialog extends StatefulWidget {
  final int reportableId;
  final String reportableType; // 'user' or 'project'
  final String title;

  const ReportDialog({
    super.key,
    required this.reportableId,
    required this.reportableType,
    required this.title,
  });

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  final _reasonController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submitReport() async {
    if (_reasonController.text.length < 10) {
      setState(() {
        _errorMessage = 'الرجاء إدخال سبب للبلاغ (على الأقل 10 أحرف)';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ApiService.submitReport(
      reportableId: widget.reportableId,
      reportableType: widget.reportableType,
      reason: _reasonController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'])),
        );
      } else {
        setState(() {
          _errorMessage = result['message'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('إبلاغ عن ${widget.title}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _reasonController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'اكتب سبب البلاغ هنا...',
              errorText: _errorMessage,
              border: const OutlineInputBorder(),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('إرسال البلاغ'),
        ),
      ],
    );
  }
}

void showReportDialog(BuildContext context, int id, String type, String title) {
  showDialog(
    context: context,
    builder: (context) => ReportDialog(
      reportableId: id,
      reportableType: type,
      title: title,
    ),
  );
}
