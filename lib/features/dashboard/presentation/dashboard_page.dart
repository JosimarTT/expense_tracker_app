import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/money/money_format.dart';
import '../../budgets/domain/budget_calculator.dart';
import '../../budgets/domain/entities/budget_rule.dart';
import '../../budgets/presentation/budget_dialog.dart';
import '../../profiles/domain/profile.dart';
import '../../profiles/presentation/category_avatar.dart';
import '../../profiles/presentation/category_manager_dialog.dart';
import '../../profiles/presentation/delete_profile_dialog.dart';
import '../../profiles/presentation/profile_avatar.dart';
import '../../profiles/presentation/profile_dialog.dart';
import '../../profiles/presentation/profile_selector.dart';
import '../../profiles/presentation/welcome_view.dart';
import '../../schedules/presentation/schedule_processor.dart';
import '../../schedules/presentation/schedules_page.dart';
import '../../transactions/domain/entities/financial_transaction.dart';
import '../../transactions/presentation/providers/transaction_providers.dart';
import '../../transactions/presentation/transaction_dialog.dart';
import '../domain/spending_analytics.dart';
import 'dashboard_widgets.dart';
import 'home_transaction_date.dart';
import 'spending_charts.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  String? _selectedId;
  bool _creatingProfile = false;

  Future<void> _createProfile() async {
    if (_creatingProfile) return;
    setState(() => _creatingProfile = true);
    try {
      final id = await showProfileDialog(context);
      if (id != null && mounted) setState(() => _selectedId = id);
    } finally {
      if (mounted) setState(() => _creatingProfile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(profilesProvider);
    return Scaffold(
      body: profiles.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _LoadError(
          message:
              'Could not load local profiles. Your data has not been reset.',
          retry: () => ref.invalidate(profilesProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return WelcomeView(onCreateProfile: _createProfile);
          }
          final selected =
              items.where((profile) => profile.id == _selectedId).firstOrNull ??
              items.first;
          return ScheduleProcessor(
            profiles: items,
            child: _ProfileDashboard(
              key: ValueKey(selected.id),
              profile: selected,
              profiles: items,
              onSelected: (id) => setState(() => _selectedId = id),
              onCreateProfile: _creatingProfile ? null : _createProfile,
            ),
          );
        },
      ),
    );
  }
}

class _ProfileDashboard extends ConsumerStatefulWidget {
  const _ProfileDashboard({
    required this.profile,
    required this.profiles,
    required this.onSelected,
    required this.onCreateProfile,
    super.key,
  });
  final LocalProfile profile;
  final List<LocalProfile> profiles;
  final ValueChanged<String> onSelected;
  final VoidCallback? onCreateProfile;

  @override
  ConsumerState<_ProfileDashboard> createState() => _ProfileDashboardState();
}

