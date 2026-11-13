import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const String _productsUrl = 'https://fakestoreapi.com/products';
  static const Duration _timeout = Duration(seconds: 10);

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(_productsUrl)).timeout(_timeout);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is! List) {
          throw const ApiException('Unexpected response format from the server.');
        }
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(Product.fromJson)
            .toList();
      } else if (response.statusCode == 404) {
        throw const ApiException('Products not found (404).');
      } else if (response.statusCode >= 500) {
        throw ApiException('Server error (${response.statusCode}). Please try again later.');
      } else {
        throw ApiException('Unexpected server response (${response.statusCode}).');
      }
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException('The server took too long to respond (10 s timeout).');
    } on FormatException {
      throw const ApiException('Received invalid data from the server.');
    } catch (_) {
      throw const ApiException('No internet connection.\nCheck your network and try again.');
    }
  }
}