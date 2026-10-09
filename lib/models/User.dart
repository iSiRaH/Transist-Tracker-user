class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? licenseNumber;
  final String? profileImage;
  final bool isActive;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.licenseNumber,
    this.profileImage,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'user',
      phone: json['phone']?.toString(),
      licenseNumber: json['licenseNumber']?.toString(),
      profileImage: json['profileImage']?.toString(),
      isActive: json['isActive'] == null ? true : json['isActive'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'licenseNumber': licenseNumber,
      'profileImage': profileImage,
      'isActive': isActive,
    };
  }
}
