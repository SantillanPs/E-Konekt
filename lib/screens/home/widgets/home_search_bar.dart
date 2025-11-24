import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/custom_text_field.dart';

class HomeSearchBar extends StatelessWidget {
  final VoidCallback onTap;

  const HomeSearchBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: CustomTextField(
        hintText: 'What are you looking for?',
        prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
        suffixIcon: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.tune, color: AppColors.primaryBlue, size: 20),
        ),
        readOnly: true,
        onTap: onTap,
      ),
    );
  }
}
