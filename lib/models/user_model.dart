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
    // Handle cases where Laravel wraps the response in a 'data' or 'user' key
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
}

class Profile {
  final int id;
  final int userId;
  // Add other profile fields if needed

  Profile({required this.id, required this.userId});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(id: json['id'], userId: json['user_id']);
  }
}
