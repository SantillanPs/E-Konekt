import 'package:flutter/material.dart';
import '../../../../models/job_model.dart';
import '../../../../theme/app_theme.dart';

class CompensationCard extends StatelessWidget {
  final JobModel job;

  const CompensationCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            '₱${job.salary.toStringAsFixed(0)}',
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
    );
  }
}
