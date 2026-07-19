import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_chains_management_fe/core/constants/currency_constants.dart';

void main() {
  group('CurrencyConstants.convertUsdToVnd', () {
    test('should convert a representative positive USD amount to VND', () {
      expect(CurrencyConstants.convertUsdToVnd(5), 125000);
    });

    test('should return zero when the USD amount is zero', () {
      expect(CurrencyConstants.convertUsdToVnd(0), 0);
    });

    test('should preserve fractional USD precision during conversion', () {
      expect(CurrencyConstants.convertUsdToVnd(0.01), 250);
    });

    test('should convert a negative boundary value without changing sign', () {
      expect(CurrencyConstants.convertUsdToVnd(-0.01), -250);
    });
  });
}
