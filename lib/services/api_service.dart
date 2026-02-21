import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';
import '../models/chat_model.dart';
import '../models/activity_model.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.226.1:8000/api';

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // --- Auth ---

  static Future<AuthResponse?> login(String login, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'login': login, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);
        await saveToken(authResponse.accessToken);
        return authResponse;
      } else {
        print('Login failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
      return null;
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  static Future<AuthResponse?> register({
    required String name,
    required String username,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'username': username,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'role': role,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);
        await saveToken(authResponse.accessToken);
        return authResponse;
      } else {
        print('Registration failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
      return null;
    } catch (e) {
      print('Error during registration: $e');
      return null;
    }
  }

  static Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: await _getHeaders(),
      );
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    }
  }

  // --- Profiles ---

  static Future<User?> getMyProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: await _getHeaders(),
      );
      print('Profile status: ${response.statusCode}');
      print('Profile body: ${response.body}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Handle wrapped responses (e.g. {data: {user: {...}}} or {user: {...}})
        if (decoded is Map<String, dynamic>) {
          if (decoded.containsKey('data') &&
              decoded['data'] is Map<String, dynamic>) {
            final data = decoded['data'];
            if (data.containsKey('user') &&
                data['user'] is Map<String, dynamic>) {
              return User.fromJson(data['user']);
            }
            return User.fromJson(data);
          }
          if (decoded.containsKey('user') &&
              decoded['user'] is Map<String, dynamic>) {
            return User.fromJson(decoded['user']);
          }
          return User.fromJson(decoded);
        }
      }
    } catch (e) {
      print('Error getting profile: $e');
    }
    return null;
  }

  static Future<User?> getUserProfile(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profiles/$userId'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error getting other profile: $e');
    }
    return null;
  }

  // --- Projects ---

  static List _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      if (decoded.containsKey('data') && decoded['data'] is List) {
        return decoded['data'];
      }
      if (decoded.containsKey('projects') && decoded['projects'] is List) {
        return decoded['projects'];
      }
    }
    return [];
  }

  static Future<List<ProjectModel>> getPublicProjects() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/projects/public'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = _extractList(decoded);
        return data.map((json) => ProjectModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error getting public projects: $e');
    }
    return [];
  }

  static Future<List<ProjectModel>> getMyProjects() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/projects'),
        headers: await _getHeaders(),
      );
      print('Projects status: ${response.statusCode}');
      print('Projects body: ${response.body}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = _extractList(decoded);
        return data.map((json) => ProjectModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error getting my projects: $e');
    }
    return [];
  }

  static Future<ProjectModel?> createProject(
    Map<String, dynamic> projectData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/projects'),
        headers: await _getHeaders(),
        body: jsonEncode(projectData),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return ProjectModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error creating project: $e');
    }
    return null;
  }

  static Future<ProjectModel?> getProject(int projectId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/projects/$projectId'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return ProjectModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error getting project details: $e');
    }
    return null;
  }

  static Future<bool> joinProject(int projectId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/projects/$projectId/join'),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // --- Tasks & Sections ---

  static Future<List<SectionModel>> getSections(int projectId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/projects/$projectId/sections'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = _extractList(decoded);
        return data.map((json) => SectionModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error getting sections: $e');
    }
    return [];
  }

  static Future<SectionModel?> createSection(int projectId, String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/projects/$projectId/sections'),
        headers: await _getHeaders(),
        body: jsonEncode({'name': name}),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return SectionModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error creating section: $e');
    }
    return null;
  }

  static Future<TaskModel?> createTask(
    int projectId,
    Map<String, dynamic> taskData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/projects/$projectId/tasks'),
        headers: await _getHeaders(),
        body: jsonEncode(taskData),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return TaskModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error creating task: $e');
    }
    return null;
  }

  static Future<bool> toggleTaskStatus(int projectId, int taskId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/projects/$projectId/tasks/$taskId/toggle'),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // --- Messaging ---

  static Future<List<ConversationModel>> getConversations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/conversations'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => ConversationModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error getting conversations: $e');
    }
    return [];
  }

  static Future<ConversationModel?> getOrCreateConversation(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/conversations/$userId'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return ConversationModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error opening conversation: $e');
    }
    return null;
  }

  static Future<MessageModel?> sendMessage(
    int conversationId,
    String content,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/conversations/$conversationId/messages'),
        headers: await _getHeaders(),
        body: jsonEncode({'content': content}),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return MessageModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error sending message: $e');
    }
    return null;
  }

  // --- Reports & Activities ---

  static Future<bool> submitReport(Map<String, dynamic> reportData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reports'),
        headers: await _getHeaders(),
        body: jsonEncode(reportData),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<ActivityModel>> getMyActivities() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/activities'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => ActivityModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error getting activities: $e');
    }
    return [];
  }

  // --- Admin ---

  static Future<List<User>> adminGetUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => User.fromJson(json)).toList();
      }
    } catch (e) {
      print('Admin: Error getting users: $e');
    }
    return [];
  }

  static Future<List<ProjectModel>> adminGetAllProjects() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/projects'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => ProjectModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Admin: Error getting all projects: $e');
    }
    return [];
  }

  static Future<List<ReportModel>> adminGetReports() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/reports'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => ReportModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Admin: Error getting reports: $e');
    }
    return [];
  }

  static Future<bool> adminResolveReport(
    int reportId,
    String action,
    String? note,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/admin/reports/$reportId/resolve'),
        headers: await _getHeaders(),
        body: jsonEncode({'action': action, 'admin_note': note}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<ActivityModel>> adminGetGlobalLogs() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/activities'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => ActivityModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Admin: Error getting global logs: $e');
    }
    return [];
  }

  // --- Helpers ---

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
