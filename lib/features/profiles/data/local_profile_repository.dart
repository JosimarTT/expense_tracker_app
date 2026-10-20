import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/money/currency.dart';
import '../../transactions/domain/entities/financial_transaction.dart';
import '../domain/category_options.dart';
import '../domain/profile.dart';

class LocalProfileRepository implements ProfileRepository, CategoryRepository {
  LocalProfileRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<LocalProfile>> watchProfiles() {
    final query = _database.select(_database.profiles)
      ..where((row) => row.deletedAt.isNull())
      ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          LocalProfile(
            id: row.profileId,
            name: row.name,
            currencyCode: row.currencyCode,
            currencyScale: row.currencyScale,
            autoSavings: row.autoSavings == 1,
            avatar: ProfileAvatar.values.byName(row.avatarKey),
          ),
      ],
    );
  }

  @override
  Stream<List<TransactionCategory>> watchCategories(String profileId) {
    _requireId(profileId);
    final query = _database.select(_database.categories)
      ..where((row) => row.profileId.equals(profileId))
      ..orderBy([(row) => OrderingTerm.asc(row.name)]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          TransactionCategory(
            id: row.categoryId,
            name: row.name,
            type: TransactionType.values.byName(row.type),
            iconKey: row.iconKey,
            colorArgb: row.colorArgb,
            defaultBudgetBucket: row.defaultBudgetBucket,
            isArchived: row.deletedAt != null,
          ),
      ],
    );
  }

  @override
  Future<void> create(LocalProfile profile) {
    if (profile.id.trim().isEmpty || profile.name.trim().isEmpty) {
      throw ArgumentError('Profile name and identifier are required.');
    }
    final currency = Currency.fromCode(profile.currencyCode);
    if (profile.currencyScale != currency.scale) {
      throw ArgumentError(
        '${currency.code} requires ${currency.scale} decimal places.',
      );
    }
    return _database.transaction(() async {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await _database
          .into(_database.profiles)
          .insert(
            ProfilesCompanion.insert(
              profileId: profile.id,
              name: profile.name.trim(),
              avatarKey: Value(profile.avatar.name),
              currencyCode: profile.currencyCode,
              currencyScale: profile.currencyScale,
              createdAt: now,
              updatedAt: now,
            ),
          );
      for (final category in _starterCategories) {
        await _database
            .into(_database.categories)
            .insert(
              CategoriesCompanion.insert(
                profileId: profile.id,
                categoryId: category.id,
                name: category.name,
                type: category.type.name,
                iconKey: Value(category.iconKey),
                colorArgb: Value(category.colorArgb),
                defaultBudgetBucket: Value(category.defaultBudgetBucket),
                createdAt: now,
                updatedAt: now,
              ),
            );
      }
    });
  }

  static const _starterCategories = [
    TransactionCategory(
      id: 'investments',
      name: 'Investments',
      type: TransactionType.savings,
      iconKey: 'work',
      colorArgb: 0xFF2E7D32,
      defaultBudgetBucket: null,
    ),
    TransactionCategory(
      id: 'retirement',
      name: 'Retirement',
      type: TransactionType.savings,
      iconKey: 'home',
      colorArgb: 0xFF1565C0,
      defaultBudgetBucket: null,
    ),
    TransactionCategory(
      id: 'emergency_fund',
      name: 'Emergency fund',
      type: TransactionType.savings,
      iconKey: 'health_and_safety',
      colorArgb: 0xFF00838F,
      defaultBudgetBucket: null,
    ),
    TransactionCategory(
      id: TransactionCategory.unusedMoneyId,
      name: 'Unused money',
      type: TransactionType.savings,
      iconKey: 'payments',
      colorArgb: 0xFF2E7D32,
      defaultBudgetBucket: null,
    ),
    TransactionCategory(
      id: 'salary',
      name: 'Salary',
      type: TransactionType.income,
      iconKey: 'payments',
      colorArgb: 0xFF2E7D32,
      defaultBudgetBucket: null,
    ),
    TransactionCategory(
      id: 'other_income',
      name: 'Other income',
      type: TransactionType.income,
      iconKey: 'payments',
      colorArgb: 0xFF388E3C,
      defaultBudgetBucket: null,
    ),
    TransactionCategory(
      id: 'housing',
      name: 'Housing',
      type: TransactionType.expense,
      iconKey: 'home',
      colorArgb: 0xFF1565C0,
      defaultBudgetBucket: 'needs',
    ),
    TransactionCategory(
      id: 'groceries',
      name: 'Groceries',
      type: TransactionType.expense,
      iconKey: 'grocery',
      colorArgb: 0xFF2E7D32,
      defaultBudgetBucket: 'needs',
    ),
    TransactionCategory(
      id: 'transport',
      name: 'Transport',
      type: TransactionType.expense,
      iconKey: 'directions_car',
      colorArgb: 0xFF00838F,
      defaultBudgetBucket: 'needs',
    ),
    TransactionCategory(
      id: 'dining',
      name: 'Dining out',
      type: TransactionType.expense,
      iconKey: 'restaurant',
      colorArgb: 0xFFE65100,
      defaultBudgetBucket: 'wants',
    ),
    TransactionCategory(
      id: 'entertainment',
      name: 'Entertainment',
      type: TransactionType.expense,
      iconKey: 'movie',
      colorArgb: 0xFF6A1B9A,
      defaultBudgetBucket: 'wants',
    ),
    TransactionCategory(
      id: 'other_expense',
      name: 'Other expense',
      type: TransactionType.expense,
      iconKey: 'category',
      colorArgb: 0xFF455A64,
      defaultBudgetBucket: 'wants',
    ),
  ];

  @override
  Future<void> save(String profileId, TransactionCategory category) async {
    _requireId(profileId);
    _requireEditableCategory(category.id);
    if (category.id.trim().isEmpty || category.name.trim().isEmpty) {
      throw ArgumentError('Category name and identifier are required.');
    }
    if (!CategoryPresentationOptions.iconKeys.contains(category.iconKey)) {
      throw ArgumentError.value(
        category.iconKey,
        'iconKey',
        'Choose a predefined icon.',
      );
    }
    if (!CategoryPresentationOptions.colors.contains(category.colorArgb)) {
      throw ArgumentError.value(
        category.colorArgb,
        'colorArgb',
        'Choose a predefined color.',
      );
    }
    if (category.type != TransactionType.expense) {
      if (category.defaultBudgetBucket != null) {
        throw ArgumentError(
          'Only expense categories can have a Needs/Wants budget bucket.',
        );
      }
    } else if (category.defaultBudgetBucket != 'needs' &&
        category.defaultBudgetBucket != 'wants') {
      throw ArgumentError('Expense categories must default to Needs or Wants.');
    }

    await _database.transaction(() async {
      final profile =
          await (_database.select(_database.profiles)..where(
                (row) =>
                    row.profileId.equals(profileId) & row.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (profile == null) {
        throw StateError('The selected profile is no longer active.');
      }
      final existing =
          await (_database.select(_database.categories)..where(
                (row) =>
                    row.profileId.equals(profileId) &
                    row.categoryId.equals(category.id),
              ))
              .getSingleOrNull();
      final referenced =
          await (_database.select(_database.transactions)
                ..where(
                  (row) =>
                      row.profileId.equals(profileId) &
                      row.categoryId.equals(category.id),
                )
                ..limit(1))
              .getSingleOrNull();
      final budgetReferences =
          await (_database.select(_database.budgetCategoryAllocations)
                ..where(
                  (row) =>
                      row.profileId.equals(profileId) &
                      row.categoryId.equals(category.id),
                )
                ..limit(1))
              .getSingleOrNull();
      final scheduleReferences =
          await (_database.select(_database.transactionSchedules)
                ..where(
                  (row) =>
                      row.profileId.equals(profileId) &
                      row.categoryId.equals(category.id),
                )
                ..limit(1))
              .getSingleOrNull();
      if (existing != null &&
          existing.type != category.type.name &&
          (referenced != null ||
              budgetReferences != null ||
              scheduleReferences != null)) {
        throw StateError(
          'A category with history cannot change transaction type. '
          'Archive it and create a new category instead.',
        );
      }
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await _database
          .into(_database.categories)
          .insertOnConflictUpdate(
            CategoriesCompanion.insert(
              profileId: profileId,
              categoryId: category.id,
              name: category.name.trim(),
              type: category.type.name,
              iconKey: Value(category.iconKey),
              colorArgb: Value(category.colorArgb),
              defaultBudgetBucket: Value(category.defaultBudgetBucket),
              createdAt: existing?.createdAt ?? now,
              updatedAt: now,
              deletedAt: Value(existing?.deletedAt),
              localRevision: Value((existing?.localRevision ?? 0) + 1),
              isSynced: const Value(0),
            ),
          );
    });
  }

  @override
  Future<bool> canDelete({
    required String profileId,
    required String categoryId,
  }) async {
    _requireId(profileId);
    _requireId(categoryId);
    if (categoryId == TransactionCategory.unusedMoneyId) return false;
    final references = await _database
        .customSelect(
          '''SELECT EXISTS(
        SELECT 1 FROM transactions WHERE profile_id = ? AND category_id = ? AND deleted_at IS NULL
        UNION ALL
        SELECT 1 FROM budget_category_allocations WHERE profile_id = ? AND category_id = ? AND deleted_at IS NULL
        UNION ALL
        SELECT 1 FROM transaction_schedules WHERE profile_id = ? AND category_id = ? AND deleted_at IS NULL
      ) AS referenced''',
          variables: [
            Variable(profileId),
            Variable(categoryId),
            Variable(profileId),
            Variable(categoryId),
            Variable(profileId),
            Variable(categoryId),
          ],
          readsFrom: {
            _database.transactions,
            _database.budgetCategoryAllocations,
            _database.transactionSchedules,
          },
        )
        .getSingle();
    return references.read<int>('referenced') == 0;
  }

  @override
  Future<void> setArchived({
    required String profileId,
    required String categoryId,
    required bool archived,
  }) async {
    _requireId(profileId);
    _requireId(categoryId);
    _requireEditableCategory(categoryId);
    await _database.transaction(() async {
      final category =
          await (_database.select(_database.categories)..where(
                (row) =>
                    row.profileId.equals(profileId) &
                    row.categoryId.equals(categoryId),
              ))
              .getSingleOrNull();
      if (category == null) throw StateError('No category found.');
      if ((category.deletedAt != null) == archived) return;
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await (_database.update(_database.categories)..where(
            (row) =>
                row.profileId.equals(profileId) &
                row.categoryId.equals(categoryId),
          ))
          .write(
            CategoriesCompanion(
              deletedAt: Value(archived ? now : null),
              updatedAt: Value(now),
              localRevision: Value(category.localRevision + 1),
              isSynced: const Value(0),
            ),
          );
    });
  }

  @override
  Future<void> delete({
    required String profileId,
    required String categoryId,
  }) async {
    _requireId(profileId);
    _requireId(categoryId);
    _requireEditableCategory(categoryId);
    await _database.transaction(() async {
      final category =
          await (_database.select(_database.categories)..where(
                (row) =>
                    row.profileId.equals(profileId) &
                    row.categoryId.equals(categoryId),
              ))
              .getSingleOrNull();
      if (category == null) throw StateError('No category found.');
      if (!await canDelete(profileId: profileId, categoryId: categoryId)) {
        throw StateError(
          'This category has active transactions, budget mappings, or schedules. Archive it instead.',
        );
      }
      // Permanent category removal also purges its deleted dependents.
      final deletedSchedules =
          _database.selectOnly(_database.transactionSchedules)
            ..addColumns([_database.transactionSchedules.scheduleId])
            ..where(
              _database.transactionSchedules.profileId.equals(profileId) &
                  _database.transactionSchedules.categoryId.equals(categoryId) &
                  _database.transactionSchedules.deletedAt.isNotNull(),
            );
      await (_database.delete(_database.scheduleOccurrences)..where(
            (row) =>
                row.profileId.equals(profileId) &
                row.scheduleId.isInQuery(deletedSchedules),
          ))
          .go();
      await (_database.delete(_database.transactionSchedules)..where(
            (row) =>
                row.profileId.equals(profileId) &
                row.categoryId.equals(categoryId) &
                row.deletedAt.isNotNull(),
          ))
          .go();
      await (_database.delete(_database.transactions)..where(
            (row) =>
                row.profileId.equals(profileId) &
                row.categoryId.equals(categoryId) &
                row.deletedAt.isNotNull(),
          ))
          .go();
      await (_database.delete(_database.budgetCategoryAllocations)..where(
            (row) =>
                row.profileId.equals(profileId) &
                row.categoryId.equals(categoryId) &
                row.deletedAt.isNotNull(),
          ))
          .go();
      await (_database.delete(_database.categories)..where(
            (row) =>
                row.profileId.equals(profileId) &
                row.categoryId.equals(categoryId),
          ))
          .go();
    });
  }

  @override
  Future<void> deletePermanently(String profileId) {
    _requireId(profileId);
    return _database.transaction(() async {
      final exists = await (_database.select(
        _database.profiles,
      )..where((row) => row.profileId.equals(profileId))).getSingleOrNull();
      if (exists == null) {
        throw StateError('The selected profile no longer exists.');
      }
      await (_database.delete(
        _database.scheduleOccurrences,
      )..where((row) => row.profileId.equals(profileId))).go();
      await (_database.delete(
        _database.transactionSchedules,
      )..where((row) => row.profileId.equals(profileId))).go();
      await (_database.delete(
        _database.budgetCategoryAllocations,
      )..where((row) => row.profileId.equals(profileId))).go();
      await (_database.delete(
        _database.budgetBuckets,
      )..where((row) => row.profileId.equals(profileId))).go();
      await (_database.delete(
        _database.budgets,
      )..where((row) => row.profileId.equals(profileId))).go();
      await (_database.delete(
        _database.transactions,
      )..where((row) => row.profileId.equals(profileId))).go();
      await (_database.delete(
        _database.categories,
      )..where((row) => row.profileId.equals(profileId))).go();
      final deleted = await (_database.delete(
        _database.profiles,
      )..where((row) => row.profileId.equals(profileId))).go();
      if (deleted != 1) {
        throw StateError('The profile was not deleted.');
      }
    });
  }

  void _requireId(String id) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Must not be empty.');
    }
  }

  void _requireEditableCategory(String id) {
    if (id == TransactionCategory.unusedMoneyId) {
      throw StateError(
        'Unused money is managed by automatic savings and cannot be changed.',
      );
    }
  }
}
