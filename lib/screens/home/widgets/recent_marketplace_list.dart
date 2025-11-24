import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../models/product_model.dart';
import '../../../../widgets/product_card.dart';
import '../../marketplace/product_detail_screen.dart';

class RecentMarketplaceList extends StatelessWidget {
  final List<ProductModel> products;
  final VoidCallback onViewAll;

  const RecentMarketplaceList({
    super.key,
    required this.products,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Fresh Finds', style: AppTextStyles.titleLarge),
            TextButton(
              onPressed: onViewAll,
              child: Text('View All', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryBlue)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Container(
                width: 180,
                margin: const EdgeInsets.only(right: 16, bottom: 8),
                child: ProductCard(
                  product: product,
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
        const SizedBox(height: 24),
      ],
    );
  }
}
