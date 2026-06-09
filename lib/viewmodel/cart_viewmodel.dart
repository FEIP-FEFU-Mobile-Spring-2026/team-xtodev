import 'package:flutter/foundation.dart';
import '../data/cart_database.dart';
import '../models/cart_item.dart';

class CartViewModel extends ChangeNotifier {
  final CartDatabase _db;
  List<CartItem> _items = [];

  CartViewModel({CartDatabase? db}) : _db = db ?? CartDatabase.instance;

  List<CartItem> get items => _items;
  int get totalCount => _items.fold(0, (sum, item) => sum + item.quantity);

  Future<void> load() async {
    _items = await _db.loadAll();
    notifyListeners();
  }

  Future<void> addItem({required String productId, required String sizeId}) async {
    await _db.upsert(productId, sizeId);
    _items = await _db.loadAll();
    notifyListeners();
  }

  Future<void> updateQuantity(String productId, String sizeId, int quantity) async {
    if (quantity <= 0) {
      await _db.delete(productId, sizeId);
    } else {
      await _db.setQuantity(productId, sizeId, quantity);
    }
    _items = await _db.loadAll();
    notifyListeners();
  }

  Future<void> removeItem(String productId, String sizeId) async {
    await _db.delete(productId, sizeId);
    _items = await _db.loadAll();
    notifyListeners();
  }

  Future<void> clear() async {
    await _db.clear();
    _items = [];
    notifyListeners();
  }
}
