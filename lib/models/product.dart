class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String imageUrl;
  final double rating;
  final int reviewCount;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final ratingJson = json['rating'];
    final Map<String, dynamic> ratingMap =
    ratingJson is Map<String, dynamic> ? ratingJson : <String, dynamic>{};

    return Product(
      id: _toInt(json['id']),
      title: _toText(json['title'], fallback: 'Untitled product'),
      price: _toDouble(json['price']),
      description: _toText(json['description'], fallback: 'No description available.'),
      category: _toText(json['category'], fallback: 'uncategorized'),
      imageUrl: _toText(json['image'], fallback: ''),
      rating: _toDouble(ratingMap['rate']),
      reviewCount: _toInt(ratingMap['count']),
    );
  }


  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _toText(dynamic value, {required String fallback}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String get deepLink => 'narxoz://store/product/$id';

  List<String> get galleryImages => [imageUrl, imageUrl, imageUrl];
}