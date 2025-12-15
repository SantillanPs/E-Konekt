import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../models/job_model.dart';
import '../../services/auth_service.dart';
import '../../services/product_service.dart';
import '../../services/job_service.dart';
import '../../services/business_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_card.dart';
import '../../widgets/listing_card.dart';
import '../marketplace/product_detail_screen.dart';
import '../jobs/job_detail_screen.dart';
import '../marketplace/add_product_screen.dart';
import '../jobs/add_job_screen.dart';
import 'create_business_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<ProductModel> _myProducts = [];
  List<JobModel> _myJobs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // Rebuild to update FAB label
      }
    });
    _loadListings();
  }

  @override
  void dispose() {
    _tabController.removeListener(() {}); // Cleanup not strictly necessary but good practice
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadListings() async {
    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final productService = Provider.of<ProductService>(context, listen: false);
      final jobService = Provider.of<JobService>(context, listen: false);
      final businessService = Provider.of<BusinessService>(context, listen: false);
      
      final currentUser = authService.currentUser;
      if (currentUser == null) return;

      // Load products
      final products = await productService.getProductsByOwner(currentUser.id);

      // Load jobs (need business ID first)
      final business = await businessService.getBusinessByOwnerId(currentUser.id);
      List<JobModel> jobs = [];
      if (business != null) {
        jobs = await jobService.getJobsByBusiness(business.businessId);
      }

      if (mounted) {
        setState(() {
          _myProducts = products;
          _myJobs = jobs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading listings: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: AppColors.textLight,
          indicatorColor: AppColors.primaryBlue,
          tabs: const [
            Tab(text: 'Products'),
            Tab(text: 'Jobs'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_tabController.index == 0) {
            // Navigate to Add Product
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddProductScreen()),
            );
            _loadListings(); // Refresh list after returning
          } else {
            // Navigate to Add Job
            final businessService = Provider.of<BusinessService>(context, listen: false);
            final authService = Provider.of<AuthService>(context, listen: false);
            final currentUser = authService.currentUser;
            
            if (currentUser != null) {
              final business = await businessService.getBusinessByOwnerId(currentUser.id);
              if (context.mounted) {
                if (business != null) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddJobScreen()),
                  );
                  _loadListings(); // Refresh list after returning
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('You need a business profile to post jobs'),
                      action: SnackBarAction(
                        label: 'Create',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CreateBusinessScreen()),
                          );
                        },
                      ),
                    ),
                  );
                }
              }
            }
          }
        },
        label: Text(_tabController.index == 0 ? 'Add Product' : 'Post Job'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildProductsList(),
                _buildJobsList(),
              ],
            ),
    );
  }

  Widget _buildProductsList() {
    if (_myProducts.isEmpty) {
      return const Center(child: Text('No products listed yet'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _myProducts.length,
      itemBuilder: (context, index) {
        final product = _myProducts[index];
        return ProductCard(
          product: product,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(product: product),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildJobsList() {
    if (_myJobs.isEmpty) {
      return const Center(child: Text('No jobs posted yet'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myJobs.length,
      itemBuilder: (context, index) {
        final job = _myJobs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
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
              '₱${job.salary.toStringAsFixed(0)}/mo',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
