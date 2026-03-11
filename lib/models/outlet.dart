class Outlet {
  final int id;
  final String outletName;
  final String ownerName;
  final String contactNumber;
  final String? alternateContact;
  final String email;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String pinCode;
  final String? gstNumber;
  final String? fssaiLicenceNumber;
  final DateTime? fssaiExpiryDate;
  final String? shopActNumber;
  final DateTime? shopActExpiryDate;
  final DateTime? franchiseSignedDate;
  final DateTime? franchiseExpiryDate;
  final String outletType;
  final DateTime openingDate;
  final String? bankAccountNumber;
  final String? bankIfscCode;
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
    this.addressLine2,
    required this.city,
    required this.state,
    required this.pinCode,
    this.gstNumber,
    this.fssaiLicenceNumber,
    this.fssaiExpiryDate,
    this.shopActNumber,
    this.shopActExpiryDate,
    this.franchiseSignedDate,
    this.franchiseExpiryDate,
    required this.outletType,
    required this.openingDate,
    this.bankAccountNumber,
    this.bankIfscCode,
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
      id: json['id'],
      outletName: json['outlet_name'],
      ownerName: json['owner_name'],
      contactNumber: json['contact_number'],
      alternateContact: json['alternate_contact']?.toString(),
      email: json['email'],
      addressLine1: json['address_line_1'],
      addressLine2: json['address_line_2']?.toString(),
      city: json['city'],
      state: json['state'],
      pinCode: json['pin_code'],
      gstNumber: json['gst_number']?.toString(),
      fssaiLicenceNumber: json['fssai_licence_number']?.toString(),
      fssaiExpiryDate: json['fssai_expiry_date'] != null ? DateTime.parse(json['fssai_expiry_date']) : null,
      shopActNumber: json['shop_act_number']?.toString(),
      shopActExpiryDate: json['shop_act_expiry_date'] != null ? DateTime.parse(json['shop_act_expiry_date']) : null,
      franchiseSignedDate: json['franchise_signed_date'] != null ? DateTime.parse(json['franchise_signed_date']) : null,
      franchiseExpiryDate: json['franchise_expiry_date'] != null ? DateTime.parse(json['franchise_expiry_date']) : null,
      outletType: json['outlet_type'],
      openingDate: DateTime.parse(json['opening_date']),
      bankAccountNumber: json['bank_account_number']?.toString(),
      bankIfscCode: json['bank_ifsc_code']?.toString(),
      bankName: json['bank_name']?.toString(),
      bankAccountHolder: json['bank_account_holder']?.toString(),
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      status: json['status'] ?? true,
      statusReason: json['status_reason']?.toString(),
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'outlet_name': outletName,
      'owner_name': ownerName,
      'contact_number': contactNumber,
      'alternate_contact': alternateContact,
      'email': email,
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'city': city,
      'state': state,
      'pin_code': pinCode,
      'gst_number': gstNumber,
      'fssai_licence_number': fssaiLicenceNumber,
      'fssai_expiry_date': fssaiExpiryDate?.toIso8601String(),
      'shop_act_number': shopActNumber,
      'shop_act_expiry_date': shopActExpiryDate?.toIso8601String(),
      'franchise_signed_date': franchiseSignedDate?.toIso8601String(),
      'franchise_expiry_date': franchiseExpiryDate?.toIso8601String(),
      'outlet_type': outletType,
      'opening_date': openingDate.toIso8601String(),
      'bank_account_number': bankAccountNumber,
      'bank_ifsc_code': bankIfscCode,
      'bank_name': bankName,
      'bank_account_holder': bankAccountHolder,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'status_reason': statusReason,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  String get fullAddress {
    final parts = [addressLine1, addressLine2, city, state, pinCode]
        .where((part) => part != null && part.isNotEmpty);
    return parts.join(', ');
  }
}