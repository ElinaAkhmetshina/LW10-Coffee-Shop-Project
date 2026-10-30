import 'dart:math';
import '../models/product.dart';

List<Product> seedProducts() => [
      Product(
        id: 1,
        title: 'Latte',
        category: 'Milk Coffee',
        description: 'A smooth coffee drink made with espresso and a large amount of steamed milk, topped with a thin layer of foam.',
        imagePath: 'assets/latte_img.jpg',
        price: '1 200₸',
        options: ['Hot', 'Cold', 'Sugar', 'Syrups', 'Cinnamon'],
        rating: 4.5,
      ),
      Product(
        id: 2,
        title: 'Americano',
        category: 'Black Coffee',
        description: 'A coffee drink made by pouring hot water over one shot of espresso.',
        imagePath: 'assets/americano_img.jpg',
        price: '650₸',
        options: ['Hot', 'Cold', 'Extra Shot'],
        rating: 4.8,
      ),
      Product(
        id: 3,
        title: 'Affogato',
        category: 'Dessert',
        description: 'A scoop of cold vanilla ice cream drowned with a hot, freshly pulled shot of espresso.',
        imagePath: 'assets/affogato_img.jpg',
        price: '1 500₸',
        options: ['Extra Ice Cream', 'Chocolate Drizzle'],
        rating: 4.7,
      ),
      Product(
        id: 4,
        title: 'Mocha',
        category: 'Milk Coffee',
        description: 'A sweet, chocolate-flavored variant of a latte made by combining espresso, chocolate, and steamed milk.',
        imagePath: 'assets/mocha_img.jpg',
        price: '1 300₸',
        options: ['Hot', 'Cold', 'Extra Chocolate', 'Whipped Cream'],
        rating: 4.9,
      ),
    ];

Product generateNewProduct() {
  final random = Random();
  final names = ['Cappuccino', 'Flat White', 'Raf', 'Macchiato', 'Cold Brew', 'Espresso'];
  final categories = ['Milk Coffee', 'Black Coffee', 'Signature', 'Seasonal'];
  final images = [
    'assets/latte_img.jpg',
    'assets/americano_img.jpg',
    'assets/affogato_img.jpg',
    'assets/mocha_img.jpg',
  ];

  return Product(
    id: DateTime.now().millisecondsSinceEpoch,
    title: names[random.nextInt(names.length)],
    category: categories[random.nextInt(categories.length)],
    description: 'A freshly added drink from today\'s menu update.',
    imagePath: images[random.nextInt(images.length)],
    price: '${(6 + random.nextInt(10)) * 100}₸',
    options: ['Hot', 'Cold', 'Sugar'],
    rating: double.parse((3.5 + random.nextDouble() * 1.5).toStringAsFixed(1)),
  );
}