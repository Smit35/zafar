import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _baseUrl = 'https://api.example.com';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  Future<User?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['user']);
        await _saveToken(data['token']);
        await _saveUser(user);
        return user;
      }
    } catch (e) {
      print('Login error: $e');
    }

    // For demo purposes, determine user type based on email pattern
    // Emails ending with @driver.com will be drivers, others will be outlets
    UserType userType;
    if (email.toLowerCase().contains('driver') || email.toLowerCase().endsWith('@driver.com')) {
      userType = UserType.driver;
    } else {
      userType = UserType.outlet;
    }

    final user = User(
      id: userType == UserType.outlet ? 'outlet_123' : 'driver_456',
      email: email,
      name: userType == UserType.outlet ? 'Demo Restaurant' : 'Demo Driver',
      type: userType,
    );
    await _saveUser(user);
    return user;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}