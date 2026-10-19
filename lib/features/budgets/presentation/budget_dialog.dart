import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/money/decimal_input.dart';
import '../../profiles/domain/profile.dart';
import '../../transactions/domain/entities/financial_transaction.dart';
import '../domain/entities/budget_rule.dart';

class BudgetDialog extends ConsumerStatefulWidget {
  const BudgetDialog({
    required this.profileId,
    required this.month,
    required this.categories,
    this.existing,
    super.key,
  });

  final String profileId;
  final DateTime month;
  final List<TransactionCategory> categories;
  final BudgetRule? existing;

  @override
  ConsumerState<BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends ConsumerState<BudgetDialog> {
  static const _ids = ['needs', 'wants', 'savings'];
  static const _names = ['Needs', 'Wants', 'Savings'];
  late final List<TextEditingController> _percentages = List.generate(3, (
    index,
  ) {
    final existing = widget.existing?.buckets
        .where((bucket) => bucket.id == _ids[index])
        .firstOrNull;
    final bps = existing?.allocationBps ?? [5000, 3000, 2000][index];
    return TextEditingController(
      text: '${bps ~/ 100}.${(bps % 100).toString().padLeft(2, '0')}',
    );
  });
  late final Map<String, String> _assignments = {
    for (final category in widget.categories.where(
      (category) =>
          category.type == TransactionType.expense &&
          (!category.isArchived ||
              widget.existing?.buckets.any(
                    (bucket) => bucket.categoryIds.contains(category.id),
                  ) ==
                  true),
    ))
      category.id: widget.existing == null
          ? (category.defaultBudgetBucket ?? 'unassigned')
          : (widget.existing!.buckets
                    .where((bucket) => bucket.categoryIds.contains(category.id))
                    .firstOrNull
                    ?.id ??
                'unassigned'),
  };
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    for (final controller in _percentages) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final rule = BudgetRule(
        id: widget.existing?.id ?? ref.read(idGeneratorProvider).generate(),
        profileId: widget.profileId,
        name: widget.existing?.name ?? 'Monthly allocation',
        periodStart: DateTime(widget.month.year, widget.month.month),
        periodEnd: DateTime(widget.month.year, widget.month.month + 1),
        buckets: [
          for (var index = 0; index < 3; index++)
            BudgetBucket(
              id: _ids[index],
              name:
                  widget.existing?.buckets
                      .where((bucket) => bucket.id == _ids[index])
                      .firstOrNull
                      ?.name ??
                  _names[index],
              allocationBps: parseScaledDecimal(_percentages[index].text, 2),
              categoryIds: [
                for (final entry in _assignments.entries)
                  if (entry.value == _ids[index]) entry.key,
              ],
            ),
        ],
      );
      await ref.read(budgetRepositoryProvider).save(rule);
      if (mounted) Navigator.pop(context);
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save budget: $error';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Monthly budget'),
    content: SizedBox(
      width: 400,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Percentages must total 100%. All savings transactions count toward the Savings target, separately from expenses.',
            ),
            for (var index = 0; index < 3; index++)
              TextField(
                controller: _percentages[index],
                enabled: !_saving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: '${_names[index]} (%)'),
              ),
            const SizedBox(height: 16),
            const Text('Expense category mapping'),
            for (final category in widget.categories.where(
              (category) =>
                  category.type == TransactionType.expense &&
                  !category.isArchived,
            ))
              DropdownButtonFormField<String>(
                initialValue: _assignments[category.id],
                decoration: InputDecoration(labelText: category.name),
                items: const [
                  DropdownMenuItem(value: 'needs', child: Text('Needs')),
                  DropdownMenuItem(value: 'wants', child: Text('Wants')),
                  DropdownMenuItem(
                    value: 'unassigned',
                    child: Text('Unassigned'),
                  ),
                ],
                onChanged: _saving
                    ? null
                    : (value) =>
                          setState(() => _assignments[category.id] = value!),
              ),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: Text(_saving ? 'Saving...' : 'Save budget'),
      ),
    ],
  );
}
