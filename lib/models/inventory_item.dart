class InventoryItem {
  final dynamic id;
  final dynamic outletId;
  final dynamic productId;
  final String name;
  final String sku;
  final String uom;
  final String price;
  final dynamic posPrice;
  final String? description;
  final String? imagePath;
  final int minOrderQty;
  final int maxOrderQty;
  final String minAlertLevel;
  final Category category;
  final StockSummary stockSummary;
  final List<UOMWiseStock> uomWiseStock;

  InventoryItem({
    required this.id,
    required this.outletId,
    required this.productId,
    required this.name,
    required this.sku,
    required this.uom,
    required this.price,
    required this.posPrice,
    this.description,
    this.imagePath,
    required this.minOrderQty,
    required this.maxOrderQty,
    required this.minAlertLevel,
    required this.category,
    required this.stockSummary,
    required this.uomWiseStock,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    // Get the default UOM from uom_wise_stock
    final uomWiseStockList = (json['uom_wise_stock'] as List? ?? [])
        .map((item) => UOMWiseStock.fromJson(item))
        .toList();
    
    final defaultUOM = uomWiseStockList.isNotEmpty 
        ? uomWiseStockList.firstWhere(
            (uom) => uom.isDefault, 
            orElse: () => uomWiseStockList.first
          )
        : null;

    return InventoryItem(
      id: json['id'],
      outletId: json['outlet_id'],
      productId: json['product_id'],
      name: json['product_name']?.toString() ?? '',
      sku: json['product_sku']?.toString() ?? '',
      uom: defaultUOM?.unitAbbreviation ?? 'PCS',
      price: json['product_price']?.toString() ?? '0',
      posPrice: json['product_pos_price'],
      description: json['product_description']?.toString(),
      imagePath: json['product_image']?.toString(),
      minOrderQty: int.tryParse(json['min_order_qty']?.toString() ?? '0') ?? 0,
      maxOrderQty: int.tryParse(json['max_order_qty']?.toString() ?? '0') ?? 0,
      minAlertLevel: json['min_alert_level']?.toString() ?? '0',
      category: Category.fromJson(json['category'] ?? {}),
      stockSummary: StockSummary.fromJson(json['stock_summary'] ?? {}),
      uomWiseStock: uomWiseStockList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'outlet_id': outletId,
      'product_id': productId,
      'product_name': name,
      'product_sku': sku,
      'product_price': price,
      'product_pos_price': posPrice,
      'product_description': description,
      'product_image': imagePath,
      'min_order_qty': minOrderQty,
      'max_order_qty': maxOrderQty,
      'min_alert_level': minAlertLevel,
      'category': category.toJson(),
      'stock_summary': stockSummary.toJson(),
      'uom_wise_stock': uomWiseStock.map((item) => item.toJson()).toList(),
    };
  }

  String get imageUrl {
    if (imagePath == null || imagePath!.isEmpty) return '';
    return 'https://zafs.copytrading.cloud/storage/$imagePath';
  }

  double get priceValue => double.tryParse(price) ?? 0.0;
  double get availableStock => stockSummary.availableStock.toDouble();
  bool get isInStock => availableStock > 0;
}

class Category {
  final dynamic id;
  final String name;
  final dynamic displayOrder;
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
      name: json['name']?.toString() ?? '',
      displayOrder: json['display_order'],
      imagePath: json['image_path']?.toString(),
      status: json['status'] == true || json['status'] == 1 || json['status']?.toString().toLowerCase() == 'true',
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
  final dynamic id;
  final dynamic productId;
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
      totalStock: json['total_stock']?.toString() ?? '0',
      reservedStock: json['reserved_stock']?.toString() ?? '0',
      availableStock: json['available_stock']?.toString() ?? '0',
      minAlertLevel: json['min_alert_level']?.toString() ?? '0',
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

class StockSummary {
  final dynamic baseUnitId;
  final String qtyInStock;
  final String reservedQty;
  final String posReservedQty;
  final int availableStock;
  final bool isLowStock;

  StockSummary({
    this.baseUnitId,
    required this.qtyInStock,
    required this.reservedQty,
    required this.posReservedQty,
    required this.availableStock,
    required this.isLowStock,
  });

  factory StockSummary.fromJson(Map<String, dynamic> json) {
    return StockSummary(
      baseUnitId: json['base_unit_id'],
      qtyInStock: json['qty_in_stock']?.toString() ?? '0',
      reservedQty: json['reserved_qty']?.toString() ?? '0',
      posReservedQty: json['pos_reserved_qty']?.toString() ?? '0',
      availableStock: int.tryParse(json['available_stock']?.toString() ?? '0') ?? 0,
      isLowStock: json['is_low_stock'] == true || json['is_low_stock'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_unit_id': baseUnitId,
      'qty_in_stock': qtyInStock,
      'reserved_qty': reservedQty,
      'pos_reserved_qty': posReservedQty,
      'available_stock': availableStock,
      'is_low_stock': isLowStock,
    };
  }
}

class UOMWiseStock {
  final int unitId;
  final String unitName;
  final String unitAbbreviation;
  final bool isBaseUnit;
  final bool isDefault;
  final int availableStock;
  final String conversionRatio;
  final String retailPrice;
  final int inwardUnitId;
  final String inwardUnitName;

  UOMWiseStock({
    required this.unitId,
    required this.unitName,
    required this.unitAbbreviation,
    required this.isBaseUnit,
    required this.isDefault,
    required this.availableStock,
    required this.conversionRatio,
    required this.retailPrice,
    required this.inwardUnitId,
    required this.inwardUnitName,
  });

  factory UOMWiseStock.fromJson(Map<String, dynamic> json) {
    return UOMWiseStock(
      unitId: int.tryParse(json['unit_id']?.toString() ?? '0') ?? 0,
      unitName: json['unit_name']?.toString() ?? '',
      unitAbbreviation: json['unit_abbreviation']?.toString() ?? '',
      isBaseUnit: json['is_base_unit'] == true || json['is_base_unit'] == 1,
      isDefault: json['is_default'] == true || json['is_default'] == 1,
      availableStock: int.tryParse(json['available_stock']?.toString() ?? '0') ?? 0,
      conversionRatio: json['conversion_ratio']?.toString() ?? '1.0',
      retailPrice: json['retail_price']?.toString() ?? '0',
      inwardUnitId: int.tryParse(json['inward_unit_id']?.toString() ?? '0') ?? 0,
      inwardUnitName: json['inward_unit_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unit_id': unitId,
      'unit_name': unitName,
      'unit_abbreviation': unitAbbreviation,
      'is_base_unit': isBaseUnit,
      'is_default': isDefault,
      'available_stock': availableStock,
      'conversion_ratio': conversionRatio,
      'retail_price': retailPrice,
      'inward_unit_id': inwardUnitId,
      'inward_unit_name': inwardUnitName,
    };
  }
}