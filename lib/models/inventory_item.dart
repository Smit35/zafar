class InventoryItem {
  final int id;
  final int categoryId;
  final String name;
  final String sku;
  final String uom;
  final String price;
  final String posPrice;
  final String? description;
  final String? imagePath;
  final bool status;
  final Category category;
  final Inventory inventory;

  InventoryItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.sku,
    required this.uom,
    required this.price,
    required this.posPrice,
    this.description,
    this.imagePath,
    required this.status,
    required this.category,
    required this.inventory,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      categoryId: json['category_id'],
      name: json['name'],
      sku: json['sku'],
      uom: json['uom'],
      price: json['price'],
      posPrice: json['pos_price'],
      description: json['description'],
      imagePath: json['image_path'],
      status: json['status'],
      category: Category.fromJson(json['category']),
      inventory: Inventory.fromJson(json['inventory']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'sku': sku,
      'uom': uom,
      'price': price,
      'pos_price': posPrice,
      'description': description,
      'image_path': imagePath,
      'status': status,
      'category': category.toJson(),
      'inventory': inventory.toJson(),
    };
  }

  String get imageUrl {
    if (imagePath == null) return '';
    return 'https://zafs.copytrading.cloud/storage/$imagePath';
  }

  double get priceValue => double.tryParse(price) ?? 0.0;
  double get availableStock => double.tryParse(inventory.availableStock) ?? 0.0;
  bool get isInStock => availableStock > 0;
}

class Category {
  final int id;
  final String name;
  final int displayOrder;
  final String? imagePath;
  final bool status;

  Category({
    required this.id,
    required this.name,
    required this.displayOrder,
    this.imagePath,
    required this.status,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      displayOrder: json['display_order'],
      imagePath: json['image_path'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_order': displayOrder,
      'image_path': imagePath,
      'status': status,
    };
  }
}

class Inventory {
  final int id;
  final int productId;
  final String totalStock;
  final String reservedStock;
  final String availableStock;
  final String minAlertLevel;

  Inventory({
    required this.id,
    required this.productId,
    required this.totalStock,
    required this.reservedStock,
    required this.availableStock,
    required this.minAlertLevel,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['id'],
      productId: json['product_id'],
      totalStock: json['total_stock'],
      reservedStock: json['reserved_stock'],
      availableStock: json['available_stock'],
      minAlertLevel: json['min_alert_level'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'total_stock': totalStock,
      'reserved_stock': reservedStock,
      'available_stock': availableStock,
      'min_alert_level': minAlertLevel,
    };
  }
}