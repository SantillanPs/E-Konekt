import 'package:flutter/material.dart';
import '../../../../models/job_model.dart';
import '../../../../theme/app_theme.dart';

class JobDescription extends StatelessWidget {
  final JobModel job;

  const JobDescription({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            job.description,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.6, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
