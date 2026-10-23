import 'package:expense_tracker_app/app/providers.dart';
import 'package:expense_tracker_app/features/profiles/domain/profile.dart';
import 'package:expense_tracker_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:expense_tracker_app/features/transactions/domain/transaction_filter.dart';
import 'package:expense_tracker_app/features/transactions/presentation/providers/transaction_scope_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Type and archived visibility clear only hidden selections', () async {
    const categories = [
      TransactionCategory(
        id: 'food',
        name: 'Food',
        type: TransactionType.expense,
        iconKey: 'grocery',
        colorArgb: 0xFF1565C0,
        defaultBudgetBucket: 'needs',
      ),
      TransactionCategory(
        id: 'pay',
        name: 'Pay',
        type: TransactionType.income,
        iconKey: 'payments',
        colorArgb: 0xFF2E7D32,
        defaultBudgetBucket: null,
      ),
      TransactionCategory(
        id: 'old',
        name: 'Old',
        type: TransactionType.expense,
        iconKey: 'category',
        colorArgb: 0xFFE65100,
        defaultBudgetBucket: 'needs',
        isArchived: true,
      ),
    ];
    final container = ProviderContainer(
      overrides: [
        categoriesProvider('a').overrideWith((ref) => Stream.value(categories)),
      ],
    );
    addTearDown(container.dispose);
    container.listen(categoriesProvider('a'), (_, _) {});
    await container.read(categoriesProvider('a').future);
    final notifier = container.read(transactionScopeProvider('a').notifier);
    notifier.setShowArchived(true);
    notifier.setCategories({'food', 'pay', 'old'});
    notifier.setType(TransactionType.expense);
    expect(container.read(transactionScopeProvider('a')).filter.categoryIds, {
      'food',
      'old',
    });
    notifier.setShowArchived(false);
    expect(container.read(transactionScopeProvider('a')).filter.categoryIds, {
      'food',
    });
    notifier.setType(TransactionType.income);
    expect(
      container.read(transactionScopeProvider('a')).filter.categoryIds,
      isEmpty,
    );
    notifier.setCategories({'pay'});
    notifier.setType(null);
    expect(container.read(transactionScopeProvider('a')).filter.categoryIds, {
      'pay',
    });
    expect(container.read(transactionScopeProvider('b')).showArchived, isFalse);
    notifier.setShowArchived(true);
    notifier.reset();
    expect(container.read(transactionScopeProvider('a')).showArchived, isFalse);
    expect(
      container.read(transactionScopeProvider('a')).filter.categoryIds,
      isEmpty,
    );
  });

  test('Date scope bounds: month, all time and inclusive custom range', () {
    final month = DateScope.month(DateTime(2026, 2, 17));
    expect(month.start, DateTime(2026, 2));
    expect(month.end, DateTime(2026, 3));
    const all = DateScope.allTime();
    expect(all.start, isNull);
    expect(all.end, isNull);
    final custom = DateScope.custom(
      DateTime(2026, 5, 9, 14),
      DateTime(2026, 5, 2),
    );
    expect(custom.start, DateTime(2026, 5, 2));
    expect(custom.end, DateTime(2026, 5, 10));
    expect(
      custom,
      DateScope.custom(DateTime(2026, 5, 2), DateTime(2026, 5, 9)),
    );
    expect(
      DateScope.custom(DateTime(2026, 12, 31), DateTime(2026, 12, 31)).end,
      DateTime(2027),
    );

    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(transactionScopeProvider('a').notifier);
    notifier.setDates(all);
    expect(container.read(transactionScopeProvider('a')).activeCount, 1);
    expect(container.read(transactionScopeProvider('a')).ranged.start, isNull);
    notifier.reset();
    expect(
      container.read(transactionScopeProvider('a')).dates.mode,
      DateRangeMode.month,
    );
  });

  test('Scope is kept per profile and counts sheet choices only', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final a = container.read(transactionScopeProvider('a').notifier);
    expect(container.read(transactionScopeProvider('a')).activeCount, 0);

    a.setType(TransactionType.income);
    a.setCategories({'x', 'y'});
    a.setSort(TransactionSort.oldestFirst);
    a.setQuery('coffee');
    final scope = container.read(transactionScopeProvider('a'));
    expect(scope.activeCount, 4);
    expect(scope.filter.query, 'coffee');
    expect(container.read(transactionScopeProvider('b')).activeCount, 0);

    a.reset();
    final reset = container.read(transactionScopeProvider('a'));
    expect(reset.activeCount, 0);
    expect(reset.filter.query, 'coffee');
    expect(reset.sort, TransactionSort.newestFirst);
  });
}
