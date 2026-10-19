import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../transactions/domain/entities/financial_transaction.dart';
import '../domain/profile.dart';
import 'category_editor_dialog.dart';

class CategoryManagerDialog extends ConsumerWidget {
  const CategoryManagerDialog({required this.profileId, super.key});

  final String profileId;

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    TransactionCategory? category,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          CategoryEditorDialog(profileId: profileId, category: category),
    );
    ref.invalidate(categoriesProvider(profileId));
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    TransactionCategory category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove category?'),
        content: Text(
          'Remove "${category.name}"? If it is used by transactions or budgets, '
          'it will be archived so existing records keep their category. Otherwise it will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove category'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref
          .read(categoryRepositoryProvider)
          .delete(profileId: profileId, categoryId: category.id);
      ref.invalidate(categoriesProvider(profileId));
    } on Object catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not remove category: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider(profileId));
    return AlertDialog(
      title: const Text('Manage categories'),
      content: SizedBox(
        width: 480,
        height: MediaQuery.sizeOf(context).height * 0.55,
        child: switch (categories) {
          AsyncData(:final value) when value.isEmpty => const Center(
            child: Text('No categories yet.'),
          ),
          AsyncData(:final value) => ListView(
            shrinkWrap: true,
            children: [
              for (final category in value)
                ListTile(
                  leading: Icon(
                    categoryIcons[category.iconKey] ?? Icons.category,
                    color: Color(category.colorArgb),
                  ),
                  title: Text(category.name),
                  subtitle: Text(
                    '${category.type == TransactionType.income ? 'Income' : 'Expense'}'
                    '${category.type == TransactionType.expense ? ' - ${category.defaultBudgetBucket == 'needs' ? 'Needs' : 'Wants'}' : ''}'
                    '${category.isArchived ? ' - Archived' : ''}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Edit ${category.name}',
                        onPressed: category.isArchived
                            ? null
                            : () => _edit(context, ref, category),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        tooltip: 'Remove ${category.name}',
                        onPressed: category.isArchived
                            ? null
                            : () => _delete(context, ref, category),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          AsyncError(:final error) => Center(
            child: Text('Could not load categories: $error'),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        FilledButton.icon(
          onPressed: () => _edit(context, ref, null),
          icon: const Icon(Icons.add),
          label: const Text('Add category'),
        ),
      ],
    );
  }
}
