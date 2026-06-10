import 'package:flutter_test/flutter_test.dart';
import 'package:fastbuy/models/cart_item.dart';

void main() {
  group('CartItem.copyWith', () {
    const base = CartItem(productId: 'p1', sizeId: 's1', quantity: 2);

    test('updates quantity when provided', () {
      final updated = base.copyWith(quantity: 5);
      expect(updated.quantity, 5);
      expect(updated.productId, 'p1');
      expect(updated.sizeId, 's1');
    });

    test('preserves all fields when called with no arguments', () {
      final copy = base.copyWith();
      expect(copy.productId, base.productId);
      expect(copy.sizeId, base.sizeId);
      expect(copy.quantity, base.quantity);
    });
  });

  group('Cart totalCount', () {
    test('sums quantities across all items', () {
      final items = [
        const CartItem(productId: 'p1', sizeId: 's1', quantity: 3),
        const CartItem(productId: 'p2', sizeId: 's2', quantity: 2),
        const CartItem(productId: 'p3', sizeId: 's1', quantity: 1),
      ];
      final total = items.fold<int>(0, (sum, item) => sum + item.quantity);
      expect(total, 6);
    });

    test('returns zero for empty cart', () {
      final items = <CartItem>[];
      final total = items.fold<int>(0, (sum, item) => sum + item.quantity);
      expect(total, 0);
    });
  });
}
