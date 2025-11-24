// Marketplace screen - displays all products
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import 'add_product_screen.dart';
import 'product_detail_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/category_pill.dart';
import '../../widgets/product_card.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductModel> _allProducts = [];
  List<ProductModel> _displayedProducts = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Food & Drinks', 'Handicrafts', 'Home Goods', 'Services'];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final productService = Provider.of<ProductService>(context, listen: false);
      final products = await productService.getProducts();
      setState(() {
        _allProducts = products;
        _displayedProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading products: $e')),
        );
      }
    }
  }

  void _filterProducts() {
    List<ProductModel> filtered = _allProducts;
    
    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((product) => 
        product.name.toLowerCase().contains(_searchController.text.toLowerCase())
      ).toList();
    }

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((product) => product.category == _selectedCategory).toList();
    }

    setState(() {
      _displayedProducts = filtered;
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
                        child: const Icon(Icons.store_mall_directory_outlined, color: AppColors.primaryBlue, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Marketplace', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryBlue)),
                          Text('Discover local goods', style: AppTextStyles.bodyMedium.copyWith(fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Search Bar
                  CustomTextField(
                    controller: _searchController,
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
                    onChanged: (value) => _filterProducts(),
                  ),
                  const SizedBox(height: 16),

                  // Category Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: CategoryPill(
                            label: category,
                            isSelected: _selectedCategory == category,
                            onTap: () {
                              setState(() => _selectedCategory = category);
                              _filterProducts();
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Text('Featured Items', style: AppTextStyles.titleLarge),
                ],
              ),
            ),
            
            // Product Grid
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _displayedProducts.isEmpty
                      ? const Center(child: Text('No products found'))
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: _displayedProducts.length,
                          itemBuilder: (context, index) {
                            final product = _displayedProducts[index];
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
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'marketplace_fab',
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );
          if (result == true) _loadProducts();
        },
        backgroundColor: AppColors.accentGold,
        child: const Icon(Icons.add, color: AppColors.textDark),
      ),
    );
  }
}