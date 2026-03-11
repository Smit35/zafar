class Driver {
  final int id;
  final String name;
  final String email;
  final String contact;
  final String licenceNumber;
  final String? vehicle;
  final bool status;
  final int activeManifestCount;

  Driver({
    required this.id,
    required this.name,
    required this.email,
    required this.contact,
    required this.licenceNumber,
    this.vehicle,
    required this.status,
    required this.activeManifestCount,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id'],
      name: json['full_name'],
      email: json['email'],
      contact: json['contact_number'],
      licenceNumber: json['licence_number'],
      vehicle: json['vehicle']?.toString(),
      status: json['status'] ?? false,
      activeManifestCount: json['active_manifest_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'contact': contact,
      'licence_number': licenceNumber,
      'vehicle': vehicle,
      'status': status,
      'active_manifest_count': activeManifestCount,
    };
  }

  Driver copyWith({
    int? id,
    String? name,
    String? email,
    String? contact,
    String? licenceNumber,
    String? vehicle,
    bool? status,
    int? activeManifestCount,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      contact: contact ?? this.contact,
      licenceNumber: licenceNumber ?? this.licenceNumber,
      vehicle: vehicle ?? this.vehicle,
      status: status ?? this.status,
      activeManifestCount: activeManifestCount ?? this.activeManifestCount,
    );
  }
}