import 'package:expense_tracker_app/features/profiles/domain/profile.dart';
import 'package:expense_tracker_app/features/schedules/presentation/schedule_editor_dialog.dart';
import 'package:expense_tracker_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:expense_tracker_app/features/transactions/presentation/transaction_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const categories = [
    TransactionCategory(
      id: 'food',
      name: 'Food',
      type: TransactionType.expense,
      iconKey: 'restaurant',
      colorArgb: 0xFF455A64,
      defaultBudgetBucket: 'needs',
    ),
  ];
  for (final (code, scale, valid) in [
    ('JPY', 0, '125'),
    ('USD', 2, '12.50'),
    ('KWD', 3, '12.500'),
  ]) {
    for (final scheduled in [false, true]) {
      testWidgets(
        '${scheduled ? 'Schedule' : 'Transaction'} restricts $code amount input',
        (tester) async {
          final profile = LocalProfile(
            id: 'a',
            name: 'Personal',
            currencyCode: code,
            currencyScale: scale,
          );
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
                home: Scaffold(
                  body: scheduled
                      ? ScheduleEditorDialog(
                          profile: profile,
                          categories: categories,
                        )
                      : TransactionDialog(
                          profile: profile,
                          categories: categories,
                        ),
                ),
              ),
            ),
          );
          final field = find.widgetWithText(TextField, 'Amount ($code)');
          await tester.ensureVisible(field);
          await tester.enterText(field, valid);
          expect(tester.widget<TextField>(field).controller!.text, valid);
          for (final invalid in [
            'letters',
            '-12',
            '1,25',
            '12..50',
            '${valid}0.1',
            if (scale > 0) '${valid}1' else '12.5',
          ]) {
            await tester.enterText(field, invalid);
            expect(tester.widget<TextField>(field).controller!.text, valid);
          }
          await tester.enterText(field, '');
          expect(tester.widget<TextField>(field).controller!.text, isEmpty);
        },
      );
    }
  }
}
