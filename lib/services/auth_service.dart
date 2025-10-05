// Authentication service - handles sign up, login, logout
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Sign up with email and password
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    required String barangay,
    required String city,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) throw Exception('Failed to create user');

      // Create user profile in database using service role client
      final userModel = UserModel(
        userId: user.id,
        name: name,
        email: email,
        role: role,
        barangay: barangay,
        city: city,
        createdAt: DateTime.now(),
      );

      // Use service role key for user profile creation
      final serviceClient = SupabaseClient(
        dotenv.get('SUPABASE_URL', fallback: 'YOUR_SUPABASE_URL'),
        dotenv.get('SUPABASE_SERVICE_ROLE_KEY', fallback: 'YOUR_SERVICE_ROLE_KEY'),
      );

      await serviceClient.from('users').insert(userModel.toJson());
      return userModel;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // Login with email and password
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  // Password reset
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }
}