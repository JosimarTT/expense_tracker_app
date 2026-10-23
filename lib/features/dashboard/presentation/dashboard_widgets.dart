import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../budgets/domain/budget_calculator.dart';

class DashboardSummaryCard extends StatelessWidget {
  const DashboardSummaryCard({
    required this.summary,
    required this.money,
    super.key,
  });

  final BudgetSummary summary;
  final String Function(int) money;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.extension<AppSemanticColors>()!;
    return Column(
      key: const Key('dashboard-summary'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked =
                constraints.maxWidth < 340 ||
                MediaQuery.textScalerOf(context).scale(16) > 18;
            final tiles = [
              _SummaryMetric(
                label: 'Expenses',
                amount: '-${money(summary.expenseMinor)}',
                icon: Icons.call_made_rounded,
                background: semantic.expenseContainer,
                accent: semantic.onExpenseContainer,
                compact: !stacked,
              ),
              _SummaryMetric(
                label: 'Income',
                amount: '+${money(summary.incomeMinor)}',
                icon: Icons.call_received_rounded,
                background: semantic.incomeContainer,
                accent: semantic.onIncomeContainer,
                compact: !stacked,
              ),
              _SummaryMetric(
                label: 'Savings',
                amount: money(summary.savingsMinor),
                icon: Icons.savings_rounded,
                background: semantic.infoContainer,
                accent: semantic.onInfoContainer,
                compact: !stacked,
              ),
            ];
            if (stacked) {
              return Column(
                children: [
                  for (var i = 0; i < tiles.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    tiles[i],
                  ],
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < tiles.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: tiles[i]),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.amount,
    required this.icon,
    required this.background,
    required this.accent,
    required this.compact,
  });
  final String label;
  final String amount;
  final IconData icon;
  final Color background;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      key: ValueKey('summary-${label.toLowerCase()}'),
      margin: EdgeInsets.zero,
      color: background,
      child: Padding(
        padding: EdgeInsets.all(compact ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: accent, size: compact ? 20 : 24),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style:
                        (compact ? textTheme.labelLarge : textTheme.titleMedium)
                            ?.copyWith(color: accent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style:
                  (compact
                          ? textTheme.titleMedium?.copyWith(fontSize: 14)
                          : textTheme.headlineMedium)
                      ?.copyWith(color: accent),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardEmptyState extends StatelessWidget {
  const DashboardEmptyState({
    required this.month,
    required this.onAdd,
    super.key,
  });
  final DateTime month;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) => Card(
    key: const Key('dashboard-empty'),
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          SvgPicture.asset(
            'assets/images/welcome-mascot.svg',
            width: 140,
            height: 100,
            excludeFromSemantics: true,
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions in ${DateFormat.MMMM().format(month)}!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          const Text(
            'A fresh start for your money. Log your first coffee, grocery run, or paycheck to get started.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add first transaction'),
          ),
        ],
      ),
    ),
  );
}

class DashboardBottomBar extends StatelessWidget {
  const DashboardBottomBar({
    required this.selected,
    required this.onSelected,
    required this.onAdd,
    super.key,
  });
  final int selected;
  final ValueChanged<int> onSelected;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          children: [
            _destination(context, 0, 'Home', Icons.home_outlined),
            _destination(
              context,
              1,
              'Transactions',
              Icons.receipt_long_outlined,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SizedBox(
                width: 54,
                height: 54,
                child: IconButton.filled(
                  key: const Key('add-transaction'),
                  tooltip: 'Add transaction',
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 28),
                ),
              ),
            ),
            _destination(context, 2, 'Stats', Icons.bar_chart_outlined),
            _destination(context, 3, 'Profile', Icons.person_outline),
          ],
        ),
      ),
    ),
  );

  Widget _destination(
    BuildContext context,
    int index,
    String label,
    IconData icon,
  ) => Expanded(
    child: Semantics(
      selected: selected == index,
      button: true,
      label: label,
      child: InkWell(
        key: ValueKey('dashboard-tab-$index'),
        borderRadius: BorderRadius.circular(20),
        onTap: () => onSelected(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: selected == index
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
