import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../models/user_model.dart';

class HomeHeader extends StatelessWidget {
  final UserModel user;

  const HomeHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.connect_without_contact, color: AppColors.primaryBlue, size: 28),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('E-Konekt', style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                Text('Connect. Uplift. Thrive', style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, color: AppColors.textLight)),
              ],
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2), width: 2),
          ),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.inputBackground,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryBlue),
            ),
          ),
        ),
      ],
    );
  }
}
