// Job service - handles job CRUD operations
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/job_model.dart';
import '../models/application_model.dart';

class JobService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Create job
  Future<void> createJob(JobModel job) async {
    try {
      await _supabase.from('jobs').insert(job.toJson());
    } catch (e) {
      throw Exception('Failed to create job: $e');
    }
  }

  // Get all jobs
  Future<List<JobModel>> getAllJobs() async {
    try {
      final data = await _supabase
          .from('jobs')
          .select()
          .order('created_at', ascending: false);

      return data.map((json) => JobModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get jobs: $e');
    }
  }

  // Get job by ID
  Future<JobModel?> getJobById(String jobId) async {
    try {
      final data = await _supabase
          .from('jobs')
          .select()
          .eq('id', jobId)
          .single();

      return JobModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  // Get jobs by business
  Future<List<JobModel>> getJobsByBusiness(String businessId) async {
    try {
      final data = await _supabase
          .from('jobs')
          .select()
          .eq('business_id', businessId)
          .order('created_at', ascending: false);

      return data.map((json) => JobModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get jobs: $e');
    }
  }

  // Search jobs
  Future<List<JobModel>> searchJobs(String query) async {
    try {
      final data = await _supabase
          .from('jobs')
          .select()
          .ilike('title', '%$query%')
          .order('created_at', ascending: false);

      return data.map((json) => JobModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search jobs: $e');
    }
  }

  // Apply for job
  Future<void> applyForJob(ApplicationModel application) async {
    try {
      await _supabase.from('applications').insert(application.toJson());
    } catch (e) {
      throw Exception('Failed to apply: $e');
    }
  }

  // Check if user already applied
  Future<bool> hasUserApplied(String jobId, String userId) async {
    try {
      final data = await _supabase
          .from('applications')
          .select()
          .eq('job_id', jobId)
          .eq('user_id', userId);

      return data.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get applications for a job
  Future<List<ApplicationModel>> getJobApplications(String jobId) async {
    try {
      final data = await _supabase
          .from('applications')
          .select()
          .eq('job_id', jobId)
          .order('applied_at', ascending: false);

      return data.map((json) => ApplicationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get applications: $e');
    }
  }

  // Get user applications
  Future<List<ApplicationModel>> getUserApplications(String userId) async {
    try {
      final data = await _supabase
          .from('applications')
          .select()
          .eq('user_id', userId)
          .order('applied_at', ascending: false);

      return data.map((json) => ApplicationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get applications: $e');
    }
  }

  // Delete job
  Future<void> deleteJob(String jobId) async {
    try {
      await _supabase
          .from('jobs')
          .delete()
          .eq('id', jobId);
    } catch (e) {
      throw Exception('Failed to delete job: $e');
    }
  }
}