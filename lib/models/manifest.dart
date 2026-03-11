import 'vehicle.dart';
import 'manifest_order.dart';

class Manifest {
  final int id;
  final String manifestNumber;
  final DateTime dispatchDate;
  final String status;
  final int totalOrders;
  final Vehicle vehicle;
  final String? notes;
  final List<ManifestOrder>? orders;
  final DateTime? startedAt;
  final DateTime? createdAt;

  Manifest({
    required this.id,
    required this.manifestNumber,
    required this.dispatchDate,
    required this.status,
    required this.totalOrders,
    required this.vehicle,
    this.notes,
    this.orders,
    this.startedAt,
    this.createdAt,
  });

  factory Manifest.fromJson(Map<String, dynamic> json) {
    return Manifest(
      id: json['id'],
      manifestNumber: json['manifest_number'],
      dispatchDate: DateTime.parse(json['dispatch_date']),
      status: json['status'],
      totalOrders: json['total_orders'],
      vehicle: Vehicle.fromJson(json['vehicle']),
      notes: json['notes']?.toString(),
      orders: json['orders'] != null
          ? (json['orders'] as List)
              .map((order) => ManifestOrder.fromJson(order))
              .toList()
          : null,
      startedAt: json['started_at'] != null 
          ? DateTime.parse(json['started_at'])
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'manifest_number': manifestNumber,
      'dispatch_date': dispatchDate.toIso8601String(),
      'status': status,
      'total_orders': totalOrders,
      'vehicle': vehicle.toJson(),
      'notes': notes,
      'orders': orders?.map((order) => order.toJson()).toList(),
      'started_at': startedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  bool get isReadyToDispatch => status == 'ready_to_dispatch';
  bool get isOutForDelivery => status == 'out_for_delivery';
  bool get isCompleted => status == 'completed';
}