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

        await repository.delete(profileId: 'a', categoryId: 'custom');
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
      await repository.delete(profileId: 'a', categoryId: 'custom');
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
