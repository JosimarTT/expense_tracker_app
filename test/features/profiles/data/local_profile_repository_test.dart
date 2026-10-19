import 'package:drift/native.dart';
import 'package:expense_tracker_app/core/database/app_database.dart'
    hide BudgetBucket;
import 'package:expense_tracker_app/features/budgets/data/local_budget_repository.dart';
import 'package:expense_tracker_app/features/budgets/domain/entities/budget_rule.dart';
import 'package:expense_tracker_app/features/profiles/data/local_profile_repository.dart';
import 'package:expense_tracker_app/features/profiles/domain/profile.dart';
import 'package:expense_tracker_app/features/transactions/data/repositories/local_transaction_repository.dart';
import 'package:expense_tracker_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> createProfile(AppDatabase db, String id) => LocalProfileRepository(
  db,
).create(LocalProfile(id: id, name: id, currencyCode: 'USD', currencyScale: 2));

BudgetRule budget(String profileId) => BudgetRule(
  id: 'budget',
  profileId: profileId,
  name: 'Monthly',
  periodStart: DateTime.utc(2026, 10),
  periodEnd: DateTime.utc(2026, 11),
  buckets: [
    BudgetBucket(
      id: 'needs',
      name: 'Needs',
      allocationBps: 5000,
      categoryIds: ['groceries'],
    ),
    BudgetBucket(id: 'wants', name: 'Wants', allocationBps: 3000),
    BudgetBucket(id: 'savings', name: 'Savings', allocationBps: 2000),
  ],
);

Future<void> addTransaction(AppDatabase db, String profileId) =>
    LocalTransactionRepository(db).save(
      FinancialTransaction(
        id: 'transaction',
        profileId: profileId,
        notes: 'Groceries',
        amountMinor: 1000,
        type: TransactionType.expense,
        categoryId: 'groceries',
        occurredAt: DateTime.utc(2026, 10, 10),
      ),
    );

void main() {
  late AppDatabase db;
  late LocalProfileRepository repository;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LocalProfileRepository(db);
    await createProfile(db, 'a');
    await createProfile(db, 'b');
  });

  tearDown(() => db.close());

  test(
    'Permanently deletes all profile data without affecting other profiles',
    () async {
      final budgets = LocalBudgetRepository(db);
      await budgets.save(budget('a'));
      await budgets.save(budget('b'));
      await addTransaction(db, 'a');
      await addTransaction(db, 'b');

      await repository.deletePermanently('a');

      expect(await repository.watchProfiles().first, hasLength(1));
      expect((await repository.watchProfiles().first).single.id, 'b');
      expect(await repository.watchCategories('a').first, isEmpty);
      expect(await repository.watchCategories('b').first, hasLength(8));
      expect(
        await (db.select(
          db.transactions,
        )..where((row) => row.profileId.equals('a'))).get(),
        isEmpty,
      );
      expect(
        await (db.select(
          db.transactions,
        )..where((row) => row.profileId.equals('b'))).get(),
        hasLength(1),
      );
      expect(
        await (db.select(
          db.budgets,
        )..where((row) => row.profileId.equals('a'))).get(),
        isEmpty,
      );
      expect(
        await (db.select(
          db.budgetBuckets,
        )..where((row) => row.profileId.equals('a'))).get(),
        isEmpty,
      );
      expect(
        await (db.select(
          db.budgetCategoryAllocations,
        )..where((row) => row.profileId.equals('a'))).get(),
        isEmpty,
      );
      expect(await budgets.watchBudgets('b').first, hasLength(1));
    },
  );

  test('Deletion is atomic when removing dependent data fails', () async {
    await LocalBudgetRepository(db).save(budget('a'));
    await addTransaction(db, 'a');
    await db.customStatement(
      "CREATE TRIGGER reject_transaction_delete BEFORE DELETE ON transactions "
      "WHEN OLD.profile_id = 'a' BEGIN SELECT RAISE(ABORT, 'test failure'); END",
    );

    await expectLater(
      repository.deletePermanently('a'),
      throwsA(isA<Exception>()),
    );

    expect(
      (await repository.watchProfiles().first).map((profile) => profile.id),
      contains('a'),
    );
    expect(await repository.watchCategories('a').first, hasLength(8));
    expect(
      await (db.select(
        db.transactions,
      )..where((row) => row.profileId.equals('a'))).get(),
      hasLength(1),
    );
    expect(
      await LocalBudgetRepository(db).watchBudgets('a').first,
      hasLength(1),
    );
    expect(
      await (db.select(
        db.budgetBuckets,
      )..where((row) => row.profileId.equals('a'))).get(),
      hasLength(3),
    );
  });

  test(
    'Rejects blank and unknown profiles without affecting existing data',
    () async {
      expect(() => repository.deletePermanently(' '), throwsArgumentError);
      await expectLater(
        repository.deletePermanently('missing'),
        throwsStateError,
      );
      expect(await repository.watchProfiles().first, hasLength(2));
    },
  );
}
