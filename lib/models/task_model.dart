class SectionModel {
  final int id;
  final int projectId;
  final String name;
  final String description;
  final List<TaskModel> tasks;

  SectionModel({
    required this.id,
    required this.projectId,
    required this.name,
    this.description = '',
    this.tasks = const [],
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id'] ?? 0,
      projectId: json['project_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      tasks: (json['tasks'] is List)
          ? (json['tasks'] as List).map((i) => TaskModel.fromJson(i)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'project_id': projectId,
    'name': name,
    'description': description,
    'tasks': tasks.map((e) => e.toJson()).toList(),
  };
}

class TaskModel {
  final int id;
  final int projectId;
  final int sectionId;
  final String name;
  final String description;
  final String status;
  final List<int> dependsOn;
  final List<AttachmentModel> attachments;
  final DateTime? dueDate;
  final String? color;
  final int progress;
  final int points;
  final int? assignedTo;
  final List<String> skills;
  final String? projectName;

  TaskModel({
    required this.id,
    required this.projectId,
    required this.sectionId,
    required this.name,
    this.description = '',
    this.status = 'pending',
    this.dependsOn = const [],
    this.attachments = const [],
    this.dueDate,
    this.color,
    this.progress = 0,
    this.points = 0,
    this.assignedTo,
    this.skills = const [],
    this.projectName,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? 0,
      projectId: json['project_id'] ?? (json['project'] != null ? json['project']['id'] : 0),
      sectionId: json['section_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      dependsOn: (json['depends_on'] is List)
          ? List<int>.from(json['depends_on'])
          : [],
      attachments: (json['attachments'] is List)
          ? (json['attachments'] as List)
                .map((i) => AttachmentModel.fromJson(i))
                .toList()
          : [],
      dueDate: (json['due_date'] ?? json['deadline']) != null
          ? DateTime.tryParse((json['due_date'] ?? json['deadline']).toString())
          : null,
      color: json['color'],
      progress: json['progress'] ?? 0,
      points: json['points'] ?? 0,
      assignedTo: json['assigned_to'] is Map
          ? (json['assigned_to']['id'] ?? 0)
          : json['assigned_to'],
      skills: (json['skills'] is List) ? List<String>.from(json['skills']) : [],
      projectName: json['project'] != null && json['project'] is Map
          ? json['project']['name']?.toString()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'project_id': projectId,
    'section_id': sectionId,
    'name': name,
    'description': description,
    'status': status,
    'depends_on': dependsOn,
    'attachments': attachments.map((e) => e.toJson()).toList(),
    'progress': progress,
    'points': points,
    'assigned_to': assignedTo,
    'skills': skills,
    'due_date': dueDate?.toIso8601String(),
  };

  TaskModel copyWith({
    int? id,
    int? projectId,
    int? sectionId,
    String? name,
    String? description,
    String? status,
    List<int>? dependsOn,
    List<AttachmentModel>? attachments,
    DateTime? dueDate,
    String? color,
    int? progress,
    int? points,
    int? assignedTo,
    List<String>? skills,
    String? projectName,
  }) {
    return TaskModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      sectionId: sectionId ?? this.sectionId,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      dependsOn: dependsOn ?? this.dependsOn,
      attachments: attachments ?? this.attachments,
      dueDate: dueDate ?? this.dueDate,
      color: color ?? this.color,
      progress: progress ?? this.progress,
      points: points ?? this.points,
      assignedTo: assignedTo ?? this.assignedTo,
      skills: skills ?? this.skills,
      projectName: projectName ?? this.projectName,
    );
  }
}

class AttachmentModel {
  final int id;
  final String fileName;
  final String filePath;

  AttachmentModel({
    required this.id,
    required this.fileName,
    required this.filePath,
  });

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(
      id: json['id'] ?? 0,
      fileName: json['file_name'] ?? '',
      filePath: json['file_path'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'file_name': fileName,
    'file_path': filePath,
  };
}
