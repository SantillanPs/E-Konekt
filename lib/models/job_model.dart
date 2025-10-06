// Job data model
class JobModel {
  final String jobId;
  final String businessId;
  final String title;
  final String description;
  final double salary;
  final String category;
  final String location;
  final String businessName;
  final DateTime createdAt;

  JobModel({
    required this.jobId,
    required this.businessId,
    required this.title,
    required this.description,
    required this.salary,
    required this.category,
    required this.location,
    required this.businessName,
    required this.createdAt,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      jobId: json['id']?.toString() ?? '',
      businessId: json['business_id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      salary: (json['salary'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      location: json['location'] ?? '',
      businessName: json['business_name'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_id': businessId,
      'title': title,
      'description': description,
      'salary': salary,
      'category': category,
      'location': location,
      'business_name': businessName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}