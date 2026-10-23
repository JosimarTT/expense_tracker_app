import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:expense_tracker_app/core/database/app_database.dart';
import 'package:expense_tracker_app/features/transactions/data/repositories/local_transaction_repository.dart';
import 'package:expense_tracker_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:expense_tracker_app/features/transactions/domain/transaction_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late LocalTransactionRepository repository;

  Future<void> add(
    String id,
    int minor, {
    String profile = 'a',
    String category = 'food',
    TransactionType type = TransactionType.expense,
    String notes = '',
    DateTime? at,
  }) => repository.save(
    FinancialTransaction(
      id: id,
      profileId: profile,
      notes: notes,
      amountMinor: minor,
      type: type,
      categoryId: category,
      occurredAt: at ?? DateTime.utc(2026, 10, 14, 12),
    ),
  );

  Future<List<String>> ids(
    TransactionFilter filter, {
    TransactionSort sort = TransactionSort.newestFirst,
    String profile = 'a',
  }) async => [
    for (final t
        in (await repository.watchPage(profile, filter, sort: sort).first)
            .items)
      t.id,
  ];

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
      for (final (id, name, type) in [
        ('food', 'Food', 'expense'),
        ('rent', 'Rent', 'expense'),
        ('pay', 'Salary', 'income'),
        ('save', 'Goals', 'savings'),
      ]) {
        await database
            .into(database.categories)
            .insert(
              CategoriesCompanion.insert(
                profileId: profile,
                categoryId: id,
                name: name,
                type: type,
                createdAt: 0,
                updatedAt: 0,
                defaultBudgetBucket: Value(type == 'expense' ? 'needs' : null),
              ),
            );
      }
    }
  });

  tearDown(() => database.close());

  test(
    'Filters by range, type and categories with profile isolation',
    () async {
      await add('old', 100, at: DateTime(2026, 9, 30, 23));
      await add('food', 200, at: DateTime(2026, 10, 5));
      await add('rent', 300, category: 'rent', at: DateTime(2026, 10, 6));
      await add(
        'pay',
        900,
        category: 'pay',
        type: TransactionType.income,
        at: DateTime(2026, 10, 7),
      );
      await add('other', 700, profile: 'b', at: DateTime(2026, 10, 5));

      final october = TransactionFilter.month(DateTime(2026, 10, 20));
      expect(await ids(october), ['pay', 'rent', 'food']);
      expect(await ids(TransactionFilter()), ['pay', 'rent', 'food', 'old']);
      expect(await ids(october, sort: TransactionSort.oldestFirst), [
        'food',
        'rent',
        'pay',
      ]);
      expect(await ids(october.withType(TransactionType.expense)), [
        'rent',
        'food',
      ]);
      expect(await ids(october.withCategories({'rent', 'pay'})), [
        'pay',
        'rent',
      ]);
      expect(await ids(TransactionFilter(), profile: 'b'), ['other']);
    },
  );

  test('End bound is exclusive and soft-deleted rows are hidden', () async {
    await add('edge', 100, at: DateTime(2026, 11));
    await add('gone', 100, at: DateTime(2026, 10, 2));
    await repository.delete(profileId: 'a', transactionId: 'gone');
    expect(await ids(TransactionFilter.month(DateTime(2026, 10))), isEmpty);
    expect(await ids(TransactionFilter.month(DateTime(2026, 11))), ['edge']);
  });

  test('Search matches notes, category name and amount', () async {
    await add('a', 1250, notes: 'Team LUNCH');
    await add('b', 99, category: 'rent', notes: 'x');
    await add('c', 500000, category: 'pay', type: TransactionType.income);
    final base = TransactionFilter();
    expect(await ids(base.withQuery('lunch')), ['a']);
    expect(await ids(base.withQuery('RENT')), ['b']);
    expect(await ids(base.withQuery('12.50')), ['a']);
    expect(await ids(base.withQuery(r'$5,000.00')), ['c']);
    expect(await ids(base.withQuery('0.99')), ['b']);
    expect(await ids(base.withQuery('100%')), isEmpty);
    expect(await ids(base.withQuery('_')), isEmpty);
  });

  test('Pages with hasMore and unlimited reads', () async {
    for (var i = 0; i < 25; i++) {
      await add('t$i', 100 + i, at: DateTime.utc(2026, 1, 1, i));
    }
    final page = await repository
        .watchPage('a', TransactionFilter(), limit: 10)
        .first;
    expect(page.items, hasLength(10));
    expect(page.hasMore, isTrue);
    expect(page.items.first.id, 't24');
    final exact = await repository
        .watchPage('a', TransactionFilter(), limit: 25)
        .first;
    expect(exact.items, hasLength(25));
    expect(exact.hasMore, isFalse);
    final all = await repository.watchPage('a', TransactionFilter()).first;
    expect(all.items, hasLength(25));
    expect(
      () => repository.watchPage('a', TransactionFilter(), limit: 0),
      throwsArgumentError,
    );
  });

  test('Totals are exact and do not overflow near the integer limit', () async {
    const big = 4611686018427387000;
    await add('x', big);
    await add('y', big, category: 'rent');
    await add('z', 5, category: 'pay', type: TransactionType.income);
    final totals = await repository.watchTotals('a', TransactionFilter()).first;
    expect(totals.expense, BigInt.from(big) * BigInt.two);
    expect(totals.income, BigInt.from(5));
    expect(totals.expenseCount, 2);
    expect(totals.count, 3);
    expect(totals.savings, BigInt.zero);
  });

  test('Period totals bucket by local day, week and month', () async {
    await add('d1', 100, at: DateTime(2026, 10, 5, 0, 30));
    await add('d2', 200, at: DateTime(2026, 10, 5, 23, 30));
    await add('d3', 400, at: DateTime(2026, 10, 7));
    await add('m', 800, at: DateTime(2026, 11, 2));
    final october = TransactionFilter.month(DateTime(2026, 10));

    final days = await repository
        .watchPeriodTotals('a', october, PeriodGranularity.day)
        .first;
    expect(days, hasLength(31));
    expect(days[4].totals.expense, BigInt.from(300));
    expect(days[6].totals.expense, BigInt.from(400));
    expect(days[5].totals.count, 0);

    final weeks = await repository
        .watchPeriodTotals('a', october, PeriodGranularity.week)
        .first;
    expect(weeks.first.start, DateTime(2026, 9, 28));
    expect(weeks[1].totals.expense, BigInt.from(700));

    final open = await repository
        .watchPeriodTotals('a', TransactionFilter(), PeriodGranularity.month)
        .first;
    expect(open.map((p) => p.start), [DateTime(2026, 10), DateTime(2026, 11)]);
    expect(open.map((p) => p.totals.expense), [
      BigInt.from(700),
      BigInt.from(800),
    ]);
  });

  test(
    'Period totals re-emit when an amount changes and cap periods',
    () async {
      await add('x', 100, at: DateTime(2026, 10, 5));
      final stream = repository.watchPeriodTotals(
        'a',
        TransactionFilter.month(DateTime(2026, 10)),
        PeriodGranularity.month,
      );
      final expectation = expectLater(
        stream.map((p) => p.single.totals.expense),
        emitsInOrder([BigInt.from(100), BigInt.from(250)]),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await add('x', 250, at: DateTime(2026, 10, 5));
      await expectation;

      await add('y', 1, at: DateTime.utc(2000));
      await expectLater(
        repository
            .watchPeriodTotals('a', TransactionFilter(), PeriodGranularity.day)
            .first,
        throwsArgumentError,
      );
    },
  );

  test(
    'Expense category aggregates preserve all filters and exact sums',
    () async {
      const big = 4611686018427387000;
      await add('a', big, notes: 'matched');
      await add('b', big, notes: 'matched');
      await add('c', big, notes: 'matched');
      await add('rent', 300, category: 'rent', notes: 'matched');
      await add('pay', 400, category: 'pay', type: TransactionType.income);
      await add('other', 700, profile: 'b');
      await add('gone', 800);
      await repository.delete(profileId: 'a', transactionId: 'gone');
      await add('old', 900, at: DateTime(2025));
      final filter = TransactionFilter.month(DateTime(2026, 10))
          .withQuery('matched');
      final sums = await repository
          .watchExpenseCategoryTotals('a', filter)
          .first;
      expect(sums, {
        'food': BigInt.from(big) * BigInt.from(3),
        'rent': BigInt.from(300),
      });
      expect(
        await repository
            .watchExpenseCategoryTotals('a', filter.withCategories({'rent'}))
            .first,
        {'rent': BigInt.from(300)},
      );
      expect(
        await repository
            .watchExpenseCategoryTotals(
              'a',
              filter.withType(TransactionType.income),
            )
            .first,
        isEmpty,
      );
      expect(
        await repository
            .watchExpenseCategoryTotals('b', TransactionFilter())
            .first,
        {'food': BigInt.from(700)},
      );
    },
  );

  test('Category aggregates react to edits', () async {
    await add('x', 100);
    final result = expectLater(
      repository.watchExpenseCategoryTotals('a', TransactionFilter()),
      emitsInOrder([
        {'food': BigInt.from(100)},
        {'rent': BigInt.from(250)},
      ]),
    );
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await add('x', 250, category: 'rent');
    await result;
  });

  test(
    'All-time aggregates handle 10000 rows without materializing history',
    () async {
      await database.batch((batch) {
        batch.insertAll(database.transactions, [
          for (var i = 0; i < 10000; i++)
            TransactionsCompanion.insert(
              profileId: 'a',
              transactionId: 'bulk-$i',
              amountMinor: 100,
              type: 'expense',
              categoryId: 'food',
              occurredAt: DateTime(
                2026,
                i.isEven ? 1 : 2,
                2,
              ).toUtc().millisecondsSinceEpoch,
              createdAt: 0,
              updatedAt: 0,
            ),
        ]);
      });
      final filter = TransactionFilter();
      final totals = await repository.watchTotals('a', filter).first;
      expect(totals.expense, BigInt.from(1000000));
      expect(totals.firstOccurredAt, DateTime(2026, 1, 2).toUtc());
      expect(totals.lastOccurredAt, DateTime(2026, 2, 2).toUtc());
      expect(await repository.watchExpenseCategoryTotals('a', filter).first, {
        'food': BigInt.from(1000000),
      });
      final months = await repository
          .watchPeriodTotals('a', filter, PeriodGranularity.month)
          .first;
      expect(months.length, 2);
      expect(months.map((period) => period.totals.expense), [
        BigInt.from(500000),
        BigInt.from(500000),
      ]);
      final page = await repository.watchPage('a', filter, limit: 100).first;
      expect(page.items.length, 100);
      expect(page.hasMore, isTrue);
    },
  );

  test('Filter validates its range and compares by value', () {
    expect(
      () => TransactionFilter(start: DateTime(2026, 2), end: DateTime(2026, 1)),
      throwsArgumentError,
    );
    expect(
      TransactionFilter(categoryIds: ['a', 'b']),
      TransactionFilter(categoryIds: ['b', 'a']),
    );
    expect(TransactionFilter(query: ' x '), TransactionFilter(query: 'x'));
    expect(
      PeriodGranularity.suggest(DateTime(2026, 1), DateTime(2026, 2)),
      PeriodGranularity.day,
    );
    expect(
      PeriodGranularity.suggest(DateTime(2026, 1), DateTime(2026, 5)),
      PeriodGranularity.week,
    );
    expect(
      PeriodGranularity.suggest(DateTime(2025, 1), DateTime(2026, 5)),
      PeriodGranularity.month,
    );
  });
}
