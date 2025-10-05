// User data model matching Supabase structure
class UserModel {
  final String userId;
  final String name;
  final String email;
  final String role;
  final String barangay;
  final String city;
  final DateTime? createdAt;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.barangay,
    required this.city,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      barangay: json['barangay'] ?? '',
      city: json['city'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'name': name,
      'email': email,
      'role': role,
      'barangay': barangay,
      'city': city,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}