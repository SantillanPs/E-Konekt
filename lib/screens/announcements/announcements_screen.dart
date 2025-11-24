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
import '../../widgets/custom_text_field.dart';
import '../../widgets/listing_card.dart';

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
      final announcements = await announcementService.getAllAnnouncements();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Header
                  Row(
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
                        child: const Icon(Icons.campaign, color: AppColors.primaryBlue, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Alerts', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryBlue)),
                          Text('Stay updated', style: AppTextStyles.bodyMedium.copyWith(fontSize: 10)),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: AppColors.primaryBlue),
                        onPressed: _loadAnnouncements,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Search Bar
                  CustomTextField(
                    controller: _searchController,
                    hintText: 'Search alerts...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                    onChanged: _searchAnnouncements,
                  ),
                  const SizedBox(height: 24),

                  // Filters
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all'),
                        _buildFilterChip('Barangay', 'barangay'),
                        _buildFilterChip('Business', 'business'),
                        _buildFilterChip('City', 'city'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _displayedAnnouncements.isEmpty
                      ? const Center(child: Text('No announcements'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          itemCount: _displayedAnnouncements.length,
                          itemBuilder: (context, index) {
                            final announcement = _displayedAnnouncements[index];
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
                                  style: AppTextStyles.bodyMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: _canPost
          ? FloatingActionButton(
              heroTag: 'announcement_fab',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddAnnouncementScreen()),
                );
                if (result == true) _loadAnnouncements();
              },
              backgroundColor: AppColors.accentGold,
              child: const Icon(Icons.add, color: AppColors.textDark),
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
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) => _filterAnnouncements(value),
        backgroundColor: Colors.white,
        selectedColor: AppColors.primaryBlue,
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.transparent : AppColors.textLight.withValues(alpha: 0.3),
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