import 'user_model.dart';
import 'task_model.dart';

class ProjectModel {
  final int id;
  final String name;
  final String description;
  final String visibility;
  final List<String> skills;
  final int? userId;
  final User? owner;
  final List<ParticipantModel> participants;
  final List<SectionModel> sections;
  final DateTime? createdAt;

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    this.visibility = 'public',
    this.skills = const [],
    this.userId,
    this.owner,
    this.participants = const [],
    this.sections = const [],
    this.createdAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      visibility: json['visibility'] ?? 'public',
      skills: json['skills'] != null
          ? (json['skills'] as List)
                .map((s) {
                  if (s is String) return s;
                  if (s is Map && s.containsKey('name')) {
                    return s['name'].toString();
                  }
                  return s.toString();
                })
                .where((s) => s.isNotEmpty)
                .toList()
                .cast<String>()
          : [],
      userId: json['user_id'],
      owner: json['user'] != null ? User.fromJson(json['user']) : null,
      participants: (json['participants'] is List)
          ? (json['participants'] as List)
                .map((i) => ParticipantModel.fromJson(i))
                .toList()
          : [],
      sections: (json['sections'] is List)
          ? (json['sections'] as List)
                .map((i) => SectionModel.fromJson(i))
                .toList()
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'visibility': visibility,
    'skills': skills,
    if (owner != null) 'user': owner!.toJson(),
  };
}

class ParticipantModel {
  final int id;
  final int userId;
  final int projectId;
  final String status;
  final String role;
  final User? user;

  ParticipantModel({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.status,
    this.role = 'member',
    this.user,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      projectId: json['project_id'] ?? 0,
      status: json['status'] ?? 'pending',
      role: json['role'] ?? 'member',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}
