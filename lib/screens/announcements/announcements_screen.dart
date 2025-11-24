// Announcements screen - displays all announcements
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/announcement_model.dart';
import '../../services/announcement_service.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import 'add_announcement_screen.dart';
import 'announcement_detail_screen.dart';

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
      appBar: AppBar(
        title: const Text('Announcements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnnouncements,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search announcements...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: _searchAnnouncements,
                ),
                const SizedBox(height: 12),
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
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _displayedAnnouncements.isEmpty
                    ? const Center(child: Text('No announcements'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _displayedAnnouncements.length,
                        itemBuilder: (context, index) {
                          final announcement = _displayedAnnouncements[index];
                          return _buildAnnouncementCard(announcement);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: _canPost
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddAnnouncementScreen()),
                );
                if (result == true) _loadAnnouncements();
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) => _filterAnnouncements(value),
      ),
    );
  }

  Widget _buildAnnouncementCard(AnnouncementModel announcement) {
    Color typeColor;
    IconData typeIcon;
    
    switch (announcement.type) {
      case 'barangay':
        typeColor = Colors.blue;
        typeIcon = Icons.location_city;
        break;
      case 'business':
        typeColor = Colors.purple;
        typeIcon = Icons.business;
        break;
      case 'city':
        typeColor = Colors.orange;
        typeIcon = Icons.location_on;
        break;
      default:
        typeColor = Colors.grey;
        typeIcon = Icons.announcement;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnnouncementDetailScreen(announcement: announcement),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(typeIcon, size: 16, color: typeColor),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      announcement.type.toUpperCase(),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: typeColor),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(announcement.createdAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                announcement.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                announcement.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Posted by: ${announcement.postedBy}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
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