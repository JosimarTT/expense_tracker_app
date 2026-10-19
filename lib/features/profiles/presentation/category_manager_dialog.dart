import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../transactions/domain/entities/financial_transaction.dart';
import '../domain/profile.dart';
import 'category_editor_dialog.dart';

class CategoryManagerDialog extends ConsumerStatefulWidget {
  const CategoryManagerDialog({required this.profileId, super.key});

  final String profileId;

  @override
  ConsumerState<CategoryManagerDialog> createState() =>
      _CategoryManagerDialogState();
}

class _CategoryManagerDialogState extends ConsumerState<CategoryManagerDialog> {
  bool _showArchived = false;
  String get profileId => widget.profileId;

  Future<void> _archive(TransactionCategory category) async {
    final archived = !category.isArchived;
    if (archived) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Archive "${category.name}"?'),
          content: const Text(
            'It will no longer appear when adding transactions or creating budgets. '
            'Existing transactions and budget history will remain unchanged.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Archive'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    try {
      await ref
          .read(categoryRepositoryProvider)
          .setArchived(
            profileId: profileId,
            categoryId: category.id,
            archived: archived,
          );
    } on Object catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not ${archived ? 'archive' : 'restore'} category: $error',
            ),
          ),
        );
      }
    }
  }

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
        title: const Text('Delete category permanently?'),
        content: Text(
          'Permanently delete "${category.name}"? This cannot be undone. '
          'Categories with active transactions or budget mappings cannot be deleted. '
          'Previously deleted records linked to this category will also be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete permanently'),
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
          SnackBar(content: Text('Could not delete category: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          AsyncData(:final value) => Column(
            children: [
              SwitchListTile(
                title: const Text('Show archived'),
                value: _showArchived,
                onChanged: (value) => setState(() => _showArchived = value),
              ),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final category in value)
                      if (_showArchived || !category.isArchived)
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
                                tooltip:
                                    '${category.isArchived ? 'Restore' : 'Archive'} ${category.name}',
                                onPressed: () => _archive(category),
                                icon: Icon(
                                  category.isArchived
                                      ? Icons.unarchive_outlined
                                      : Icons.archive_outlined,
                                ),
                              ),
                              if (category.isArchived)
                                FutureBuilder<bool>(
                                  future: ref
                                      .read(categoryRepositoryProvider)
                                      .canDelete(
                                        profileId: profileId,
                                        categoryId: category.id,
                                      ),
                                  builder: (context, snapshot) =>
                                      snapshot.hasError
                                      ? Tooltip(
                                          message:
                                              'Could not check category references: ${snapshot.error}',
                                          child: const Icon(
                                            Icons.error_outline,
                                          ),
                                        )
                                      : IconButton(
                                          tooltip: snapshot.data == true
                                              ? 'Delete ${category.name} permanently'
                                              : 'Active transactions or budget mappings prevent permanent deletion',
                                          onPressed: snapshot.data == true
                                              ? () => _delete(
                                                  context,
                                                  ref,
                                                  category,
                                                )
                                              : null,
                                          icon: const Icon(
                                            Icons.delete_forever_outlined,
                                          ),
                                        ),
                                ),
                            ],
                          ),
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
