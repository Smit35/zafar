class WalletTransaction {
  final int id;
  final int outletId;
  final int walletId;
  final String type;
  final String source;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final int? referenceOrderId;
  final int? referenceReturnId;
  final String? remarks;
  final int? createdBy;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.outletId,
    required this.walletId,
    required this.type,
    required this.source,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.referenceOrderId,
    this.referenceReturnId,
    this.remarks,
    this.createdBy,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] ?? 0,
      outletId: json['outlet_id'] ?? 0,
      walletId: json['wallet_id'] ?? 0,
      type: json['type'] ?? '',
      source: json['source'] ?? '',
      amount: double.parse(json['amount']?.toString() ?? '0'),
      balanceBefore: double.parse(json['balance_before']?.toString() ?? '0'),
      balanceAfter: double.parse(json['balance_after']?.toString() ?? '0'),
      referenceOrderId: json['reference_order_id'],
      referenceReturnId: json['reference_return_id'],
      remarks: json['remarks'],
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  bool get isCredit => type.toLowerCase() == 'credit';
  bool get isDebit => type.toLowerCase() == 'debit';
}