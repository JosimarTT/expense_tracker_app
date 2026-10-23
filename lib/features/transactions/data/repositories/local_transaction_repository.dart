import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/financial_transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/transaction_filter.dart';
import '../../../savings/data/local_savings_repository.dart';
import '../../../profiles/domain/profile.dart';

class LocalTransactionRepository implements TransactionRepository {
  LocalTransactionRepository(this._database, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _now;

  @override
  Stream<List<FinancialTransaction>> watchTransactions(String profileId) {
    _requireId(profileId);
    final query = _database.select(_database.transactions)
      ..where((row) => row.profileId.equals(profileId) & row.deletedAt.isNull())
      ..orderBy([
        (row) => OrderingTerm.desc(row.occurredAt),
        (row) => OrderingTerm.asc(row.transactionId),
      ]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          FinancialTransaction(
            id: row.transactionId,
            profileId: row.profileId,
            notes: row.notes,
            amountMinor: row.amountMinor,
            type: TransactionType.values.byName(row.type),
            categoryId: row.categoryId,
            savingsMonth: row.savingsMonth,
            occurredAt: DateTime.fromMillisecondsSinceEpoch(
              row.occurredAt,
              isUtc: true,
            ),
          ),
      ],
    );
  }

  @override
  Stream<TransactionPage> watchPage(
    String profileId,
    TransactionFilter filter, {
    TransactionSort sort = TransactionSort.newestFirst,
    int? limit,
  }) {
    _requireId(profileId);
    if (limit != null && limit < 1) {
      throw ArgumentError.value(limit, 'limit', 'Must be positive.');
    }
    final where = _where(profileId, filter);
    final direction = sort == TransactionSort.newestFirst ? 'DESC' : 'ASC';
    final sql =
        'SELECT t.* FROM transactions t ${where.sql} '
        'ORDER BY t.occurred_at $direction, t.transaction_id ASC'
        '${limit == null ? '' : ' LIMIT ${limit + 1}'}';
    return _database
        .customSelect(sql, variables: where.variables, readsFrom: _tables)
        .watch()
        .map((rows) {
          final more = limit != null && rows.length > limit;
          return TransactionPage(
            items: [
              for (final row in rows.take(limit ?? rows.length))
                FinancialTransaction(
                  id: row.read<String>('transaction_id'),
                  profileId: row.read<String>('profile_id'),
                  notes: row.read<String>('notes'),
                  amountMinor: row.read<int>('amount_minor'),
                  type: TransactionType.values.byName(row.read<String>('type')),
                  categoryId: row.read<String>('category_id'),
                  savingsMonth: row.readNullable<String>('savings_month'),
                  occurredAt: DateTime.fromMillisecondsSinceEpoch(
                    row.read<int>('occurred_at'),
                    isUtc: true,
                  ),
                ),
            ],
            hasMore: more,
          );
        });
  }

  @override
  Stream<TransactionTotals> watchTotals(
    String profileId,
    TransactionFilter filter,
  ) {
    _requireId(profileId);
    final where = _where(profileId, filter);
    return _database
        .customSelect(
          'SELECT t.type AS type, COUNT(*) AS n, '
          'MIN(t.occurred_at) AS first_at, MAX(t.occurred_at) AS last_at, '
          'SUM(t.amount_minor / 1000000) AS hi, '
          'SUM(t.amount_minor % 1000000) AS lo '
          'FROM transactions t ${where.sql} GROUP BY t.type',
          variables: where.variables,
          readsFrom: _tables,
        )
        .watch()
        .map(_totalsFrom);
  }

  @override
  Stream<Map<String, BigInt>> watchExpenseCategoryTotals(
    String profileId,
    TransactionFilter filter,
  ) {
    _requireId(profileId);
    final where = _where(profileId, filter);
    return _database
        .customSelect(
          'SELECT t.category_id AS category_id, '
          'SUM(t.amount_minor / 1000000) AS hi, '
          'SUM(t.amount_minor % 1000000) AS lo '
          'FROM transactions t ${where.sql} AND t.type = \'expense\' '
          'GROUP BY t.category_id',
          variables: where.variables,
          readsFrom: _tables,
        )
        .watch()
        .map(
          (rows) => {
            for (final row in rows)
              row.read<String>('category_id'): _exactSum(row),
          },
        );
  }

