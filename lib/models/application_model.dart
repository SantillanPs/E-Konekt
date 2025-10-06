// Job application data model
class ApplicationModel {
  final String applicationId;
  final String jobId;
  final String userId;
  final String userName;
  final String userEmail;
  final String status;
  final DateTime appliedAt;

  ApplicationModel({
    required this.applicationId,
    required this.jobId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.status,
    required this.appliedAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      applicationId: json['id']?.toString() ?? '',
      jobId: json['job_id']?.toString() ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      userEmail: json['user_email'] ?? '',
      status: json['status'] ?? 'pending',
      appliedAt: json['applied_at'] != null
          ? DateTime.parse(json['applied_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_id': jobId,
      'user_id': userId,
      'user_name': userName,
      'user_email': userEmail,
      'status': status,
      'applied_at': appliedAt.toIso8601String(),
    };
  }
}