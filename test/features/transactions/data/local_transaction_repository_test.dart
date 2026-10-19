import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:expense_tracker_app/core/database/app_database.dart';
import 'package:expense_tracker_app/features/transactions/data/repositories/local_transaction_repository.dart';
import 'package:expense_tracker_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

FinancialTransaction transaction({
  String profileId = 'a',
  String id = 'transaction',
  String categoryId = 'food',
  TransactionType type = TransactionType.expense,
  int amountMinor = 1250,
  DateTime? occurredAt,
}) => FinancialTransaction(
  id: id,
  profileId: profileId,
  notes: 'Lunch',
  amountMinor: amountMinor,
  type: type,
  categoryId: categoryId,
  occurredAt: occurredAt ?? DateTime.utc(2026, 10, 14, 12),
);

void main() {
  late AppDatabase database;
  late LocalTransactionRepository repository;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LocalTransactionRepository(database);
    for (final profile in ['a', 'b']) {
      await database
          .into(database.profiles)
          .insert(
            ProfilesCompanion.insert(
              profileId: profile,
              name: profile,
              currencyCode: 'USD',
              currencyScale: 2,
              createdAt: 0,
              updatedAt: 0,
            ),
          );
      await database
          .into(database.categories)
          .insert(
            CategoriesCompanion.insert(
              profileId: profile,
              categoryId: 'food',
              name: 'Food',
              type: 'expense',
              createdAt: 0,
              updatedAt: 0,
            ),
          );
    }
  });

  tearDown(() => database.close());

  test('Persists exact minor units and UTC timestamps', () async {
    final original = transaction();
    await repository.save(original);
    final saved = (await repository.watchTransactions('a').first).single;
    expect(saved.amountMinor, 1250);
    expect(saved.notes, 'Lunch');
    expect(saved.occurredAt, original.occurredAt);
    expect(saved.occurredAt.isUtc, isTrue);
    final row = await database.select(database.transactions).getSingle();
    expect(row.isSynced, 0);
    expect(row.localRevision, 1);
  });

  test('Persists income through a matching income category', () async {
    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(
            profileId: 'a',
            categoryId: 'salary',
            name: 'Salary',
            type: 'income',
            createdAt: 0,
            updatedAt: 0,
          ),
        );
    await repository.save(
      transaction(
        categoryId: 'salary',
        type: TransactionType.income,
        amountMinor: 500000,
      ),
    );
    final saved = (await repository.watchTransactions('a').first).single;
    expect(saved.type, TransactionType.income);
    expect(saved.amountMinor, 500000);
  });

  test('Accepts transactions without notes', () async {
    final entry = transaction();
    await repository.save(
      FinancialTransaction(
        id: entry.id,
        profileId: entry.profileId,
        amountMinor: entry.amountMinor,
        type: entry.type,
        categoryId: entry.categoryId,
        occurredAt: entry.occurredAt,
      ),
    );
    expect(
      (await repository.watchTransactions('a').first).single.notes,
      isEmpty,
    );
  });

  test(
    'Preserves integer precision beyond floating-point safe integers',
    () async {
      const amount = 9007199254740993;
      await repository.save(transaction(amountMinor: amount));
      expect(
        (await repository.watchTransactions('a').first).single.amountMinor,
        amount,
      );
    },
  );

  test('Isolates reads, updates and deletion for identical IDs', () async {
    await repository.save(transaction());
    await repository.save(transaction(profileId: 'b', amountMinor: 2500));
    await repository.save(transaction(amountMinor: 999));
    expect(
      (await repository.watchTransactions('b').first).single.amountMinor,
      2500,
    );
    await repository.delete(profileId: 'a', transactionId: 'transaction');
    expect(await repository.watchTransactions('a').first, isEmpty);
    expect(await repository.watchTransactions('b').first, hasLength(1));
  });

  test('Local edits reset sync state and increment the revision', () async {
    await repository.save(transaction());
    final before = await database.select(database.transactions).getSingle();
    await database
        .update(database.transactions)
        .write(const TransactionsCompanion(isSynced: Value(1)));
    await repository.save(transaction(amountMinor: 1800));
    final after = await database.select(database.transactions).getSingle();
    expect(after.createdAt, before.createdAt);
    expect(after.localRevision, 2);
    expect(after.isSynced, 0);
    expect(after.amountMinor, 1800);
  });

  test('Deletion keeps a pending tombstone', () async {
    await repository.save(transaction());
    await database
        .update(database.transactions)
        .write(const TransactionsCompanion(isSynced: Value(1)));
    await repository.delete(profileId: 'a', transactionId: 'transaction');
    final row = await database.select(database.transactions).getSingle();
    expect(row.deletedAt, isNotNull);
    expect(row.localRevision, 2);
    expect(row.isSynced, 0);
    expect(await repository.watchTransactions('a').first, isEmpty);
  });

  test(
    'Explicit save restores a tombstone as a new pending revision',
    () async {
      await repository.save(transaction());
      final before = await database.select(database.transactions).getSingle();
      await repository.delete(profileId: 'a', transactionId: 'transaction');
      await repository.save(transaction(amountMinor: 2000));
      final restored = await database.select(database.transactions).getSingle();
      expect(restored.deletedAt, null);
      expect(restored.createdAt, before.createdAt);
      expect(restored.localRevision, 3);
      expect(restored.isSynced, 0);
      expect(
        (await repository.watchTransactions('a').first).single.amountMinor,
        2000,
      );
    },
  );

  test('Rejects unknown deletes and blank profile identifiers', () async {
    await expectLater(
      repository.delete(profileId: 'a', transactionId: 'missing'),
      throwsStateError,
    );
    expect(() => repository.watchTransactions(' '), throwsArgumentError);
  });

  test(
    'Rejects cross-profile categories and mismatched income types',
    () async {
      await database
          .into(database.categories)
          .insert(
            CategoriesCompanion.insert(
              profileId: 'b',
              categoryId: 'private',
              name: 'Private',
              type: 'expense',
              createdAt: 0,
              updatedAt: 0,
            ),
          );
      final foreignKeyError = throwsA(
        predicate<Object>(
          (error) => error.toString().contains('FOREIGN KEY constraint failed'),
        ),
      );
      await expectLater(
        repository.save(transaction(categoryId: 'private')),
        foreignKeyError,
      );
      await expectLater(
        repository.save(transaction(type: TransactionType.income)),
        foreignKeyError,
      );
    },
  );

  test('Watch stream emits changes in descending occurrence order', () async {
    final changes = StreamIterator(repository.watchTransactions('a'));
    addTearDown(changes.cancel);
    expect(await changes.moveNext(), isTrue);
    expect(changes.current, isEmpty);
    await repository.save(transaction());
    expect(await changes.moveNext(), isTrue);
    expect(changes.current.single.id, 'transaction');
  });

  test('Orders transactions by occurrence rather than write time', () async {
    await repository.save(
      transaction(id: 'new', occurredAt: DateTime.utc(2026, 11)),
    );
    await repository.save(
      transaction(id: 'old', occurredAt: DateTime.utc(2026, 10)),
    );
    expect(
      (await repository.watchTransactions('a').first).map((row) => row.id),
      ['new', 'old'],
    );
  });

  test('Domain rejects invalid amounts and blank transaction identifiers', () {
    expect(() => transaction(amountMinor: 0), throwsArgumentError);
    expect(() => transaction(amountMinor: -1), throwsArgumentError);
    expect(() => transaction(id: ' '), throwsArgumentError);
  });
}
