// Announcement detail screen - shows full announcement
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/announcement_model.dart';
import '../../services/announcement_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  final AnnouncementModel announcement;

  const AnnouncementDetailScreen({super.key, required this.announcement});

  @override
  State<AnnouncementDetailScreen> createState() => _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  bool _isMarkingRead = false;
  late bool _isRead;

  @override
  void initState() {
    super.initState();
    _isRead = widget.announcement.isRead;
  }

  Future<void> _markAsRead() async {
    setState(() => _isMarkingRead = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final announcementService = Provider.of<AnnouncementService>(context, listen: false);
      
      final currentUser = authService.currentUser;
      if (currentUser != null) {
        await announcementService.markAsRead(currentUser.id, widget.announcement.announcementId);
        setState(() => _isRead = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Marked as read')),
          );
          // Return true to pop to indicate change
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark as read: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isMarkingRead = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData typeIcon;
    List<Color> gradientColors;
    Color typeColor;

    switch (widget.announcement.type.toLowerCase()) {
      case 'barangay':
        typeIcon = Icons.location_city;
        typeColor = Colors.blue;
        gradientColors = [Colors.blue, Colors.blue.shade800];
        break;
      case 'business':
        typeIcon = Icons.store;
        typeColor = Colors.purple;
        gradientColors = [Colors.purple, Colors.purple.shade800];
        break;
      case 'city':
        typeIcon = Icons.location_on;
        typeColor = Colors.orange;
        gradientColors = [Colors.orange, Colors.deepOrange];
        break;
      default:
        typeIcon = Icons.campaign;
        typeColor = Colors.grey;
        gradientColors = [Colors.grey, Colors.blueGrey];
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light grey background
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: gradientColors[0],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(
                        typeIcon,
                        size: 150,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            typeIcon,
                            size: 48,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.announcement.type.toUpperCase(),
                            style: AppTextStyles.titleMedium.copyWith(
                              color: Colors.white,
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Date Section
                  Text(
                    widget.announcement.title,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontSize: 26,
                      height: 1.2,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.label, size: 14, color: typeColor),
                            const SizedBox(width: 6),
                            Text(
                              widget.announcement.type.toUpperCase(),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: typeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 16, color: AppColors.textLight),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(widget.announcement.createdAt),
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Content Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DETAILS',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textLight,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.announcement.content,
                          style: AppTextStyles.bodyMedium.copyWith(
                            height: 1.8,
                            fontSize: 16,
                            color: AppColors.textDark.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.share_outlined),
                          label: const Text('Share'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: AppColors.primaryBlue.withValues(alpha: 0.5)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isRead ? null : _markAsRead, // Disable if already read
                          icon: _isMarkingRead 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Icon(_isRead ? Icons.check_circle : Icons.check, color: Colors.white),
                          label: Text(
                            _isRead ? 'Read' : 'Mark as Read', 
                            style: const TextStyle(color: Colors.white)
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isRead ? Colors.green : AppColors.primaryBlue,
                            disabledBackgroundColor: Colors.green.withValues(alpha: 0.6),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Simple date formatting
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
