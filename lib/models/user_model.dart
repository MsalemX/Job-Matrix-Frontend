import 'task_model.dart';

class AuthResponse {
  final String accessToken;
  final String tokenType;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        json.containsKey('data') && json['data'] is Map<String, dynamic>
        ? json['data']
        : json;

    final userJson = data['user'] ?? json['user'];

    return AuthResponse(
      accessToken:
          data['access_token'] ??
          data['token'] ??
          data['auth_token'] ??
          json['access_token'] ??
          json['token'] ??
          '',
      tokenType: data['token_type'] ?? json['token_type'] ?? 'Bearer',
      user: userJson != null && userJson is Map<String, dynamic>
          ? User.fromJson(userJson)
          : User(id: 0, name: 'User', email: '', username: '', role: 'user'),
    );
  }

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'token_type': tokenType,
    'user': user.toJson(),
  };
}

class User {
  final int id;
  final String name;
  final String email;
  final String username;
  final String role;
  final Profile? profile;
  // Raw project_participants json list — parsed lazily in UserProfileScreen
  final List<Map<String, dynamic>> rawProjectParticipants;
  final List<TaskModel> assignedTasks;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.role,
    this.profile,
    this.rawProjectParticipants = const [],
    this.assignedTasks = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? 'user',
      profile: json['profile'] != null
          ? Profile.fromJson(json['profile'])
          : null,
      rawProjectParticipants: (json['project_participants'] is List)
          ? (json['project_participants'] as List)
                .whereType<Map<String, dynamic>>()
                .toList()
          : [],
      assignedTasks: (json['assigned_tasks'] is List)
          ? (json['assigned_tasks'] as List)
                .map((i) => TaskModel.fromJson(i))
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'username': username,
    'role': role,
    if (profile != null) 'profile': profile!.toJson(),
  };
}

class Profile {
  final int id;
  final int userId;
  final String? profileImage;
  final String? bio;
  final int points;
  final List<String> skills;

  Profile({
    required this.id,
    required this.userId,
    this.profileImage,
    this.bio,
    this.points = 0,
    this.skills = const [],
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    var rawSkills = json['skills'];
    List<String> skillsList = [];
    if (rawSkills != null && rawSkills is List) {
      skillsList = rawSkills
          .map((s) {
            if (s is String) return s;
            if (s is Map && s.containsKey('name')) return s['name'].toString();
            return s.toString();
          })
          .where((s) => s.isNotEmpty)
          .toList()
          .cast<String>();
    }

    return Profile(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      profileImage: json['profile_image'] ?? json['avatar'] ?? json['image'],
      bio: json['bio'],
      points: json['points'] ?? 0,
      skills: skillsList,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    if (profileImage != null) 'profile_image': profileImage,
    if (bio != null) 'bio': bio,
    'skills': skills,
  };
}
