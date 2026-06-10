import 'package:flutter_test/flutter_test.dart';
import 'package:fastbuy/models/product.dart';

Product _makeProduct({required String id, required String categoryId, List<String> tags = const []}) =>
    Product(
      id: id,
      name: 'Product $id',
      priceInKopecks: 1000,
      imageUrl: '',
      tags: tags,
      categoryId: categoryId,
      longDescription: '',
      sizes: [],
      material: '',
      weight: '',
      season: '',
      countryOfOrigin: '',
    );

void main() {
  final products = [
    _makeProduct(id: 'p1', categoryId: 'shoes', tags: ['New']),
    _makeProduct(id: 'p2', categoryId: 'shoes'),
    _makeProduct(id: 'p3', categoryId: 'bags', tags: ['New', 'Sale']),
    _makeProduct(id: 'p4', categoryId: 'bags'),
  ];

  group('Catalog filter', () {
    test('New tab returns only products with New tag', () {
      final result = products.where((p) => p.isNew).toList();
      expect(result.map((p) => p.id), containsAll(['p1', 'p3']));
      expect(result.length, 2);
    });

    test('Category tab returns only products matching categoryId', () {
      final result = products.where((p) => p.categoryId == 'shoes').toList();
      expect(result.map((p) => p.id), containsAll(['p1', 'p2']));
      expect(result.length, 2);
    });

    test('Category filter excludes products from other categories', () {
      final result = products.where((p) => p.categoryId == 'bags').toList();
      expect(result.any((p) => p.categoryId == 'shoes'), isFalse);
    });

    test('Empty product list returns empty filtered result', () {
      final result = <Product>[].where((p) => p.isNew).toList();
      expect(result, isEmpty);
    });
  });
}
