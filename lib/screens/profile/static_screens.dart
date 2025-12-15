import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How can we help you?', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),
            const Text(
              'If you are experiencing issues or have questions, please contact our support team.',
              style: TextStyle(fontSize: 16, height: 1.5, color: AppColors.textDark),
            ),
            const SizedBox(height: 32),
            _buildSupportItem(
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'support@ekonekt.com',
            ),
            const SizedBox(height: 16),
            _buildSupportItem(
              icon: Icons.phone_outlined,
              title: 'Phone Support',
              subtitle: '+63 900 000 0000',
            ),
            const SizedBox(height: 16),
            _buildSupportItem(
              icon: Icons.chat_bubble_outline,
              title: 'Live Chat',
              subtitle: 'Available Mon-Fri, 9AM-6PM',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportItem({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.titleMedium.copyWith(fontSize: 16)),
              Text(subtitle, style: AppTextStyles.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Privacy Policy', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text('Last updated: December 15, 2025', style: AppTextStyles.bodySmall),
            const SizedBox(height: 24),
            _buildSection(
              title: '1. Information We Collect',
              content: 'We collect information you provide directly to us, such as when you create an account, update your profile, or communicate with us.',
            ),
            _buildSection(
              title: '2. How We Use Information',
              content: 'We use the information we collect to provide, maintain, and improve our services, processing transactions, and sending you related information.',
            ),
            _buildSection(
              title: '3. Information Sharing',
              content: 'We do not share your personal information with third parties except as described in this privacy policy or with your consent.',
            ),
            _buildSection(
              title: '4. Security',
              content: 'We take reasonable measures to help protect information about you from loss, theft, misuse and unauthorized access.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.textLight),
          ),
        ],
      ),
    );
  }
}
