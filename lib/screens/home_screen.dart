// Home screen with navigation for future features
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

import '../models/user_model.dart';
import 'marketplace/marketplace_screen.dart';
import 'jobs/jobs_screen.dart';
import 'announcements/announcements_screen.dart';
import 'profile/profile_screen.dart';
import '../models/announcement_model.dart';
import '../models/product_model.dart';
import '../models/job_model.dart';
import '../services/announcement_service.dart';
import '../services/product_service.dart';
import '../services/job_service.dart';

import '../theme/app_theme.dart';
import 'home/widgets/home_header.dart';
import 'home/widgets/home_search_bar.dart';
import 'home/widgets/quick_actions.dart';
import 'home/widgets/recent_marketplace_list.dart';
import 'home/widgets/recent_jobs_list.dart';
import 'home/widgets/community_updates.dart';

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
          HomeHeader(user: user),
          const SizedBox(height: 28),

          // Search Bar
          HomeSearchBar(onTap: () => setState(() => _selectedIndex = 1)),
          const SizedBox(height: 32),

          // Quick Actions
          QuickActions(onActionComplete: _loadHomeData),
          const SizedBox(height: 32),

          // Recent Marketplace Items
          RecentMarketplaceList(
            products: _recentProducts,
            onViewAll: () => setState(() => _selectedIndex = 1),
          ),

          // Recent Jobs
          RecentJobsList(
            jobs: _recentJobs,
            onViewAll: () => setState(() => _selectedIndex = 2),
          ),

          // Community Announcements
          CommunityUpdates(
            announcements: _announcements,
            isLoading: _isLoading,
            onViewAll: () => setState(() => _selectedIndex = 3),
          ),
        ],
      ),
    );
  }
}