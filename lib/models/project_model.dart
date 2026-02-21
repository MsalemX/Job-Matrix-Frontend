import 'user_model.dart';

class ProjectModel {
  final int id;
  final String name;
  final String description;
  final String visibility;
  final List<String> skills;
  final User? owner;
  final List<ParticipantModel> participants;

  ProjectModel({
    required this.id,
    required this.name,
    required this.description,
    this.visibility = 'public',
    this.skills = const [],
    this.owner,
    this.participants = const [],
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      visibility: json['visibility'] ?? 'public',
      skills: json['skills'] != null ? List<String>.from(json['skills']) : [],
      owner: json['user'] != null ? User.fromJson(json['user']) : null,
      participants: json['participants'] != null
          ? (json['participants'] as List)
                .map((i) => ParticipantModel.fromJson(i))
                .toList()
          : [],
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
  final User? user;

  ParticipantModel({
    required this.id,
    required this.userId,
    required this.projectId,
    required this.status,
    this.user,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      projectId: json['project_id'] ?? 0,
      status: json['status'] ?? 'pending',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}
