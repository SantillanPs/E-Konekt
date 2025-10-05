// App routing configuration
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  
  // Placeholders for future screens
  static const String marketplace = '/marketplace';
  static const String jobs = '/jobs';
  static const String announcements = '/announcements';
  static const String applications = '/applications';
  
  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    signup: (context) => const SignupScreen(),
    home: (context) => const HomeScreen(),
    // TODO: Add marketplace, jobs, announcements screens
  };
}