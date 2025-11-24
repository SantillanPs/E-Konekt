// Home screen with navigation for future features
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

import '../models/user_model.dart';
import 'marketplace/marketplace_screen.dart';
import 'jobs/jobs_screen.dart';
import 'announcements/announcements_screen.dart';
import 'announcements/announcement_detail_screen.dart';
import 'profile/profile_screen.dart';
import '../models/announcement_model.dart';
import '../models/product_model.dart';
import '../models/job_model.dart';
import '../services/announcement_service.dart';
import '../services/product_service.dart';
import '../services/job_service.dart';
import 'marketplace/add_product_screen.dart';
import 'jobs/add_job_screen.dart';
import 'marketplace/product_detail_screen.dart';
import 'jobs/job_detail_screen.dart';

import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/listing_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<AnnouncementModel> _announcements = [];
  List<ProductModel> _recentProducts = [];
  List<JobModel> _recentJobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    setState(() => _isLoading = true);
    try {
      final announcementService = Provider.of<AnnouncementService>(context, listen: false);
      final productService = Provider.of<ProductService>(context, listen: false);
      final jobService = Provider.of<JobService>(context, listen: false);

      final results = await Future.wait([
        announcementService.getAllAnnouncements(),
        productService.getProducts(),
        jobService.getAllJobs(),
      ]);

      if (mounted) {
        setState(() {
          _announcements = results[0] as List<AnnouncementModel>;
          _recentProducts = (results[1] as List<ProductModel>).take(5).toList();
          _recentJobs = (results[2] as List<JobModel>).take(5).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userService = Provider.of<UserService>(context, listen: false);
    final currentUser = authService.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      body: StreamBuilder<UserModel?>(
        stream: userService.getUserStream(currentUser.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('User data not found'));
          }

          return SafeArea(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildHome(user),
                const MarketplaceScreen(),
                const JobsScreen(),
                const AnnouncementsScreen(),
                ProfileScreen(user: user),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: AppColors.textLight,
          showUnselectedLabels: true,
          elevation: 0,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.store_outlined), activeIcon: Icon(Icons.store), label: 'Marketplace'),
            BottomNavigationBarItem(icon: Icon(Icons.work_outline), activeIcon: Icon(Icons.work), label: 'Jobs'),
            BottomNavigationBarItem(icon: Icon(Icons.campaign_outlined), activeIcon: Icon(Icons.campaign), label: 'Alerts'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildHome(UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Logo placeholder or Icon
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
                    child: const Icon(Icons.connect_without_contact, color: AppColors.primaryBlue, size: 32),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('E-Konekt', style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryBlue)),
                      Text('Connect. Uplift. Thrive', style: AppTextStyles.bodyMedium.copyWith(fontSize: 12)),
                    ],
                  ),
                ],
              ),
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.inputBackground,
                child: Text(user.name[0].toUpperCase(), style: AppTextStyles.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Search Bar
          CustomTextField(
            hintText: 'Search jobs...',
            prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
            suffixIcon: const Icon(Icons.tune, color: AppColors.primaryBlue),
            readOnly: true,
            onTap: () => setState(() => _selectedIndex = 2),
          ),
          const SizedBox(height: 32),

          // Quick Actions
          Text('Quick Actions', style: AppTextStyles.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.store,
                  label: 'Sell Item',
                  color: AppColors.primaryBlue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddProductScreen()),
                    ).then((_) => _loadHomeData());
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.work,
                  label: 'Post Job',
                  color: AppColors.accentGold,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddJobScreen()),
                    ).then((_) => _loadHomeData());
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Recent Marketplace Items
          if (_recentProducts.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Items', style: AppTextStyles.titleLarge),
                TextButton(
                  onPressed: () => setState(() => _selectedIndex = 1),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _recentProducts.length,
                itemBuilder: (context, index) {
                  final product = _recentProducts[index];
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 16),
                    child: ListingCard(
                      title: product.name,
                      subtitle: 'PHP ${product.price.toStringAsFixed(0)}',
                      location: product.location,
                      imageUrl: product.imageUrl,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(product: product),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Recent Jobs
          if (_recentJobs.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Jobs', style: AppTextStyles.titleLarge),
                TextButton(
                  onPressed: () => setState(() => _selectedIndex = 2),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _recentJobs.length,
                itemBuilder: (context, index) {
                  final job = _recentJobs[index];
                  return Container(
                    width: 280,
                    margin: const EdgeInsets.only(right: 16),
                    child: ListingCard(
                      title: job.title,
                      subtitle: job.businessName,
                      location: job.location,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobDetailScreen(job: job),
                          ),
                        );
                      },
                      actionButton: Text(
                        'PHP ${job.salary.toStringAsFixed(0)}/mo',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],

          // Community Announcements Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Community Announcements', style: AppTextStyles.titleLarge),
              TextButton(
                onPressed: () => setState(() => _selectedIndex = 3),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Announcement Cards
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _announcements.isEmpty
                  ? const Center(child: Text('No announcements yet'))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _announcements.take(3).length,
                      itemBuilder: (context, index) {
                        final announcement = _announcements[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ListingCard(
                            title: announcement.title,
                            subtitle: '${announcement.postedBy} • ${_formatDate(announcement.createdAt)}',
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
        ],
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
      return '${date.day}/${date.month}';
    }
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