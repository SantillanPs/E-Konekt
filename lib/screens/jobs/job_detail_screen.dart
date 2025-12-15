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
  bool _isSaved = false; // Mock state

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
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality coming soon')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER CARD
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  widget.job.businessName.isNotEmpty ? widget.job.businessName[0].toUpperCase() : 'C',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.job.title,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.job.businessName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Meta Info Row
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildMetaItem(Icons.location_on_outlined, widget.job.location),
                              const SizedBox(width: 16),
                              _buildMetaItem(Icons.access_time, _formatDate(widget.job.createdAt)),
                              const SizedBox(width: 16),
                              _buildMetaItem(Icons.bookmark_outline, 'Full-time'), // Mock
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildChip(
                              label: widget.job.category,
                              color: const Color(0xFFE3F2FD),
                              textColor: const Color(0xFF1565C0),
                            ),
                            _buildChip(
                              label: _formatSalary(widget.job.salary),
                              color: const Color(0xFFFFF3E0),
                              textColor: const Color(0xFFEF6C00),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () {
                                  setState(() => _isSaved = !_isSaved);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(_isSaved ? 'Job Saved' : 'Job Unsaved'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  _isSaved ? Icons.bookmark : Icons.bookmark_border,
                                  color: _isSaved ? AppColors.primaryBlue : Colors.grey,
                                  size: 20,
                                ),
                                label: Text(
                                  _isSaved ? 'Saved' : 'Save Job',
                                  style: TextStyle(
                                    color: _isSaved ? AppColors.primaryBlue : Colors.grey[700],
                                    fontWeight: _isSaved ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  backgroundColor: _isSaved ? AppColors.primaryBlue.withValues(alpha: 0.1) : Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () {},
                                icon: Icon(Icons.share, color: Colors.grey[700], size: 20),
                                label: Text('Share', style: TextStyle(color: Colors.grey[700])),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),

                  // DESCRIPTION CARD
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About the Role',
                          style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.job.description,
                          style: AppTextStyles.bodyMedium.copyWith(
                            height: 1.6,
                            fontSize: 15,
                            color: AppColors.textDark.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          
          // Bottom Sticky Apply Bar
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _hasApplied || _isLoading ? null : _handleApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasApplied ? Colors.grey : AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text(
                        _hasApplied ? 'Application Submitted' : 'Apply Now',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  String _formatSalary(double salary) {
    if (salary >= 1000) {
      return '₱${(salary / 1000).toStringAsFixed(0)}k /mo';
    }
    return '₱${salary.toStringAsFixed(0)} /mo';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return '1d ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${difference.inDays ~/ 7}w ago';
  }
}
