import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/business_service.dart';
import '../../marketplace/add_product_screen.dart';
import '../../jobs/add_job_screen.dart';
import '../../profile/create_business_screen.dart';

class QuickActions extends StatefulWidget {
  final VoidCallback onActionComplete;

  const QuickActions({super.key, required this.onActionComplete});

  @override
  State<QuickActions> createState() => _QuickActionsState();
}

class _QuickActionsState extends State<QuickActions> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTextStyles.titleLarge),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.storefront_outlined,
                label: 'Sell Item',
                color: AppColors.primaryBlue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddProductScreen()),
                  ).then((_) => widget.onActionComplete());
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.work_outline,
                label: 'Post Job',
                color: AppColors.accentGold,
                onTap: () async {
                  final authService = Provider.of<AuthService>(context, listen: false);
                  final businessService = Provider.of<BusinessService>(context, listen: false);
                  final currentUser = authService.currentUser;

                  if (currentUser == null) return;

                  setState(() => _isLoading = true);
                  try {
                    // Note: currentUser is Supabase User, so use .id
                    final business = await businessService.getBusinessByOwnerId(currentUser.id);
                    
                    if (!mounted) return;
                    setState(() => _isLoading = false);

                    if (business != null) {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddJobScreen()),
                      );
                      if (result == true) widget.onActionComplete();
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Create Business Profile'),
                          content: const Text('You need to create a business profile before you can post jobs.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const CreateBusinessScreen()),
                                ).then((result) {
                                  if (result == true) {
                                    widget.onActionComplete();
                                  }
                                });
                              },
                              child: const Text('Create Profile'),
                            ),
                          ],
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      setState(() => _isLoading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error checking business profile: $e')),
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: LinearProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.titleMedium.copyWith(color: color, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
