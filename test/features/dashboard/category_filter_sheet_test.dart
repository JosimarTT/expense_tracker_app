import 'package:expense_tracker_app/app/providers.dart';
import 'package:expense_tracker_app/app/theme/app_theme.dart';
import 'package:expense_tracker_app/features/dashboard/presentation/category_filter_pill.dart';
import 'package:expense_tracker_app/features/dashboard/presentation/transaction_filter_sheet.dart';
import 'package:expense_tracker_app/features/profiles/domain/category_options.dart';
import 'package:expense_tracker_app/features/profiles/domain/profile.dart';
import 'package:expense_tracker_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:expense_tracker_app/features/transactions/presentation/providers/transaction_scope_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

TransactionCategory category(
  String id, {
  TransactionType type = TransactionType.expense,
  bool archived = false,
  int color = 0xFF1565C0,
}) => TransactionCategory(
  id: id,
  name: id,
  type: type,
  iconKey: 'category',
  colorArgb: color,
  defaultBudgetBucket: type == TransactionType.expense ? 'needs' : null,
  isArchived: archived,
);

Future<void> openSheet(
  WidgetTester tester,
  List<TransactionCategory> categories, {
  ThemeData? theme,
  double scale = 1,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        categoriesProvider('a').overrideWith((ref) => Stream.value(categories)),
        filteredCountProvider.overrideWith((ref, key) => Stream.value(0)),
      ],
      child: MaterialApp(
        theme: theme ?? AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  showTransactionFilterSheet(context, profileId: 'a'),
              child: const Text('Open filters'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open filters'));
  await tester.pumpAndSettle();
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> closeSheet(WidgetTester tester) async {
  await tester.tap(find.text('Show 0 transactions'));
  await tester.pumpAndSettle();
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('All categories wrap, multi-select, clear and hide by type', (
    tester,
  ) async {
    await openSheet(tester, [
      for (var i = 0; i < 16; i++) category('Expense $i'),
      category('Income category', type: TransactionType.income),
      category('Archived category', archived: true),
    ]);
    expect(find.byType(CategoryFilterPill), findsNWidgets(17));
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Archived category (archived)'), findsNothing);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(TransactionFilterSheet)),
    );
    final provider = transactionScopeProvider('a');
    await tapVisible(tester, find.text('Expense 0'));
    await tapVisible(tester, find.text('Income category'));
    expect(container.read(provider).filter.categoryIds, {
      'Expense 0',
      'Income category',
    });
    await tapVisible(tester, find.widgetWithText(ChoiceChip, 'Expense'));
    expect(find.text('Income category'), findsNothing);
    expect(container.read(provider).filter.categoryIds, {'Expense 0'});
    await tapVisible(tester, find.text('Select all'));
    expect(container.read(provider).filter.categoryIds.length, 16);
    await tapVisible(tester, find.text('Clear'));
    expect(container.read(provider).filter.categoryIds, isEmpty);
    await tapVisible(tester, find.text('Show archived'));
    await tapVisible(tester, find.text('Archived category (archived)'));
    expect(container.read(provider).filter.categoryIds, {'Archived category'});
    await tapVisible(tester, find.text('Show archived'));
    expect(container.read(provider).filter.categoryIds, isEmpty);
    expect(find.text('Archived category (archived)'), findsNothing);
    await tapVisible(tester, find.text('Show archived'));
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(container.read(provider).showArchived, isFalse);
    expect(container.read(provider).filter.type, isNull);
    await closeSheet(tester);
  });

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('Category colors and contrast in ${theme.brightness}', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Wrap(
                children: [
                  for (final color in CategoryPresentationOptions.colors)
                    CategoryFilterPill(
                      category: category('$color', color: color),
                      selected: true,
                      onSelected: (_) {},
                    ),
                ],
              ),
            ),
          ),
        ),
      );
      for (final color in CategoryPresentationOptions.colors) {
        final chip = tester.widget<FilterChip>(
          find.widgetWithText(FilterChip, '$color'),
        );
        expect(chip.selectedColor, Color(color));
        expect(chip.showCheckmark, isNot(false));
        expect(chip.checkmarkColor, chip.labelStyle!.color);
        final a = Color(color).computeLuminance();
        final b = chip.labelStyle!.color!.computeLuminance();
        final contrast = a > b
            ? (a + 0.05) / (b + 0.05)
            : (b + 0.05) / (a + 0.05);
        expect(contrast, greaterThanOrEqualTo(4.5));
      }
    });

    for (final (size, scale) in [
      (const Size(320, 568), 2.0),
      (const Size(390, 844), 1.0),
      (const Size(1000, 900), 1.0),
    ]) {
      testWidgets('Sheet fits ${theme.brightness} at $size, scale $scale', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await openSheet(
          tester,
          [
            for (var i = 0; i < 20; i++)
              category('Long category name number $i'),
          ],
          theme: theme,
          scale: scale,
        );
        expect(find.byType(CategoryFilterPill), findsNWidgets(20));
        expect(find.byType(TextField), findsNothing);
        await tapVisible(tester, find.text('Long category name number 19'));
        final button = find.widgetWithText(FilledButton, 'Show 0 transactions');
        expect(tester.getRect(button).bottom, lessThanOrEqualTo(size.height));
        expect(button.hitTestable(), findsOneWidget);
        expect(find.text('Reset').hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        await closeSheet(tester);
      });
    }
  }
}