  @override
  Stream<List<PeriodTotal>> watchPeriodTotals(
    String profileId,
    TransactionFilter filter,
    PeriodGranularity granularity,
  ) {
    _requireId(profileId);
    final where = _where(profileId, filter);
    // The probe also carries a change token so edits re-run the bucket query.
    return _database
        .customSelect(
          'SELECT MIN(t.occurred_at) AS lo, MAX(t.occurred_at) AS hi, '
          'COUNT(*) AS n, COALESCE(SUM(t.local_revision), 0) AS rev, '
          'COALESCE(MAX(t.updated_at), 0) AS upd '
          'FROM transactions t ${where.sql}',
          variables: where.variables,
          readsFrom: _tables,
        )
        .watch()
        .asyncMap((probe) async {
          final row = probe.single;
          if (row.read<int>('n') == 0) return const <PeriodTotal>[];
          final first = DateTime.fromMillisecondsSinceEpoch(
            row.read<int>('lo'),
            isUtc: true,
          );
          final last = DateTime.fromMillisecondsSinceEpoch(
            row.read<int>('hi'),
            isUtc: true,
          );
          var from = granularity.floor(filter.start ?? first);
          final until = filter.end?.toLocal() ?? last.toLocal();
          final bounds = <(DateTime, DateTime)>[];
          while (filter.end == null
              ? !from.isAfter(until)
              : from.isBefore(until)) {
            bounds.add((from, granularity.next(from)));
            from = granularity.next(from);
            if (bounds.length > _maxPeriods) {
              throw ArgumentError(
                'Too many $granularity periods; use a coarser granularity.',
              );
            }
          }
          final values = [
            for (var i = 0; i < bounds.length; i++)
              '($i, ${bounds[i].$1.toUtc().millisecondsSinceEpoch}, '
                  '${bounds[i].$2.toUtc().millisecondsSinceEpoch})',
          ];
          final rows = await _database
              .customSelect(
                'WITH b(idx, s, e) AS (VALUES ${values.join(', ')}) '
                'SELECT b.idx AS idx, t.type AS type, COUNT(*) AS n, '
                'MIN(t.occurred_at) AS first_at, MAX(t.occurred_at) AS last_at, '
                'SUM(t.amount_minor / 1000000) AS hi, '
                'SUM(t.amount_minor % 1000000) AS lo '
                'FROM transactions t JOIN b '
                'ON t.occurred_at >= b.s AND t.occurred_at < b.e '
                '${where.sql} GROUP BY b.idx, t.type',
                variables: where.variables,
                readsFrom: _tables,
              )
              .get();
          final byIndex = <int, List<QueryRow>>{};
          for (final r in rows) {
            byIndex.putIfAbsent(r.read<int>('idx'), () => []).add(r);
          }
          return [
            for (var i = 0; i < bounds.length; i++)
              PeriodTotal(
                start: bounds[i].$1,
                end: bounds[i].$2,
                totals: _totalsFrom(byIndex[i] ?? const []),
              ),
          ];
        });
  }

  static const _maxPeriods = 1000;

  Set<TableInfo> get _tables => {
    _database.transactions,
    _database.categories,
    _database.profiles,
  };

  TransactionTotals _totalsFrom(List<QueryRow> rows) {
    BigInt? income, expense, savings;
    DateTime? first, last;
    var incomeN = 0, expenseN = 0, savingsN = 0;
    for (final r in rows) {
      final n = r.read<int>('n');
      final rowFirst = DateTime.fromMillisecondsSinceEpoch(
        r.read<int>('first_at'),
        isUtc: true,
      );
      final rowLast = DateTime.fromMillisecondsSinceEpoch(
        r.read<int>('last_at'),
        isUtc: true,
      );
      if (first == null || rowFirst.isBefore(first)) first = rowFirst;
      if (last == null || rowLast.isAfter(last)) last = rowLast;
      switch (TransactionType.values.byName(r.read<String>('type'))) {
        case TransactionType.income:
          income = _exactSum(r);
          incomeN = n;
        case TransactionType.expense:
          expense = _exactSum(r);
          expenseN = n;
        case TransactionType.savings:
          savings = _exactSum(r);
          savingsN = n;
      }
    }
    return TransactionTotals(
      incomeMinor: income,
      expenseMinor: expense,
      savingsMinor: savings,
      incomeCount: incomeN,
      expenseCount: expenseN,
      savingsCount: savingsN,
      firstOccurredAt: first,
      lastOccurredAt: last,
    );
  }

  BigInt _exactSum(QueryRow row) =>
      BigInt.from(row.read<int>('hi')) * BigInt.from(1000000) +
      BigInt.from(row.read<int>('lo'));

