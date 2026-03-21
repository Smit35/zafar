class CartItem {
  final int id;
  final int outletId;
  final int productId;
  final String qty;
  final String lastActivityAt;
  final String createdAt;
  final String updatedAt;
  final CartProduct product;

  CartItem({
    required this.id,
    required this.outletId,
    required this.productId,
    required this.qty,
    required this.lastActivityAt,
    required this.createdAt,
    required this.updatedAt,
    required this.product,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      outletId: json['outlet_id'],
      productId: json['product_id'],
      qty: json['qty'],
      lastActivityAt: json['last_activity_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      product: CartProduct.fromJson(json['product']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'outlet_id': outletId,
      'product_id': productId,
      'qty': qty,
      'last_activity_at': lastActivityAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'product': product.toJson(),
    };
  }

  double get quantity => double.tryParse(qty) ?? 0.0;
  double get totalPrice => product.priceValue * quantity;
}

class CartProduct {
  final int id;
  final String name;
  final String sku;
  final String price;
  final String uom;
  final String? imagePath;
  final bool status;
  final CartInventory? inventory;

  CartProduct({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    required this.uom,
    this.imagePath,
    required this.status,
    this.inventory,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: json['id'],
      name: json['name'],
      sku: json['sku'],
      price: json['price'],
      uom: json['uom'],
      imagePath: json['image_path'],
      status: json['status'],
      inventory: json['inventory'] != null
          ? CartInventory.fromJson(json['inventory'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'price': price,
      'uom': uom,
      'image_path': imagePath,
      'status': status,
      'inventory': inventory?.toJson(),
    };
  }

  double get priceValue => double.tryParse(price) ?? 0.0;
  
  String get imageUrl {
    if (imagePath == null) return '';
    return 'https://zafs.copytrading.cloud/storage/$imagePath';
  }
}

class CartInventory {
  final int productId;
  final String totalStock;
  final String reservedStock;

  CartInventory({
    required this.productId,
    required this.totalStock,
    required this.reservedStock,
  });

  factory CartInventory.fromJson(Map<String, dynamic> json) {
    return CartInventory(
      productId: json['product_id'],
      totalStock: json['total_stock'],
      reservedStock: json['reserved_stock'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'total_stock': totalStock,
      'reserved_stock': reservedStock,
    };
  }
}

class AddToCartRequest {
  final int productId;
  final int quantity;

  AddToCartRequest({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
    };
  }
}