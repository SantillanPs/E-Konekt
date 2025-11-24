import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../models/announcement_model.dart';
import '../../../../widgets/listing_card.dart';
import '../../announcements/announcement_detail_screen.dart';

class CommunityUpdates extends StatelessWidget {
  final List<AnnouncementModel> announcements;
  final bool isLoading;
  final VoidCallback onViewAll;

  const CommunityUpdates({
    super.key,
    required this.announcements,
    required this.isLoading,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Community Updates', style: AppTextStyles.titleLarge),
            TextButton(
              onPressed: onViewAll,
              child: Text('View All', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryBlue)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : announcements.isEmpty
                ? const Center(child: Text('No announcements yet'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: announcements.take(3).length,
                    itemBuilder: (context, index) {
                      final announcement = announcements[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ListingCard(
                          title: announcement.title,
                          subtitle: _formatDate(announcement.createdAt),
                          location: announcement.type.toUpperCase(),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AnnouncementDetailScreen(announcement: announcement),
                              ),
                            );
                          },
                          actionButton: Text(
                            announcement.content,
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textLight),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
