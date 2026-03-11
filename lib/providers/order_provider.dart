import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../models/menu_item.dart';
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

  // Initialize with mock data for demo
  OrderProvider() {
    _initializeMockData();
  }

  void _initializeMockData() {
    _activeOrders = [
      Order(
        id: 'ORD001',
        outletId: 'outlet_123',
        driverId: 'driver_456',
        items: [
          CartItem(
            menuItem: MenuItem(
              id: '1',
              name: 'Chicken Biryani',
              description: 'Aromatic basmati rice with tender chicken',
              price: 299.0,
              image: '🍛',
              category: 'Main Course',
            ),
            quantity: 2,
          ),
          CartItem(
            menuItem: MenuItem(
              id: '3',
              name: 'Chicken Tikka',
              description: 'Grilled chicken marinated in spices',
              price: 199.0,
              image: '🍗',
              category: 'Starter',
            ),
            quantity: 1,
          ),
        ],
        totalAmount: 797.0,
        status: OrderStatus.assigned,
        paymentMethod: 'COD',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        deliveryAddress: '123 Main Street, Downtown, City - 400001',
        customerName: 'John Doe',
        customerPhone: '+91 9876543210',
      ),
      Order(
        id: 'ORD002',
        outletId: 'outlet_123',
        driverId: 'driver_456',
        items: [
          CartItem(
            menuItem: MenuItem(
              id: '2',
              name: 'Paneer Butter Masala',
              description: 'Creamy tomato curry with cottage cheese',
              price: 249.0,
              image: '🍛',
              category: 'Main Course',
            ),
            quantity: 1,
          ),
        ],
        totalAmount: 347.0,
        status: OrderStatus.active,
        paymentMethod: 'Online',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        deliveryAddress: '456 Park Avenue, Uptown, City - 400002',
        customerName: 'Jane Smith',
        customerPhone: '+91 8765432109',
      ),
    ];

    _completedOrders = [
      Order(
        id: 'ORD003',
        outletId: 'outlet_123',
        driverId: 'driver_456',
        items: [
          CartItem(
            menuItem: MenuItem(
              id: '4',
              name: 'Dal Makhani',
              description: 'Rich and creamy black lentil curry',
              price: 179.0,
              image: '🍲',
              category: 'Main Course',
            ),
            quantity: 1,
          ),
        ],
        totalAmount: 179.0,
        status: OrderStatus.completed,
        paymentMethod: 'COD',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        deliveryAddress: '789 Oak Street, Midtown, City - 400003',
        customerName: 'Mike Johnson',
        customerPhone: '+91 7654321098',
      ),
    ];
  }

  Future<void> refreshOrders() async {
    _setLoading(true);
    try {
      // Fetch today's orders and active orders
      final todayResult = await _apiService.getDriverOrders(tab: 'today');
      final completedResult = await _apiService.getDriverOrders(tab: 'completed');
      
      if (todayResult['success'] == true && completedResult['success'] == true) {
        // Filter today's orders into active and assigned
        final todayOrders = todayResult['orders'] as List<Order>;
        _activeOrders = todayOrders.where((order) => 
          order.status == OrderStatus.assigned || order.status == OrderStatus.active
        ).toList();
        
        _completedOrders = completedResult['orders'] as List<Order>;
        _setError('');
      }
    } catch (e) {
      _setError(e.toString());
      // Keep existing data if API fails
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadOrdersByTab(String tab, {int page = 1}) async {
    if (page == 1) _setLoading(true);
    
    try {
      final result = await _apiService.getDriverOrders(tab: tab, page: page);
      
      if (result['success'] == true) {
        final orders = result['orders'] as List<Order>;
        
        if (page == 1) {
          // Replace existing orders
          if (tab == 'completed') {
            _completedOrders = orders;
          } else {
            // For today/upcoming tabs, filter into active orders
            _activeOrders = orders.where((order) => 
              order.status == OrderStatus.assigned || order.status == OrderStatus.active
            ).toList();
          }
        } else {
          // Append for pagination
          if (tab == 'completed') {
            _completedOrders.addAll(orders);
          } else {
            _activeOrders.addAll(orders.where((order) => 
              order.status == OrderStatus.assigned || order.status == OrderStatus.active
            ));
          }
        }
        _setError('');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      if (page == 1) _setLoading(false);
    }
  }

  // This method is for accepting orders that are assigned to the driver
  Future<bool> acceptOrder(String orderId) async {
    try {
      // For now, just mark as active. In real implementation, this might
      // involve updating the driver's status or confirming availability
      final orderIndex = _activeOrders.indexWhere((order) => order.id == orderId);
      if (orderIndex != -1) {
        final order = _activeOrders[orderIndex];
        final updatedOrder = Order(
          id: order.id,
          outletId: order.outletId,
          driverId: order.driverId,
          items: order.items,
          totalAmount: order.totalAmount,
          status: OrderStatus.active,
          paymentMethod: order.paymentMethod,
          createdAt: order.createdAt,
          deliveryAddress: order.deliveryAddress,
          customerName: order.customerName,
          customerPhone: order.customerPhone,
        );
        _activeOrders[orderIndex] = updatedOrder;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to accept order');
      return false;
    }
  }

  // Confirm delivery using OTP (most critical method)
  Future<Map<String, dynamic>> confirmDelivery(String orderId, String otp) async {
    try {
      final result = await _apiService.confirmDelivery(orderId, otp);
      
      if (result['success'] == true) {
        // Move order from active to completed
        final orderIndex = _activeOrders.indexWhere((order) => order.id == orderId);
        if (orderIndex != -1) {
          final deliveredOrder = result['order'] as Order;
          _activeOrders.removeAt(orderIndex);
          _completedOrders.insert(0, deliveredOrder);
          notifyListeners();
        }
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

  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      final success = await _apiService.updateOrderStatus(orderId, newStatus);
      if (success) {
        final orderIndex = _activeOrders.indexWhere((order) => order.id == orderId);
        if (orderIndex != -1) {
          final order = _activeOrders[orderIndex];
          final updatedOrder = Order(
            id: order.id,
            outletId: order.outletId,
            driverId: order.driverId,
            items: order.items,
            totalAmount: order.totalAmount,
            status: newStatus,
            paymentMethod: order.paymentMethod,
            createdAt: order.createdAt,
            deliveryAddress: order.deliveryAddress,
            customerName: order.customerName,
            customerPhone: order.customerPhone,
          );

          if (newStatus == OrderStatus.completed || newStatus == OrderStatus.delivered) {
            _activeOrders.removeAt(orderIndex);
            _completedOrders.insert(0, updatedOrder);
          } else {
            _activeOrders[orderIndex] = updatedOrder;
          }
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _setError('Failed to update order status');
      return false;
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