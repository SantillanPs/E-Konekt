// Business service - handles business CRUD operations
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/business_model.dart';

class BusinessService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Create business
  Future<void> createBusiness(BusinessModel business) async {
    try {
      await _supabase.from('businesses').insert(business.toJson());
    } catch (e) {
      throw Exception('Failed to create business: $e');
    }
  }

  // Get business by ID
  Future<BusinessModel?> getBusinessById(String businessId) async {
    try {
      final data = await _supabase
          .from('businesses')
          .select()
          .eq('id', businessId)
          .single();

      return BusinessModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  // Get business by owner ID
  Future<BusinessModel?> getBusinessByOwnerId(String ownerId) async {
    try {
      final data = await _supabase
          .from('businesses')
          .select()
          .eq('owner_id', ownerId)
          .single();

      return BusinessModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  // Get all businesses
  Future<List<BusinessModel>> getAllBusinesses() async {
    try {
      final data = await _supabase
          .from('businesses')
          .select()
          .order('created_at', ascending: false);

      return data.map((json) => BusinessModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get businesses: $e');
    }
  }

  // Update business
  Future<void> updateBusiness(String businessId, Map<String, dynamic> data) async {
    try {
      await _supabase
          .from('businesses')
          .update(data)
          .eq('id', businessId);
    } catch (e) {
      throw Exception('Failed to update business: $e');
    }
  }

  // Upload logo to Supabase Storage
  Future<String> uploadLogo(File imageFile, String businessName) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'logos/$timestamp-${businessName.replaceAll(' ', '_')}.jpg';

      await _supabase.storage
          .from('businesses')
          .upload(fileName, imageFile);

      final imageUrl = _supabase.storage
          .from('businesses')
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload logo: $e');
    }
  }

  // Delete business
  Future<void> deleteBusiness(String businessId) async {
    try {
      await _supabase
          .from('businesses')
          .delete()
          .eq('id', businessId);
    } catch (e) {
      throw Exception('Failed to delete business: $e');
    }
  }
}