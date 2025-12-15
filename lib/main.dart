// Entry point for E-Konekt app
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/product_service.dart';
import 'services/business_service.dart';
import 'services/job_service.dart';
import 'services/announcement_service.dart';
import 'services/notification_service.dart';
import 'app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables from .env file
    await dotenv.load(fileName: ".env");

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
          Provider<AnnouncementService>(
            create: (_) => AnnouncementService(),
          ),
          Provider<NotificationService>(
            create: (_) => NotificationService(),
          ),
        ],
        child: const EKonektApp(),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('Initialization Error: $e');
    debugPrint(stackTrace.toString());
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: SelectableText(
                'Initialization Error:\n$e\n\n$stackTrace',
                style: const TextStyle(color: Colors.red, fontFamily: 'Courier'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}