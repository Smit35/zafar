class ReturnItem {
  final int id;
  final int orderId;
  final int orderItemId;
  final int outletId;
  final String returnInitiator;
  final double returnedQty;
  final String rejectionReason;
  final String? outletRemarks;
  final String? adminRemarks;
  final String status;
  final Map<String, dynamic>? reviewedBy;
  final DateTime? reviewedAt;
  final int? creditNoteId;
  final double? walletCreditAmount;
  final bool stockRestored;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ReturnOrder? order;
  final ReturnOrderItem? orderItem;
  final List<ReturnPhoto> photos;
  final ReturnCreditNote? creditNote;

  ReturnItem({
    required this.id,
    required this.orderId,
    required this.orderItemId,
    required this.outletId,
    required this.returnInitiator,
    required this.returnedQty,
    required this.rejectionReason,
    this.outletRemarks,
    this.adminRemarks,
    required this.status,
    this.reviewedBy,
    this.reviewedAt,
    this.creditNoteId,
    this.walletCreditAmount,
    required this.stockRestored,
    required this.createdAt,
    required this.updatedAt,
    this.order,
    this.orderItem,
    this.photos = const [],
    this.creditNote,
  });

  factory ReturnItem.fromJson(Map<String, dynamic> json) {
    return ReturnItem(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      orderItemId: json['order_item_id'] ?? 0,
      outletId: json['outlet_id'] ?? 0,
      returnInitiator: json['return_initiator'] ?? '',
      returnedQty: double.parse(json['returned_qty']?.toString() ?? '0'),
      rejectionReason: json['rejection_reason'] ?? '',
      outletRemarks: json['outlet_remarks'],
      adminRemarks: json['admin_remarks'],
      status: json['status'] ?? 'pending',
      reviewedBy: json['reviewed_by'],
      reviewedAt: json['reviewed_at'] != null ? DateTime.parse(json['reviewed_at']) : null,
      creditNoteId: json['credit_note_id'],
      walletCreditAmount: json['wallet_credit_amount'] != null 
          ? double.parse(json['wallet_credit_amount'].toString())
          : null,
      stockRestored: json['stock_restored'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      order: json['order'] != null ? ReturnOrder.fromJson(json['order']) : null,
      orderItem: json['order_item'] != null ? ReturnOrderItem.fromJson(json['order_item']) : null,
      photos: (json['photos'] as List?)?.map((photo) => ReturnPhoto.fromJson(photo)).toList() ?? [],
      creditNote: json['credit_note'] != null ? ReturnCreditNote.fromJson(json['credit_note']) : null,
    );
  }

  String get statusDisplayText {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'PENDING';
      case 'approved':
        return 'APPROVED';
      case 'rejected':
        return 'REJECTED';
      default:
        return status.toUpperCase();
    }
  }

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase() == 'rejected';
}

class ReturnOrder {
  final int id;
  final String orderNumber;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final DateTime createdAt;

  ReturnOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.createdAt,
  });

  factory ReturnOrder.fromJson(Map<String, dynamic> json) {
    return ReturnOrder(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      status: json['status'] ?? '',
      paymentStatus: json['payment_status'] ?? '',
      paymentMethod: json['payment_method'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class ReturnOrderItem {
  final int id;
  final int productId;
  final String productName;
  final String sku;
  final String uom;
  final double qtyOrdered;
  final double unitPrice;

  ReturnOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.uom,
    required this.qtyOrdered,
    required this.unitPrice,
  });

  factory ReturnOrderItem.fromJson(Map<String, dynamic> json) {
    return ReturnOrderItem(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      sku: json['sku'] ?? '',
      uom: json['uom'] ?? '',
      qtyOrdered: double.parse(json['qty_ordered']?.toString() ?? '0'),
      unitPrice: double.parse(json['unit_price']?.toString() ?? '0'),
    );
  }
}

class ReturnPhoto {
  final int id;
  final int returnId;
  final String filePath;
  final String fileName;
  final String signedUrl;

  ReturnPhoto({
    required this.id,
    required this.returnId,
    required this.filePath,
    required this.fileName,
    required this.signedUrl,
  });

  factory ReturnPhoto.fromJson(Map<String, dynamic> json) {
    return ReturnPhoto(
      id: json['id'] ?? 0,
      returnId: json['return_id'] ?? 0,
      filePath: json['file_path'] ?? '',
      fileName: json['file_name'] ?? '',
      signedUrl: json['signed_url'] ?? '',
    );
  }
}

class ReturnCreditNote {
  final int id;
  final String creditNoteNumber;
  final double totalAmount;
  final DateTime issuedAt;

  ReturnCreditNote({
    required this.id,
    required this.creditNoteNumber,
    required this.totalAmount,
    required this.issuedAt,
  });

  factory ReturnCreditNote.fromJson(Map<String, dynamic> json) {
    return ReturnCreditNote(
      id: json['id'] ?? 0,
      creditNoteNumber: json['credit_note_number'] ?? '',
      totalAmount: double.parse(json['total_amount']?.toString() ?? '0'),
      issuedAt: DateTime.parse(json['issued_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class ReturnStats {
  final int totalReturns;
  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;
  final double totalCreditAmount;
  final double returnRatePercentage;

  ReturnStats({
    required this.totalReturns,
    required this.pendingCount,
    required this.approvedCount,
    required this.rejectedCount,
    required this.totalCreditAmount,
    required this.returnRatePercentage,
  });

  factory ReturnStats.fromJson(Map<String, dynamic> json) {
    return ReturnStats(
      totalReturns: json['total_returns'] ?? 0,
      pendingCount: json['pending_count'] ?? 0,
      approvedCount: json['approved_count'] ?? 0,
      rejectedCount: json['rejected_count'] ?? 0,
      totalCreditAmount: double.parse(json['total_credit_amount']?.toString() ?? '0'),
      returnRatePercentage: double.parse(json['return_rate_percentage']?.toString() ?? '0'),
    );
  }
}