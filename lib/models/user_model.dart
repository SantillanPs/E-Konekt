// User data model matching Supabase structure
class UserModel {
  final String userId;
  final String name;
  final String email;
  final String phoneNumber;
  final String role;
  final String barangay;
  final String city;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool barangayAdmin;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    this.phoneNumber = '',
    required this.role,
    required this.barangay,
    required this.city,
    this.createdAt,
    this.updatedAt,
    this.barangayAdmin = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      role: json['role'] ?? 'user',
      barangay: json['barangay'] ?? '',
      city: json['city'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      barangayAdmin: json['barangay_admin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'role': role,
      'barangay': barangay,
      'city': city,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'barangay_admin': barangayAdmin,
    };
  }
}