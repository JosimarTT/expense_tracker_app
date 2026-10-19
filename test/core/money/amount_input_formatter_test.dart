import 'package:expense_tracker_app/core/money/amount_input_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final scale in [0, 2, 3]) {
    group('Amount input with $scale decimal places', () {
      late AmountInputFormatter formatter;
      setUp(() => formatter = AmountInputFormatter(scale));

      for (final input in ['', '0', '1234567890123456789']) {
        test('Accepts "$input"', () {
          final value = TextEditingValue(text: input);
          expect(
            formatter.formatEditUpdate(TextEditingValue.empty, value),
            value,
          );
        });
      }

      for (final input in [
        'abc',
        '12a',
        '-12',
        '+12',
        '1,25',
        '1 000',
        '1e3',
        '\$12',
        '1\n',
      ]) {
        test('Rejects "$input" without changing the previous value', () {
          const previous = TextEditingValue(
            text: '12',
            selection: TextSelection.collapsed(offset: 1),
          );
          expect(
            formatter.formatEditUpdate(previous, TextEditingValue(text: input)),
            previous,
          );
        });
      }

      test('Enforces currency precision and a single decimal separator', () {
        for (final input in [
          '12.',
          '12.0',
          '12.50',
          '12.500',
          '12.5000',
          '12..5',
        ]) {
          const previous = TextEditingValue(text: '12');
          final next = TextEditingValue(text: input);
          final valid =
              scale > 0 &&
              input.split('.').length == 2 &&
              input.split('.').last.length <= scale;
          expect(
            formatter.formatEditUpdate(previous, next),
            valid ? next : previous,
          );
        }
      });

      test('Preserves selection when replacing and deleting digits', () {
        const previous = TextEditingValue(text: '1234');
        const next = TextEditingValue(
          text: '134',
          selection: TextSelection.collapsed(offset: 1),
        );
        expect(formatter.formatEditUpdate(previous, next), next);
      });
    });
  }
}
