import 'package:flutter/material.dart';

import '../models/product.dart';
import '../widgets/category_badge.dart';
import '../widgets/product_image.dart';

class ProductFeedView extends StatelessWidget {
  final List<Product> products;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final ValueChanged<Product> onProductTap;

  const ProductFeedView({
    super.key,
    required this.products,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
    required this.onRetry,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const _LoadingState();

    if (errorMessage != null) {
      return _ErrorState(message: errorMessage!, onRetry: onRetry);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: products.isEmpty ? _buildEmptyList() : _buildList(context),
    );
  }

  Widget _buildList(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: products.length,
      separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5, indent: 96),
      itemBuilder: (context, index) {
        final product = products[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Hero(
            tag: 'product_image_${product.id}',
            child: Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ProductImage(url: product.imageUrl, iconSize: 24),
            ),
          ),
          title: Text(
            product.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CategoryBadge(category: product.category),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(' ${product.rating}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(' (${product.reviewCount})', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          trailing: Text(
            product.formattedPrice,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          onTap: () => onProductTap(product),
        );
      },
    );
  }

  Widget _buildEmptyList() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 200),
        Center(child: Text('No products found.\nPull down to refresh.', textAlign: TextAlign.center)),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading products...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 96, color: Colors.brown[200]),
            const SizedBox(height: 16),
            const Text('Connection Problem', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 15)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Connection'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}