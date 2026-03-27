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
      final uri = Uri.parse('$baseUrl/login');

      print('>>> LOGIN ATTEMPT: POST $uri');

      // Using urlencoded body can sometimes bypass certain CORS preflight issues
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
              'Accept': 'application/json',
            },
            body: {'login': login, 'password': password},
          )
          .timeout(const Duration(seconds: 15));

      print('>>> RESPONSE STATUS: ${response.statusCode}');
      print('>>> RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data);
        await saveToken(authResponse.accessToken);
        return authResponse;
      } else {
        print(
          'Login failed: Status ${response.statusCode}, Body: ${response.body}',
        );
      }
      return null;
    } catch (e, stackTrace) {
      print('!!! LOGIN ERROR: $e');
      print('!!! STACKTRACE: $stackTrace');
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
        if (decoded == null) return null;
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

  static Future<User?> updateProfile(Map<String, dynamic> profileData,
      {List<int>? imageBytes, String? imageFileName}) async {
    try {
      final uri = Uri.parse('$baseUrl/profile');
      final headers = await _getHeaders();

      if (imageBytes != null) {
        // Use MultipartRequest for file upload
        // Note: Laravel/PHP often requires POST + _method: PATCH for multipart PATCH requests
        var request = http.MultipartRequest('POST', uri);
        request.headers.addAll(headers);
        request.fields['_method'] = 'PATCH';

        // Add regular fields
        profileData.forEach((key, value) {
          if (value is List) {
            for (var i = 0; i < value.length; i++) {
              request.fields['$key[$i]'] = value[i].toString();
            }
          } else {
            request.fields[key] = value.toString();
          }
        });

        // Add avatar file
        request.files.add(http.MultipartFile.fromBytes(
          'avatar',
          imageBytes,
          filename: imageFileName ?? 'avatar.jpg',
        ));

        print('Sending Multipart Request: ${request.fields}');
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        print('Update Profile (Multipart) status: ${response.statusCode}');
        print('Update Profile (Multipart) body: ${response.body}');

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          if (decoded != null && decoded is Map<String, dynamic>) {
            return User.fromJson(decoded['user'] ?? decoded);
          }
        }
      } else {
        // Fallback to regular JSON PATCH if no image is provided
        final response = await http.patch(
          uri,
          headers: headers,
          body: jsonEncode(profileData),
        );
        print('Update Profile (JSON) status: ${response.statusCode}');
        print('Update Profile (JSON) body: ${response.body}');
        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          if (decoded != null && decoded is Map<String, dynamic>) {
            return User.fromJson(decoded['user'] ?? decoded);
          }
        }
      }
    } catch (e) {
      print('Error updating profile: $e');
    }
    return null;
  }

  static Future<User?> getUserProfile(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profiles/$userId'),
        headers: await _getHeaders(),
      );
      print('getUserProfile status: ${response.statusCode}');
      print('getUserProfile body: ${response.body}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // API returns { "user": { ... } }
        final userJson = decoded is Map<String, dynamic> && decoded.containsKey('user')
            ? decoded['user']
            : decoded;
        return User.fromJson(userJson);
      }
    } catch (e) {
      print('Error getting other profile: $e');
    }
    return null;
  }

  // --- Projects ---

  static List _extractList(dynamic decoded) {
    if (decoded == null) return [];
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      if (decoded.containsKey('data') && decoded['data'] is List) {
        return decoded['data'];
      }
      if (decoded.containsKey('projects') && decoded['projects'] is List) {
        return decoded['projects'];
      }
      if (decoded.containsKey('tasks') && decoded['tasks'] is List) {
        return decoded['tasks'];
      }
      if (decoded.containsKey('sections') && decoded['sections'] is List) {
        return decoded['sections'];
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

  static Future<List<ProjectModel>> getJoinedProjects() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/my/projects'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = _extractList(decoded);
        return data.map((json) => ProjectModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error getting joined projects: $e');
    }
    return [];
  }

  static Future<List<ProjectModel>> getMyProjects() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/my/projects'),
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

  static Future<List<ProjectModel>> searchPublicProjects(
    String term, {
    int perPage = 15,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/projects/search/public?q=${Uri.encodeComponent(term)}&per_page=$perPage',
        ),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = _extractList(decoded);
        return data.map((json) => ProjectModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error searching public projects: $e');
    }
    return [];
  }

  static Future<List<ProjectModel>> searchJoinedProjects(
    String term, {
    int perPage = 15,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/projects/search/joined?q=${Uri.encodeComponent(term)}&per_page=$perPage',
        ),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = _extractList(decoded);
        return data.map((json) => ProjectModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error searching joined projects: $e');
    }
    return [];
  }

  static Future<List<ProjectModel>> searchPrivateProjects(
    String term, {
    int perPage = 15,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/projects/search/private?q=${Uri.encodeComponent(term)}&per_page=$perPage',
        ),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = _extractList(decoded);
        return data.map((json) => ProjectModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error searching private projects: $e');
    }
    return [];
  }

  static Future<List<ProjectModel>> searchProjects(
    String term, {
    int perPage = 15,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/projects/search?q=${Uri.encodeComponent(term)}&per_page=$perPage',
        ),
        headers: await _getHeaders(),
      );
      print('Search status: ${response.statusCode}');
      print('Search body: ${response.body}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = _extractList(decoded);
        return data.map((json) => ProjectModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error searching projects: $e');
    }
    return [];
  }

  static Future<List<ProjectModel>> filterProjectsBySkill(
    String skill, {
    int perPage = 15,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/projects/filter-by-skill?skill=${Uri.encodeComponent(skill)}&per_page=$perPage',
        ),
        headers: await _getHeaders(),
      );
      print('Filter by skill status: ${response.statusCode}');
      print('Filter by skill body: ${response.body}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = _extractList(decoded);
        return data.map((json) => ProjectModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error filtering projects by skill: $e');
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
        Uri.parse('$baseUrl/projects/$projectId?include=sections.tasks'),
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

  static Future<Map<String, dynamic>?> getProjectMembership(
    int projectId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/projects/$projectId/membership'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error getting project membership: $e');
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

  static Future<bool> resolveJoinRequest(
    int projectId,
    int participantId,
    bool accept,
  ) async {
    try {
      final action = accept ? 'approve' : 'reject';
      final response = await http.post(
        Uri.parse(
          '$baseUrl/projects/$projectId/requests/$participantId/$action',
        ),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error resolving join request: $e');
      return false;
    }
  }

  static Future<bool> inviteMemberByUsername(
    int projectId,
    String username,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/projects/$projectId/invite'),
        headers: await _getHeaders(),
        body: jsonEncode({'username': username}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error inviting member: $e');
      return false;
    }
  }

  static Future<String?> getInviteLink(int projectId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/projects/$projectId/invite-link'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['link'] ?? data['invite_link'] ?? data['url'];
      }
    } catch (e) {
      print('Error getting invite link: $e');
    }
    return null;
  }

  // --- Tasks & Sections ---

  static Future<List<SectionModel>> getSections(int projectId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/projects/$projectId/sections'),
        headers: await _getHeaders(),
      );
      print('Sections status: ${response.statusCode}');
      print('Sections body: ${response.body}');
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

  static Future<List<TaskModel>> getSectionTasks(
    int projectId,
    int sectionId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/projects/$projectId/sections/$sectionId/tasks'),
        headers: await _getHeaders(),
      );
      print('Section $sectionId tasks status: ${response.statusCode}');
      print('Section $sectionId tasks body: ${response.body}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = _extractList(decoded);
        return data.map((json) => TaskModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error getting section tasks: $e');
    }
    return [];
  }

  static Future<List<TaskModel>> getProjectTasks(int projectId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/projects/$projectId/tasks'),
        headers: await _getHeaders(),
      );
      print('Project $projectId tasks status: ${response.statusCode}');
      print('Project $projectId tasks body: ${response.body}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = _extractList(decoded);
        return data.map((json) => TaskModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error getting project tasks: $e');
    }
    return [];
  }

  static Future<SectionModel?> createSection(
    int projectId,
    String name, {
    String description = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/projects/$projectId/sections'),
        headers: await _getHeaders(),
        body: jsonEncode({'name': name, 'description': description}),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return SectionModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error creating section: $e');
    }
    return null;
  }

  static Future<SectionModel?> updateSection(
    int projectId,
    int sectionId, {
    required String name,
    String description = '',
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/projects/$projectId/sections/$sectionId'),
        headers: await _getHeaders(),
        body: jsonEncode({'name': name, 'description': description}),
      );
      if (response.statusCode == 200) {
        return SectionModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error updating section: $e');
    }
    return null;
  }

  static Future<bool> deleteSection(int projectId, int sectionId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/projects/$projectId/sections/$sectionId'),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting section: $e');
      return false;
    }
  }

  static Future<List<TaskModel>> getMyTasks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/my/tasks'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = _extractList(decoded);
        return data.map((json) => TaskModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error getting my tasks: $e');
    }
    return [];
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

  static Future<TaskModel?> toggleTaskStatus(int projectId, int taskId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/projects/$projectId/tasks/$taskId/toggle'),
        headers: await _getHeaders(),
      );
      print('Toggle status: ${response.statusCode}');
      print('Toggle body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // The backend returns the task object directly or wrapped in 'task'
        final taskData = decoded['task'] ?? decoded;
        return TaskModel.fromJson(taskData);
      } else if (response.statusCode == 403) {
        final decoded = jsonDecode(response.body);
        throw Exception(decoded['message'] ?? 'Action forbidden by server.');
      }
    } catch (e) {
      print('Error toggling task status: $e');
      rethrow;
    }
    return null;
  }

  static Future<TaskModel?> updateTask(
    int projectId,
    int taskId,
    Map<String, dynamic> taskData,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/projects/$projectId/tasks/$taskId'),
        headers: await _getHeaders(),
        body: jsonEncode(taskData),
      );
      if (response.statusCode == 200) {
        return TaskModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('Error updating task: $e');
    }
    return null;
  }

  static Future<TaskModel?> selfAssignTask(int projectId, int taskId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/projects/$projectId/tasks/$taskId/assign-self'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TaskModel.fromJson(data['task']);
      }
    } catch (e) {
      print('Error assigning task to self: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>> uploadTaskAttachment(
    int projectId,
    int taskId,
    List<int> fileBytes,
    String fileName,
  ) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/projects/$projectId/tasks/$taskId/attachments',
      );
      final headers = await _getHeaders();

      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      request.files.add(
        http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Upload status: ${response.statusCode}');
      print('Upload body: ${response.body}');

      final decoded = jsonDecode(response.body);
      return {
        'success': response.statusCode == 201 || response.statusCode == 200,
        'status': response.statusCode,
        'data': decoded,
      };
    } catch (e) {
      print('Error uploading attachment: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<bool> deleteTask(int projectId, int taskId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/projects/$projectId/tasks/$taskId'),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error deleting task: $e');
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
      print('getConversations status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data = decoded is List ? decoded : (decoded['data'] ?? []);
        return data.map((json) => ConversationModel.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error getting conversations: $e');
    }
    return [];
  }

  static Future<int> getUnreadConversationsCount() async {
    try {
      final conversations = await getConversations();
      return conversations.where((c) => c.unreadCount > 0).length;
    } catch (e) {
      return 0;
    }
  }

  // GET /conversations/{user} — returns {conversation, messages}
  static Future<ConversationModel?> getOrCreateConversation(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/conversations/$userId'),
        headers: await _getHeaders(),
      );
      print('getOrCreate status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // response = { "conversation": {...}, "messages": [...] }
        final convJson = decoded is Map && decoded.containsKey('conversation')
            ? decoded['conversation']
            : decoded;
        return ConversationModel.fromJson(convJson);
      }
    } catch (e) {
      print('Error opening conversation: $e');
    }
    return null;
  }

  // GET /conversations/{otherUserId} — returns messages inside same response
  static Future<List<MessageModel>> getMessages(int otherUserId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/conversations/$otherUserId'),
        headers: await _getHeaders(),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // response = { "conversation": {...}, "messages": [...] }
        final List msgs = decoded['messages'] ?? [];
        return msgs.map((j) => MessageModel.fromJson(j)).toList();
      }
    } catch (e) {
      print('Error getting messages: $e');
    }
    return [];
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
