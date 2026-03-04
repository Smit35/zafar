import 'cart_item.dart';

enum OrderStatus { active, assigned, delivered, completed, cancelled }

class Order {
  final String id;
  final String outletId;
  final String? driverId;
  final List<CartItem> items;
  final double totalAmount;
  final OrderStatus status;
  final String paymentMethod;
  final DateTime createdAt;
  final String deliveryAddress;
  final String customerName;
  final String customerPhone;

  Order({
    required this.id,
    required this.outletId,
    this.driverId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
    required this.deliveryAddress,
    required this.customerName,
    required this.customerPhone,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      outletId: json['outletId'],
      driverId: json['driverId'],
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      totalAmount: json['totalAmount'].toDouble(),
      status: _parseOrderStatus(json['status']),
      paymentMethod: json['paymentMethod'],
      createdAt: DateTime.parse(json['createdAt']),
      deliveryAddress: json['deliveryAddress'],
      customerName: json['customerName'],
      customerPhone: json['customerPhone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'outletId': outletId,
      'driverId': driverId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': _orderStatusToString(status),
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'deliveryAddress': deliveryAddress,
      'customerName': customerName,
      'customerPhone': customerPhone,
    };
  }

  static OrderStatus _parseOrderStatus(String status) {
    switch (status) {
      case 'active':
        return OrderStatus.active;
      case 'assigned':
        return OrderStatus.assigned;
      case 'delivered':
        return OrderStatus.delivered;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.active;
    }
  }

  static String _orderStatusToString(OrderStatus status) {
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