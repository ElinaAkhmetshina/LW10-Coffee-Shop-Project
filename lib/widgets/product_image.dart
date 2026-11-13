import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double iconSize;

  const ProductImage({
    super.key,
    required this.url,
    this.fit = BoxFit.contain,
    this.iconSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _placeholder();

    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() => Center(
    child: Icon(Icons.image_not_supported_outlined, size: iconSize, color: Colors.grey),
  );
}