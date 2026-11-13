import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/api_service.dart';
import '../widgets/product_image.dart';
import 'product_detail_screen.dart';
import 'product_feed_view.dart';
import 'registration_screen.dart';

class HomeScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String role;

  const HomeScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.role,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final ApiService _api = ApiService();
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  final Set<int> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _loadProducts(showSpinner: false); // _isLoading is already true
  }

  Future<void> _loadProducts({bool showSpinner = true}) async {
    if (showSpinner) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final products = await _api.fetchProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
        _isLoading = false;
        _errorMessage = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    }
  }

  void _toggleFavorite(int productId) {
    setState(() {
      if (!_favoriteIds.remove(productId)) _favoriteIds.add(productId);
    });
  }

  Future<void> _openDetails(Product product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          product: product,
          isFavorite: _favoriteIds.contains(product.id),
          onToggleFavorite: () => _toggleFavorite(product.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      ProductFeedView(
        products: _products,
        isLoading: _isLoading,
        errorMessage: _errorMessage,
        onRefresh: () => _loadProducts(showSpinner: false),
        onRetry: () => _loadProducts(),
        onProductTap: _openDetails,
      ),

      _buildFavoritesTab(),

      _buildProfileTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0
            ? 'Product Explorer'
            : _currentIndex == 1
            ? 'Favorites'
            : 'User Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF613A28),
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    final favorites = _products.where((p) => _favoriteIds.contains(p.id)).toList();

    if (favorites.isEmpty) {
      return const Center(
        child: Text(
          'No favorite items yet!\nOpen a product and tap the bookmark icon.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: favorites.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final product = favorites[index];
        return Card(
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(10),
            leading: Hero(
              tag: 'product_image_${product.id}',
              child: SizedBox(
                width: 50,
                height: 50,
                child: ProductImage(url: product.imageUrl, iconSize: 20),
              ),
            ),
            title: Text(
              product.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(product.formattedPrice),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _openDetails(product),
          ),
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.brown,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(widget.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(widget.email, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 16),
          Chip(label: Text('Role: ${widget.role}')),
          const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const RegistrationScreen()),
                    (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}