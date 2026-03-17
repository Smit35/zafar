class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final String sku;
  final String productName;
  final String hsnCode;
  final String uom;
  final double qtyOrdered;
  final double unitPrice;
  final double gstPercent;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double lineTotal;
  
  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.sku,
    required this.productName,
    required this.hsnCode,
    required this.uom,
    required this.qtyOrdered,
    required this.unitPrice,
    required this.gstPercent,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.lineTotal,
  });
  
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      sku: json['sku'] ?? '',
      productName: json['product_name'] ?? '',
      hsnCode: json['hsn_code'] ?? '',
      uom: json['uom'] ?? '',
      qtyOrdered: double.parse(json['qty_ordered']?.toString() ?? '0'),
      unitPrice: double.parse(json['unit_price']?.toString() ?? '0'),
      gstPercent: double.parse(json['gst_percent']?.toString() ?? '0'),
      cgstAmount: double.parse(json['cgst_amount']?.toString() ?? '0'),
      sgstAmount: double.parse(json['sgst_amount']?.toString() ?? '0'),
      igstAmount: double.parse(json['igst_amount']?.toString() ?? '0'),
      lineTotal: double.parse(json['line_total']?.toString() ?? '0'),
    );
  }
}

class Order {
  final dynamic id;
  final String orderNumber;
  final int outletId;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final double subtotal;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double grandTotal;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final String? specialInstructions;
  final List<OrderItem> items;
  
  Order({
    required this.id,
    required this.orderNumber,
    required this.outletId,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.subtotal,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.grandTotal,
    required this.createdAt,
    this.deliveredAt,
    this.specialInstructions,
    this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      outletId: json['outlet_id'] ?? 0,
      status: json['status'] ?? 'active',
      paymentStatus: json['payment_status'] ?? 'pending',
      paymentMethod: json['payment_method'] ?? 'upi',
      subtotal: double.parse(json['subtotal']?.toString() ?? '0'),
      cgstAmount: double.parse(json['cgst_amount']?.toString() ?? '0'),
      sgstAmount: double.parse(json['sgst_amount']?.toString() ?? '0'),
      igstAmount: double.parse(json['igst_amount']?.toString() ?? '0'),
      grandTotal: double.parse(json['grand_total']?.toString() ?? '0'),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at']) : null,
      specialInstructions: json['special_instructions'],
      items: (json['items'] as List?)
          ?.map((item) => OrderItem.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'outlet_id': outletId,
      'status': status,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'subtotal': subtotal.toString(),
      'cgst_amount': cgstAmount.toString(),
      'sgst_amount': sgstAmount.toString(),
      'igst_amount': igstAmount.toString(),
      'grand_total': grandTotal.toString(),
      'created_at': createdAt.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'special_instructions': specialInstructions,
      'items': items.map((item) => item).toList(),
    };
  }

  // Getter for backward compatibility
  double get totalAmount => grandTotal;
  
  // Legacy properties for backward compatibility
  String get customerName => 'Customer';
  String get customerPhone => '';
  String get deliveryAddress => '';
  String? get driverId => null;
}