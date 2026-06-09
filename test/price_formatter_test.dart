import 'package:flutter_test/flutter_test.dart';
import 'package:fastbuy/utils/price_formatter.dart';

void main() {
  group('formatPrice', () {
    test('zero kopecks shows only rubles without fraction', () {
      expect(formatPrice(0), '0 ₽');
    });

    test('exact rubles with no kopecks omits fractional part', () {
      expect(formatPrice(100), '1 ₽');
      expect(formatPrice(5000), '50 ₽');
    });

    test('non-zero kopecks are shown with two decimal places', () {
      expect(formatPrice(9990), '99.90 ₽');
      expect(formatPrice(101), '1.01 ₽');
      expect(formatPrice(1), '0.01 ₽');
    });

    test('thousands separator is a non-breaking space', () {
      final result = formatPrice(150000);
      expect(result, '1 500 ₽');
    });

    test('thousands separator and kopecks together', () {
      expect(formatPrice(150050), '1 500.50 ₽');
    });
  });
}
