import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../transactions/domain/entities/financial_transaction.dart';
import '../../transactions/domain/transaction_filter.dart';
import '../../transactions/presentation/providers/transaction_scope_provider.dart';
import 'type_filter_pills.dart';
import 'category_filter_pill.dart';

Future<void> showTransactionFilterSheet(
  BuildContext context, {
  required String profileId,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  constraints: const BoxConstraints(maxWidth: 560),
  builder: (_) => TransactionFilterSheet(profileId: profileId),
);

String dateScopeLabel(DateScope dates) {
  final format = DateFormat.yMMMd();
  return switch (dates.mode) {
    DateRangeMode.month => DateFormat.yMMM().format(dates.month!),
    DateRangeMode.allTime => 'All time',
    DateRangeMode.custom =>
      DateUtils.isSameDay(dates.customStart, dates.customEnd)
          ? format.format(dates.customStart!)
          : '${format.format(dates.customStart!)} – '
                '${format.format(dates.customEnd!)}',
  };
}

Future<void> pickCustomRange(
  BuildContext context,
  TransactionScopeNotifier notifier,
  DateScope current,
) async {
  final now = DateTime.now();
  final picked = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2000),
    lastDate: DateTime(now.year + 10, 12, 31),
    initialDateRange: current.mode == DateRangeMode.custom
        ? DateTimeRange(start: current.customStart!, end: current.customEnd!)
        : null,
  );
  if (picked != null) {
    notifier.setDates(DateScope.custom(picked.start, picked.end));
  }
}

class TransactionFilterSheet extends ConsumerWidget {
  const TransactionFilterSheet({super.key, required this.profileId});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scope = ref.watch(transactionScopeProvider(profileId));
    final notifier = ref.read(transactionScopeProvider(profileId).notifier);
    final count = ref.watch(
      filteredCountProvider((profileId: profileId, filter: scope.ranged)),
    );
    final categories = ref.watch(categoriesProvider(profileId));
    final visibleCategories =
        [
          ...?categories.asData?.value.where(
            (category) =>
                (scope.showArchived || !category.isArchived) &&
                (scope.filter.type == null ||
                    category.type == scope.filter.type),
          ),
        ]..sort((a, b) {
          final name = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          return name != 0 ? name : a.id.compareTo(b.id);
        });
    Widget section(String title, List<Widget> chips) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: chips),
        const SizedBox(height: 16),
      ],
    );
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filter & sort',
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  TextButton(
                    onPressed: scope.activeCount == 0 && !scope.showArchived
                        ? null
                        : notifier.reset,
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      section('Date', [
                        ChoiceChip(
                          shape: const StadiumBorder(),
                          showCheckmark: false,
                          label: const Text('Month'),
                          selected: scope.dates.mode == DateRangeMode.month,
                          onSelected: (_) => notifier.setDates(
                            DateScope.month(DateTime.now()),
                          ),
                        ),
                        ChoiceChip(
                          shape: const StadiumBorder(),
                          showCheckmark: false,
                          label: const Text('All time'),
                          selected: scope.dates.mode == DateRangeMode.allTime,
                          onSelected: (_) =>
                              notifier.setDates(const DateScope.allTime()),
                        ),
                        ChoiceChip(
                          shape: const StadiumBorder(),
                          showCheckmark: false,
                          avatar: const Icon(Icons.date_range, size: 18),
                          label: Text(
                            scope.dates.mode == DateRangeMode.custom
                                ? dateScopeLabel(scope.dates)
                                : 'Custom range',
                          ),
                          selected: scope.dates.mode == DateRangeMode.custom,
                          onSelected: (_) =>
                              pickCustomRange(context, notifier, scope.dates),
                        ),
                      ]),
                      section('Sort by', [
                        for (final (label, sort) in [
                          ('Newest first', TransactionSort.newestFirst),
                          ('Oldest first', TransactionSort.oldestFirst),
                        ])
                          ChoiceChip(
                            shape: const StadiumBorder(),
                            showCheckmark: false,
                            label: Text(label),
                            selected: scope.sort == sort,
                            onSelected: (_) => notifier.setSort(sort),
                          ),
                      ]),
                      section('Type', [
                        for (final type in [null, ...TransactionType.values])
                          TransactionTypePill(
                            type: type,
                            selected: scope.filter.type == type,
                            onSelected: () => notifier.setType(type),
                          ),
                      ]),
                      Text('Categories', style: theme.textTheme.labelLarge),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Show archived'),
                        value: scope.showArchived,
                        onChanged: notifier.setShowArchived,
                      ),
                      Wrap(
                        spacing: 8,
                        children: [
                          TextButton(
                            onPressed:
                                !categories.hasValue ||
                                    visibleCategories.isEmpty
                                ? null
                                : () => notifier.setCategories(
                                    visibleCategories.map(
                                      (category) => category.id,
                                    ),
                                  ),
                            child: const Text('Select all'),
                          ),
                          TextButton(
                            onPressed: scope.filter.categoryIds.isEmpty
                                ? null
                                : () => notifier.setCategories(const []),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                      if (categories.hasError)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Could not load categories. Try again.'),
                            TextButton(
                              onPressed: () =>
                                  ref.invalidate(categoriesProvider(profileId)),
                              child: const Text('Retry categories'),
                            ),
                          ],
                        )
                      else if (!categories.hasValue)
                        const Center(child: CircularProgressIndicator())
                      else if (visibleCategories.isEmpty)
                        const Text('No categories for this type.')
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final category in visibleCategories)
                              CategoryFilterPill(
                                key: ValueKey('category-filter-${category.id}'),
                                category: category,
                                selected: scope.filter.categoryIds.contains(
                                  category.id,
                                ),
                                onSelected: (selected) {
                                  final ids = {...scope.filter.categoryIds};
                                  if (selected) {
                                    ids.add(category.id);
                                  } else {
                                    ids.remove(category.id);
                                  }
                                  notifier.setCategories(ids);
                                },
                              ),
                          ],
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              if (count.hasError) ...[
                const Text('Could not count transactions. Try again.'),
                TextButton(
                  onPressed: () => ref.invalidate(
                    filteredCountProvider((
                      profileId: profileId,
                      filter: scope.ranged,
                    )),
                  ),
                  child: const Text('Retry count'),
                ),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(switch (count.asData?.value) {
                    null => 'Show transactions',
                    1 => 'Show 1 transaction',
                    final total => 'Show $total transactions',
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
