// Centralized Firebase service instances
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static FirebaseAuth? _auth;
  static FirebaseFirestore? _firestore;
  static FirebaseStorage? _storage;

  // Initialize all Firebase services
  static void initialize() {
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    _storage = FirebaseStorage.instance;
  }

  // Getters for Firebase instances
  static FirebaseAuth get auth {
    if (_auth == null) {
      throw Exception('FirebaseAuth not initialized. Call initialize() first.');
    }
    return _auth!;
  }

  static FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('Firestore not initialized. Call initialize() first.');
    }
    return _firestore!;
  }

  static FirebaseStorage get storage {
    if (_storage == null) {
      throw Exception('FirebaseStorage not initialized. Call initialize() first.');
    }
    return _storage!;
  }

  // Collection references for easy access
  static CollectionReference get usersCollection =>
      firestore.collection('users');
  
  static CollectionReference get businessesCollection =>
      firestore.collection('businesses');
  
  static CollectionReference get announcementsCollection =>
      firestore.collection('announcements');
  
  static CollectionReference get applicationsCollection =>
      firestore.collection('applications');
}