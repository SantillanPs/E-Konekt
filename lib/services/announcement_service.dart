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

  // Mark announcement as read
  Future<void> markAsRead(String userId, String announcementId) async {
    try {
      await _supabase.from('announcement_reads').upsert({
        'user_id': userId,
        'announcement_id': announcementId,
        'read_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,announcement_id');
    } catch (e) {
      throw Exception('Failed to mark announcement as read: $e');
    }
  }

  // Get read announcement IDs for a user
  Future<List<String>> getReadAnnouncementIds(String userId) async {
    try {
      final data = await _supabase
          .from('announcement_reads')
          .select('announcement_id')
          .eq('user_id', userId);

      return (data as List).map((e) => e['announcement_id'] as String).toList();
    } catch (e) {
      return []; // Return empty list on error
    }
  }

  // Mark all announcements as read
  Future<void> markAllAsRead(String userId) async {
    try {
      await _supabase.rpc('mark_all_announcements_read', params: {
        'target_user_id': userId,
      });
    } catch (e) {
      throw Exception('Failed to mark all announcements as read: $e');
    }
  }
}