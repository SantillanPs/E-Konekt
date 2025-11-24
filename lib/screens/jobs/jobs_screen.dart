// Jobs screen - displays all job listings
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/job_model.dart';
import '../../services/job_service.dart';
import '../../services/auth_service.dart';
import '../../services/business_service.dart';
import 'add_job_screen.dart';
import 'job_detail_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/custom_button.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<JobModel> _allJobs = [];
  List<JobModel> _displayedJobs = [];
  bool _isLoading = true;
  bool _hasBusinessProfile = false;

  @override
  void initState() {
    super.initState();
    _loadJobs();
    _checkBusinessProfile();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    setState(() => _isLoading = true);
    try {
      final jobService = Provider.of<JobService>(context, listen: false);
      final jobs = await jobService.getAllJobs();
      setState(() {
        _allJobs = jobs;
        _displayedJobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading jobs: $e')),
        );
      }
    }
  }

  Future<void> _checkBusinessProfile() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final businessService = Provider.of<BusinessService>(context, listen: false);
    final currentUser = authService.currentUser;

    if (currentUser != null) {
      final business = await businessService.getBusinessByOwnerId(currentUser.id);
      setState(() => _hasBusinessProfile = business != null);
    }
  }

  void _searchJobs(String query) {
    if (query.isEmpty) {
      setState(() => _displayedJobs = _allJobs);
    } else {
      setState(() {
        _displayedJobs = _allJobs
            .where((job) => job.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.connect_without_contact, color: AppColors.primaryBlue, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('E-Konekt', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryBlue)),
                          Text('Connect. Uplift. Thrive', style: AppTextStyles.bodyMedium.copyWith(fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Search Bar
                  CustomTextField(
                    controller: _searchController,
                    hintText: 'Search jobs...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                    suffixIcon: const Icon(Icons.add_box_outlined, color: AppColors.primaryBlue), // Mocking the + icon in search bar from design
                    onChanged: _searchJobs, // CustomTextField needs to support this or use controller listener
                  ),
                  const SizedBox(height: 24),

                  Text('Job Board', style: AppTextStyles.titleLarge),
                ],
              ),
            ),
            
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _displayedJobs.isEmpty
                      ? const Center(child: Text('No jobs available'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          itemCount: _displayedJobs.length,
                          itemBuilder: (context, index) {
                            final job = _displayedJobs[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: ListingCard(
                                title: job.title,
                                subtitle: job.businessName,
                                price: 'PHP ${job.salary.toStringAsFixed(0)} / month', // Format as per design
                                location: job.location, // Assuming job has location or use business location
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => JobDetailScreen(job: job),
                                    ),
                                  );
                                },
                                actionButton: Align(
                                  alignment: Alignment.centerRight,
                                  child: SizedBox(
                                    height: 36,
                                    child: CustomButton(
                                      text: 'Apply Now',
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Application Sent'),
                                            content: Text('Your application for ${job.title} at ${job.businessName} has been sent!'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      type: ButtonType.secondary, // Blue button
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: _hasBusinessProfile
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddJobScreen()),
                );
                if (result == true) _loadJobs();
              },
              backgroundColor: AppColors.accentGold,
              child: const Icon(Icons.add, color: AppColors.textDark),
            )
          : null,
    );
  }
}