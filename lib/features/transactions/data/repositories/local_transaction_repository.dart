import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/financial_transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

class LocalTransactionRepository implements TransactionRepository {
  LocalTransactionRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<FinancialTransaction>> watchTransactions(String profileId) {
    _requireId(profileId);
    final query = _database.select(_database.transactions)
      ..where(
        (row) => row.profileId.equals(profileId) & row.deletedAt.isNull(),
      )
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
            title: row.title,
            amountMinor: row.amountMinor,
            type: TransactionType.values.byName(row.type),
            categoryId: row.categoryId,
            occurredAt: DateTime.fromMillisecondsSinceEpoch(
              row.occurredAt,
              isUtc: true,
            ),
          ),
      ],
    );
  }

  @override
  Future<void> save(FinancialTransaction transaction) {
    return _database.transaction(() async {
      final profile = await (_database.select(_database.profiles)
            ..where((row) => row.profileId.equals(transaction.profileId) & row.deletedAt.isNull()))
          .getSingleOrNull();
      final category = await (_database.select(_database.categories)
            ..where((row) =>
                row.profileId.equals(transaction.profileId) &
                row.categoryId.equals(transaction.categoryId)))
          .getSingleOrNull();
      if (profile == null) {
        throw StateError('The selected profile is no longer active.');
      }
      if (category?.deletedAt != null) {
        throw StateError('The selected category is no longer active.');
      }
      final existing = await (_database.select(_database.transactions)
            ..where(
              (row) =>
                  row.profileId.equals(transaction.profileId) &
                  row.transactionId.equals(transaction.id),
            ))
          .getSingleOrNull();
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await _database.into(_database.transactions).insertOnConflictUpdate(
        TransactionsCompanion.insert(
          profileId: transaction.profileId,
          transactionId: transaction.id,
          title: transaction.title,
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
    });
  }

  @override
  Future<void> delete({
    required String profileId,
    required String transactionId,
  }) async {
    _requireId(profileId);
    _requireId(transactionId);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    final count = await (_database.update(_database.transactions)
          ..where(
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
            localRevision: _database.transactions.localRevision + const Constant(1),
          ),
        );
    if (count == 0) {
      throw StateError('No active transaction found in the selected profile.');
    }
  }

  void _requireId(String id) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Must not be empty.');
    }
  }
}
