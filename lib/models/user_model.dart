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

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
    required this.role,
    this.profile,
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

  Profile({
    required this.id,
    required this.userId,
    this.profileImage,
    this.bio,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      profileImage: json['profile_image'] ?? json['avatar'] ?? json['image'],
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    if (profileImage != null) 'profile_image': profileImage,
    if (bio != null) 'bio': bio,
  };
}
