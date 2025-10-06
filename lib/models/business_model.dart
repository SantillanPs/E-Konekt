// Business data model
class BusinessModel {
  final String businessId;
  final String ownerId;
  final String name;
  final String description;
  final String address;
  final String contactInfo;
  final String logoUrl;
  final DateTime createdAt;

  BusinessModel({
    required this.businessId,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.address,
    required this.contactInfo,
    required this.logoUrl,
    required this.createdAt,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      businessId: json['id']?.toString() ?? '',
      ownerId: json['owner_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      contactInfo: json['contact_info'] ?? '',
      logoUrl: json['logo_url'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'owner_id': ownerId,
      'name': name,
      'description': description,
      'address': address,
      'contact_info': contactInfo,
      'logo_url': logoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}