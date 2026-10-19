import 'package:drift/native.dart';
import 'package:expense_tracker_app/core/database/app_database.dart'
    hide BudgetBucket;
import 'package:expense_tracker_app/features/budgets/data/local_budget_repository.dart';
import 'package:expense_tracker_app/features/budgets/domain/entities/budget_rule.dart';
import 'package:expense_tracker_app/features/profiles/data/local_profile_repository.dart';
import 'package:expense_tracker_app/features/profiles/domain/category_options.dart';
import 'package:expense_tracker_app/features/profiles/domain/profile.dart';
import 'package:expense_tracker_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:expense_tracker_app/features/transactions/data/repositories/local_transaction_repository.dart';
import 'package:flutter_test/flutter_test.dart';

const profile = LocalProfile(
  id: 'a',
  name: 'Personal',
  currencyCode: 'USD',
  currencyScale: 2,
);

TransactionCategory category({
  String id = 'custom',
  String name = 'Coffee',
  TransactionType type = TransactionType.expense,
  String? bucket = 'wants',
  String icon = 'restaurant',
  int color = 0xFFE65100,
}) => TransactionCategory(
  id: id,
  name: name,
  type: type,
  iconKey: icon,
  colorArgb: color,
  defaultBudgetBucket: type == TransactionType.expense ? bucket : null,
);

BudgetRule budget({String id = 'budget', int month = 10}) => BudgetRule(
  id: id,
  profileId: 'a',
  name: 'October',
  periodStart: DateTime.utc(2026, month),
  periodEnd: DateTime.utc(2026, month + 1),
  buckets: [
    BudgetBucket(
      id: 'needs',
      name: 'Needs',
      allocationBps: 5000,
      categoryIds: ['custom'],
    ),
    BudgetBucket(id: 'wants', name: 'Wants', allocationBps: 3000),
    BudgetBucket(id: 'savings', name: 'Savings', allocationBps: 2000),
  ],
);

