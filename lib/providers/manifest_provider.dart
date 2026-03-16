import 'package:flutter/material.dart';
import '../models/manifest.dart';
import '../services/api_service.dart';

class ManifestProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Manifest> _allManifests = [];
  List<Manifest> _newManifests = [];
  List<Manifest> _activeManifests = [];
  bool _isLoading = false;
  String _error = '';

  List<Manifest> get allManifests => _allManifests;
  List<Manifest> get newManifests => _newManifests;
  List<Manifest> get activeManifests => _activeManifests;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchManifests() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Fetch all manifests first
      final response = await _apiService.getDriverManifests();
      
      if (response['success']) {
        _allManifests = response['manifests'] as List<Manifest>;
        
        // Filter manifests by status
        _newManifests = _allManifests
            .where((manifest) => manifest.status == 'ready_to_dispatch')
            .toList();
        
        _activeManifests = _allManifests
            .where((manifest) => manifest.status == 'out_for_delivery')
            .toList();
      }
    } catch (e) {
      _error = 'Failed to load manifests: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchNewManifests() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _apiService.getDriverManifests(status: 'ready_to_dispatch');
      
      if (response['success']) {
        _newManifests = response['manifests'] as List<Manifest>;
      }
    } catch (e) {
      _error = 'Failed to load new manifests: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchActiveManifests() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _apiService.getDriverManifests(status: 'out_for_delivery');
      
      if (response['success']) {
        _activeManifests = response['manifests'] as List<Manifest>;
      }
    } catch (e) {
      _error = 'Failed to load active manifests: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Manifest?> getManifestDetails(int manifestId) async {
    try {
      final response = await _apiService.getManifestDetails(manifestId);
      
      if (response['success']) {
        final manifest = response['manifest'] as Manifest;
        
        // Update the manifest in our lists
        _updateManifestInLists(manifest);
        
        return manifest;
      }
    } catch (e) {
      throw Exception('Failed to load manifest details: ${e.toString()}');
    }

    return null;
  }

  Future<bool> startDelivery(int manifestId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _apiService.startDelivery(manifestId);
      
      if (response['success']) {
        final updatedManifest = response['manifest'] as Manifest;
        
        // Move manifest from new to active
        _newManifests.removeWhere((m) => m.id == manifestId);
        _activeManifests.add(updatedManifest);
        
        // Update in all manifests list
        _updateManifestInLists(updatedManifest);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to start delivery';
      }
    } catch (e) {
      _error = 'Failed to start delivery: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void _updateManifestInLists(Manifest updatedManifest) {
    // Update in all manifests
    final allIndex = _allManifests.indexWhere((m) => m.id == updatedManifest.id);
    if (allIndex != -1) {
      _allManifests[allIndex] = updatedManifest;
    }

    // Update in new manifests
    final newIndex = _newManifests.indexWhere((m) => m.id == updatedManifest.id);
    if (newIndex != -1) {
      _newManifests[newIndex] = updatedManifest;
    }

    // Update in active manifests
    final activeIndex = _activeManifests.indexWhere((m) => m.id == updatedManifest.id);
    if (activeIndex != -1) {
      _activeManifests[activeIndex] = updatedManifest;
    }
  }

  Future<void> refreshManifests() async {
    await fetchManifests();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  Future<bool> verifyOTP(int orderId, String otp) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await _apiService.verifyOTP(orderId, otp);
      
      if (response['success']) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Failed to verify OTP';
      }
    } catch (e) {
      _error = 'Failed to verify OTP: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void clearData() {
    _allManifests.clear();
    _newManifests.clear();
    _activeManifests.clear();
    _error = '';
    _isLoading = false;
    notifyListeners();
  }
}