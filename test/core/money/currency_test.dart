import 'package:expense_tracker_app/core/money/currency.dart';
import 'package:expense_tracker_app/core/money/decimal_input.dart';
import 'package:expense_tracker_app/core/money/money_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Currency catalog has unique codes and searchable names and aliases',
    () {
      expect(
        Currency.supported.map((currency) => currency.code).toSet().length,
        Currency.supported.length,
      );
      final pen = Currency.fromCode('PEN');
      for (final query in ['pen', 'sol', 'Peru', ' soles ']) {
        expect(pen.matches(query), isTrue);
      }
      expect(pen.matches('yen'), isFalse);
      expect(() => Currency.fromCode('XXX'), throwsArgumentError);
    },
  );

  test('Currencies use the correct minor-unit precision', () {
    expect(Currency.fromCode('PEN').scale, 2);
    expect(Currency.fromCode('JPY').scale, 0);
    expect(Currency.fromCode('KWD').scale, 3);
    expect(parseScaledDecimal('123', 0), 123);
    expect(() => parseScaledDecimal('123.45', 0), throwsFormatException);
    expect(parseScaledDecimal('12.345', 3), 12345);
    expect(() => parseScaledDecimal('12.3456', 3), throwsFormatException);
  });

  test('Currency display follows locale placement and decimal separators', () {
    expect(formatMoney(123450, 'USD', 2, locale: 'en_US'), r'$1,234.50');
    expect(formatMoney(123450, 'PEN', 2, locale: 'es_PE'), 'S/1,234.50');
    expect(formatMoney(123450, 'EUR', 2, locale: 'de_DE'), '1.234,50\u00a0€');
    expect(formatMoney(1234, 'JPY', 0, locale: 'en_US'), '¥1,234');
    expect(formatMoney(12345, 'KWD', 3, locale: 'en_US'), 'din12.345');
    expect(formatMoney(0, 'JPY', 0, locale: 'en_US'), '¥0');
    expect(formatMoney(-1250, 'USD', 2, locale: 'en_US'), r'-$12.50');
  });

  test('Locale formatting keeps large fractional amounts exact', () {
    expect(
      formatMoney(9223372036854775807, 'EUR', 2, locale: 'de_DE'),
      '92.233.720.368.547.758,07\u00a0€',
    );
    expect(
      formatMoney(9223372036854775807, 'KWD', 3, locale: 'en_US'),
      'din9,223,372,036,854,775.807',
    );
  });
}
