// Job detail screen - shows full job information and apply button
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/job_model.dart';
import '../../models/application_model.dart';
import '../../services/job_service.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';

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
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.teal,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.teal, Colors.teal.shade800],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      bottom: -30,
                      child: Icon(
                        Icons.work_outline,
                        size: 200,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.business_center,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.job.businessName.toUpperCase(),
                            style: AppTextStyles.titleMedium.copyWith(
                              color: Colors.white,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.accentGold, AppColors.accentGold.withValues(alpha: 0.8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentGold.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'COMPENSATION',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textDark.withValues(alpha: 0.7),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₱${widget.job.salary.toStringAsFixed(0)}',
                          style: AppTextStyles.titleLarge.copyWith(
                            fontSize: 32,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          'per month',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textDark.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Job Details Grid
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(Icons.category_outlined, 'Job Type', widget.job.category),
                        const Divider(height: 24),
                        _buildDetailRow(Icons.location_on_outlined, 'Location', widget.job.location),
                        const Divider(height: 24),
                        _buildDetailRow(Icons.calendar_today_outlined, 'Posted', _formatDate(widget.job.createdAt)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Job Description',
                    style: AppTextStyles.titleMedium.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.job.description,
                      style: AppTextStyles.bodyMedium.copyWith(height: 1.6, fontSize: 16),
                    ),
                  ),
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.primaryBlue),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
            ),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}