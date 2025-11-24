import 'package:flutter/material.dart';
import '../../../models/job_model.dart';
import '../../../widgets/listing_card.dart';
import '../../../widgets/custom_button.dart';
import '../job_detail_screen.dart';

class JobsList extends StatelessWidget {
  final List<JobModel> jobs;
  final bool isLoading;

  const JobsList({
    super.key,
    required this.jobs,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (jobs.isEmpty) {
      return const Center(child: Text('No jobs available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ListingCard(
            title: job.title,
            subtitle: job.businessName,
            price: 'PHP ${job.salary.toStringAsFixed(0)} / month',
            location: job.location,
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
                  type: ButtonType.secondary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
