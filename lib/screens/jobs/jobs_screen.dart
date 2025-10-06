// Jobs screen - displays all job listings
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/job_model.dart';
import '../../services/job_service.dart';
import '../../services/auth_service.dart';
import '../../services/business_service.dart';
import 'add_job_screen.dart';
import 'job_detail_screen.dart';

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
      appBar: AppBar(
        title: const Text('Jobs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadJobs,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search jobs...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: _searchJobs,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _displayedJobs.isEmpty
                    ? const Center(child: Text('No jobs available'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _displayedJobs.length,
                        itemBuilder: (context, index) {
                          final job = _displayedJobs[index];
                          return _buildJobCard(job);
                        },
                      ),
          ),
        ],
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
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildJobCard(JobModel job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailScreen(job: job),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                job.businessName,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.attach_money, size: 16, color: Colors.green),
                  Text(
                    '₱${job.salary.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  Expanded(
                    child: Text(
                      job.location,
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  job.category,
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}