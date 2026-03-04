import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/menu_item.dart';

class ApiService {
  static const String baseUrl = 'https://api.zafar.com'; // Replace with actual API URL
  
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;
  
  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Mock response for demo - replace with actual API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate successful login for demo
      if (email.isNotEmpty && password.isNotEmpty) {
        return {
          'success': true,
          'token': 'mock_driver_token_123',
          'user': {
            'id': 'driver_001',
            'name': 'John Driver',
            'email': email,
            'phone': '+91 9876543210',
            'type': 'driver',
            'isOnline': true,
          }
        };
      } else {
        return {
          'success': false,
          'message': 'Invalid credentials'
        };
      }

      // Actual API implementation would be:
      // final response = await http.post(
      //   Uri.parse('$baseUrl/auth/login'),
      //   headers: _headers,
      //   body: jsonEncode({'email': email, 'password': password}),
      // );
      // return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}'
      };
    }
  }

  // Get driver orders
  Future<List<Order>> getDriverOrders(String status) async {
    try {
      // Mock data for demo - replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Return mock orders based on status
      return _getMockOrders(status);

      // Actual API implementation:
      // final response = await http.get(
      //   Uri.parse('$baseUrl/driver/orders?status=$status'),
      //   headers: _headers,
      // );
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   return (data['orders'] as List).map((json) => Order.fromJson(json)).toList();
      // }
      // throw Exception('Failed to load orders');
    } catch (e) {
      throw Exception('Failed to load orders: ${e.toString()}');
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      // Mock response for demo
      await Future.delayed(const Duration(milliseconds: 300));
      return true;

      // Actual API implementation:
      // final response = await http.patch(
      //   Uri.parse('$baseUrl/orders/$orderId/status'),
      //   headers: _headers,
      //   body: jsonEncode({'status': _orderStatusToString(status)}),
      // );
      // return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Update driver location
  Future<bool> updateLocation(double latitude, double longitude) async {
    try {
      // Mock response for demo
      await Future.delayed(const Duration(milliseconds: 200));
      return true;

      // Actual API implementation:
      // final response = await http.patch(
      //   Uri.parse('$baseUrl/driver/location'),
      //   headers: _headers,
      //   body: jsonEncode({'latitude': latitude, 'longitude': longitude}),
      // );
      // return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get driver earnings
  Future<Map<String, dynamic>> getEarnings(String period) async {
    try {
      // Mock data for demo
      await Future.delayed(const Duration(milliseconds: 300));
      
      return {
        'totalEarnings': 2450.00,
        'todayEarnings': 340.00,
        'completedOrders': 23,
        'totalDistance': 145.5,
        'averageRating': 4.7,
      };

      // Actual API implementation:
      // final response = await http.get(
      //   Uri.parse('$baseUrl/driver/earnings?period=$period'),
      //   headers: _headers,
      // );
      // return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to load earnings');
    }
  }

  // Mock data helper
  List<Order> _getMockOrders(String status) {
    // This would be replaced by actual API data
    final mockOrders = <Order>[
      // Add mock orders here if needed
    ];
    
    return mockOrders.where((order) {
      switch (status) {
        case 'active':
          return order.status == OrderStatus.assigned || order.status == OrderStatus.active;
        case 'completed':
          return order.status == OrderStatus.completed || order.status == OrderStatus.delivered;
        default:
          return true;
      }
    }).toList();
  }

  String _orderStatusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.active:
        return 'active';
      case OrderStatus.assigned:
        return 'assigned';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.completed:
        return 'completed';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }
}