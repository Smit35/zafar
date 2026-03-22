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
  final String status;
  final bool inwardLocked;
  
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
    required this.status,
    required this.inwardLocked,
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
      status: json['status'] ?? 'pending',
      inwardLocked: json['inward_locked'] ?? false,
    );
  }
}

class Outlet {
  final int id;
  final String outletName;
  final String ownerName;
  final String contactNumber;
  final String? alternateContact;
  final String email;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String pinCode;
  final String gstNumber;
  final String? fssaiLicenceNumber;
  final DateTime? fssaiExpiryDate;
  final String? shopActNumber;
  final DateTime? shopActExpiryDate;
  final DateTime? franchiseSignedDate;
  final DateTime? franchiseExpiryDate;
  final String outletType;
  final DateTime? openingDate;
  final String? bankAccountNumber;
  final String bankIfscCode;
  final String? bankName;
  final String? bankAccountHolder;
  final double? latitude;
  final double? longitude;
  final bool status;
  final String? statusReason;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Outlet({
    required this.id,
    required this.outletName,
    required this.ownerName,
    required this.contactNumber,
    this.alternateContact,
    required this.email,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.gstNumber,
    this.fssaiLicenceNumber,
    this.fssaiExpiryDate,
    this.shopActNumber,
    this.shopActExpiryDate,
    this.franchiseSignedDate,
    this.franchiseExpiryDate,
    required this.outletType,
    this.openingDate,
    this.bankAccountNumber,
    required this.bankIfscCode,
    this.bankName,
    this.bankAccountHolder,
    this.latitude,
    this.longitude,
    required this.status,
    this.statusReason,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Outlet.fromJson(Map<String, dynamic> json) {
    return Outlet(
      id: json['id'] ?? 0,
      outletName: json['outlet_name'] ?? '',
      ownerName: json['owner_name'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      alternateContact: json['alternate_contact'],
      email: json['email'] ?? '',
      addressLine1: json['address_line_1'] ?? '',
      addressLine2: json['address_line_2'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pinCode: json['pin_code'] ?? '',
      gstNumber: json['gst_number'] ?? '',
      fssaiLicenceNumber: json['fssai_licence_number'],
      fssaiExpiryDate: json['fssai_expiry_date'] != null ? DateTime.parse(json['fssai_expiry_date']) : null,
      shopActNumber: json['shop_act_number'],
      shopActExpiryDate: json['shop_act_expiry_date'] != null ? DateTime.parse(json['shop_act_expiry_date']) : null,
      franchiseSignedDate: json['franchise_signed_date'] != null ? DateTime.parse(json['franchise_signed_date']) : null,
      franchiseExpiryDate: json['franchise_expiry_date'] != null ? DateTime.parse(json['franchise_expiry_date']) : null,
      outletType: json['outlet_type'] ?? '',
      openingDate: json['opening_date'] != null ? DateTime.parse(json['opening_date']) : null,
      bankAccountNumber: json['bank_account_number'],
      bankIfscCode: json['bank_ifsc_code'] ?? '',
      bankName: json['bank_name'],
      bankAccountHolder: json['bank_account_holder'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      status: json['status'] ?? true,
      statusReason: json['status_reason'],
      createdBy: json['created_by'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
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
  final DateTime? dispatchDate;
  final Map<String, dynamic>? otp;
  final String? specialInstructions;
  final List<OrderItem> items;
  final Outlet? outlet;
  
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
    this.dispatchDate,
    this.otp,
    this.specialInstructions,
    this.items = const [],
    this.outlet,
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
      dispatchDate: json['dispatch_date'] != null ? DateTime.parse(json['dispatch_date']) : null,
      otp: json['otp'] is Map<String, dynamic> ? json['otp'] : null,
      specialInstructions: json['special_instructions'],
      items: (json['items'] as List?)
          ?.map((item) => OrderItem.fromJson(item))
          .toList() ?? [],
      outlet: json['outlet'] != null ? Outlet.fromJson(json['outlet']) : null,
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
  
  // OTP helper methods
  String? get deliveryOtp => otp?['otp_hash'];
  bool get hasOtp => otp != null && otp!['otp_hash'] != null;
  bool get isOtpExpired => otp?['is_expired'] ?? true;
  bool get isOtpVerified => otp?['is_verified'] ?? false;
  
  // Legacy properties for backward compatibility
  String get customerName => 'Customer';
  String get customerPhone => '';
  String get deliveryAddress => '';
  String? get driverId => null;
  
  // Inward helper method
  bool get shouldShowInwardButton {
    // Show inward button if any item has inward_locked: false AND status is not 'delivered'
    return status.toLowerCase() != 'delivered' && 
           items.any((item) => !item.inwardLocked);
  }
}