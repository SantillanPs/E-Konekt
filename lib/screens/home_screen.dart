// Home screen with navigation for future features
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

import '../models/user_model.dart';
import 'marketplace/marketplace_screen.dart';
import 'jobs/jobs_screen.dart';
import 'announcements/announcements_screen.dart';

import '../theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/category_pill.dart';
import '../widgets/listing_card.dart';
import '../widgets/custom_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await Provider.of<AuthService>(context, listen: false).logout();
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
                _buildProfile(user),
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
          ),
          const SizedBox(height: 24),

          // Category Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                CategoryPill(
                  label: 'Marketplace',
                  isSelected: true,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
                const SizedBox(width: 12),
                CategoryPill(
                  label: 'Announcements',
                  isSelected: false,
                  onTap: () => setState(() => _selectedIndex = 3),
                ),
                const SizedBox(width: 12),
                CategoryPill(
                  label: 'Jobs',
                  isSelected: false,
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Community Announcements Header
          Text('Community Announcements', style: AppTextStyles.titleLarge),
          const SizedBox(height: 16),

          // Announcement Cards (Mock Data)
          ListingCard(
            title: 'Water Interruption Notice',
            subtitle: 'Barangay San Jose • 2h ago',
            location: 'Cebu City',
            onTap: () {},
            actionButton: Text(
              'Scheduled maintenance on May 15, 9 AM - 3 PM. Please store water.',
              style: AppTextStyles.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
          ListingCard(
            title: 'New Opening: 20% off all drinks!',
            subtitle: 'Sulu Coffee • 2h ago',
            location: 'Cebu City',
            imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&q=80&w=500', // Placeholder
            onTap: () {},
          ),
          const SizedBox(height: 16),
           ListingCard(
            title: 'Free Mobile Photography Workshop',
            subtitle: 'Visayas Creatives',
            location: 'Cebu City',
            onTap: () {},
            actionButton: Align(
              alignment: Alignment.centerRight,
              child: CustomButton(
                text: 'Apply Now',
                onPressed: () {},
                type: ButtonType.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile(UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 24),
          Text(user.name, style: AppTextStyles.headlineMedium),
          Text(user.email, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Logout',
            onPressed: _handleLogout,
            type: ButtonType.outline,
            icon: Icons.logout,
          ),
        ],
      ),
    );
  }
}