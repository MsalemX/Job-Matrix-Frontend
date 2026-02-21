class ActivityModel {
  final int id;
  final int userId;
  final String description;
  final String type;
  final DateTime? createdAt;

  ActivityModel({
    required this.id,
    required this.userId,
    required this.description,
    required this.type,
    this.createdAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}

class ReportModel {
  final int id;
  final int reporterId;
  final int reportableId;
  final String reportableType;
  final String reason;
  final String status;
  final String? adminNote;

  ReportModel({
    required this.id,
    required this.reporterId,
    required this.reportableId,
    required this.reportableType,
    required this.reason,
    required this.status,
    this.adminNote,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] ?? 0,
      reporterId: json['reporter_id'] ?? 0,
      reportableId: json['reportable_id'] ?? 0,
      reportableType: json['reportable_type'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
      adminNote: json['admin_note'],
    );
  }
}
