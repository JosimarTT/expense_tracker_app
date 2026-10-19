import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../core/money/money_format.dart';
import '../../budgets/domain/budget_calculator.dart';
import '../../budgets/domain/entities/budget_rule.dart';
import '../../budgets/presentation/budget_dialog.dart';
import '../../profiles/domain/profile.dart';
import '../../profiles/presentation/delete_profile_dialog.dart';
import '../../profiles/presentation/category_manager_dialog.dart';
import '../../profiles/presentation/category_editor_dialog.dart';
import '../../profiles/presentation/profile_dialog.dart';
import '../../transactions/domain/entities/financial_transaction.dart';
import '../../transactions/presentation/providers/transaction_providers.dart';
import '../../transactions/presentation/transaction_dialog.dart';
import '../../schedules/presentation/schedule_processor.dart';
import '../../schedules/presentation/schedules_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  String? _selectedId;

  Future<void> _createProfile() async {
    final id = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ProfileDialog(),
    );
    if (id != null && mounted) setState(() => _selectedId = id);
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(profilesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            onPressed: _createProfile,
            tooltip: 'Create profile',
            icon: const Icon(Icons.person_add_alt_1),
          ),
        ],
      ),
      body: profiles.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _LoadError(
          message:
              'Could not load local profiles. Your data has not been reset.',
          retry: () => ref.invalidate(profilesProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Your finances, local first'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _createProfile,
                    child: const Text('Create your first profile'),
                  ),
                ],
              ),
            );
          }
          final selected =
              items.where((profile) => profile.id == _selectedId).firstOrNull ??
              items.first;
          return ScheduleProcessor(
            profiles: items,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    key: ValueKey(selected.id),
                    initialValue: selected.id,
                    decoration: const InputDecoration(
                      labelText: 'Active profile',
                    ),
                    items: [
                      for (final profile in items)
                        DropdownMenuItem(
                          value: profile.id,
                          child: Text(
                            '${profile.name} (${profile.currencyCode})',
                          ),
                        ),
                    ],
                    onChanged: (id) => setState(() => _selectedId = id),
                  ),
                ),
                Expanded(
                  child: _ProfileDashboard(
                    key: ValueKey(selected.id),
                    profile: selected,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileDashboard extends ConsumerStatefulWidget {
  const _ProfileDashboard({required this.profile, super.key});
  final LocalProfile profile;

  @override
  ConsumerState<_ProfileDashboard> createState() => _ProfileDashboardState();
}

class _ProfileDashboardState extends ConsumerState<_ProfileDashboard> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  final _deleting = <String>{};

  String _money(int minor) => formatMoney(
    minor,
    widget.profile.currencyCode,
    widget.profile.currencyScale,
    locale: View.of(context).platformDispatcher.locale.toString(),
  );

  Future<void> _deleteProfile() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DeleteProfileDialog(profileName: widget.profile.name),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref
          .read(profileRepositoryProvider)
          .deletePermanently(widget.profile.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile "${widget.profile.name}" was permanently deleted.',
            ),
          ),
        );
      }
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete profile: $error')),
        );
      }
    }
  }

  Future<void> _delete(FinancialTransaction transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: const Text('The entry will be removed from your totals.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _deleting.add(transaction.id));
    try {
      await ref
          .read(transactionRepositoryProvider)
          .delete(profileId: widget.profile.id, transactionId: transaction.id);
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete transaction: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _deleting.remove(transaction.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.profile.id;
    final categories = ref.watch(categoriesProvider(id));
    final transactions = ref.watch(transactionsProvider(id));
    final budgets = ref.watch(budgetsProvider(id));
    if (categories.hasError || transactions.hasError || budgets.hasError) {
      return _LoadError(
        message: 'Could not load this profile. Try again.',
        retry: () {
          ref.invalidate(categoriesProvider(id));
          ref.invalidate(transactionsProvider(id));
          ref.invalidate(budgetsProvider(id));
        },
      );
    }
    if (!categories.hasValue || !transactions.hasValue || !budgets.hasValue) {
      return const Center(child: CircularProgressIndicator());
    }
    final start = _month.toUtc();
    final end = DateTime(_month.year, _month.month + 1).toUtc();
    final monthly = transactions.requireValue
        .where(
          (row) =>
              !row.occurredAt.isBefore(start) && row.occurredAt.isBefore(end),
        )
        .toList();
    final rule = budgets.requireValue
        .where(
          (budget) => budget.periodStart == start && budget.periodEnd == end,
        )
        .firstOrNull;
    BudgetSummary? summary;
    try {
      summary = const BudgetCalculator().calculate(
        rule:
            rule ??
            BudgetRule(
              id: 'summary-only',
              profileId: id,
              name: 'Monthly summary',
              periodStart: start,
              periodEnd: end,
              buckets: [
                BudgetBucket(
                  id: 'unallocated',
                  name: 'Unallocated',
                  allocationBps: 10000,
                ),
              ],
            ),
        transactions: monthly,
      );
    } on StateError {
      // Keep entries editable even when an aggregate cannot be represented.
      summary = null;
    }
    final canEditBudget =
        rule == null ||
        (rule.buckets.length == 3 &&
            rule.buckets.every(
              (bucket) => {'needs', 'wants', 'savings'}.contains(bucket.id),
            ) &&
            rule.buckets
                .firstWhere((bucket) => bucket.id == 'savings')
                .categoryIds
                .isEmpty);
    final names = {
      for (final category in categories.requireValue)
        category.id: category.name,
    };
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            key: const Key('delete-profile'),
            onPressed: _deleteProfile,
            icon: const Icon(Icons.delete_forever_outlined),
            label: const Text('Delete Profile'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              tooltip: 'Previous month',
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(
                () => _month = DateTime(_month.year, _month.month - 1),
              ),
            ),
            Text(
              DateFormat.yMMMM().format(_month),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            IconButton(
              tooltip: 'Next month',
              icon: const Icon(Icons.chevron_right),
              onPressed: () => setState(
                () => _month = DateTime(_month.year, _month.month + 1),
              ),
            ),
          ],
        ),
        if (summary == null)
          const Text(
            'Monthly totals exceed the supported range. Edit or delete an entry to calculate totals.',
          )
        else ...[
          Text('Income: ${_money(summary.incomeMinor)}'),
          Text('Expenses: ${_money(summary.expenseMinor)}'),
          Text('Net income: ${_money(summary.balanceMinor)}'),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (_) => SchedulesPage(profile: widget.profile),
                ),
              ),
              icon: const Icon(Icons.event_repeat),
              label: const Text('Scheduled transactions'),
            ),
            OutlinedButton.icon(
              key: const Key('manage-categories'),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => CategoryManagerDialog(profileId: id),
              ),
              icon: const Icon(Icons.category_outlined),
              label: const Text('Manage categories'),
            ),
            FilledButton.icon(
              onPressed:
                  !categories.requireValue.any(
                    (category) => !category.isArchived,
                  )
                  ? null
                  : () => showDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => TransactionDialog(
                        profile: widget.profile,
                        categories: categories.requireValue,
                      ),
                    ),
              icon: const Icon(Icons.add),
              label: const Text('Add transaction'),
            ),
            OutlinedButton(
              onPressed: !canEditBudget
                  ? null
                  : () => showDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => BudgetDialog(
                        profileId: id,
                        month: _month,
                        categories: categories.requireValue,
                        existing: rule,
                      ),
                    ),
              child: Text(
                rule == null ? 'Set monthly budget' : 'Edit monthly budget',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (rule == null)
          const Text(
            'No budget saved for this month. Set your allocation to see progress.',
          )
        else if (summary != null) ...[
          if (summary.incomeMinor == 0)
            const Text(
              'No income this month. Budget limits are zero until income is recorded.',
            ),
          for (final progress in summary.buckets)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${progress.bucket.name} (${progress.bucket.allocationBps / 100}%)',
                    ),
                    if (progress.bucket.id == 'savings') ...[
                      Text('Savings target: ${_money(progress.targetMinor)}'),
                      const Text(
                        'Target only; savings transfers are not tracked as spending.',
                      ),
                    ] else ...[
                      Text(
                        '${_money(progress.spentMinor)} of ${_money(progress.targetMinor)}',
                      ),
                      LinearProgressIndicator(
                        value: progress.progress,
                        semanticsLabel: '${progress.bucket.name} spending',
                        color: progress.isOverBudget
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
                      if (progress.isOverBudget)
                        Text(
                          'Over budget by ${_money(progress.spentMinor - progress.targetMinor)}',
                        ),
                    ],
                  ],
                ),
              ),
            ),
          Text(
            'Unallocated expenses: ${_money(summary.unallocatedExpenseMinor)}',
          ),
        ],
        if (!canEditBudget)
          const Text(
            'This rule has custom buckets. The current editor supports Needs/Wants/Savings only and will not overwrite it.',
          ),
        const SizedBox(height: 16),
        Text('Transactions', style: Theme.of(context).textTheme.titleLarge),
        if (monthly.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text('No transactions in this month.'),
          ),
        for (final transaction in monthly)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: Color(
                categories.requireValue
                        .where(
                          (category) => category.id == transaction.categoryId,
                        )
                        .firstOrNull
                        ?.colorArgb ??
                    0xFF455A64,
              ),
              child: Icon(
                categoryIcons[categories.requireValue
                        .where(
                          (category) => category.id == transaction.categoryId,
                        )
                        .firstOrNull
                        ?.iconKey] ??
                    Icons.category,
                color: Colors.white,
              ),
            ),
            title: Text(
              transaction.notes.isEmpty
                  ? names[transaction.categoryId] ?? transaction.categoryId
                  : transaction.notes,
            ),
            subtitle: Text(
              '${names[transaction.categoryId] ?? transaction.categoryId} - ${DateFormat.yMMMd().format(transaction.occurredAt.toLocal())}',
            ),
            onTap: _deleting.contains(transaction.id)
                ? null
                : () => showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => TransactionDialog(
                      profile: widget.profile,
                      categories: categories.requireValue,
                      existing: transaction,
                    ),
                  ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${transaction.type == TransactionType.income ? '+' : '-'}${_money(transaction.amountMinor)}',
                ),
                IconButton(
                  tooltip:
                      'Delete ${transaction.notes.isEmpty ? names[transaction.categoryId] ?? transaction.categoryId : transaction.notes}',
                  onPressed: _deleting.contains(transaction.id)
                      ? null
                      : () => _delete(transaction),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.retry});
  final String message;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message, textAlign: TextAlign.center),
        TextButton(onPressed: retry, child: const Text('Retry')),
      ],
    ),
  );
}
