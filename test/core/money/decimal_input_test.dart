import 'package:expense_tracker_app/core/money/decimal_input.dart';
import 'package:expense_tracker_app/core/money/money_format.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  test('Parses exact minor units without floating point', () {
    expect(parseScaledDecimal('12.50', 2), 1250);
    expect(parseScaledDecimal('0.01', 2), 1);
    expect(parseScaledDecimal('65.25', 2), 6525);
    expect(parseScaledDecimal('90071992547409.93', 2), 9007199254740993);
    expect(parseScaledDecimal('92233720368547758.07', 2), 9223372036854775807);
    expect(parseScaledDecimal('123', 0), 123);
  });
  test('Rejects ambiguity, excess decimals, negatives and overflow', () {
    for (final value in [
      '-1',
      '1,20',
      '1.001',
      'NaN',
      '1e2',
      '',
      '.5',
      '92233720368547758.08',
    ]) {
      expect(() => parseScaledDecimal(value, 2), throwsFormatException);
    }
  });
  test('Formatting preserves cents above floating-point safe range', () {
    final previous = Intl.defaultLocale;
    Intl.defaultLocale = 'en_US';
    addTearDown(() => Intl.defaultLocale = previous);
    expect(formatMoney(9007199254740993, 'USD', 2), r'$90,071,992,547,409.93');
    expect(
      formatMoney(9223372036854775807, 'USD', 2),
      r'$92,233,720,368,547,758.07',
    );
    expect(formatMoney(-1250, 'EUR', 2), '-€12.50');
  });
}
