// Jobs screen - displays all job listings
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/job_model.dart';
import '../../services/job_service.dart';
import '../../services/auth_service.dart';
import '../../services/business_service.dart';
import 'add_job_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../profile/create_business_screen.dart';
import 'widgets/jobs_header.dart';
import 'widgets/jobs_list.dart';

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

  @override
  void initState() {
    super.initState();
    _loadJobs();
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
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading jobs: $e')),
        );
      }
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
                  const JobsHeader(),
                  const SizedBox(height: 24),

                  // Search Bar
                  CustomTextField(
                    controller: _searchController,
                    hintText: 'Search jobs...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                    onChanged: _searchJobs,
                  ),
                  const SizedBox(height: 24),

                  // Section Title
                  Text('Latest Opportunities', style: AppTextStyles.titleLarge),
                ],
              ),
            ),
            
            Expanded(
              child: JobsList(
                jobs: _displayedJobs,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'jobs_fab',
        onPressed: () async {
          final authService = Provider.of<AuthService>(context, listen: false);
          final businessService = Provider.of<BusinessService>(context, listen: false);
          final currentUser = authService.currentUser;

          if (currentUser == null) return;

          setState(() => _isLoading = true);
          try {
            // Note: currentUser is Supabase User, so use .id
            final business = await businessService.getBusinessByOwnerId(currentUser.id);
            
            if (!mounted) return;
            setState(() => _isLoading = false);

            if (business != null) {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddJobScreen()),
              );
              if (!mounted) return;
              if (result == true) _loadJobs();
            } else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Create Business Profile'),
                  content: const Text('You need to create a business profile before you can post jobs.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CreateBusinessScreen()),
                        ).then((result) {
                          if (result == true) {
                            _loadJobs();
                          }
                        });
                      },
                      child: const Text('Create Profile'),
                    ),
                  ],
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error checking business profile: $e')),
              );
            }
          }
        },
        backgroundColor: AppColors.accentGold,
        child: const Icon(Icons.add, color: AppColors.textDark),
      ),
    );
  }
}