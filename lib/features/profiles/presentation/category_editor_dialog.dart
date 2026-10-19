import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../transactions/domain/entities/financial_transaction.dart';
import '../domain/category_options.dart';
import '../domain/profile.dart';

const categoryIcons = <String, IconData>{
  'category': Icons.category,
  'payments': Icons.payments,
  'home': Icons.home,
  'grocery': Icons.local_grocery_store,
  'directions_car': Icons.directions_car,
  'restaurant': Icons.restaurant,
  'movie': Icons.movie,
  'health_and_safety': Icons.health_and_safety,
  'school': Icons.school,
  'shopping_bag': Icons.shopping_bag,
  'pets': Icons.pets,
  'flight': Icons.flight,
  'bolt': Icons.bolt,
  'subscriptions': Icons.subscriptions,
  'fitness_center': Icons.fitness_center,
  'work': Icons.work,
};

class CategoryEditorDialog extends ConsumerStatefulWidget {
  const CategoryEditorDialog({
    required this.profileId,
    this.category,
    super.key,
  });

  final String profileId;
  final TransactionCategory? category;

  @override
  ConsumerState<CategoryEditorDialog> createState() =>
      _CategoryEditorDialogState();
}

class _CategoryEditorDialogState extends ConsumerState<CategoryEditorDialog> {
  late final _name = TextEditingController(text: widget.category?.name);
  late TransactionType _type = widget.category?.type ?? TransactionType.expense;
  late String _budgetBucket = widget.category?.defaultBudgetBucket ?? 'needs';
  late String _icon = widget.category?.iconKey ?? 'category';
  late int _color =
      widget.category?.colorArgb ?? CategoryPresentationOptions.colors.first;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Enter a category name.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(categoryRepositoryProvider)
          .save(
            widget.profileId,
            TransactionCategory(
              id:
                  widget.category?.id ??
                  ref.read(idGeneratorProvider).generate(),
              name: _name.text.trim(),
              type: _type,
              iconKey: _icon,
              colorArgb: _color,
              defaultBudgetBucket: _type == TransactionType.expense
                  ? _budgetBucket
                  : null,
            ),
          );
      if (mounted) Navigator.pop(context);
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save category: $error';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.category == null ? 'New category' : 'Edit category'),
    content: SizedBox(
      width: 420,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.category != null)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Name, icon, and color changes also update how historical transactions appear. '
                  'A category with history cannot change transaction type.',
                ),
              ),
            TextField(
              controller: _name,
              enabled: !_saving,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Category name'),
            ),
            DropdownButtonFormField<TransactionType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Transaction type'),
              items: const [
                DropdownMenuItem(
                  value: TransactionType.income,
                  child: Text('Income'),
                ),
                DropdownMenuItem(
                  value: TransactionType.expense,
                  child: Text('Expense'),
                ),
                DropdownMenuItem(
                  value: TransactionType.savings,
                  child: Text('Savings'),
                ),
              ],
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _type = value!),
            ),
            if (_type == TransactionType.expense)
              DropdownButtonFormField<String>(
                key: const Key('category-budget-bucket'),
                initialValue: _budgetBucket,
                decoration: const InputDecoration(
                  labelText: 'Default budget classification',
                ),
                items: const [
                  DropdownMenuItem(value: 'needs', child: Text('Needs')),
                  DropdownMenuItem(value: 'wants', child: Text('Wants')),
                ],
                onChanged: _saving
                    ? null
                    : (value) => setState(() => _budgetBucket = value!),
              ),
            const SizedBox(height: 16),
            Text(
              'Material icon',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Wrap(
              spacing: 4,
              children: [
                for (final entry in categoryIcons.entries)
                  IconButton(
                    key: ValueKey('category-icon-${entry.key}'),
                    tooltip: entry.key.replaceAll('_', ' '),
                    onPressed: _saving
                        ? null
                        : () => setState(() => _icon = entry.key),
                    style: IconButton.styleFrom(
                      backgroundColor: _icon == entry.key
                          ? Theme.of(context).colorScheme.secondaryContainer
                          : null,
                    ),
                    icon: Icon(entry.value),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Color', style: Theme.of(context).textTheme.labelLarge),
            Wrap(
              spacing: 8,
              children: [
                for (final color in CategoryPresentationOptions.colors)
                  Semantics(
                    label: 'Color ${color.toRadixString(16)}',
                    selected: color == _color,
                    child: InkWell(
                      key: ValueKey('category-color-$color'),
                      onTap: _saving
                          ? null
                          : () => setState(() => _color = color),
                      customBorder: const CircleBorder(),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(color),
                        child: color == _color
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(categoryIcons[_icon], color: Color(_color)),
                const SizedBox(width: 8),
                Text(_name.text.isEmpty ? 'Category preview' : _name.text),
              ],
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
        child: Text(_saving ? 'Saving...' : 'Save category'),
      ),
    ],
  );
}
