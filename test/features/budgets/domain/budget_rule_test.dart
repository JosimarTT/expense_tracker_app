import 'package:expense_tracker_app/features/budgets/domain/entities/budget_rule.dart';
import 'package:flutter_test/flutter_test.dart';

BudgetRule rule(List<BudgetBucket> buckets) => BudgetRule(
  id: 'budget',
  profileId: 'profile',
  name: 'Monthly budget',
  periodStart: DateTime.utc(2026, 10),
  periodEnd: DateTime.utc(2026, 11),
  buckets: buckets,
);

BudgetBucket bucket(String id, int bps, [List<String> categories = const []]) =>
    BudgetBucket(
      id: id,
      name: id,
      allocationBps: bps,
      categoryIds: categories,
    );

void main() {
  test('Supports 50/30/20 and arbitrary labels and decimal percentages', () {
    final standard = rule([
      bucket('Needs', 5000),
      bucket('Wants', 3000),
      bucket('Savings', 2000),
    ]);
    expect(standard.buckets.length, 3);

    final custom = rule([
      bucket('Essentials', 6525),
      bucket('Future', 3475),
    ]);
    expect(custom.buckets.first.allocationBps, 6525);
  });

  for (final total in [9999, 10001]) {
    test('Rejects allocations totaling $total instead of 10000', () {
      expect(
        () => rule([bucket('a', 5000), bucket('b', total - 5000)]),
        throwsArgumentError,
      );
    });
  }

  test('Rejects empty rules and duplicate buckets', () {
    expect(() => rule([]), throwsArgumentError);
    expect(
      () => rule([bucket('a', 5000), bucket('a', 5000)]),
      throwsArgumentError,
    );
  });

  test('Rejects a category allocated to multiple buckets', () {
    expect(
      () => rule([
        bucket('a', 5000, ['food']),
        bucket('b', 5000, ['food']),
      ]),
      throwsArgumentError,
    );
  });

  test('Rejects invalid bucket percentages and blank identifiers', () {
    expect(() => bucket('a', -1), throwsArgumentError);
    expect(() => bucket('a', 10001), throwsArgumentError);
    expect(() => bucket(' ', 10000), throwsArgumentError);
    expect(() => bucket('a', 10000, [' ']), throwsArgumentError);
  });

  test('Copies and protects budget collections from mutation', () {
    final categories = ['food'];
    final buckets = [bucket('a', 10000, categories)];
    final budget = rule(buckets);
    categories.add('travel');
    buckets.clear();
    expect(budget.buckets.single.categoryIds, {'food'});
    expect(() => budget.buckets.clear(), throwsUnsupportedError);
    expect(
      () => budget.buckets.single.categoryIds.clear(),
      throwsUnsupportedError,
    );
  });

  test('Rejects zero-length and reversed periods', () {
    for (final end in [DateTime.utc(2026, 10), DateTime.utc(2026, 9)]) {
      expect(
        () => BudgetRule(
          id: 'budget',
          profileId: 'profile',
          name: 'Monthly',
          periodStart: DateTime.utc(2026, 10),
          periodEnd: end,
          buckets: [bucket('a', 10000)],
        ),
        throwsArgumentError,
      );
    }
  });
}