class _ProfileDashboardState extends ConsumerState<_ProfileDashboard> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  final _deleting = <String>{};
  bool _savingAutomatic = false;
  int _tab = 0;
  TransactionType? _filter;
  bool _searching = false;
  bool _oldestFirst = false;
  bool _swipeHintDismissed = false;
  final _search = TextEditingController();

  Future<void> _showSortSheet() => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (label, oldest) in [
            ('Newest first', false),
            ('Oldest first', true),
          ])
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text(label),
              trailing: _oldestFirst == oldest ? const Icon(Icons.check) : null,
              onTap: () {
                setState(() => _oldestFirst = oldest);
                Navigator.pop(sheetContext);
              },
            ),
        ],
      ),
    ),
  );

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  String _analyticsMoney(BigInt amount) =>
      amount > BigInt.from(9223372036854775807)
      ? 'Total exceeds supported range'
      : _money(amount.toInt());

  String _dayLabel(DateTime date) {
    final local = date.toLocal();
    final today = DateUtils.dateOnly(DateTime.now());
    if (DateUtils.isSameDay(local, today)) return 'Today';
    if (DateUtils.isSameDay(
      local,
      DateTime(today.year, today.month, today.day - 1),
    )) {
      return 'Yesterday';
    }
    return DateFormat.yMMMd().format(local);
  }

  Widget _header() {
    final monthPicker = Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(28),
      child: Row(
        mainAxisSize: _tab == 1 ? MainAxisSize.max : MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Previous month',
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(
              () => _month = DateTime(_month.year, _month.month - 1),
            ),
          ),
          Flexible(
            fit: _tab == 1 ? FlexFit.tight : FlexFit.loose,
            child: Text(
              DateFormat.yMMM().format(_month),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge,
            ),
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
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_tab == 1 && _searching) ...[
            TextField(
              controller: _search,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Category, notes or amount',
                prefixIcon: IconButton(
                  tooltip: 'Close search',
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() {
                    _searching = false;
                    _search.clear();
                  }),
                ),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(_search.clear),
                      ),
              ),
            ),
            const SizedBox(height: 12),
          ] else if (_tab != 0) ...[
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(switch (_tab) {
                        1 => 'Transactions',
                        2 => 'Stats',
                        _ => 'Profile & settings',
                      }, style: Theme.of(context).textTheme.headlineMedium),
                    ],
                  ),
                ),
                if (_tab == 1) ...[
                  IconButton(
                    tooltip: 'Search transactions',
                    icon: const Icon(Icons.search),
                    onPressed: () => setState(() => _searching = true),
                  ),
                  Badge(
                    isLabelVisible: _oldestFirst,
                    smallSize: 8,
                    alignment: const AlignmentDirectional(28, 8),
                    child: IconButton(
                      tooltip: 'Sort transactions',
                      icon: const Icon(Icons.tune),
                      onPressed: _showSortSheet,
                    ),
                  ),
                ] else
                  IconButton(
                    tooltip: 'Settings and tracker management',
                    onPressed: () => setState(() => _tab = 3),
                    icon: ProfileAvatarIcon(avatar: widget.profile.avatar),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          LayoutBuilder(
            builder: (context, constraints) {
              if (_tab == 1) return monthPicker;
              final profilePicker = ProfileSelector(
                compact: true,
                profiles: widget.profiles,
                selected: widget.profile,
                onSelected: widget.onSelected,
              );
              if (constraints.maxWidth < 350 ||
                  MediaQuery.textScalerOf(context).scale(16) > 22) {
                return Column(
                  children: [
                    profilePicker,
                    const SizedBox(height: 8),
                    monthPicker,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: profilePicker),
                  const SizedBox(width: 8),
                  monthPicker,
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _setAutomaticSavings(bool value) async {
    setState(() => _savingAutomatic = true);
    try {
      await ref
          .read(savingsRepositoryProvider)
          .setAutomatic(widget.profile.id, value, DateTime.now());
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update automatic savings: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _savingAutomatic = false);
    }
  }

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
    final monthly =
        transactions.requireValue
            .where(
              (row) =>
                  !row.occurredAt.isBefore(start) &&
                  row.occurredAt.isBefore(end),
            )
            .toList()
          ..sort((a, b) {
            final byDate = b.occurredAt.compareTo(a.occurredAt);
            return byDate != 0 ? byDate : a.id.compareTo(b.id);
          });
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
    final canAdd = categories.requireValue.any(
      (category) => !category.isArchived && !category.isSystem,
    );
    void addTransaction() => showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TransactionDialog(
        profile: widget.profile,
        categories: categories.requireValue,
      ),
    );
    void editBudget() => showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BudgetDialog(
        profileId: id,
        month: _month,
        categories: categories.requireValue,
        existing: rule,
      ),
    );
    final budgetLabel = rule == null
        ? 'Set monthly budget'
        : 'Edit monthly budget';
    final analytics = SpendingAnalytics(
      profileId: id,
      month: _month,
      transactions: transactions.requireValue,
    );
    final query = _search.text.trim().toLowerCase();
    final amountQuery = query.replaceAll(RegExp(r'[,\s]'), '');
    final filtered = monthly.where(
      (row) =>
          _tab != 1 ||
          ((_filter == null || row.type == _filter) &&
              (query.isEmpty ||
                  row.notes.toLowerCase().contains(query) ||
                  (names[row.categoryId]?.toLowerCase().contains(query) ??
                      false) ||
                  (amountQuery.isNotEmpty &&
                      _money(row.amountMinor)
                          .toLowerCase()
                          .replaceAll(RegExp(r'[,\s]'), '')
                          .contains(amountQuery)))),
    );
    final visible =
        (_tab == 1 && _oldestFirst ? filtered.toList().reversed : filtered)
            .take(_tab == 0 ? 3 : monthly.length)
            .toList();
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final content = <Widget>[
      if ((_tab == 0 || _tab == 2) && summary == null)
        const Text(
          'Monthly totals exceed the supported range. Edit or delete an entry to calculate totals.',
        ),
      if (_tab == 0) ...[
        if (summary != null)
          DashboardSummaryCard(summary: summary, money: _money),
        const SizedBox(height: 16),
        SpendingOverview(
          compact: true,
          onShowAll: () => setState(() => _tab = 2),
          analytics: analytics,
          categories: categories.requireValue,
          money: _analyticsMoney,
        ),
        const SizedBox(height: 16),
      ],
      if (_tab == 3) ...[
        ListTile(
          leading: const Icon(Icons.person_add_alt_1),
          title: const Text('Create profile'),
          trailing: IconButton(
            tooltip: 'Create profile',
            onPressed: widget.onCreateProfile,
            icon: const Icon(Icons.person_add_alt_1),
          ),
          onTap: widget.onCreateProfile,
        ),
        ListTile(
          key: const Key('manage-categories'),
          leading: const Icon(Icons.category_outlined),
          title: const Text('Manage categories'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showDialog<void>(
            context: context,
            builder: (_) => CategoryManagerDialog(profileId: id),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.event_repeat),
          title: const Text('Scheduled transactions'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (_) => SchedulesPage(profile: widget.profile),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            key: const Key('automatic-unused-savings'),
            title: const Text('Automatically save unused money'),
            subtitle: const Text(
              'Starting this month, record any money left over as savings when you next open the app after month-end. '
              'No money is moved between accounts.',
            ),
            value: widget.profile.autoSavings,
            onChanged: _savingAutomatic ? null : _setAutomaticSavings,
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          key: const Key('delete-profile'),
          onPressed: _deleteProfile,
          icon: const Icon(Icons.delete_forever_outlined),
          label: const Text('Delete Profile'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
            side: BorderSide(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
      if (_tab == 2) ...[
        ExpenseStatsCard(analytics: analytics, money: _analyticsMoney),
        const SizedBox(height: 16),
        SpendingOverview(
          title: 'Expenses by category',
          analytics: analytics,
          categories: categories.requireValue,
          money: _analyticsMoney,
        ),
        const SizedBox(height: 16),
        DailySpendingChart(analytics: analytics, money: _analyticsMoney),
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
                        : '${analytics.expenseCount} ${analytics.expenseCount == 1 ? 'expense' : 'expenses'} recorded this month. Every entry helps you see the bigger picture.',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (summary != null) ...[
          Card(
            key: const Key('monthly-summary'),
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Monthly summary (${widget.profile.currencyCode})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Text('Income: ${_money(summary.incomeMinor)}'),
                  Text('Expenses: ${_money(summary.expenseMinor)}'),
                  Text('Savings: ${_money(summary.savingsMinor)}'),
                  const SizedBox(height: 8),
                  const Text('Remaining to allocate'),
                  Text(
                    _money(summary.remainingMinor),
                    key: const Key('remaining-amount'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
        Text(
          'Monthly budget',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        TextButton(
          onPressed: canEditBudget ? editBudget : null,
          child: Text(budgetLabel),
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
          for (final progress in summary.buckets) ...[
            Card(
              margin: EdgeInsets.zero,
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
                      Text('Saved: ${_money(progress.spentMinor)}'),
                      LinearProgressIndicator(
                        value: progress.progress,
                        semanticsLabel: 'Savings progress',
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
            const SizedBox(height: 16),
          ],
          Text(
            'Unallocated expenses: ${_money(summary.unallocatedExpenseMinor)}',
          ),
        ],
        if (!canEditBudget)
          const Text(
            'This rule has custom buckets. The current editor supports Needs/Wants/Savings only and will not overwrite it.',
          ),
      ],
      if (_tab == 0)
        Card(
          key: const Key('recent-transactions'),
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Recent transactions',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (monthly.isNotEmpty)
                      TextButton(
                        onPressed: () => setState(() => _tab = 1),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('View all'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (monthly.isEmpty)
                  DashboardEmptyState(
                    month: _month,
                    onAdd: canAdd ? addTransaction : null,
                  ),
                for (var index = 0; index < visible.length; index++) ...[
                  if (index > 0) const SizedBox(height: 8),
                  _transactionCard(
                    visible[index],
                    categories.requireValue,
                    names,
                  ),
                ],
              ],
            ),
          ),
        ),
      if (_tab == 1) ...[
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final type in [null, ...TransactionType.values])
              ChoiceChip(
                shape: const StadiumBorder(),
                showCheckmark: false,
                label: Text(type?.label ?? 'All'),
                selected: _filter == type,
                onSelected: (_) => setState(() => _filter = type),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (!_swipeHintDismissed && visible.any(_isDeletable)) ...[
          Card(
            key: const Key('swipe-hint'),
            margin: EdgeInsets.zero,
            color: semantic.infoContainer,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: Icon(
                Icons.swipe_left_rounded,
                color: semantic.onInfoContainer,
              ),
              title: Text(
                'Swipe left to delete. Tap to edit.',
                style: TextStyle(color: semantic.onInfoContainer),
              ),
              trailing: IconButton(
                tooltip: 'Dismiss hint',
                icon: Icon(Icons.close, color: semantic.onInfoContainer),
                onPressed: () => setState(() => _swipeHintDismissed = true),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (monthly.isEmpty)
          DashboardEmptyState(
            month: _month,
            onAdd: canAdd ? addTransaction : null,
          ),
        if (monthly.isNotEmpty && visible.isEmpty)
          const Text('No transactions match your filters.'),
        for (var index = 0; index < visible.length; index++) ...[
          if (_tab == 1 &&
              (index == 0 ||
                  !DateUtils.isSameDay(
                    visible[index - 1].occurredAt.toLocal(),
                    visible[index].occurredAt.toLocal(),
                  )))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Text(
                _dayLabel(visible[index].occurredAt),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          _transactionCard(visible[index], categories.requireValue, names),
        ],
      ],
    ];
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              key: ValueKey('dashboard-content-$_tab'),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [_header(), ...content],
            ),
          ),
        ),
      ),
      bottomNavigationBar: DashboardBottomBar(
        selected: _tab,
        onSelected: (value) => setState(() => _tab = value),
        onAdd: canAdd ? addTransaction : null,
      ),
    );
  }

  Widget _transactionCard(
    FinancialTransaction transaction,
    List<TransactionCategory> categories,
    Map<String, String> names,
  ) {
    final category = categories
        .where((row) => row.id == transaction.categoryId)
        .firstOrNull;
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final color = switch (transaction.type) {
      TransactionType.income => semantic.income,
      TransactionType.expense => semantic.expense,
      TransactionType.savings => semantic.info,
    };
    final title = transaction.notes.isEmpty
        ? names[transaction.categoryId] ?? transaction.categoryId
        : transaction.notes;
    final amountText =
        '${transaction.type == TransactionType.income ? '+' : '-'}${_money(transaction.amountMinor)}';
    final amountLabel = Text(
      amountText,
      key: ValueKey('transaction-amount-${transaction.id}'),
      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
    );
    final dateLabel = Tooltip(
      message: DateFormat.yMMMd().add_jm().format(
        transaction.occurredAt.toLocal(),
      ),
      child: Text(
        _tab == 0
            ? homeTransactionDate(
                occurredAt: transaction.occurredAt,
                selectedMonth: _month,
                now: DateTime.now(),
              )
            : DateFormat.jm().format(transaction.occurredAt.toLocal()),
        key: ValueKey('transaction-date-${transaction.id}'),
        textAlign: TextAlign.right,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
    final sideAmount =
        MediaQuery.sizeOf(context).width >= 390 &&
        MediaQuery.textScalerOf(context).scale(16) <= 20 &&
        amountText.length <= 16;
    final deletable = _tab == 1 && _isDeletable(transaction);
    final card = Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: CategoryAvatar(
          colorArgb: category?.colorArgb ?? 0xFF455A64,
          iconKey: category?.iconKey ?? 'category',
        ),
        title: Text(names[transaction.categoryId] ?? transaction.categoryId),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.notes.isNotEmpty) Text(transaction.notes),
            if (!sideAmount) ...[amountLabel, dateLabel],
            if (transaction.savingsMonth != null)
              const Text('Automatic; edit source transactions to recalculate'),
          ],
        ),
        onTap:
            _deleting.contains(transaction.id) ||
                transaction.savingsMonth != null
            ? null
            : () => showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (_) => TransactionDialog(
                  profile: widget.profile,
                  categories: categories,
                  existing: transaction,
                ),
              ),
        trailing: sideAmount
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [amountLabel, dateLabel],
              )
            : null,
      ),
    );
    if (_tab != 1) return card;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: deletable
          ? Semantics(
              customSemanticsActions: {
                CustomSemanticsAction(label: 'Delete $title'): () =>
                    _delete(transaction),
              },
              child: Dismissible(
                key: ValueKey('swipe-${transaction.id}'),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) async {
                  await _delete(transaction);
                  return false;
                },
                background: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
                child: card,
              ),
            )
          : card,
    );
  }

  bool _isDeletable(FinancialTransaction transaction) =>
      !_deleting.contains(transaction.id) && transaction.savingsMonth == null;
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
