// Product data model
class ProductModel {
  final String productId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String location;
  final String category;
  final String ownerId;
  final String ownerName;
  final DateTime createdAt;

  ProductModel({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.location,
    required this.category,
    required this.ownerId,
    required this.ownerName,
    required this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['image_url'] ?? '',
      location: json['location'] ?? '',
      category: json['category'] ?? '',
      ownerId: json['owner_id'] ?? '',
      ownerName: json['owner_name'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'location': location,
      'category': category,
      'owner_id': ownerId,
      'owner_name': ownerName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}