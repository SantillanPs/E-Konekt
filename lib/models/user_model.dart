// User data model matching Firestore structure
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

  // Convert Firestore document to UserModel
  factory UserModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return UserModel(
      userId: documentId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      barangay: data['barangay'] ?? '',
      city: data['city'] ?? '',
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'])
          : null,
    );
  }

  // Convert UserModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'barangay': barangay,
      'city': city,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  // Create copy with updated fields
  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? role,
    String? barangay,
    String? city,
    DateTime? createdAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      barangay: barangay ?? this.barangay,
      city: city ?? this.city,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}