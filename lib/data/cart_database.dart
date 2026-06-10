import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../models/cart_item.dart';

class CartDatabase {
  static final CartDatabase instance = CartDatabase._();
  CartDatabase._();

  Future<Database>? _dbFuture;

  Future<Database> get _database => _dbFuture ??= _open();

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), 'cart.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE cart_items (
          product_id TEXT NOT NULL,
          size_id    TEXT NOT NULL,
          quantity   INTEGER NOT NULL,
          PRIMARY KEY (product_id, size_id)
        )
      '''),
    );
  }

  Future<List<CartItem>> loadAll() async {
    final db = await _database;
    final rows = await db.query('cart_items');
    return rows
        .map((r) => CartItem(
              productId: r['product_id'] as String,
              sizeId: r['size_id'] as String,
              quantity: r['quantity'] as int,
            ))
        .toList();
  }

  Future<void> upsert(String productId, String sizeId) async {
    final db = await _database;
    await db.rawInsert('''
      INSERT INTO cart_items (product_id, size_id, quantity)
      VALUES (?, ?, 1)
      ON CONFLICT(product_id, size_id) DO UPDATE SET quantity = quantity + 1
    ''', [productId, sizeId]);
  }

  Future<void> setQuantity(String productId, String sizeId, int quantity) async {
    final db = await _database;
    await db.update(
      'cart_items',
      {'quantity': quantity},
      where: 'product_id = ? AND size_id = ?',
      whereArgs: [productId, sizeId],
    );
  }

  Future<void> delete(String productId, String sizeId) async {
    final db = await _database;
    await db.delete(
      'cart_items',
      where: 'product_id = ? AND size_id = ?',
      whereArgs: [productId, sizeId],
    );
  }

  Future<void> clear() async {
    final db = await _database;
    await db.delete('cart_items');
  }
}
