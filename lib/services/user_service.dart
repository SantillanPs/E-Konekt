// User service - handles database CRUD operations for users
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Create user in database
  Future<void> createUser(UserModel user) async {
    try {
      await _supabase.from('users').insert(user.toJson());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      return UserModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  // Get user stream (real-time updates)
  Stream<UserModel?> getUserStream(String userId) {
    return _supabase
        .from('users')
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((data) {
          if (data.isEmpty) return null;
          return UserModel.fromJson(data.first);
        });
  }

  // Update user data
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _supabase
          .from('users')
          .update(data)
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _supabase
          .from('users')
          .delete()
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Get users by barangay
  Future<List<UserModel>> getUsersByBarangay(String barangay) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('barangay', barangay);

      return data.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get users by barangay: $e');
    }
  }

  // Get users by city
  Future<List<UserModel>> getUsersByCity(String city) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('city', city);

      return data.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get users by city: $e');
    }
  }

  // Get users by role
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('role', role);

      return data.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get users by role: $e');
    }
  }
}