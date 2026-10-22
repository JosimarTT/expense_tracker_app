import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../profiles/domain/profile.dart';
import '../domain/spending_analytics.dart';

class SpendingOverview extends StatelessWidget {
  const SpendingOverview({
    required this.analytics,
    required this.categories,
    required this.money,
    this.title = 'Spending overview',
    super.key,
  });

  final SpendingAnalytics analytics;
  final List<TransactionCategory> categories;
  final String Function(BigInt) money;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = analytics.categoryMinor.entries.toList()
      ..sort((a, b) {
        final amount = b.value.compareTo(a.value);
        return amount != 0 ? amount : a.key.compareTo(b.key);
      });
    final names = {
      for (final category in categories) category.id: category.name,
    };
    const accents = [
      AppColors.coral,
      AppColors.sky,
      AppColors.lavender,
      AppColors.mint,
      AppColors.primary,
    ];
    final legend = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < entries.length; index++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: accents[index % accents.length],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${names[entries[index].key] ?? entries[index].key}  '
                    '${money(entries[index].value)}  '
                    '${(entries[index].value / analytics.expenseMinor * 100).toStringAsFixed(1)}%',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
    final chart = SizedBox(
      height: 140,
      width: 140,
      child: Semantics(
        container: true,
        label:
            'Total expenses: ${money(analytics.expenseMinor)}. Category breakdown follows.',
        child: ExcludeSemantics(
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                duration: Duration.zero,
                PieChartData(
                  centerSpaceRadius: 44,
                  sectionsSpace: 2,
                  pieTouchData: PieTouchData(enabled: false),
                  sections: [
                    for (var index = 0; index < entries.length; index++)
                      PieChartSectionData(
                        value:
                            entries[index].value / analytics.expenseMinor * 100,
                        color: accents[index % accents.length],
                        radius: 24,
                        showTitle: false,
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (money(analytics.expenseMinor).length <= 12 &&
                        MediaQuery.textScalerOf(context).scale(16) <= 20)
                      Text(
                        money(analytics.expenseMinor),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelLarge,
                      ),
                    const Text('Total', textAlign: TextAlign.center),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return Card(
      key: const Key('spending-overview'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            Text(DateFormat.yMMMM().format(analytics.month)),
            Text('Total expenses: ${money(analytics.expenseMinor)}'),
            const SizedBox(height: 16),
            if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No expenses this month. Your category breakdown will appear here.',
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 300 ||
                      MediaQuery.textScalerOf(context).scale(16) > 22) {
                    return Column(
                      children: [
                        Center(child: chart),
                        const SizedBox(height: 16),
                        legend,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      chart,
                      const SizedBox(width: 16),
                      Expanded(child: legend),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class ExpenseStatsCard extends StatelessWidget {
  const ExpenseStatsCard({
    required this.analytics,
    required this.money,
    super.key,
  });
  final SpendingAnalytics analytics;
  final String Function(BigInt) money;

  @override
  Widget build(BuildContext context) {
    final change = analytics.changePercent;
    final theme = Theme.of(context);
    return Card(
      key: const Key('expense-stats'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total expenses', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    money(analytics.expenseMinor),
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    change == null
                        ? 'No expenses recorded in the previous month to compare.'
                        : '${change > 0
                                  ? 'Up'
                                  : change < 0
                                  ? 'Down'
                                  : 'Unchanged'} '
                              '${change.abs().toStringAsFixed(1)}% vs previous month (full month).',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ExcludeSemantics(
              child: SvgPicture.asset(
                'assets/images/welcome-mascot.svg',
                width: 80,
                height: 80,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DailySpendingChart extends StatelessWidget {
  const DailySpendingChart({
    required this.analytics,
    required this.money,
    super.key,
  });
  final SpendingAnalytics analytics;
  final String Function(BigInt) money;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.extension<AppSemanticColors>()!;
    final max = analytics.dailyMinor.fold(BigInt.zero, (a, b) => a > b ? a : b);
    final descriptions = [
      for (var index = 0; index < analytics.dailyMinor.length; index++)
        if (analytics.dailyMinor[index] > BigInt.zero)
          '${DateFormat.MMMd().format(DateTime(analytics.month.year, analytics.month.month, index + 1))}: ${money(analytics.dailyMinor[index])}',
    ];
    return Card(
      key: const Key('daily-spending'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily trend', style: theme.textTheme.titleMedium),
            Text(
              'Daily expenses - ${DateFormat.yMMMM().format(analytics.month)}',
            ),
            const SizedBox(height: 16),
            if (max == BigInt.zero)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('Record an expense to see your daily trend.'),
              )
            else ...[
              Text('Highest daily spending: ${money(max)}'),
              const SizedBox(height: 12),
              Semantics(
                container: true,
                label: 'Daily expenses. ${descriptions.join('. ')}',
                child: ExcludeSemantics(
                  child: SizedBox(
                    height: 180,
                    child: LineChart(
                      duration: Duration.zero,
                      LineChartData(
                        minX: 1,
                        maxX: analytics.dailyMinor.length.toDouble(),
                        minY: 0,
                        maxY: 1,
                        clipData: const FlClipData.all(),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 7,
                              reservedSize:
                                  MediaQuery.textScalerOf(context).scale(20) +
                                  8,
                              getTitlesWidget: (value, meta) => Text(
                                '${value.toInt()}',
                                style: theme.textTheme.labelSmall,
                              ),
                            ),
                          ),
                        ),
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (spots) => [
                              for (final spot in spots)
                                LineTooltipItem(
                                  'Day ${spot.x.toInt()}\n${money(analytics.dailyMinor[spot.x.toInt() - 1])}',
                                  TextStyle(color: theme.colorScheme.onSurface),
                                ),
                            ],
                            getTooltipColor: (_) => theme.colorScheme.surface,
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              for (
                                var index = 0;
                                index < analytics.dailyMinor.length;
                                index++
                              )
                                FlSpot(
                                  index + 1.0,
                                  analytics.dailyMinor[index] / max,
                                ),
                            ],
                            color: semantic.income,
                            barWidth: 2,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: semantic.incomeContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
