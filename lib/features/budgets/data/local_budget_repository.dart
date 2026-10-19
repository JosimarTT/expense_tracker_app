import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart' hide BudgetBucket;
import '../domain/entities/budget_rule.dart';
import '../domain/repositories/budget_repository.dart';

class LocalBudgetRepository implements BudgetRepository {
  LocalBudgetRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<BudgetRule>> watchBudgets(String profileId) {
    _requireId(profileId);
    return _database
        .customSelect(
          '''
      SELECT b.budget_id, b.name AS budget_name, b.period_start, b.period_end,
             k.bucket_id, k.name AS bucket_name, k.allocation_bps, a.category_id
      FROM budgets b
      LEFT JOIN budget_buckets k ON k.profile_id = b.profile_id
        AND k.budget_id = b.budget_id AND k.deleted_at IS NULL
      LEFT JOIN budget_category_allocations a ON a.profile_id = k.profile_id
        AND a.budget_id = k.budget_id AND a.bucket_id = k.bucket_id
        AND a.deleted_at IS NULL
      WHERE b.profile_id = ? AND b.deleted_at IS NULL
      ORDER BY b.period_start, b.budget_id, k.bucket_id, a.category_id
      ''',
          variables: [Variable(profileId)],
          readsFrom: {
            _database.budgets,
            _database.budgetBuckets,
            _database.budgetCategoryAllocations,
          },
        )
        .watch()
        .map((rows) {
          final grouped = <String, List<QueryRow>>{};
          for (final row in rows) {
            grouped
                .putIfAbsent(row.read<String>('budget_id'), () => [])
                .add(row);
          }
          return [
            for (final entry in grouped.entries)
              _mapRule(profileId, entry.key, entry.value),
          ];
        });
  }

  BudgetRule _mapRule(String profileId, String id, List<QueryRow> rows) {
    final buckets = <String, List<QueryRow>>{};
    for (final row in rows) {
      final bucketId = row.readNullable<String>('bucket_id');
      if (bucketId != null) {
        buckets.putIfAbsent(bucketId, () => []).add(row);
      }
    }
    final first = rows.first;
    return BudgetRule(
      id: id,
      profileId: profileId,
      name: first.read<String>('budget_name'),
      periodStart: DateTime.fromMillisecondsSinceEpoch(
        first.read<int>('period_start'),
        isUtc: true,
      ),
      periodEnd: DateTime.fromMillisecondsSinceEpoch(
        first.read<int>('period_end'),
        isUtc: true,
      ),
      buckets: [
        for (final entry in buckets.entries)
          BudgetBucket(
            id: entry.key,
            name: entry.value.first.read<String>('bucket_name'),
            allocationBps: entry.value.first.read<int>('allocation_bps'),
            categoryIds: entry.value
                .map((row) => row.readNullable<String>('category_id'))
                .whereType<String>(),
          ),
      ],
    );
  }

