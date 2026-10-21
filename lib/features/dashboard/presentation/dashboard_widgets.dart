import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../budgets/domain/budget_calculator.dart';

class DashboardSummaryCard extends StatelessWidget {
  const DashboardSummaryCard({
    required this.summary,
    required this.money,
    required this.currencyCode,
    required this.isEmpty,
    required this.incomeCount,
    required this.expenseCount,
    required this.budgetLabel,
    required this.onBudget,
    this.savingsTarget,
    super.key,
  });

  final BudgetSummary summary;
  final String Function(int) money;
  final String currencyCode;
  final bool isEmpty;
  final int incomeCount;
  final int expenseCount;
  final String budgetLabel;
  final VoidCallback? onBudget;
  final int? savingsTarget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = theme.extension<AppSemanticColors>()!;
    final used =
        BigInt.from(summary.expenseMinor) + BigInt.from(summary.savingsMinor);
    final ratio = summary.incomeMinor == 0
        ? (used == BigInt.zero ? 0.0 : 1.0)
        : used / BigInt.from(summary.incomeMinor);
    final allocatedPercent = (ratio * 100).toStringAsFixed(1);
    final remaining = summary.remainingMinor;
    final status = isEmpty
        ? 'Clean slate'
        : remaining < 0
        ? 'Over allocated'
        : remaining == 0
        ? 'Fully allocated'
        : 'Available';
    return Card(
      key: const Key('dashboard-summary'),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Remaining to allocate',
                  style: theme.textTheme.titleSmall,
                ),
                Tooltip(
                  triggerMode: TooltipTriggerMode.tap,
                  message:
                      'Income minus expenses and savings recorded this month.',
                  child: Icon(
                    Icons.info_outline,
                    size: 18,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: remaining < 0
                        ? semantic.expenseContainer
                        : colors.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(status, style: theme.textTheme.labelMedium),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Semantics(
              label: 'Remaining to allocate: ${money(remaining)}',
              child: Text(
                money(remaining),
                key: const Key('remaining-amount'),
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
            ),
            Text(currencyCode, style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            const Text('Money left after expenses and savings'),
            if (!isEmpty) ...[
              const SizedBox(height: 20),
              LinearProgressIndicator(
                value: ratio.clamp(0, 1),
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
                color: remaining < 0 ? semantic.expense : colors.primary,
                backgroundColor: colors.surfaceContainerHighest,
                semanticsLabel: 'Income allocated to expenses and savings',
                semanticsValue:
                    '${(ratio.clamp(0, 1) * 100).toStringAsFixed(1)}%',
              ),
              const SizedBox(height: 8),
              Text(
                summary.incomeMinor == 0
                    ? 'Record income to see your allocation'
                    : '$allocatedPercent% of income allocated',
              ),
            ],
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final stack =
                    constraints.maxWidth < 270 ||
                    MediaQuery.textScalerOf(context).scale(16) > 22;
                final tiles = [
                  _SummaryMetric(
                    label: 'Income',
                    amount: '+${money(summary.incomeMinor)}',
                    detail: incomeCount == 0
                        ? 'Waiting for funds'
                        : '$incomeCount ${incomeCount == 1 ? 'transaction' : 'transactions'}',
                    icon: Icons.south,
                    color: semantic.income,
                    background: semantic.incomeContainer,
                  ),
                  _SummaryMetric(
                    label: 'Expenses',
                    amount: '-${money(summary.expenseMinor)}',
                    detail: expenseCount == 0
                        ? 'No spend yet'
                        : '$expenseCount ${expenseCount == 1 ? 'transaction' : 'transactions'}',
                    icon: Icons.north,
                    color: semantic.expense,
                    background: semantic.expenseContainer,
                  ),
                ];
                return stack
                    ? Column(
                        children: [
                          tiles[0],
                          const SizedBox(height: 12),
                          tiles[1],
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: tiles[0]),
                          const SizedBox(width: 12),
                          Expanded(child: tiles[1]),
                        ],
                      );
              },
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.savings_outlined, color: colors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Savings: ${money(summary.savingsMinor)}'),
                      ),
                    ],
                  ),
                  if (savingsTarget != null)
                    Text('Savings target: ${money(savingsTarget!)}'),
                  TextButton(onPressed: onBudget, child: Text(budgetLabel)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.amount,
    required this.detail,
    required this.icon,
    required this.color,
    required this.background,
  });
  final String label;
  final String amount;
  final String detail;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
    key: ValueKey('summary-${label.toLowerCase()}'),
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.labelLarge),
            ),
            CircleAvatar(
              radius: 14,
              backgroundColor: background,
              child: Icon(icon, color: color, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          amount,
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(detail),
      ],
    ),
  );
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
            width: 180,
            height: 140,
            excludeFromSemantics: true,
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions in ${DateFormat.MMMM().format(month)}!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
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
            _destination(context, 0, 'Home', Icons.grid_view_outlined),
            _destination(context, 1, 'History', Icons.receipt_long_outlined),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SizedBox(
                width: 58,
                height: 58,
                child: IconButton.filled(
                  key: const Key('add-transaction'),
                  tooltip: 'Add transaction',
                  onPressed: onAdd,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  icon: const Icon(Icons.add, size: 32),
                ),
              ),
            ),
            _destination(context, 2, 'Budget', Icons.pie_chart_outline),
            _destination(context, 3, 'Profile', Icons.account_circle_outlined),
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
      child: InkWell(
        key: ValueKey('dashboard-tab-$index'),
        borderRadius: BorderRadius.circular(20),
        onTap: () => onSelected(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected == index
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
