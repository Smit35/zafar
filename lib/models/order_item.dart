class OrderItem {
  final int id;
  final String productName;
  final String sku;
  final int? quantity;
  final double unitPrice;
  final double lineTotal;

  OrderItem({
    required this.id,
    required this.productName,
    required this.sku,
    this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      productName: json['product_name'],
      sku: json['sku'],
      quantity: json['quantity'],
      unitPrice: double.parse(json['unit_price'].toString()),
      lineTotal: double.parse(json['line_total'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_name': productName,
      'sku': sku,
      'quantity': quantity,
      'unit_price': unitPrice.toStringAsFixed(2),
      'line_total': lineTotal.toStringAsFixed(2),
    };
  }
}