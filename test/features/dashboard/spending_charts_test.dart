import 'package:expense_tracker_app/app/theme/app_theme.dart';
import 'package:expense_tracker_app/features/dashboard/domain/spending_analytics.dart';
import 'package:expense_tracker_app/features/dashboard/presentation/spending_charts.dart';
import 'package:expense_tracker_app/features/profiles/domain/profile.dart';
import 'package:expense_tracker_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final loader = FontLoader('Nunito')
      ..addFont(rootBundle.load('assets/fonts/Nunito-Variable.ttf'));
    await loader.load();
  });
  const longName = 'Entertainment and subscriptions for the entire household';
  for (final theme in [AppTheme.light, AppTheme.dark]) {
    for (final (width, scale) in [
      (320.0, 1.0),
      (390.0, 1.0),
      (760.0, 1.0),
      (320.0, 2.0),
    ]) {
      testWidgets('Legend columns at $width / $scale / ${theme.brightness}', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final semantics = tester.ensureSemantics();
        try {
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: Scaffold(
                body: MediaQuery(
                  data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SpendingOverview(
                      compact: true,
                      analytics: SpendingAnalytics(
                        profileId: 'a',
                        month: DateTime(2026, 10),
                        transactions: [
                          for (final (id, amount) in [
                            ('long', 200),
                            ('short', 100),
                          ])
                            FinancialTransaction(
                              id: id,
                              profileId: 'a',
                              categoryId: id,
                              amountMinor: amount,
                              type: TransactionType.expense,
                              occurredAt: DateTime(2026, 10, 1),
                            ),
                        ],
                      ),
                      categories: [
                        for (final (id, name) in [
                          ('long', longName),
                          ('short', 'Food'),
                        ])
                          TransactionCategory(
                            id: id,
                            name: name,
                            type: TransactionType.expense,
                            iconKey: 'category',
                            colorArgb: 0xFF000000,
                            defaultBudgetBucket: null,
                          ),
                      ],
                      money: (amount) =>
                          '\$${(amount.toInt() / 100).toStringAsFixed(2)}',
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final category = find.byKey(const ValueKey('legend-category-long'));
          final amount = find.byKey(const ValueKey('legend-amount-long'));
          final percentage = find.byKey(
            const ValueKey('legend-percentage-long'),
          );
          final categoryText = tester.widget<Text>(category);
          expect(categoryText.maxLines, 1);
          expect(categoryText.overflow, TextOverflow.ellipsis);
          expect(categoryText.textAlign, TextAlign.left);
          expect(tester.widget<Text>(amount).textAlign, TextAlign.center);
          expect(tester.widget<Text>(percentage).textAlign, TextAlign.right);
          expect(find.text('67%'), findsOneWidget);
          expect(find.text('33%'), findsOneWidget);
          expect(
            tester.getCenter(amount).dx,
            closeTo(
              tester
                  .getCenter(find.byKey(const ValueKey('legend-amount-short')))
                  .dx,
              0.1,
            ),
          );
          expect(
            tester.getRect(percentage).right,
            closeTo(
              tester
                  .getRect(
                    find.byKey(const ValueKey('legend-percentage-short')),
                  )
                  .right,
              0.1,
            ),
          );
          expect(find.bySemanticsLabel(RegExp(longName)), findsWidgets);
          final table = tester.getRect(find.byType(Table));
          final pie = tester.getRect(find.byType(PieChart));
          if (scale == 1 && width >= 390) {
            expect(table.left, greaterThan(pie.right));
          } else {
            expect(table.top, greaterThan(pie.bottom));
          }
          await tester.tap(category);
          await tester.pumpAndSettle();
          expect(find.text(longName), findsNWidgets(2));
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
        } finally {
          semantics.dispose();
        }
      });
    }
  }
  for (final count in [0, 1, 5, 6, 10]) {
    testWidgets(
      'Compact overview groups $count categories without losing money',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var opened = false;
        final analytics = SpendingAnalytics(
          profileId: 'a',
          month: DateTime(2026, 10),
          transactions: [
            for (var index = 0; index < count; index++)
              FinancialTransaction(
                id: '$index',
                profileId: 'a',
                categoryId: 'Category $index',
                amountMinor: 100 - index,
                type: TransactionType.expense,
                occurredAt: DateTime(2026, 10, 1),
              ),
          ],
        );
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: SingleChildScrollView(
                child: SpendingOverview(
                  compact: true,
                  onShowAll: () => opened = true,
                  analytics: analytics,
                  categories: const [],
                  money: (amount) => '\$$amount',
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (count == 0) {
          expect(find.byType(PieChart), findsNothing);
          expect(find.text('Total expenses: \$0'), findsOneWidget);
          return;
        }
        final pie = tester.widget<PieChart>(find.byType(PieChart));
        expect(pie.data.sections.length, count > 5 ? 5 : count);
        expect(
          pie.data.sections.fold(0.0, (sum, section) => sum + section.value),
          closeTo(100, 0.00001),
        );
        expect(
          tester.getRect(find.byType(Table)).left,
          greaterThan(tester.getRect(find.byType(PieChart)).right),
        );
        expect(
          tester.getSize(find.byKey(const Key('spending-overview'))).height,
          lessThanOrEqualTo(300),
        );
        expect(find.text('October 2026'), findsNothing);
        expect(find.textContaining('Total expenses:'), findsNothing);
        expect(
          find.text('\$${analytics.expenseMinor}'),
          findsNWidgets(count == 1 ? 2 : 1),
        );
        if (count > 5) {
          final other = analytics.categoryMinor.entries
              .skip(4)
              .fold(BigInt.zero, (sum, entry) => sum + entry.value);
          expect(find.text('Other'), findsOneWidget);
          expect(
            find.byKey(const ValueKey('legend-category-Category 4')),
            findsNothing,
          );
          expect(
            tester
                .widget<Text>(find.byKey(const ValueKey('legend-amount-null')))
                .data,
            '\$$other',
          );
          expect(
            pie.data.sections.last.value,
            closeTo(other / analytics.expenseMinor * 100, 0.00001),
          );
          if (count == 10) {
            expect(
              pie.data.sections.last.value,
              greaterThan(pie.data.sections.first.value),
            );
          }
          await tester.tap(find.text('Other'));
          await tester.pumpAndSettle();
          expect(opened, isTrue);
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
        } else {
          expect(find.text('Other'), findsNothing);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Detailed overview retains all categories', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SingleChildScrollView(
            child: SpendingOverview(
              analytics: SpendingAnalytics(
                profileId: 'a',
                month: DateTime(2026, 10),
                transactions: [
                  for (var index = 0; index < 7; index++)
                    FinancialTransaction(
                      id: '$index',
                      profileId: 'a',
                      categoryId: 'Category $index',
                      amountMinor: 100,
                      type: TransactionType.expense,
                      occurredAt: DateTime(2026, 10, 1),
                    ),
                ],
              ),
              categories: const [],
              money: (amount) => '\$$amount',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<PieChart>(find.byType(PieChart)).data.sections,
      hasLength(7),
    );
    expect(find.text('Other'), findsNothing);
    expect(find.text('Category 6'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
