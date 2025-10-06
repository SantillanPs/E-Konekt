// Entry point for E-Konekt app
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/product_service.dart';
import 'services/business_service.dart';
import 'services/job_service.dart';
import 'app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load();

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY'),
  );
  
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<UserService>(
          create: (_) => UserService(),
        ),
        Provider<ProductService>(
          create: (_) => ProductService(),
        ),
        Provider<BusinessService>(
          create: (_) => BusinessService(),
        ),
        Provider<JobService>(
          create: (_) => JobService(),
        ),
      ],
      child: const EKonektApp(),
    ),
  );
}