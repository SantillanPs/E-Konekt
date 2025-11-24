import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../models/job_model.dart';
import '../../../../widgets/listing_card.dart';
import '../../jobs/job_detail_screen.dart';

class RecentJobsList extends StatelessWidget {
  final List<JobModel> jobs;
  final VoidCallback onViewAll;

  const RecentJobsList({
    super.key,
    required this.jobs,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Latest Jobs', style: AppTextStyles.titleLarge),
            TextButton(
              onPressed: onViewAll,
              child: Text('View All', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryBlue)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16, bottom: 8),
                child: ListingCard(
                  title: job.title,
                  subtitle: job.businessName,
                  location: job.location,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobDetailScreen(job: job),
                      ),
                    );
                  },
                  actionButton: Text(
                    '₱${job.salary.toStringAsFixed(0)}/mo',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
