import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../models/driver.dart';
import '../models/outlet.dart';
import '../services/api_service.dart';
import 'manifest_provider.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = false;
  String _error = '';
  ManifestProvider? _manifestProvider;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isLoggedIn => _user != null;

  Future<bool> login(
    String email,
    String password, {
    UserType? userType,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      Map<String, dynamic> response;

      // If userType is specified, use that; otherwise default to driver for backward compatibility
      if (userType == UserType.outlet) {
        response = await _apiService.outletLogin(email, password);
      } else {
        response = await _apiService.driverLogin(email, password);
      }

      if (response['success']) {
        final token = response['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        _apiService.setToken(token);

        if (userType == UserType.outlet) {
          final outlet = response['outlet'] as Outlet;

          // Save outlet data to local storage
          await prefs.setString(
            'user_data',
            jsonEncode({
              'id': outlet.id.toString(),
              'email': outlet.email,
              'name': outlet.outletName,
              'phone': outlet.contactNumber,
              'type': 'outlet',
            }),
          );

          _user = User(
            id: outlet.id.toString(),
            email: outlet.email,
            name: outlet.outletName,
            phone: outlet.contactNumber,
            type: UserType.outlet,
          );

          // Save outlet details for later use
          await prefs.setString('outlet_data', jsonEncode(outlet.toJson()));
        } else {
          final driver = response['driver'] as Driver;

          // Save driver data to local storage
          await prefs.setString(
            'user_data',
            jsonEncode({
              'id': driver.id.toString(),
              'email': driver.email,
              'name': driver.name,
              'phone': driver.contact,
              'type': 'driver',
            }),
          );

          _user = User(
            id: driver.id.toString(),
            email: driver.email,
            name: driver.name,
            phone: driver.contact,
            type: UserType.driver,
          );

          // Save driver details for later use
          await prefs.setString('driver_data', jsonEncode(driver.toJson()));

          // Fetch manifests after successful driver login
          if (_manifestProvider != null) {
            _manifestProvider!.fetchManifests();
          }
        }

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
      await prefs.remove('driver_data');
      await prefs.remove('outlet_data');

      _apiService.clearToken();
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

  void setManifestProvider(ManifestProvider manifestProvider) {
    _manifestProvider = manifestProvider;
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
