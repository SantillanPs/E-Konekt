// Job detail screen - shows full job information and apply button
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/job_model.dart';
import '../../models/application_model.dart';
import '../../services/job_service.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';
import 'widgets/job_detail_header.dart';
import 'widgets/compensation_card.dart';
import 'widgets/job_info_grid.dart';
import 'widgets/job_description.dart';

class JobDetailScreen extends StatefulWidget {
  final JobModel job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isLoading = false;
  bool _hasApplied = false;

  @override
  void initState() {
    super.initState();
    _checkApplicationStatus();
  }

  Future<void> _checkApplicationStatus() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final jobService = Provider.of<JobService>(context, listen: false);
    final currentUser = authService.currentUser;

    if (currentUser != null) {
      final applied = await jobService.hasUserApplied(widget.job.jobId, currentUser.id);
      setState(() => _hasApplied = applied);
    }
  }

  Future<void> _handleApply() async {
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userService = Provider.of<UserService>(context, listen: false);
      final jobService = Provider.of<JobService>(context, listen: false);
      final currentUser = authService.currentUser;

      if (currentUser == null) throw Exception('Please login to apply');

      final userData = await userService.getUserById(currentUser.id);
      if (userData == null) throw Exception('User data not found');

      final application = ApplicationModel(
        applicationId: '',
        jobId: widget.job.jobId,
        userId: currentUser.id,
        userName: userData.name,
        userEmail: userData.email,
        status: 'pending',
        appliedAt: DateTime.now(),
      );

      await jobService.applyForJob(application);

      setState(() => _hasApplied = true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          JobDetailHeader(job: widget.job),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.job.title,
                    style: AppTextStyles.titleLarge.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 24),

                  // Compensation Card
                  CompensationCard(job: widget.job),
                  const SizedBox(height: 24),

                  // Job Details Grid
                  JobInfoGrid(job: widget.job),
                  const SizedBox(height: 24),

                  // Description
                  JobDescription(job: widget.job),
                  const SizedBox(height: 100), // Spacing for floating button
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _hasApplied || _isLoading ? null : _handleApply,
            style: ElevatedButton.styleFrom(
              backgroundColor: _hasApplied ? Colors.grey : AppColors.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: AppColors.primaryBlue.withValues(alpha: 0.4),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : Text(
                    _hasApplied ? 'ALREADY APPLIED' : 'APPLY NOW',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}