import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../profiles/domain/profile.dart';
import '../../transactions/domain/transaction_filter.dart';
import '../../transactions/presentation/providers/transaction_scope_provider.dart';
import '../domain/spending_analytics.dart';
import 'spending_charts.dart';
import 'stats_providers.dart';
import 'transaction_filter_sheet.dart';

class StatsAnalyticsPanel extends ConsumerStatefulWidget {
  const StatsAnalyticsPanel({
    super.key,
    required this.profile,
    required this.categories,
    required this.money,
  });

  final LocalProfile profile;
  final List<TransactionCategory> categories;
  final String Function(BigInt) money;

  @override
  ConsumerState<StatsAnalyticsPanel> createState() =>
      _StatsAnalyticsPanelState();
}

class _StatsAnalyticsPanelState extends ConsumerState<StatsAnalyticsPanel> {
  SpendingAnalytics? _lastAnalytics;
  TransactionTotals? _lastTotals;
  LocalProfile get profile => widget.profile;
  List<TransactionCategory> get categories => widget.categories;
  String Function(BigInt) get money => widget.money;

  @override
  Widget build(BuildContext context) {
    final scope = ref.watch(transactionScopeProvider(profile.id));
    final filter = scope.ranged;
    final key = (profileId: profile.id, filter: filter);
    final totals = ref.watch(statsTotalsProvider(key));
    final rangeStart = filter.start ?? totals.asData?.value.firstOccurredAt;
    final last = totals.asData?.value.lastOccurredAt?.toLocal();
    final rangeEnd =
        filter.end ??
        (last == null ? null : DateTime(last.year, last.month, last.day + 1));
    final granularity = rangeStart == null || rangeEnd == null
        ? PeriodGranularity.month
        : PeriodGranularity.suggest(rangeStart, rangeEnd);
    final trendKey = (
      profileId: profile.id,
      filter: filter,
      granularity: granularity,
    );
    final categoryTotals = ref.watch(statsCategoriesProvider(key));
    final periods = ref.watch(statsPeriodsProvider(trendKey));
    final isMonth = scope.dates.mode == DateRangeMode.month;
    final month = scope.dates.month ?? scope.dates.start ?? DateTime.now();
    final previousKey = (
      profileId: profile.id,
      filter: filter.withRange(
        DateTime(month.year, month.month - 1),
        DateTime(month.year, month.month),
      ),
    );
    final previous = isMonth
        ? ref.watch(statsTotalsProvider(previousKey))
        : null;
    if (totals.hasError ||
        categoryTotals.hasError ||
        periods.hasError ||
        (previous?.hasError ?? false)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Could not load statistics. Try again.'),
          TextButton(
            onPressed: () {
              ref.invalidate(statsTotalsProvider(key));
              ref.invalidate(statsCategoriesProvider(key));
              ref.invalidate(statsPeriodsProvider(trendKey));
              if (isMonth) ref.invalidate(statsTotalsProvider(previousKey));
            },
            child: const Text('Retry statistics'),
          ),
        ],
      );
    }
    if (!totals.hasValue ||
        !categoryTotals.hasValue ||
        !periods.hasValue ||
        (isMonth && !previous!.hasValue)) {
      if (_lastAnalytics != null) {
        return _content(context, _lastAnalytics!, _lastTotals!, isMonth);
      }
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final analytics = SpendingAnalytics.aggregated(
      month: month,
      totals: totals.requireValue,
      categories: categoryTotals.requireValue,
      periods: periods.requireValue,
      granularity: granularity,
      periodLabel: isMonth ? null : dateScopeLabel(scope.dates),
      comparePreviousMonth: isMonth,
      previousExpense: previous?.requireValue.expense,
    );
    final summary = totals.requireValue;
    _lastAnalytics = analytics;
    _lastTotals = summary;
    return _content(context, analytics, summary, isMonth);
  }

  Widget _content(
    BuildContext context,
    SpendingAnalytics analytics,
    TransactionTotals summary,
    bool isMonth,
  ) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final limit = BigInt.from(9223372036854775807);
    final canShowSummary = [
      summary.income,
      summary.expense,
      summary.savings,
      summary.remaining,
    ].every((amount) => amount.abs() <= limit);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExpenseStatsCard(analytics: analytics, money: money),
        const SizedBox(height: 16),
        SpendingOverview(
          title: 'Expenses by category',
          analytics: analytics,
          categories: categories,
          money: money,
        ),
        const SizedBox(height: 16),
        DailySpendingChart(analytics: analytics, money: money),
        const SizedBox(height: 16),
        Card(
          color: semantic.incomeContainer,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.spa_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    analytics.expenseCount == 0
                        ? 'A fresh start. Record an expense to discover your spending patterns.'
                        : '${analytics.expenseCount} ${analytics.expenseCount == 1 ? 'expense' : 'expenses'} recorded ${isMonth ? 'this month' : 'in this period'}. Every entry helps you see the bigger picture.',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (canShowSummary)
          Card(
            key: const Key('monthly-summary'),
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${isMonth ? 'Monthly' : 'Period'} summary (${profile.currencyCode})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (!canShowSummary && !isMonth)
                    const Text(
                      'Period totals exceed the supported range. Narrow your filters to calculate totals.',
                    ),
                  const SizedBox(height: 12),
                  Text('Income: ${money(summary.income)}'),
                  Text('Expenses: ${money(summary.expense)}'),
                  Text('Savings: ${money(summary.savings)}'),
                  const SizedBox(height: 8),
                  const Text('Remaining to allocate'),
                  Text(
                    money(summary.remaining),
                    key: const Key('remaining-amount'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 24),
        if (!isMonth)
          const Text('Budget targets are available in Month view only.'),
      ],
    );
  }
}
