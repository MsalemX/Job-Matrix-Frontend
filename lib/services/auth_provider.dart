import 'package:flutter/material.dart';
import 'api_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  AuthProvider() {
    tryAutoLogin();
  }

  Future<void> tryAutoLogin() async {
    _isLoading = true;
    notifyListeners();

    try {
      _token = await ApiService.getToken();
      if (_token != null) {
        // Try to fetch profile to verify token and get user data
        _user = await ApiService.getMyProfile();
        if (_user == null) {
          // Token might be invalid or expired
          await logout();
        }
      }
    } catch (e) {
      print('Error in tryAutoLogin: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String login, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.login(login, password);
      if (response != null) {
        _token = response.accessToken;
        _user = response.user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Login error in AuthProvider: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> googleLogin() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.loginWithGoogle();
      if (response != null) {
        _token = response.accessToken;
        _user = response.user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Google Login error in AuthProvider: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String name,
    required String username,
    required String email,
    required String password,
    String role = 'user',
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.register(
        name: name,
        username: username,
        email: email,
        password: password,
        role: role,
      );
      if (response != null) {
        _token = response.accessToken;
        _user = response.user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Register error in AuthProvider: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.logout();
    } catch (e) {
      print('Logout error in AuthProvider: $e');
    } finally {
      _token = null;
      _user = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update auth data manually
  void setAuth(User? user, String? token) {
    _user = user;
    _token = token;
    _isLoading = false;
    notifyListeners();
  }

  // Update user data locally if changed elsewhere
  void setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  // Update allow_direct_add locally
  void updateLocalAllowDirectAdd(bool val) {
    if (_user?.profile != null) {
      _user = User(
        id: _user!.id,
        name: _user!.name,
        email: _user!.email,
        username: _user!.username,
        role: _user!.role,
        rawProjectParticipants: _user!.rawProjectParticipants,
        assignedTasks: _user!.assignedTasks,
        profile: Profile(
          id: _user!.profile!.id,
          userId: _user!.profile!.userId,
          bio: _user!.profile!.bio,
          profileImage: _user!.profile!.profileImage,
          points: _user!.profile!.points,
          skills: _user!.profile!.skills,
          allowDirectAdd: val,
        ),
      );
      notifyListeners();
    }
  }
}
