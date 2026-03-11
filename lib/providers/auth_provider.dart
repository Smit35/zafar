import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../models/driver.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = false;
  String _error = '';

  User? get user => _user;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isLoggedIn => _user != null;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      
      if (response['success']) {
        final token = response['token'];
        final driver = response['driver'] as Driver;
        
        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_data', jsonEncode(driver.toJson()));
        
        _apiService.setToken(token);
        _user = User(
          id: driver.id.toString(),
          email: driver.email,
          name: driver.name,
          phone: driver.contact,
          type: UserType.driver,
        );
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Invalid credentials';
      }
    } catch (e) {
      _error = 'Login failed. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      
      _user = null;
    } catch (e) {
      _error = 'Logout failed';
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userJson = prefs.getString('user_data');
      
      if (token != null && userJson != null) {
        _apiService.setToken(token);
        final userData = jsonDecode(userJson);
        _user = User.fromJson(userData);
      }
    } catch (e) {
      _error = 'Failed to check auth status';
    }
    
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}