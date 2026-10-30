import 'package:flutter/material.dart';
import '../data/product_data.dart';
import '../models/product.dart';
import 'catalog_view.dart';
import 'product_detail_screen.dart';
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
  bool _isGridView = false;

  final List<Product> _products = seedProducts();

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      CatalogView(
        products: _products,
        isGridView: _isGridView,
        onChanged: () => setState(() {}),
      ),

      Builder(
        builder: (context) {
          final bookmarkedItems = _products.where((p) => p.isBookmarked).toList();
          if (bookmarkedItems.isEmpty) {
            return const Center(
              child: Text(
                'No favorite items yet!\nTap the bookmark icon on items.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: bookmarkedItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final product = bookmarkedItems[index];
              return Card(
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(product.imagePath, width: 50, height: 50, fit: BoxFit.cover),
                  ),
                  title: Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(product.price),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
                    );
                    setState(() {});
                  },
                ),
              );
            },
          );
        },
      ),


      Padding(
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
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0
            ? (_isGridView ? 'Coffee Catalog' : 'Coffee Feed')
            : _currentIndex == 1
                ? 'Favorites'
                : 'User Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_currentIndex == 0)
            IconButton(
              tooltip: _isGridView ? 'Show as list' : 'Show as grid',
              icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
              onPressed: () => setState(() => _isGridView = !_isGridView),
            ),
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF613A28),
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.local_cafe), label: 'Catalog'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}