  @override
  Future<void> save(BudgetRule budget) => _database.transaction(() async {
    final profile =
        await (_database.select(_database.profiles)..where(
              (row) =>
                  row.profileId.equals(budget.profileId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (profile == null) {
      throw StateError('The selected profile is no longer active.');
    }
    final categories =
        await (_database.select(_database.categories)..where(
              (row) =>
                  row.profileId.equals(budget.profileId) &
                  row.deletedAt.isNull(),
            ))
            .get();
    final existingAllocations =
        await (_database.select(_database.budgetCategoryAllocations)..where(
              (row) =>
                  row.profileId.equals(budget.profileId) &
                  row.budgetId.equals(budget.id) &
                  row.deletedAt.isNull(),
            ))
            .get();
    final expenseIds = categories
        .where((row) => row.type == 'expense')
        .map((row) => row.categoryId)
        .toSet();
    for (final bucket in budget.buckets) {
      final retainedIds = existingAllocations
          .where((row) => row.bucketId == bucket.id)
          .map((row) => row.categoryId);
      if (!{...expenseIds, ...retainedIds}.containsAll(bucket.categoryIds)) {
        throw ArgumentError(
          'Only active expense categories from this profile may be budgeted.',
        );
      }
    }
    final overlaps =
        await (_database.select(_database.budgets)..where(
              (row) =>
                  row.profileId.equals(budget.profileId) &
                  row.budgetId.equals(budget.id).not() &
                  row.deletedAt.isNull() &
                  row.periodStart.isSmallerThanValue(
                    budget.periodEnd.millisecondsSinceEpoch,
                  ) &
                  row.periodEnd.isBiggerThanValue(
                    budget.periodStart.millisecondsSinceEpoch,
                  ),
            ))
            .get();
    if (overlaps.isNotEmpty) {
      throw StateError(
        'This profile already has a budget overlapping this period.',
      );
    }
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await _database.customInsert(
      '''
      INSERT INTO budgets
        (profile_id, budget_id, name, period_start, period_end, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(profile_id, budget_id) DO UPDATE SET
        name = excluded.name, period_start = excluded.period_start,
        period_end = excluded.period_end, updated_at = excluded.updated_at,
        deleted_at = NULL, is_synced = 0, local_revision = budgets.local_revision + 1
      ''',
      variables: [
        Variable(budget.profileId),
        Variable(budget.id),
        Variable(budget.name),
        Variable(budget.periodStart.millisecondsSinceEpoch),
        Variable(budget.periodEnd.millisecondsSinceEpoch),
        Variable(now),
        Variable(now),
      ],
      updates: {_database.budgets},
    );
    await _tombstoneChildren(budget.profileId, budget.id, now);
    for (final bucket in budget.buckets) {
      await _database.customInsert(
        '''
        INSERT INTO budget_buckets
          (profile_id, budget_id, bucket_id, name, allocation_bps, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(profile_id, budget_id, bucket_id) DO UPDATE SET
          name = excluded.name, allocation_bps = excluded.allocation_bps,
          updated_at = excluded.updated_at, deleted_at = NULL, is_synced = 0
        ''',
        variables: [
          Variable(budget.profileId),
          Variable(budget.id),
          Variable(bucket.id),
          Variable(bucket.name),
          Variable(bucket.allocationBps),
          Variable(now),
          Variable(now),
        ],
        updates: {_database.budgetBuckets},
      );
      for (final category in bucket.categoryIds) {
        await _database.customInsert(
          '''
          INSERT INTO budget_category_allocations
            (profile_id, budget_id, bucket_id, category_id, created_at, updated_at)
          VALUES (?, ?, ?, ?, ?, ?)
          ON CONFLICT(profile_id, budget_id, category_id) DO UPDATE SET
            bucket_id = excluded.bucket_id, updated_at = excluded.updated_at,
            deleted_at = NULL, is_synced = 0
          ''',
          variables: [
            Variable(budget.profileId),
            Variable(budget.id),
            Variable(bucket.id),
            Variable(category),
            Variable(now),
            Variable(now),
          ],
          updates: {_database.budgetCategoryAllocations},
        );
      }
    }
  });

  Future<void> _tombstoneChildren(
    String profileId,
    String budgetId,
    int now,
  ) async {
    for (final table in <TableInfo<Table, Object?>>[
      _database.budgetCategoryAllocations,
      _database.budgetBuckets,
    ]) {
      await _database.customUpdate(
        'UPDATE ${table.actualTableName} SET deleted_at = ?, updated_at = ?, '
        'is_synced = 0, local_revision = local_revision + 1 '
        'WHERE profile_id = ? AND budget_id = ?',
        variables: [
          Variable(now),
          Variable(now),
          Variable(profileId),
          Variable(budgetId),
        ],
        updates: {table},
      );
    }
  }

  @override
  Future<void> delete({required String profileId, required String budgetId}) {
    _requireId(profileId);
    _requireId(budgetId);
    return _database.transaction(() async {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      final count = await _database.customUpdate(
        'UPDATE budgets SET deleted_at = ?, updated_at = ?, is_synced = 0, '
        'local_revision = local_revision + 1 '
        'WHERE profile_id = ? AND budget_id = ? AND deleted_at IS NULL',
        variables: [
          Variable(now),
          Variable(now),
          Variable(profileId),
          Variable(budgetId),
        ],
        updates: {_database.budgets},
      );
      if (count == 0) {
        throw StateError('No active budget found in the selected profile.');
      }
      await _tombstoneChildren(profileId, budgetId, now);
    });
  }

  void _requireId(String id) {
    if (id.trim().isEmpty) throw ArgumentError('An identifier is required.');
  }
}
