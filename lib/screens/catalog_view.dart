import 'package:flutter/material.dart';
import '../data/product_data.dart';
import '../models/product.dart';
import 'product_detail_screen.dart';


class CatalogView extends StatefulWidget {
  final List<Product> products;
  final bool isGridView;
  final VoidCallback onChanged;

  const CatalogView({
    super.key,
    required this.products,
    required this.isGridView,
    required this.onChanged,
  });

  @override
  State<CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<CatalogView> {
  List<Product> get _products => widget.products;

  void _update(VoidCallback fn) {
    setState(fn);
    widget.onChanged();
  }


  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    _update(() {
      _products.insert(0, generateNewProduct());
    });
  }


  void _onDismissed(Product product, int index) {
    _update(() => _products.removeAt(index));

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('${product.title} removed'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            final safeIndex = index.clamp(0, _products.length);
            _update(() => _products.insert(safeIndex, product));
          },
        ),
      ),
    );
  }


  void _resetCatalog() {
    _update(() {
      _products
        ..clear()
        ..addAll(seedProducts());
    });
  }

  Future<void> _openDetails(Product product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
    );
    _update(() {});
  }


  Widget _dismissible({required Product product, required int index, required Widget child}) {
    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 30),
      ),
      onDismissed: (_) => _onDismissed(product, index),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_products.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: const Color(0xFF613A28),
      child: widget.isGridView ? _buildGrid() : _buildList(),
    );
  }


  Widget _buildList() {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _products.length,
      separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5, indent: 80),
      itemBuilder: (context, index) {
        final product = _products[index];
        return _dismissible(
          product: product,
          index: index,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.brown[100],
              backgroundImage: AssetImage(product.imagePath),
            ),
            title: Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  _CategoryTag(category: product.category),
                  const SizedBox(width: 8),
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  Text(' ${product.rating}'),
                ],
              ),
            ),
            trailing: Text(
              product.price,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF613A28)),
            ),
            onTap: () => _openDetails(product),
          ),
        );
      },
    );
  }


  Widget _buildGrid() {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: _products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final product = _products[index];
        return _dismissible(
          product: product,
          index: index,
          child: _GridCard(
            product: product,
            onTap: () => _openDetails(product),
            onBookmark: () => _update(() => product.isBookmarked = !product.isBookmarked),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 96, color: Colors.brown[200]),
            const SizedBox(height: 16),
            const Text('Catalog is Empty', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'You removed all items.\nRestore the original menu to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _resetCatalog,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Catalog'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF613A28),
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

class _CategoryTag extends StatelessWidget {
  final String category;
  const _CategoryTag({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.brown[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.brown.shade200),
      ),
      child: Text(category, style: TextStyle(fontSize: 11, color: Colors.brown[800])),
    );
  }
}

class _GridCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _GridCard({required this.product, required this.onTap, required this.onBookmark});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    product.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.brown[100],
                      child: const Icon(Icons.coffee, size: 48, color: Colors.brown),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 18,
                        icon: Icon(
                          product.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: Colors.brown,
                        ),
                        onPressed: onBookmark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  _CategoryTag(category: product.category),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      Text(' ${product.rating}', style: const TextStyle(fontSize: 12)),
                      const Spacer(),
                      Text(
                        product.price,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF613A28)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}