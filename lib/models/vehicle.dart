class Vehicle {
  final int id;
  final String vehicleName;
  final String registrationNumber;
  final String vehicleType;
  final String? make;
  final String? model;
  final int? manufactureYear;
  final String? color;
  final String fuelType;
  final int? capacityKg;
  final String? vehiclePhoto;
  final String? gpsTrackerId;
  final bool status;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Vehicle({
    required this.id,
    required this.vehicleName,
    required this.registrationNumber,
    required this.vehicleType,
    this.make,
    this.model,
    this.manufactureYear,
    this.color,
    required this.fuelType,
    this.capacityKg,
    this.vehiclePhoto,
    this.gpsTrackerId,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      vehicleName: json['vehicle_name'],
      registrationNumber: json['registration_number'],
      vehicleType: json['vehicle_type'],
      make: json['make']?.toString(),
      model: json['model']?.toString(),
      manufactureYear: json['manufacture_year'],
      color: json['color']?.toString(),
      fuelType: json['fuel_type'],
      capacityKg: json['capacity_kg'],
      vehiclePhoto: json['vehicle_photo']?.toString(),
      gpsTrackerId: json['gps_tracker_id']?.toString(),
      status: json['status'] ?? true,
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicle_name': vehicleName,
      'registration_number': registrationNumber,
      'vehicle_type': vehicleType,
      'make': make,
      'model': model,
      'manufacture_year': manufactureYear,
      'color': color,
      'fuel_type': fuelType,
      'capacity_kg': capacityKg,
      'vehicle_photo': vehiclePhoto,
      'gps_tracker_id': gpsTrackerId,
      'status': status,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}