import 'package:expense_tracker_app/app/theme/app_theme.dart';
import 'package:expense_tracker_app/features/dashboard/presentation/spending_charts.dart';
import 'package:expense_tracker_app/features/dashboard/presentation/stats_analytics_panel.dart';
import 'package:expense_tracker_app/features/dashboard/presentation/stats_providers.dart';
import 'package:expense_tracker_app/features/profiles/domain/profile.dart';
import 'package:expense_tracker_app/features/transactions/domain/transaction_filter.dart';
import 'package:expense_tracker_app/features/transactions/presentation/providers/transaction_scope_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const profile = LocalProfile(
    id: 'a',
    name: 'Profile',
    currencyCode: 'USD',
    currencyScale: 2,
  );

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    for (final (size, scale) in [
      (const Size(320, 568), 2.0),
      (const Size(390, 844), 1.0),
      (const Size(1000, 900), 1.0),
    ]) {
      testWidgets('Filtered Stats fits ${theme.brightness} $size at $scale', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              statsTotalsProvider.overrideWith(
                (ref, key) => Stream.value(
                  TransactionTotals(
                    expenseMinor: BigInt.from(300),
                    expenseCount: 2,
                  ),
                ),
              ),
              statsCategoriesProvider.overrideWith(
                (ref, key) => Stream.value({'food': BigInt.from(300)}),
              ),
              statsPeriodsProvider.overrideWith(
                (ref, key) => Stream.value([
                  for (var month = 1; month <= 2; month++)
                    PeriodTotal(
                      start: DateTime(2026, month),
                      end: DateTime(2026, month + 1),
                      totals: TransactionTotals(
                        expenseMinor: BigInt.from(month * 100),
                      ),
                    ),
                ]),
              ),
            ],
            child: MaterialApp(
              theme: theme,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: Scaffold(
                body: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    StatsAnalyticsPanel(
                      profile: profile,
                      categories: const [],
                      money: (amount) => '\$$amount',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        final container = ProviderScope.containerOf(
          tester.element(find.byType(StatsAnalyticsPanel)),
        );
        container
            .read(transactionScopeProvider('a').notifier)
            .setDates(const DateScope.allTime());
        await tester.pumpAndSettle();
        expect(find.textContaining('vs previous month'), findsNothing);
        await tester.scrollUntilVisible(find.byType(DailySpendingChart), 150);
        expect(find.text('Monthly trend'), findsOneWidget);
        final chart = tester.widget<LineChart>(find.byType(LineChart));
        expect(chart.data.lineBarsData.single.spots.map((spot) => spot.y), [
          0.5,
          1.0,
        ]);
        await tester.scrollUntilVisible(
          find.byKey(const Key('monthly-summary')),
          150,
        );
        expect(find.text('Period summary (USD)'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      });
    }
  }

  testWidgets('Stats failures are explicit and retryable', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statsTotalsProvider.overrideWith(
            (ref, key) => Stream.error(StateError('Database unavailable')),
          ),
          statsCategoriesProvider.overrideWith((ref, key) => Stream.value({})),
          statsPeriodsProvider.overrideWith((ref, key) => Stream.value([])),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: StatsAnalyticsPanel(
              profile: profile,
              categories: const [],
              money: (amount) => '\$$amount',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Could not load statistics. Try again.'), findsOneWidget);
    expect(find.text('Retry statistics'), findsOneWidget);
    expect(find.byType(ExpenseStatsCard), findsNothing);
    await tester.tap(find.text('Retry statistics'));
    await tester.pumpAndSettle();
    expect(find.text('Could not load statistics. Try again.'), findsOneWidget);
  });

  for (final (days, expected) in [
    (1, PeriodGranularity.day),
    (100, PeriodGranularity.week),
    (400, PeriodGranularity.month),
  ]) {
    testWidgets('All time chooses $expected for $days days of matches', (
      tester,
    ) async {
      final first = DateTime(2026, 1, 1);
      final last = DateTime(2026, 1, days);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            statsTotalsProvider.overrideWith(
              (ref, key) => Stream.value(
                TransactionTotals(
                  expenseMinor: BigInt.from(100),
                  expenseCount: 1,
                  firstOccurredAt: first.toUtc(),
                  lastOccurredAt: last.toUtc(),
                ),
              ),
            ),
            statsCategoriesProvider.overrideWith(
              (ref, key) => Stream.value({'food': BigInt.from(100)}),
            ),
            statsPeriodsProvider.overrideWith(
              (ref, key) => Stream.value([
                PeriodTotal(
                  start: key.granularity.floor(first),
                  end: key.granularity.next(key.granularity.floor(first)),
                  totals: TransactionTotals(expenseMinor: BigInt.from(100)),
                ),
              ]),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: SingleChildScrollView(
                child: StatsAnalyticsPanel(
                  profile: profile,
                  categories: const [],
                  money: (amount) => '\$$amount',
                ),
              ),
            ),
          ),
        ),
      );
      final container = ProviderScope.containerOf(
        tester.element(find.byType(StatsAnalyticsPanel)),
      );
      container
          .read(transactionScopeProvider('a').notifier)
          .setDates(const DateScope.allTime());
      await tester.pumpAndSettle();
      final chart = tester.widget<DailySpendingChart>(
        find.byType(DailySpendingChart),
      );
      expect(chart.analytics.granularity, expected);
      expect(chart.analytics.comparePreviousMonth, isFalse);
      expect(tester.takeException(), isNull);
    });
  }
}
