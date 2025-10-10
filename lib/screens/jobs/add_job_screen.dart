// Add job screen - form to post new job
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/job_model.dart';
import '../../services/job_service.dart';
import '../../services/auth_service.dart';
import '../../services/business_service.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/primary_button.dart';

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salaryController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedCategory = 'Full-time';
  bool _isLoading = false;

  final List<String> _categories = [
    'Full-time',
    'Part-time',
    'Contract',
    'Freelance',
    'Internship',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final businessService = Provider.of<BusinessService>(context, listen: false);
      final jobService = Provider.of<JobService>(context, listen: false);
      final currentUser = authService.currentUser;

      if (currentUser == null) throw Exception('Not logged in');

      final business = await businessService.getBusinessByOwnerId(currentUser.id);
      if (business == null) throw Exception('Business profile not found');

      final job = JobModel(
        jobId: '',
        businessId: business.businessId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        salary: double.parse(_salaryController.text.trim()),
        category: _selectedCategory,
        location: _locationController.text.trim(),
        businessName: business.name,
        createdAt: DateTime.now(),
      );

      await jobService.createJob(job);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job posted successfully!')),
        );
        Navigator.pop(context, true);
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
      appBar: AppBar(title: const Text('Post Job')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Job Title',
                prefixIcon: Icons.work,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Title is required';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _descriptionController,
                label: 'Job Description',
                prefixIcon: Icons.description,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Description is required';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _salaryController,
                label: 'Salary (₱)',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Salary is required';
                  if (double.tryParse(value) == null) return 'Enter valid salary';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Job Type',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedCategory = value);
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _locationController,
                label: 'Location',
                prefixIcon: Icons.location_on,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Location is required';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              PrimaryButton(
                text: 'Post Job',
                isLoading: _isLoading,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}