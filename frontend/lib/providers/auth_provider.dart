import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  // =====================
  // REGISTER
  // =====================
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiService.register(name, email, password);
      _user = User.fromJson(data);
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
      return true;
    } catch (e) {
      debugPrint("Login error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
