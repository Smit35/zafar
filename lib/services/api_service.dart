import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/menu_item.dart';
import '../models/driver.dart';

class ApiService {
  static const String baseUrl = 'https://zafar-api.copytrading.cloud';//'''https://zafs.copytrading.cloud';
  static const String apiVersion = '/api/v1';

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;
  
  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$apiVersion/driver/login'),
        headers: _headers,
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'token': data['token'],
          'driver': Driver.fromJson(data['driver']),
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Invalid email or password. Please try again.',
        };
      } else if (response.statusCode == 429) {
        return {
          'success': false,
          'message': 'Too many failed attempts. Account locked for 15 minutes.',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed. Please try again.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    }
  }

  // Verify current auth token
  Future<Map<String, dynamic>> verifyToken() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiVersion/auth/me'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': 'Session expired',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Could not verify session. Please login again.',
      };
    }
  }

  // Logout
  Future<bool> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$apiVersion/auth/logout'),
        headers: _headers,
      );
      
      clearToken();
      return response.statusCode == 200;
    } catch (e) {
      clearToken();
      return true; // Always allow logout even if API fails
    }
  }

  // Forgot password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$apiVersion/auth/forgot-password'),
        headers: _headers,
        body: jsonEncode({'email': email.trim()}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'If this email is registered, a reset link has been sent.',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to send reset link.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    }
  }

  // Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$apiVersion/auth/change-password'),
        headers: _headers,
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password changed successfully.',
        };
      } else if (response.statusCode == 422) {
        return {
          'success': false,
          'message': data['message'] ?? 'Current password is incorrect.',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to change password.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    }
  }

  // Get driver orders with pagination
  Future<Map<String, dynamic>> getDriverOrders({
    required String tab,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiVersion/driver/orders?tab=$tab&page=$page&per_page=$perPage'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'orders': (data['data'] as List).map((json) => Order.fromJson(json)).toList(),
          'meta': data['meta'],
        };
      } else if (response.statusCode == 401) {
        throw Exception('Session expired');
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      throw Exception('Failed to load orders: ${e.toString()}');
    }
  }

  // Get single order details
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiVersion/driver/orders/$orderId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'order': Order.fromJson(data['order']),
        };
      } else if (response.statusCode == 401) {
        throw Exception('Session expired');
      } else if (response.statusCode == 403) {
        throw Exception('You are not assigned to this order');
      } else if (response.statusCode == 404) {
        throw Exception('Order not found');
      } else {
        throw Exception('Failed to load order details');
      }
    } catch (e) {
      throw Exception('Failed to load order details: ${e.toString()}');
    }
  }

  // Get dashboard data
  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiVersion/driver/dashboard'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'activeCount': data['active_count'] ?? 0,
          'deliveredToday': data['delivered_today'] ?? 0,
          'totalDelivered': data['total_delivered'] ?? 0,
          'todayOrders': (data['today_orders'] as List? ?? [])
              .map((json) => Order.fromJson(json))
              .toList(),
        };
      } else if (response.statusCode == 401) {
        throw Exception('Session expired');
      } else {
        throw Exception('Failed to load dashboard');
      }
    } catch (e) {
      throw Exception('Failed to load dashboard: ${e.toString()}');
    }
  }

  // Confirm delivery with OTP (Most critical method)
  Future<Map<String, dynamic>> confirmDelivery(String orderId, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$apiVersion/driver/orders/$orderId/deliver'),
        headers: _headers,
        body: jsonEncode({'otp': otp}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Delivery confirmed',
          'order': Order.fromJson(data['order']),
        };
      } else if (response.statusCode == 422) {
        // Handle specific OTP errors
        final message = data['message'] ?? 'Invalid OTP';
        final remainingAttempts = data['remaining_attempts'];
        
        if (message.contains('expired')) {
          return {
            'success': false,
            'message': 'OTP has expired. Ask the outlet to generate a new OTP from their portal.',
            'error_type': 'expired',
          };
        } else if (message.contains('locked') || remainingAttempts == 0) {
          return {
            'success': false,
            'message': 'Maximum attempts reached. OTP is locked. Please contact the warehouse to resolve this delivery.',
            'error_type': 'locked',
          };
        } else {
          return {
            'success': false,
            'message': 'Incorrect OTP. ${remainingAttempts ?? 0} attempt(s) remaining.',
            'error_type': 'incorrect',
            'remaining_attempts': remainingAttempts ?? 0,
          };
        }
      } else if (response.statusCode == 409) {
        return {
          'success': false,
          'message': 'This order has already been delivered.',
          'error_type': 'already_delivered',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to confirm delivery',
          'error_type': 'unknown',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'No internet. Please check your connection and try again.',
        'error_type': 'network',
      };
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

  // Register FCM token for push notifications
  Future<bool> registerFCMToken(String fcmToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$apiVersion/fcm/register'),
        headers: _headers,
        body: jsonEncode({'token': fcmToken}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get notifications
  Future<Map<String, dynamic>> getNotifications({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$apiVersion/driver/notifications?page=$page&per_page=$perPage'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'notifications': data['data'] ?? [],
          'unread_count': data['unread_count'] ?? 0,
          'meta': data['meta'],
        };
      } else if (response.statusCode == 401) {
        throw Exception('Session expired');
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      throw Exception('Failed to load notifications: ${e.toString()}');
    }
  }

  // Mark notifications as read
  Future<bool> markNotificationsAsRead({
    List<int>? ids,
    bool markAllAsRead = false,
  }) async {
    try {
      final body = markAllAsRead 
          ? {'all': true} 
          : {'ids': ids ?? []};

      final response = await http.put(
        Uri.parse('$baseUrl$apiVersion/driver/notifications/read'),
        headers: _headers,
        body: jsonEncode(body),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Update order status (generic method for non-delivery status updates)
  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$apiVersion/driver/orders/$orderId/status'),
        headers: _headers,
        body: jsonEncode({'status': _orderStatusToString(status)}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Helper method to convert OrderStatus enum to string
  String _orderStatusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.assigned:
        return 'assigned';
      case OrderStatus.active:
        return 'active';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.completed:
        return 'completed';
      case OrderStatus.cancelled:
        return 'cancelled';
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

}