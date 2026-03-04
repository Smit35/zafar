enum UserType { outlet, driver }

class User {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final UserType type;
  final bool isOnline;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    required this.type,
    this.isOnline = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      type: json['type'] == 'outlet' ? UserType.outlet : UserType.driver,
      isOnline: json['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'type': type == UserType.outlet ? 'outlet' : 'driver',
      'isOnline': isOnline,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    UserType? type,
    bool? isOnline,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}