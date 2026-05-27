import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  static const _tokenKey = 'jwt_token';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';

  // =====================
  // GETTERS
  // =====================
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  // =====================
  // TRY AUTO LOGIN (from saved token)
  // =====================
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userId = prefs.getInt(_userIdKey);
    final userName = prefs.getString(_userNameKey);
    final userEmail = prefs.getString(_userEmailKey);

    if (token != null && userId != null && userName != null && userEmail != null) {
      ApiService.setToken(token);
      _user = User(id: userId, name: userName, email: userEmail);
      notifyListeners();
      return true;
    }
    return false;
  }

  // =====================
  // SAVE SESSION
  // =====================
  Future<void> _saveSession(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, data['token']);
    await prefs.setInt(_userIdKey, data['id']);
    await prefs.setString(_userNameKey, data['name']);
    await prefs.setString(_userEmailKey, data['email']);
  }

  // =====================
  // REGISTER
  // =====================
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiService.register(name, email, password);
      _user = User.fromJson(data);
      await _saveSession(data);
      return true;
    } catch (e) {
      debugPrint("Register error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =====================
  // LOGIN
  // =====================
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiService.login(email, password);
      _user = User.fromJson(data);
      await _saveSession(data);
      return true;
    } catch (e) {
      debugPrint("Login error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =====================
  // LOGOUT
  // =====================
  Future<void> logout() async {
    _user = null;
    ApiService.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    notifyListeners();
  }

  // =====================
  // UPDATE PROFILE
  // =====================
  Future<bool> updateProfile(String name, String email, String? password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiService.updateProfile(name, email, password);
      _user = User.fromJson(data);
      await _saveSession(data);
      return true;
    } catch (e) {
      debugPrint("Update profile error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
