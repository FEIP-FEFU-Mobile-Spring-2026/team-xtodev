import 'package:flutter_test/flutter_test.dart';
import 'package:fastbuy/models/product.dart';

Map<String, dynamic> _sampleJson({List<String> tags = const []}) => {
      'id': 'p1',
      'name': 'Test Shoe',
      'priceInKopecks': 9990,
      'imageUrl': 'https://example.com/img.jpg',
      'tags': tags,
      'categoryId': 'cat1',
      'longDescription': 'A fine shoe.',
      'sizes': [
        {'id': 's1', 'name': '42'},
        {'id': 's2', 'name': '43'},
      ],
      'material': 'Leather',
      'weight': '350g',
      'season': 'All',
      'countryOfOrigin': 'Italy',
    };

void main() {
  group('Product.fromJson', () {
    test('maps all scalar fields correctly', () {
      final p = Product.fromJson(_sampleJson());
      expect(p.id, 'p1');
      expect(p.name, 'Test Shoe');
      expect(p.priceInKopecks, 9990);
      expect(p.imageUrl, 'https://example.com/img.jpg');
      expect(p.categoryId, 'cat1');
      expect(p.longDescription, 'A fine shoe.');
      expect(p.material, 'Leather');
      expect(p.weight, '350g');
      expect(p.season, 'All');
      expect(p.countryOfOrigin, 'Italy');
    });

    test('maps sizes list correctly', () {
      final p = Product.fromJson(_sampleJson());
      expect(p.sizes.length, 2);
      expect(p.sizes[0].id, 's1');
      expect(p.sizes[0].name, '42');
      expect(p.sizes[1].id, 's2');
      expect(p.sizes[1].name, '43');
    });

    test('maps tags list correctly', () {
      final p = Product.fromJson(_sampleJson(tags: ['New', 'Sale']));
      expect(p.tags, ['New', 'Sale']);
    });
  });

  group('Product.isNew', () {
    test('returns true when New tag is present', () {
      final p = Product.fromJson(_sampleJson(tags: ['New']));
      expect(p.isNew, isTrue);
    });

    test('returns false when New tag is absent', () {
      final p = Product.fromJson(_sampleJson(tags: ['Sale', 'Popular']));
      expect(p.isNew, isFalse);
    });

    test('returns false for empty tags list', () {
      final p = Product.fromJson(_sampleJson());
      expect(p.isNew, isFalse);
    });
  });

  group('ProductSize.fromJson', () {
    test('maps id and name', () {
      final s = ProductSize.fromJson({'id': 'sz1', 'name': '40'});
      expect(s.id, 'sz1');
      expect(s.name, '40');
    });
  });
}
