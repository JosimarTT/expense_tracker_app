import 'package:expense_tracker_app/app/theme/app_colors.dart';
import 'package:expense_tracker_app/app/theme/app_theme.dart';
import 'package:expense_tracker_app/features/dashboard/presentation/type_filter_pills.dart';
import 'package:expense_tracker_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final theme in [AppTheme.light, AppTheme.dark]) {
    final dark = theme.brightness == Brightness.dark;
    testWidgets('Type pills use semantic colors when selected (dark: $dark)', (
      tester,
    ) async {
      final semantic = theme.extension<AppSemanticColors>()!;
      final expected = {
        TransactionType.income: (
          semantic.incomeContainer,
          semantic.onIncomeContainer,
        ),
        TransactionType.expense: (
          semantic.expenseContainer,
          semantic.onExpenseContainer,
        ),
        TransactionType.savings: (
          semantic.infoContainer,
          semantic.onInfoContainer,
        ),
      };
      TransactionType? selected;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return Wrap(
                  children: [
                    for (final type in [null, ...TransactionType.values])
                      TransactionTypePill(
                        type: type,
                        selected: selected == type,
                        onSelected: () => update(() => selected = type),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      );
      for (final entry in expected.entries) {
        await tester.tap(find.text(entry.key.label));
        await tester.pumpAndSettle();
        final chip = tester.widget<ChoiceChip>(
          find.widgetWithText(ChoiceChip, entry.key.label),
        );
        expect(chip.selected, isTrue);
        expect(chip.selectedColor, entry.value.$1);
        expect((chip.shape! as StadiumBorder).side.color, entry.value.$2);
        final text = tester.widget<Text>(
          find.descendant(
            of: find.byWidget(chip),
            matching: find.text(entry.key.label),
          ),
        );
        final style = DefaultTextStyle.of(tester.element(find.byWidget(text)));
        expect(style.style.color, entry.value.$2);
        expect(
          _contrast(entry.value.$1, entry.value.$2),
          greaterThanOrEqualTo(4.5),
        );
      }
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      final all = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'All'),
      );
      expect(all.selectedColor, isNull);
      expect(all.selected, isTrue);
    });
  }
}

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}
