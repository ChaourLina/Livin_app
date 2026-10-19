import 'package:flutter_test/flutter_test.dart';
import 'package:livin_app/core/utils/formatters.dart';
import 'package:livin_app/core/utils/phone_utils.dart';

void main() {
  group('formatters', () {
    test('formatPrice groups thousands', () {
      expect(formatPrice(45000), '45 000');
      expect(formatPrice(8500000), '8 500 000');
    });

    test('capitalize puts the first letter in uppercase', () {
      expect(capitalize('villa'), 'Villa');
    });
  });

  group('phone_utils', () {
    test('toInternationalNumber converts Algerian numbers', () {
      expect(toInternationalNumber('0550 12 34 56'), '213550123456');
      expect(toInternationalNumber('+213550123456'), '213550123456');
    });
  });
}