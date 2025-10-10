// Announcement service - handles announcement CRUD operations
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/announcement_model.dart';

class AnnouncementService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Create announcement
  Future<void> createAnnouncement(AnnouncementModel announcement) async {
    try {
      await _supabase.from('announcements').insert(announcement.toJson());
    } catch (e) {
      throw Exception('Failed to create announcement: $e');
    }
  }

  // Get all announcements
  Future<List<AnnouncementModel>> getAllAnnouncements() async {
    try {
      final data = await _supabase
          .from('announcements')
          .select()
          .order('created_at', ascending: false);

      return data.map((json) => AnnouncementModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get announcements: $e');
    }
  }

  // Get announcements stream (real-time)
  Stream<List<AnnouncementModel>> getAnnouncementsStream() {
    return _supabase
        .from('announcements')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => AnnouncementModel.fromJson(json)).toList());
  }

  // Get announcement by ID
  Future<AnnouncementModel?> getAnnouncementById(String announcementId) async {
    try {
      final data = await _supabase
          .from('announcements')
          .select()
          .eq('id', announcementId)
          .single();

      return AnnouncementModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  // Get announcements by type
  Future<List<AnnouncementModel>> getAnnouncementsByType(String type) async {
    try {
      final data = await _supabase
          .from('announcements')
          .select()
          .eq('type', type)
          .order('created_at', ascending: false);

      return data.map((json) => AnnouncementModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get announcements: $e');
    }
  }

  // Search announcements
  Future<List<AnnouncementModel>> searchAnnouncements(String query) async {
    try {
      final data = await _supabase
          .from('announcements')
          .select()
          .ilike('title', '%$query%')
          .order('created_at', ascending: false);

      return data.map((json) => AnnouncementModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search announcements: $e');
    }
  }

  // Delete announcement
  Future<void> deleteAnnouncement(String announcementId) async {
    try {
      await _supabase
          .from('announcements')
          .delete()
          .eq('id', announcementId);
    } catch (e) {
      throw Exception('Failed to delete announcement: $e');
    }
  }

  // Update announcement
  Future<void> updateAnnouncement(String announcementId, Map<String, dynamic> data) async {
    try {
      await _supabase
          .from('announcements')
          .update(data)
          .eq('id', announcementId);
    } catch (e) {
      throw Exception('Failed to update announcement: $e');
    }
  }
}