class SectionModel {
  final int id;
  final int projectId;
  final String name;
  final List<TaskModel> tasks;

  SectionModel({
    required this.id,
    required this.projectId,
    required this.name,
    this.tasks = const [],
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      id: json['id'] ?? 0,
      projectId: json['project_id'] ?? 0,
      name: json['name'] ?? '',
      tasks: json['tasks'] != null
          ? (json['tasks'] as List).map((i) => TaskModel.fromJson(i)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'project_id': projectId,
    'name': name,
    'tasks': tasks.map((e) => e.toJson()).toList(),
  };
}

class TaskModel {
  final int id;
  final int sectionId;
  final String name;
  final String description;
  final String status;
  final List<int> dependsOn;
  final List<AttachmentModel> attachments;
  final DateTime? dueDate;
  final String? color;

  TaskModel({
    required this.id,
    required this.sectionId,
    required this.name,
    this.description = '',
    this.status = 'pending',
    this.dependsOn = const [],
    this.attachments = const [],
    this.dueDate,
    this.color,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? 0,
      sectionId: json['section_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      dependsOn: json['depends_on'] != null
          ? List<int>.from(json['depends_on'])
          : [],
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
                .map((i) => AttachmentModel.fromJson(i))
                .toList()
          : [],
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'])
          : null,
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'section_id': sectionId,
    'name': name,
    'description': description,
    'status': status,
    'depends_on': dependsOn,
    'attachments': attachments.map((e) => e.toJson()).toList(),
  };
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