  ({String sql, List<Variable> variables}) _where(
    String profileId,
    TransactionFilter filter,
  ) {
    final clauses = <String>['t.profile_id = ?', 't.deleted_at IS NULL'];
    final vars = <Variable>[Variable.withString(profileId)];
    if (filter.start != null) {
      clauses.add('t.occurred_at >= ?');
      vars.add(Variable.withInt(filter.start!.millisecondsSinceEpoch));
    }
    if (filter.end != null) {
      clauses.add('t.occurred_at < ?');
      vars.add(Variable.withInt(filter.end!.millisecondsSinceEpoch));
    }
    if (filter.type != null) {
      clauses.add('t.type = ?');
      vars.add(Variable.withString(filter.type!.name));
    }
    if (filter.categoryIds.isNotEmpty) {
      clauses.add(
        't.category_id IN (${List.filled(filter.categoryIds.length, '?').join(', ')})',
      );
      vars.addAll(filter.categoryIds.map(Variable.withString));
    }
    final query = filter.query.toLowerCase();
    if (query.isNotEmpty) {
      final parts = [
        'instr(lower(t.notes), ?) > 0',
        'instr(lower(COALESCE((SELECT c.name FROM categories c '
            'WHERE c.profile_id = t.profile_id '
            'AND c.category_id = t.category_id), \'\')), ?) > 0',
      ];
      vars
        ..add(Variable.withString(query))
        ..add(Variable.withString(query));
      final amount = _amountQuery(query);
      if (amount != null) {
        const scale =
            '(SELECT p.currency_scale FROM profiles p '
            'WHERE p.profile_id = t.profile_id)';
        const divisor =
            'CASE $scale WHEN 0 THEN 1 WHEN 1 THEN 10 WHEN 2 THEN 100 '
            'WHEN 3 THEN 1000 ELSE 10000 END';
        parts.add(
          'instr(CAST(t.amount_minor / ($divisor) AS TEXT) || '
          'CASE WHEN $scale = 0 THEN \'\' ELSE \'.\' || '
          'substr(\'0000\' || CAST(t.amount_minor % ($divisor) AS TEXT), '
          '-$scale) END, ?) > 0',
        );
        vars.add(Variable.withString(amount));
      }
      clauses.add('(${parts.join(' OR ')})');
    }
    return (sql: 'WHERE ${clauses.join(' AND ')}', variables: vars);
  }

  /// Digits and a decimal point if [query] looks like an amount, ignoring
  /// currency symbols, grouping commas and spaces.
  String? _amountQuery(String query) {
    final cleaned = query.replaceAll(RegExp(r'[,\s]'), '');
    final match = RegExp(r'^[^\d.]{0,3}(\d*\.?\d*)$').firstMatch(cleaned);
    final digits = match?.group(1);
    if (digits == null || !digits.contains(RegExp(r'\d'))) return null;
    return digits;
  }

  @override
  Future<void> save(FinancialTransaction transaction) {
    return _database.transaction(() async {
      final profile =
          await (_database.select(_database.profiles)..where(
                (row) =>
                    row.profileId.equals(transaction.profileId) &
                    row.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      final category =
          await (_database.select(_database.categories)..where(
                (row) =>
                    row.profileId.equals(transaction.profileId) &
                    row.categoryId.equals(transaction.categoryId),
              ))
              .getSingleOrNull();
      if (profile == null) {
        throw StateError('The selected profile is no longer active.');
      }
      final existing =
          await (_database.select(_database.transactions)..where(
                (row) =>
                    row.profileId.equals(transaction.profileId) &
                    row.transactionId.equals(transaction.id),
              ))
              .getSingleOrNull();
      if (existing?.savingsMonth != null ||
          transaction.savingsMonth != null ||
          transaction.categoryId == TransactionCategory.unusedMoneyId) {
        throw StateError(
          'Unused money savings are recalculated automatically. Edit the source transactions instead.',
        );
      }
      if (category?.deletedAt != null &&
          (existing == null || existing.categoryId != transaction.categoryId)) {
        throw StateError('The selected category is no longer active.');
      }
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await _database
          .into(_database.transactions)
          .insertOnConflictUpdate(
            TransactionsCompanion.insert(
              profileId: transaction.profileId,
              transactionId: transaction.id,
              notes: Value(transaction.notes),
              amountMinor: transaction.amountMinor,
              type: transaction.type.name,
              categoryId: transaction.categoryId,
              occurredAt: transaction.occurredAt.millisecondsSinceEpoch,
              createdAt: existing?.createdAt ?? now,
              updatedAt: now,
              deletedAt: const Value(null),
              localRevision: Value((existing?.localRevision ?? 0) + 1),
              isSynced: const Value(0),
            ),
          );
      await LocalSavingsRepository(_database)
          .process(transaction.profileId, _now());
    });
  }

  @override
  Future<void> delete({
    required String profileId,
    required String transactionId,
  }) async {
    _requireId(profileId);
    _requireId(transactionId);
    await _database.transaction(() async {
      final existing =
          await (_database.select(_database.transactions)..where(
                (row) =>
                    row.profileId.equals(profileId) &
                    row.transactionId.equals(transactionId),
              ))
              .getSingleOrNull();
      if (existing?.savingsMonth != null) {
        throw StateError(
          'Unused money savings are recalculated automatically. Edit the source transactions instead.',
        );
      }
      final now = _now().toUtc().millisecondsSinceEpoch;
      final count =
          await (_database.update(_database.transactions)..where(
                (row) =>
                    row.profileId.equals(profileId) &
                    row.transactionId.equals(transactionId) &
                    row.deletedAt.isNull(),
              ))
              .write(
                TransactionsCompanion.custom(
                  deletedAt: Variable(now),
                  updatedAt: Variable(now),
                  isSynced: const Constant(0),
                  localRevision:
                      _database.transactions.localRevision + const Constant(1),
                ),
              );
      if (count == 0) {
        throw StateError(
          'No active transaction found in the selected profile.',
        );
      }
      await LocalSavingsRepository(_database).process(profileId, _now());
    });
  }

  void _requireId(String id) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Must not be empty.');
    }
  }
}
