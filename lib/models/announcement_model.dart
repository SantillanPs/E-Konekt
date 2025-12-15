// Announcement data model
class AnnouncementModel {
  final String announcementId;
  final String postedBy;
  final String title;
  final String content;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? location;
  final String? locationId;
  bool isRead;

  AnnouncementModel({
    required this.announcementId,
    required this.postedBy,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.location,
    this.locationId,
    this.isRead = false,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      announcementId: json['id']?.toString() ?? '',
      postedBy: json['posted_by'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'barangay',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      location: json['location'],
      locationId: json['location_id']?.toString(),
      isRead: false, // Default to false, populated separately
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'posted_by': postedBy,
      'title': title,
      'content': content,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'location': location,
      'location_id': locationId,
    };
  }
}