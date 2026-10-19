import 'dart:io';

import 'package:drift/drift.dart' show BooleanExpressionOperators;
import 'package:drift/native.dart';
import 'package:expense_tracker_app/core/database/app_database.dart';
import 'package:expense_tracker_app/features/profiles/data/local_profile_repository.dart';
import 'package:expense_tracker_app/features/profiles/domain/profile.dart';
import 'package:expense_tracker_app/features/savings/data/local_savings_repository.dart';
import 'package:expense_tracker_app/features/transactions/data/repositories/local_transaction_repository.dart';
import 'package:expense_tracker_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late LocalSavingsRepository savings;
  late LocalProfileRepository profiles;
  late LocalTransactionRepository transactions;
  var now = DateTime(2026, 10, 15);
  setUp(() async {
    now = DateTime(2026, 10, 15);
    db = AppDatabase.forTesting(NativeDatabase.memory());
    savings = LocalSavingsRepository(db);
    profiles = LocalProfileRepository(db);
    transactions = LocalTransactionRepository(db, now: () => now);
    for (final id in ['a', 'b']) {
      await profiles.create(
        LocalProfile(id: id, name: id, currencyCode: 'USD', currencyScale: 2),
      );
    }
  });
  tearDown(() => db.close());

  Future<void> save(
    String id,
    int amount,
    TransactionType type, {
    String profile = 'a',
    DateTime? date,
  }) => transactions.save(
    FinancialTransaction(
      id: id,
      profileId: profile,
      amountMinor: amount,
      type: type,
      categoryId: switch (type) {
        TransactionType.income => 'salary',
        TransactionType.expense => 'groceries',
        TransactionType.savings => 'investments',
      },
      occurredAt: date ?? DateTime(2026, 10, 20),
    ),
  );
  Future<List<Transaction>> generated() =>
      (db.select(db.transactions)..where(
            (row) => row.savingsMonth.isNotNull() & row.deletedAt.isNull(),
          ))
          .get();

  test('Savings settings, generated IDs and recalculation survive close and reopen', () async {
    await db.close();
    final directory = await Directory.systemTemp.createTemp(
      'savings_persistence_',
    );
    final file = File('${directory.path}${Platform.pathSeparator}test.sqlite');
    var persistent = AppDatabase.forTesting(NativeDatabase(file));
    try {
      await LocalProfileRepository(persistent).create(
        const LocalProfile(
          id: 'a',
          name: 'Personal',
          currencyCode: 'USD',
          currencyScale: 2,
        ),
      );
      final automatic = LocalSavingsRepository(persistent);
      await automatic.setAutomatic('a', true, DateTime(2026, 10));
      await LocalTransactionRepository(
        persistent,
        now: () => DateTime(2026, 10, 15),
      ).save(
        FinancialTransaction(
          id: 'income',
          profileId: 'a',
          amountMinor: 10000,
          type: TransactionType.income,
          categoryId: 'salary',
          occurredAt: DateTime(2026, 10, 15),
        ),
      );
      await automatic.process('a', DateTime(2026, 11));
      final generatedId =
          (await persistent.select(persistent.transactions).get())
              .singleWhere((row) => row.savingsMonth != null)
              .transactionId;
      await persistent.close();
      persistent = AppDatabase.forTesting(NativeDatabase(file));
      await LocalSavingsRepository(persistent).process('a', DateTime(2026, 11));
      expect(
        (await LocalProfileRepository(
          persistent,
        ).watchProfiles().first).single.autoSavings,
        isTrue,
      );
      await LocalTransactionRepository(
        persistent,
        now: () => DateTime(2026, 11),
      ).save(
        FinancialTransaction(
          id: 'bill',
          profileId: 'a',
          amountMinor: 3000,
          type: TransactionType.expense,
          categoryId: 'groceries',
          occurredAt: DateTime(2026, 10, 20),
        ),
      );
      final sweeps = (await persistent.select(persistent.transactions).get())
          .where((row) => row.savingsMonth != null);
      expect(sweeps, hasLength(1));
      expect(sweeps.single.transactionId, generatedId);
      expect(sweeps.single.amountMinor, 7000);
    } finally {
      await persistent.close();
      await directory.delete(recursive: true);
    }
  });

  test('Off by default; sweeps only completed months from enable month, per profile', () async {
    await save(
      'sept',
      5000,
      TransactionType.income,
      date: DateTime(2026, 9, 1),
    );
    await save('salary', 100000, TransactionType.income);
    await save('expense', 50000, TransactionType.expense);
    await save('investment', 20000, TransactionType.savings);
    await save('other-profile', 70000, TransactionType.income, profile: 'b');
    await savings.process('a', DateTime(2026, 11));
    expect(await generated(), isEmpty);
    await savings.setAutomatic('a', true, now);
    expect(
      (await profiles.watchProfiles().first)
          .singleWhere((row) => row.id == 'a')
          .autoSavings,
      isTrue,
    );
    await savings.process('a', DateTime(2026, 10, 31, 23, 59));
    expect(await generated(), isEmpty);
    now = DateTime(2026, 11);
    await Future.wait([savings.process('a', now), savings.process('a', now)]);
    final sweep = (await generated()).single;
    expect(sweep.amountMinor, 30000);
    expect(sweep.type, 'savings');
    expect(sweep.categoryId, TransactionCategory.unusedMoneyId);
    expect(sweep.profileId, 'a');
    expect(sweep.savingsMonth, '2026-10');
    expect(DateTime.fromMillisecondsSinceEpoch(sweep.occurredAt).month, 10);
    await savings.process('a', DateTime(2026, 12));
    expect(await generated(), hasLength(1));
    expect(
      (await db.select(db.transactions).get()).where(
        (row) => row.savingsMonth != null,
      ),
      hasLength(1),
    );
  });

  test('Edits, deletes, savings changes and moving entries between months recalculate without feedback loops', () async {
    await savings.setAutomatic('a', true, now);
    await save('salary', 100000, TransactionType.income);
    now = DateTime(2026, 12);
    await savings.process('a', now);
    final original = (await generated()).single;
    await save('bill', 30000, TransactionType.expense);
    expect((await generated()).single.amountMinor, 70000);
    await save('retirement', 20000, TransactionType.savings);
    expect((await generated()).single.amountMinor, 50000);
    await transactions.delete(profileId: 'a', transactionId: 'bill');
    expect((await generated()).single.amountMinor, 80000);
    await save('salary', 10000, TransactionType.income);
    expect(await generated(), isEmpty);
    await transactions.delete(profileId: 'a', transactionId: 'retirement');
    expect((await generated()).single.amountMinor, 10000);
    expect((await generated()).single.transactionId, original.transactionId);
    await save(
      'salary',
      10000,
      TransactionType.income,
      date: DateTime(2026, 11, 15),
    );
    final moved = (await generated()).single;
    expect(moved.savingsMonth, '2026-11');
    expect(moved.amountMinor, 10000);
    await savings.process('a', now);
    expect((await generated()).single.localRevision, moved.localRevision);
  });

  test('Disabling stops new sweeps but previously generated entries still recalculate', () async {
    await savings.setAutomatic('a', true, now);
    await save('salary', 10000, TransactionType.income);
    now = DateTime(2026, 11);
    await savings.process('a', now);
    await savings.setAutomatic('a', false, now);
    await save('salary', 20000, TransactionType.income);
    expect((await generated()).single.amountMinor, 20000);
    await save(
      'november',
      30000,
      TransactionType.income,
      date: DateTime(2026, 11, 5),
    );
    now = DateTime(2026, 12);
    await savings.process('a', now);
    expect(await generated(), hasLength(1));
    await savings.setAutomatic('a', true, now);
    await savings.process('a', DateTime(2027, 1));
    expect(await generated(), hasLength(1));
  });

  test('Zero and negative remainders do not create savings', () async {
    await savings.setAutomatic('a', true, now);
    await save('salary', 10000, TransactionType.income);
    await save('bill', 10000, TransactionType.expense);
    now = DateTime(2026, 11);
    await savings.process('a', now);
    expect(await generated(), isEmpty);
    await save('bill', 20000, TransactionType.expense);
    expect(await generated(), isEmpty);
  });

  test('System category and generated entries cannot be edited, archived, deleted or manually selected', () async {
    await savings.setAutomatic('a', true, now);
    await save('salary', 10000, TransactionType.income);
    now = DateTime(2026, 11);
    await savings.process('a', now);
    final sweep = (await generated()).single;
    await expectLater(
      transactions.delete(profileId: 'a', transactionId: sweep.transactionId),
      throwsStateError,
    );
    await expectLater(
      transactions.save(
        FinancialTransaction(
          id: sweep.transactionId,
          profileId: 'a',
          amountMinor: 100,
          type: TransactionType.savings,
          categoryId: 'investments',
          occurredAt: DateTime(2026, 10, 31),
        ),
      ),
      throwsStateError,
    );
    await expectLater(
      transactions.save(
        FinancialTransaction(
          id: 'manual',
          profileId: 'a',
          amountMinor: 100,
          type: TransactionType.savings,
          categoryId: TransactionCategory.unusedMoneyId,
          occurredAt: now,
        ),
      ),
      throwsStateError,
    );
    await expectLater(
      profiles.setArchived(
        profileId: 'a',
        categoryId: TransactionCategory.unusedMoneyId,
        archived: true,
      ),
      throwsStateError,
    );
    await expectLater(
      profiles.delete(
        profileId: 'a',
        categoryId: TransactionCategory.unusedMoneyId,
      ),
      throwsStateError,
    );
    expect(
      await profiles.canDelete(
        profileId: 'a',
        categoryId: TransactionCategory.unusedMoneyId,
      ),
      isFalse,
    );
    await profiles.deletePermanently('a');
    expect(await generated(), isEmpty);
    expect(await profiles.watchProfiles().first, hasLength(1));
  });

  test('A failed sweep rolls back the source edit and preserves exact large integer arithmetic', () async {
    await savings.setAutomatic('a', true, now);
    await save('salary', 9007199254740993, TransactionType.income);
    await save('expense', 1, TransactionType.expense);
    now = DateTime(2026, 11);
    await savings.process('a', now);
    expect((await generated()).single.amountMinor, 9007199254740992);
    await db.customStatement("""
      CREATE TRIGGER fail_sweep BEFORE UPDATE ON transactions
      WHEN OLD.savings_month IS NOT NULL
      BEGIN SELECT RAISE(ABORT, 'Test failure'); END
    """);
    await expectLater(
      save('expense', 2, TransactionType.expense),
      throwsA(isA<Exception>()),
    );
    expect(
      (await transactions.watchTransactions('a').first)
          .singleWhere((row) => row.id == 'expense')
          .amountMinor,
      1,
    );
    expect((await generated()).single.amountMinor, 9007199254740992);
  });
}
