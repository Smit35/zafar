import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class OrderProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Order> _activeOrders = [];
  List<Order> _completedOrders = [];
  bool _isLoading = false;
  String _error = '';

  List<Order> get activeOrders => _activeOrders;
  List<Order> get completedOrders => _completedOrders;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Initialize with empty data - commenting out mock data due to model changes
  OrderProvider() {
    // _initializeMockData(); // Commented out due to Order model changes
  }

  // Commented out due to Order model changes
  // void _initializeMockData() {
  //   _activeOrders = [...];
  //   _completedOrders = [...];
  // }

  // Commented out due to Order model changes - OrderStatus enum no longer exists
  /*
  Future<void> refreshOrders() async {
    _setLoading(true);
    try {
      final todayResult = await _apiService.getDriverOrders(tab: 'today');
      final completedResult = await _apiService.getDriverOrders(tab: 'completed');
      
      if (todayResult['success'] == true && completedResult['success'] == true) {
        final todayOrders = todayResult['orders'] as List<Order>;
        _activeOrders = todayOrders.where((order) => 
          order.status == 'assigned' || order.status == 'active'
        ).toList();
        
        _completedOrders = completedResult['orders'] as List<Order>;
        _setError('');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
  */

  // Simplified method for API integration
  Future<void> refreshOrders() async {
    _setLoading(true);
    try {
      // TODO: Implement with new Order model structure
      _setError('');
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Commented out due to Order model changes
  /*
  Future<void> loadOrdersByTab(String tab, {int page = 1}) async {
    // Implementation using old OrderStatus enum
  }

  Future<bool> acceptOrder(String orderId) async {
    // Implementation using old Order constructor
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    // Implementation using old Order constructor
  }
  */

  // Confirm delivery using OTP (most critical method) - simplified
  Future<Map<String, dynamic>> confirmDelivery(String orderId, String otp) async {
    try {
      final result = await _apiService.confirmDelivery(orderId, otp);
      
      if (result['success'] == true) {
        // TODO: Update order lists with new Order model
        notifyListeners();
      }
      
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'error_type': 'network',
      };
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}