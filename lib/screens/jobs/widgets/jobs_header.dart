import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class JobsHeader extends StatelessWidget {
  const JobsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
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
          child: const Icon(Icons.work_outline, color: AppColors.primaryBlue, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Careers', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryBlue)),
            Text('Find your path', style: AppTextStyles.bodyMedium.copyWith(fontSize: 10)),
          ],
        ),
      ],
    );
  }
}
