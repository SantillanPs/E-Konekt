// Announcements screen - displays all announcements
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/announcement_model.dart';
import '../../services/announcement_service.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import 'add_announcement_screen.dart';
import 'announcement_detail_screen.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_theme.dart';
import 'widgets/announcement_card.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<AnnouncementModel> _allAnnouncements = [];
  List<AnnouncementModel> _displayedAnnouncements = [];
  bool _isLoading = true;
  bool _canPost = false;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
    _checkPermissions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAnnouncements() async {
    setState(() => _isLoading = true);
    try {
      final announcementService = Provider.of<AnnouncementService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final announcements = await announcementService.getAllAnnouncements();
      
      // Check read status if user is logged in
      final currentUser = authService.currentUser;
      if (currentUser != null) {
        final readIds = await announcementService.getReadAnnouncementIds(currentUser.id);
        for (var announcement in announcements) {
          if (readIds.contains(announcement.announcementId)) {
            announcement.isRead = true;
          }
        }
      }

      setState(() {
        _allAnnouncements = announcements;
        _displayedAnnouncements = announcements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading announcements: $e')),
        );
      }
    }
  }

  Future<void> _checkPermissions() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userService = Provider.of<UserService>(context, listen: false);
    final currentUser = authService.currentUser;

    if (currentUser != null) {
      final userData = await userService.getUserById(currentUser.id);
      if (userData != null) {
        setState(() => _canPost = userData.role == 'admin' || userData.role == 'business');
      }
    }
  }

  void _searchAnnouncements(String query) {
    if (query.isEmpty) {
      _filterAnnouncements(_selectedFilter);
    } else {
      setState(() {
        _displayedAnnouncements = _allAnnouncements
            .where((announcement) => 
                announcement.title.toLowerCase().contains(query.toLowerCase()) ||
                announcement.content.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  void _filterAnnouncements(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'all') {
        _displayedAnnouncements = _allAnnouncements;
      } else {
        _displayedAnnouncements = _allAnnouncements
            .where((announcement) => announcement.type == filter)
            .toList();
      }
    });
  }

  Future<void> _markAllAsRead() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final announcementService = Provider.of<AnnouncementService>(context, listen: false);
      
      final currentUser = authService.currentUser;
      if (currentUser == null) return;

      // Optimistic update
      setState(() {
        for (var announcement in _allAnnouncements) {
          announcement.isRead = true;
        }
      });

      await announcementService.markAllAsRead(currentUser.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All announcements marked as read')),
        );
      }
    } catch (e) {
      _loadAnnouncements(); // Revert on error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
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
                   // Header
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Alerts & News', style: AppTextStyles.headlineMedium.copyWith(fontSize: 24)),
                          Text('Stay updated with your community', style: AppTextStyles.bodyMedium),
                        ],
                      ),
                      const Spacer(),
                      if (_allAnnouncements.isNotEmpty)
                        TextButton(
                          onPressed: _markAllAsRead,
                          child: Text(
                            'Mark all read',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _searchAnnouncements,
                      style: AppTextStyles.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Search for updates...',
                        hintStyle: AppTextStyles.bodyMedium,
                        prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All Updates', 'all'),
                        _buildFilterChip('Barangay', 'barangay'),
                        _buildFilterChip('Business', 'business'),
                        _buildFilterChip('City', 'city'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _displayedAnnouncements.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.feed_outlined, size: 64, color: AppColors.textLight.withValues(alpha: 0.3)),
                              const SizedBox(height: 16),
                              Text('No announcements found', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textLight)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          itemCount: _displayedAnnouncements.length,
                          itemBuilder: (context, index) {
                            final announcement = _displayedAnnouncements[index];
                            return AnnouncementCard(
                              announcement: announcement,
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AnnouncementDetailScreen(announcement: announcement),
                                  ),
                                );
                                if (result == true) {
                                  _loadAnnouncements();
                                }
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: _canPost
          ? FloatingActionButton.extended(
              heroTag: 'announcement_fab',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddAnnouncementScreen()),
                );
                if (result == true) _loadAnnouncements();
              },
              backgroundColor: AppColors.primaryBlue,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Post Update'),
            )
          : null,
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textDark,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) => _filterAnnouncements(value),
        backgroundColor: Colors.transparent,
        selectedColor: AppColors.primaryBlue,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.transparent : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
      ),
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
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}