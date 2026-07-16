import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/models/product.dart';
import 'package:flutter_app/models/voucher.dart';

void main() {
  group('Product model', () {
    test('parses sale price and discount badge', () {
      final product = Product.fromJson({
        'productId': 'p1',
        'name': 'Running Shoe',
        'price': 1000000,
        'salePrice': 800000,
        'images': ['shoe.png'],
        'brand': {'name': 'SportZone'},
        'category': {'name': 'Shoes'},
      });

      expect(product.id, 'p1');
      expect(product.price, 800000);
      expect(product.originalPrice, 1000000);
      expect(product.discount, '-20%');
      expect(product.imageUrl, 'shoe.png');
    });
  });

  group('Voucher model', () {
    test('caps percentage discount by max discount', () {
      final voucher = Voucher.fromJson({
        'voucherId': 'v1',
        'code': 'SALE',
        'discountType': 'percentage',
        'discountValue': 50,
        'maxDiscount': 100000,
        'minOrderValue': 0,
        'targetTier': 'bronze',
      });

      expect(voucher.calculateDiscount(500000), 100000);
    });
  });
}
