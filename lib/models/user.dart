enum UserType { outlet, driver }

class User {
  final String id;
  final String email;
  final String name;
  final UserType type;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.type,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      type: json['type'] == 'outlet' ? UserType.outlet : UserType.driver,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'type': type == UserType.outlet ? 'outlet' : 'driver',
    };
  }
}