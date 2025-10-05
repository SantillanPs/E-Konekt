import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print("🚀 Adding mock data to Supabase...");

  // Get credentials from .env file (simple parsing)
  final env = await _loadEnv();
  final supabaseUrl = env['SUPABASE_URL'] ?? 'YOUR_SUPABASE_URL';
  final serviceRoleKey = env['SUPABASE_SERVICE_ROLE_KEY'] ?? 'YOUR_SERVICE_ROLE_KEY';

  if (supabaseUrl == 'YOUR_SUPABASE_URL' || serviceRoleKey == 'YOUR_SERVICE_ROLE_KEY') {
    print("❌ Please set your Supabase credentials in .env file");
    return;
  }

  try {
    // Add mock users
    await _addMockUsers(supabaseUrl, serviceRoleKey);
    print("✅ Added 3 mock users");

    // Add mock products
    await _addMockProducts(supabaseUrl, serviceRoleKey);
    print("✅ Added 5 mock products");

    print("🎉 Mock data added successfully!");
    print("You can now test your app!");

  } catch (e) {
    print("❌ Error: $e");
  }
}

Future<Map<String, String>> _loadEnv() async {
  try {
    final file = File('.env');
    final content = await file.readAsString();
    final lines = content.split('\n');
    final env = <String, String>{};

    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.contains('=') && !trimmedLine.startsWith('#')) {
        final parts = trimmedLine.split('=');
        final key = parts[0].trim();
        final value = parts.sublist(1).join('=').trim();
        env[key] = value;
      }
    }

    return env;
  } catch (e) {
    return {};
  }
}

Future<void> _addMockUsers(String url, String key) async {
  final users = [
    {
      'name': 'Juan Dela Cruz',
      'email': 'juan.delacruz@email.com',
      'role': 'user',
      'barangay': 'Barangay 1',
      'city': 'Manila',
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'name': 'Maria Santos',
      'email': 'maria.santos@email.com',
      'role': 'user',
      'barangay': 'Barangay 2',
      'city': 'Quezon City',
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'name': 'Pedro Reyes',
      'email': 'pedro.reyes@email.com',
      'role': 'user',
      'barangay': 'Barangay 3',
      'city': 'Makati',
      'created_at': DateTime.now().toIso8601String(),
    },
  ];

  for (final user in users) {
    try {
      final response = await http.post(
        Uri.parse('$url/rest/v1/users'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': key,
          'Authorization': 'Bearer $key',
          'Prefer': 'return=representation',
        },
        body: jsonEncode(user),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("  ✓ Added user: ${user['name']}");
      } else {
        print("  ✗ Failed to add user ${user['name']}: ${response.statusCode}");
        print("    Response: ${response.body}");
      }
    } catch (e) {
      print("  ✗ Error adding user ${user['name']}: $e");
    }
  }
}

Future<void> _addMockProducts(String url, String key) async {
  final products = [
    {
      'name': 'iPhone 14 Pro',
      'description': 'Brand new iPhone 14 Pro 256GB Space Black.',
      'price': 50000.0,
      'image_url': 'https://images.unsplash.com/photo-1592899677977-9c10ca588bbd?w=400',
      'location': 'Barangay 1, Manila',
      'category': 'Electronics',
      'owner_email': 'juan.delacruz@email.com',
      'owner_name': 'Juan Dela Cruz',
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'name': 'Wooden Dining Table',
      'description': 'Beautiful wooden dining table that seats 6 people.',
      'price': 15000.0,
      'image_url': 'https://images.unsplash.com/photo-1577140917170-285929fb55b7?w=400',
      'location': 'Barangay 2, Quezon City',
      'category': 'Furniture',
      'owner_email': 'maria.santos@email.com',
      'owner_name': 'Maria Santos',
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'name': 'Fresh Organic Vegetables',
      'description': 'Fresh organic vegetables grown locally.',
      'price': 500.0,
      'image_url': 'https://images.unsplash.com/photo-1567306301408-9b74779a11af?w=400',
      'location': 'Barangay 3, Makati',
      'category': 'Food',
      'owner_email': 'pedro.reyes@email.com',
      'owner_name': 'Pedro Reyes',
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'name': 'Vintage Leather Jacket',
      'description': 'Classic vintage leather jacket in excellent condition.',
      'price': 2500.0,
      'image_url': 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=400',
      'location': 'Barangay 1, Manila',
      'category': 'Clothing',
      'owner_email': 'juan.delacruz@email.com',
      'owner_name': 'Juan Dela Cruz',
      'created_at': DateTime.now().toIso8601String(),
    },
    {
      'name': 'Home Cleaning Service',
      'description': 'Professional home cleaning service.',
      'price': 2000.0,
      'image_url': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
      'location': 'Barangay 2, Quezon City',
      'category': 'Services',
      'owner_email': 'maria.santos@email.com',
      'owner_name': 'Maria Santos',
      'created_at': DateTime.now().toIso8601String(),
    },
  ];

  for (final product in products) {
    try {
      final response = await http.post(
        Uri.parse('$url/rest/v1/products'),
        headers: {
          'Content-Type': 'application/json',
          'apikey': key,
          'Authorization': 'Bearer $key',
          'Prefer': 'return=representation',
        },
        body: jsonEncode(product),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("  ✓ Added product: ${product['name']}");
      } else {
        print("  ✗ Failed to add product ${product['name']}: ${response.statusCode}");
        print("    Response: ${response.body}");
      }
    } catch (e) {
      print("  ✗ Error adding product ${product['name']}: $e");
    }
  }
}
