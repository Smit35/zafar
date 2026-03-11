import 'outlet.dart';
import 'order_item.dart';

class ManifestOrder {
  final int id;
  final String orderNumber;
  final Outlet outlet;
  final int itemsCount;
  final double grandTotal;
  final String paymentStatus;
  final String? deliveryOtp;
  final String orderStatus;
  final List<OrderItem> items;

  ManifestOrder({
    required this.id,
    required this.orderNumber,
    required this.outlet,
    required this.itemsCount,
    required this.grandTotal,
    required this.paymentStatus,
    this.deliveryOtp,
    required this.orderStatus,
    required this.items,
  });

  factory ManifestOrder.fromJson(Map<String, dynamic> json) {
    return ManifestOrder(
      id: json['id'],
      orderNumber: json['order_number'],
      outlet: Outlet.fromJson(json['outlet']),
      itemsCount: json['items_count'],
      grandTotal: double.parse(json['grand_total'].toString()),
      paymentStatus: json['payment_status'],
      deliveryOtp: json['delivery_otp']?.toString(),
      orderStatus: json['order_status'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'outlet': outlet.toJson(),
      'items_count': itemsCount,
      'grand_total': grandTotal.toStringAsFixed(2),
      'payment_status': paymentStatus,
      'delivery_otp': deliveryOtp,
      'order_status': orderStatus,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}