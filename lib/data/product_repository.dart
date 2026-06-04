import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/category.dart';
import '../models/product.dart';

class ProductRepository {
  Future<({List<Category> categories, List<Product> products})> loadCatalog() async {
    final raw = await rootBundle.loadString('lib/products.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final categories = (json['categories'] as List)
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
    final products = (json['items'] as List)
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
    return (categories: categories, products: products);
  }
}