void main() {
  late AppDatabase db;
  late LocalProfileRepository repository;
  late LocalTransactionRepository transactions;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LocalProfileRepository(db);
    transactions = LocalTransactionRepository(db);
    await repository.create(profile);
  });

  tearDown(() => db.close());

  test(
    'Permanent deletion purges deleted references only in the selected profile',
    () async {
      await repository.create(
        const LocalProfile(
          id: 'b',
          name: 'Other',
          currencyCode: 'USD',
          currencyScale: 2,
        ),
      );
      for (final profileId in ['a', 'b']) {
        await repository.save(profileId, category());
        for (final id in ['first', 'second']) {
          await transactions.save(
            FinancialTransaction(
              id: id,
              profileId: profileId,
              amountMinor: 500,
              type: TransactionType.expense,
              categoryId: 'custom',
              occurredAt: DateTime.utc(2026, 10, 10),
            ),
          );
        }
      }
      await transactions.delete(profileId: 'a', transactionId: 'first');
      expect(
        await repository.canDelete(profileId: 'a', categoryId: 'custom'),
        isFalse,
      );
      await expectLater(
        repository.delete(profileId: 'a', categoryId: 'custom'),
        throwsStateError,
      );
      expect(
        await (db.select(
          db.transactions,
        )..where((row) => row.profileId.equals('a'))).get(),
        hasLength(2),
      );
      await transactions.delete(profileId: 'a', transactionId: 'second');
      await LocalBudgetRepository(db).save(budget());
      expect(
        await repository.canDelete(profileId: 'a', categoryId: 'custom'),
        isFalse,
      );
      await expectLater(
        repository.delete(profileId: 'a', categoryId: 'custom'),
        throwsStateError,
      );
      await LocalBudgetRepository(db)
          .delete(profileId: 'a', budgetId: 'budget');
      expect(
        await repository.canDelete(profileId: 'a', categoryId: 'custom'),
        isTrue,
      );
      await repository.setArchived(
        profileId: 'a',
        categoryId: 'custom',
        archived: true,
      );
      await repository.delete(profileId: 'a', categoryId: 'custom');
      expect(
        (await repository.watchCategories('a').first).where(
          (row) => row.id == 'custom',
        ),
        isEmpty,
      );
      expect(
        await (db.select(
          db.transactions,
        )..where((row) => row.profileId.equals('a'))).get(),
        isEmpty,
      );
      expect(await db.select(db.budgetCategoryAllocations).get(), isEmpty);
      expect(await transactions.watchTransactions('b').first, hasLength(2));
      expect(
        (await repository.watchCategories('b').first).any(
          (row) => row.id == 'custom',
        ),
        isTrue,
      );
    },
  );

  test(
    'Failed permanent deletion rolls back cleanup of deleted dependents',
    () async {
      await repository.save('a', category());
      await transactions.save(
        FinancialTransaction(
          id: 'tx',
          profileId: 'a',
          amountMinor: 500,
          type: TransactionType.expense,
          categoryId: 'custom',
          occurredAt: DateTime.utc(2026, 10, 10),
        ),
      );
      await transactions.delete(profileId: 'a', transactionId: 'tx');
      await db.customStatement('''
      CREATE TRIGGER prevent_category_delete BEFORE DELETE ON categories
      BEGIN SELECT RAISE(ABORT, 'Test failure'); END
    ''');
      await expectLater(
        repository.delete(profileId: 'a', categoryId: 'custom'),
        throwsA(isA<Exception>()),
      );
      expect(await db.select(db.transactions).get(), hasLength(1));
      expect(
        (await repository.watchCategories('a').first).any(
          (row) => row.id == 'custom',
        ),
        isTrue,
      );
    },
  );

  test('Archive and restore preserve identity, mark revisions, and stay profile scoped', () async {
    await repository.save('a', category());
    await repository.setArchived(
      profileId: 'a',
      categoryId: 'custom',
      archived: true,
    );
    expect(
      await repository.canDelete(profileId: 'a', categoryId: 'custom'),
      isTrue,
    );
    await repository.save('a', category(name: 'Renamed'));
    expect(
      (await repository.watchCategories('a').first)
          .singleWhere((row) => row.id == 'custom')
          .isArchived,
      isTrue,
    );
    await repository.setArchived(
      profileId: 'a',
      categoryId: 'custom',
      archived: false,
    );
    final saved = (await repository.watchCategories('a').first).singleWhere(
      (row) => row.id == 'custom',
    );
    expect(saved.isArchived, isFalse);
    expect(saved.name, 'Renamed');
    final row = await (db.select(
      db.categories,
    )..where((row) => row.categoryId.equals('custom'))).getSingle();
    expect(row.localRevision, 4);
    expect(row.isSynced, 0);
    await expectLater(
      repository.setArchived(
        profileId: 'b',
        categoryId: 'custom',
        archived: true,
      ),
      throwsStateError,
    );
    await repository.setArchived(
      profileId: 'a',
      categoryId: 'custom',
      archived: true,
    );
    await repository.delete(profileId: 'a', categoryId: 'custom');
    expect(
      (await repository.watchCategories('a').first).where(
        (row) => row.id == 'custom',
      ),
      isEmpty,
    );
  });

  test(
    'Archived budget mappings can be retained but not added to new budgets',
    () async {
      await repository.save('a', category());
      final budgets = LocalBudgetRepository(db);
      await budgets.save(budget());
      await repository.setArchived(
        profileId: 'a',
        categoryId: 'custom',
        archived: true,
      );
      expect(
        await repository.canDelete(profileId: 'a', categoryId: 'custom'),
        isFalse,
      );
      await budgets.save(budget());
      expect(
        (await budgets.watchBudgets('a').first).single.buckets
            .singleWhere((row) => row.id == 'needs')
            .categoryIds,
        contains('custom'),
      );
      await expectLater(
        budgets.save(budget(id: 'next', month: 11)),
        throwsArgumentError,
      );
      await expectLater(
        repository.delete(profileId: 'a', categoryId: 'custom'),
        throwsStateError,
      );
    },
  );

  test('Existing transactions retain archived categories when edited, new entries cannot use them', () async {
    await repository.save('a', category());
    FinancialTransaction transaction(String id, int amount) =>
        FinancialTransaction(
          id: id,
          profileId: 'a',
          amountMinor: amount,
          type: TransactionType.expense,
          categoryId: 'custom',
          occurredAt: DateTime.utc(2026, 10, 10),
        );
    await transactions.save(transaction('existing', 500));
    await repository.setArchived(
      profileId: 'a',
      categoryId: 'custom',
      archived: true,
    );
    await transactions.save(transaction('existing', 600));
    expect(
      (await transactions.watchTransactions('a').first).single.amountMinor,
      600,
    );
    await expectLater(
      transactions.save(transaction('new', 500)),
      throwsStateError,
    );
    expect(
      await repository.canDelete(profileId: 'a', categoryId: 'custom'),
      isFalse,
    );
  });

  for (final referenceType in ['transactions', 'budgets']) {
    test(
      'Edits and archives a category referenced by multiple $referenceType across months',
      () async {
        await repository.save('a', category());
        final budgets = LocalBudgetRepository(db);
        for (final month in [10, 11]) {
          if (referenceType == 'transactions') {
            await transactions.save(
              FinancialTransaction(
                id: 'tx-$month',
                profileId: 'a',
                amountMinor: 500,
                type: TransactionType.expense,
                categoryId: 'custom',
                occurredAt: DateTime.utc(2026, month, 10),
              ),
            );
          } else {
            await budgets.save(budget(id: 'budget-$month', month: month));
          }
        }

        await repository.save(
          'a',
          category(
            name: 'Cafe',
            icon: 'grocery',
            color: 0xFF2E7D32,
            bucket: 'needs',
          ),
        );
        final edited = (await repository.watchCategories('a').first)
            .singleWhere((item) => item.id == 'custom');
        expect(edited.name, 'Cafe');
        expect(edited.iconKey, 'grocery');
        expect(edited.colorArgb, 0xFF2E7D32);
        expect(edited.defaultBudgetBucket, 'needs');
        expect(edited.isArchived, isFalse);

        await expectLater(
          repository.save('a', category(type: TransactionType.income)),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              contains('cannot change between income and expense'),
            ),
          ),
        );

        await expectLater(
          repository.delete(profileId: 'a', categoryId: 'custom'),
          throwsStateError,
        );
        await repository.setArchived(
          profileId: 'a',
          categoryId: 'custom',
          archived: true,
        );
        final archived = (await repository.watchCategories('a').first)
            .singleWhere((item) => item.id == 'custom');
        expect(archived.name, 'Cafe');
        expect(archived.type, TransactionType.expense);
        expect(archived.isArchived, isTrue);
        if (referenceType == 'transactions') {
          final history = await transactions.watchTransactions('a').first;
          expect(history, hasLength(2));
          expect(history.every((row) => row.categoryId == 'custom'), isTrue);
        } else {
          final history = await budgets.watchBudgets('a').first;
          expect(history, hasLength(2));
          for (final rule in history) {
            expect(
              rule.buckets
                  .singleWhere((bucket) => bucket.id == 'needs')
                  .categoryIds,
              contains('custom'),
            );
          }
        }
      },
    );
  }

  test(
    'Creates categories with validated type, budget default, icon and color',
    () async {
      await repository.save('a', category());
      await repository.save(
        'a',
        category(
          id: 'income',
          name: 'Bonus',
          type: TransactionType.income,
          bucket: null,
          icon: 'payments',
          color: 0xFF2E7D32,
        ),
      );
      final categories = await repository.watchCategories('a').first;
      final coffee = categories.singleWhere((item) => item.id == 'custom');
      final bonus = categories.singleWhere((item) => item.id == 'income');
      expect(coffee.name, 'Coffee');
      expect(coffee.type, TransactionType.expense);
      expect(coffee.defaultBudgetBucket, 'wants');
      expect(coffee.iconKey, 'restaurant');
      expect(coffee.colorArgb, 0xFFE65100);
      expect(bonus.type, TransactionType.income);
      expect(bonus.defaultBudgetBucket, isNull);
    },
  );

  test(
    'Rejects unsupported icons, colors, classifications, and blank names',
    () async {
      await expectLater(
        repository.save('a', category(icon: 'not-a-material-icon')),
        throwsArgumentError,
      );
      await expectLater(
        repository.save('a', category(color: 0xFFFFFFFF)),
        throwsArgumentError,
      );
      await expectLater(
        repository.save('a', category(bucket: 'savings')),
        throwsArgumentError,
      );
      await expectLater(
        repository.save('a', category(name: ' ')),
        throwsArgumentError,
      );
      await expectLater(
        repository.save(
          'a',
          const TransactionCategory(
            id: 'bad_income',
            name: 'Bad income',
            type: TransactionType.income,
            iconKey: 'payments',
            colorArgb: 0xFF2E7D32,
            defaultBudgetBucket: 'needs',
          ),
        ),
        throwsArgumentError,
      );
    },
  );

  test('Updates presentation fields for historical records without changing their IDs', () async {
    await repository.save('a', category());
    await transactions.save(
      FinancialTransaction(
        id: 'tx',
        profileId: 'a',
        notes: 'Morning coffee',
        amountMinor: 500,
        type: TransactionType.expense,
        categoryId: 'custom',
        occurredAt: DateTime.utc(2026, 10, 10),
      ),
    );
    await repository.save(
      'a',
      category(
        name: 'Cafe',
        icon: 'grocery',
        color: 0xFF2E7D32,
        bucket: 'needs',
      ),
    );
    final saved = (await repository.watchCategories('a').first).singleWhere(
      (item) => item.id == 'custom',
    );
    final transaction =
        (await transactions.watchTransactions('a').first).single;
    expect(saved.name, 'Cafe');
    expect(saved.iconKey, 'grocery');
    expect(saved.colorArgb, 0xFF2E7D32);
    expect(saved.defaultBudgetBucket, 'needs');
    expect(transaction.categoryId, 'custom');
    expect(transaction.notes, 'Morning coffee');
  });

  test(
    'Prevents changing transaction type after transaction history exists',
    () async {
      await repository.save('a', category());
      await transactions.save(
        FinancialTransaction(
          id: 'tx',
          profileId: 'a',
          amountMinor: 500,
          type: TransactionType.expense,
          categoryId: 'custom',
          occurredAt: DateTime.utc(2026, 10, 10),
        ),
      );
      await expectLater(
        repository.save(
          'a',
          category(type: TransactionType.income, bucket: null),
        ),
        throwsStateError,
      );
      expect(
        (await repository.watchCategories('a').first)
            .singleWhere((item) => item.id == 'custom')
            .type,
        TransactionType.expense,
      );
    },
  );

  test('Prevents changing type while even a tombstoned budget mapping references it', () async {
    await repository.save('a', category());
    await LocalBudgetRepository(db).save(budget());
    await LocalBudgetRepository(db).delete(profileId: 'a', budgetId: 'budget');
    await expectLater(
      repository.save(
        'a',
        category(type: TransactionType.income, bucket: null),
      ),
      throwsStateError,
    );
  });

  test(
    'Archives referenced categories but permanently removes unused ones',
    () async {
      await repository.save('a', category());
      await transactions.save(
        FinancialTransaction(
          id: 'tx',
          profileId: 'a',
          amountMinor: 500,
          type: TransactionType.expense,
          categoryId: 'custom',
          occurredAt: DateTime.utc(2026, 10, 10),
        ),
      );
      await expectLater(
        repository.delete(profileId: 'a', categoryId: 'custom'),
        throwsStateError,
      );
      await repository.setArchived(
        profileId: 'a',
        categoryId: 'custom',
        archived: true,
      );
      final archived = (await repository.watchCategories('a').first)
          .singleWhere((item) => item.id == 'custom');
      expect(archived.isArchived, isTrue);
      expect(
        (await transactions.watchTransactions('a').first).single.categoryId,
        'custom',
      );

      await repository.save('a', category(id: 'unused', name: 'Unused'));
      await repository.delete(profileId: 'a', categoryId: 'unused');
      expect(
        (await repository.watchCategories('a').first).where(
          (item) => item.id == 'unused',
        ),
        isEmpty,
      );
    },
  );

  test('Category operations are profile scoped', () async {
    await repository.create(
      const LocalProfile(
        id: 'b',
        name: 'Other',
        currencyCode: 'USD',
        currencyScale: 2,
      ),
    );
    await repository.save('b', category());
    expect(
      (await repository.watchCategories('a').first).where(
        (item) => item.id == 'custom',
      ),
      isEmpty,
    );
    expect(
      (await repository.watchCategories('b').first)
          .singleWhere((item) => item.id == 'custom')
          .name,
      'Coffee',
    );
    expect(CategoryPresentationOptions.iconKeys, contains('restaurant'));
  });
}
