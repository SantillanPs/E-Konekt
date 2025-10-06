// Job detail screen - shows full job information and apply button
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/job_model.dart';
import '../../models/application_model.dart';
import '../../services/job_service.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';

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
      appBar: AppBar(title: const Text('Job Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.job.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.job.businessName,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.attach_money, color: Colors.green, size: 32),
                  const SizedBox(width: 8),
                  Text(
                    '₱${widget.job.salary.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.category, 'Job Type', widget.job.category),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, 'Location', widget.job.location),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today, 'Posted', _formatDate(widget.job.createdAt)),
            const SizedBox(height: 24),
            const Text(
              'Job Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.job.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _hasApplied || _isLoading ? null : _handleApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasApplied ? Colors.grey : Colors.blue,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(_hasApplied ? 'Already Applied' : 'Apply Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}