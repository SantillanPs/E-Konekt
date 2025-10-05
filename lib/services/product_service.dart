// Product service - handles database and storage operations
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Add new product
  Future<void> addProduct(ProductModel product) async {
    try {
      await _supabase.from('products').insert(product.toJson());
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  // Get all products
  Future<List<ProductModel>> getProducts() async {
    try {
      final data = await _supabase
          .from('products')
          .select()
          .order('created_at', ascending: false);

      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }

  // Get products stream (real-time)
  Stream<List<ProductModel>> getProductsStream() {
    return _supabase
        .from('products')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => ProductModel.fromJson(json)).toList());
  }

  // Get product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final data = await _supabase
          .from('products')
          .select()
          .eq('id', productId)
          .single();

      return ProductModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  // Search products by name
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final data = await _supabase
          .from('products')
          .select()
          .ilike('name', '%$query%')
          .order('created_at', ascending: false);

      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  // Upload image to Supabase Storage
  Future<String> uploadImage(File imageFile, String productName) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$timestamp-${productName.replaceAll(' ', '_')}.jpg';
      
      await _supabase.storage
          .from('products')
          .upload(fileName, imageFile);

      final imageUrl = _supabase.storage
          .from('products')
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _supabase
          .from('products')
          .delete()
          .eq('id', productId);
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Get products by owner
  Future<List<ProductModel>> getProductsByOwner(String ownerId) async {
    try {
      final data = await _supabase
          .from('products')
          .select()
          .eq('owner_id', ownerId)
          .order('created_at', ascending: false);

      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get products by owner: $e');
    }
  }

  // Get products by category
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    try {
      final data = await _supabase
          .from('products')
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);

      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get products by category: $e');
    }
  }
}