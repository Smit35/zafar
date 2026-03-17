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
  final String? orderNumber;
  final String? estimatedDeliveryTime;
  final String? specialInstructions;
  final double? subtotal;
  final double? taxAmount;
  final double? deliveryFee;
  final double? discountAmount;

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
    this.orderNumber,
    this.estimatedDeliveryTime,
    this.specialInstructions,
    this.subtotal,
    this.taxAmount,
    this.deliveryFee,
    this.discountAmount,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      outletId: json['outletId']?.toString() ?? '',
      driverId: json['driverId']?.toString(),
      items: (json['items'] as List?)
          ?.map((item) => CartItem.fromJson(item))
          .toList() ?? [],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: _parseOrderStatus(json['status'] ?? 'active'),
      paymentMethod: json['paymentMethod'] ?? 'COD',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      deliveryAddress: json['deliveryAddress'] ?? '',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      orderNumber: json['orderNumber']?.toString() ?? json['order_number']?.toString(),
      estimatedDeliveryTime: json['estimatedDeliveryTime'] ?? json['estimated_delivery_time'],
      specialInstructions: json['specialInstructions'] ?? json['special_instructions'],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      taxAmount: (json['taxAmount'] ?? json['tax_amount'] ?? 0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? json['delivery_fee'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? json['discount_amount'] ?? 0).toDouble(),
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
      'orderNumber': orderNumber,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'specialInstructions': specialInstructions,
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'deliveryFee': deliveryFee,
      'discountAmount': discountAmount,
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