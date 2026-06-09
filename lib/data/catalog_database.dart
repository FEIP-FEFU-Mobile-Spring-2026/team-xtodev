import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/category.dart';
import '../models/product.dart';

class CatalogDatabase {
  static final CatalogDatabase instance = CatalogDatabase._();
  CatalogDatabase._();

  Future<Database>? _dbFuture;

  Future<Database> get _database => _dbFuture ??= _open();

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), 'catalog.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE categories (
            id   TEXT PRIMARY KEY,
            name TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE products (
            id                TEXT PRIMARY KEY,
            name              TEXT NOT NULL,
            price_in_kopecks  INTEGER NOT NULL,
            image_url         TEXT NOT NULL,
            tags              TEXT NOT NULL,
            category_id       TEXT NOT NULL,
            long_description  TEXT NOT NULL,
            sizes             TEXT NOT NULL,
            material          TEXT NOT NULL,
            weight            TEXT NOT NULL,
            season            TEXT NOT NULL,
            country_of_origin TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<({List<Category> categories, List<Product> products})?> load() async {
    final db = await _database;
    final catRows = await db.query('categories');
    if (catRows.isEmpty) return null;
    final prodRows = await db.query('products');
    return (
      categories: catRows
          .map((r) => Category(id: r['id'] as String, name: r['name'] as String))
          .toList(),
      products: prodRows.map(_rowToProduct).toList(),
    );
  }

  Future<void> save({
    required List<Category> categories,
    required List<Product> products,
  }) async {
    final db = await _database;
    await db.transaction((txn) async {
      await txn.delete('categories');
      await txn.delete('products');
      for (final c in categories) {
        await txn.insert('categories', {'id': c.id, 'name': c.name});
      }
      for (final prod in products) {
        await txn.insert('products', _productToRow(prod));
      }
    });
  }

  Product _rowToProduct(Map<String, Object?> r) => Product(
        id: r['id'] as String,
        name: r['name'] as String,
        priceInKopecks: r['price_in_kopecks'] as int,
        imageUrl: r['image_url'] as String,
        tags: List<String>.from(jsonDecode(r['tags'] as String) as List),
        categoryId: r['category_id'] as String,
        longDescription: r['long_description'] as String,
        sizes: (jsonDecode(r['sizes'] as String) as List)
            .map((e) => ProductSize.fromJson(e as Map<String, dynamic>))
            .toList(),
        material: r['material'] as String,
        weight: r['weight'] as String,
        season: r['season'] as String,
        countryOfOrigin: r['country_of_origin'] as String,
      );

  Map<String, Object?> _productToRow(Product prod) => {
        'id': prod.id,
        'name': prod.name,
        'price_in_kopecks': prod.priceInKopecks,
        'image_url': prod.imageUrl,
        'tags': jsonEncode(prod.tags),
        'category_id': prod.categoryId,
        'long_description': prod.longDescription,
        'sizes': jsonEncode(
          prod.sizes.map((s) => {'id': s.id, 'name': s.name}).toList(),
        ),
        'material': prod.material,
        'weight': prod.weight,
        'season': prod.season,
        'country_of_origin': prod.countryOfOrigin,
      };
}
