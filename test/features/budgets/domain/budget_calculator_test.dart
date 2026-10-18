import 'package:expense_tracker_app/features/budgets/domain/budget_calculator.dart';
import 'package:expense_tracker_app/features/budgets/domain/entities/budget_rule.dart';
import 'package:expense_tracker_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

BudgetRule monthlyRule() => BudgetRule(
  id: 'budget', profileId: 'a', name: 'October',
  periodStart: DateTime.utc(2026, 10), periodEnd: DateTime.utc(2026, 11),
  buckets: [
    BudgetBucket(id: 'needs', name: 'Needs', allocationBps: 5000, categoryIds: ['food']),
    BudgetBucket(id: 'wants', name: 'Wants', allocationBps: 3000, categoryIds: ['dining']),
    BudgetBucket(id: 'savings', name: 'Savings', allocationBps: 2000),
  ],
);

FinancialTransaction entry(String id, int amount, TransactionType type, {
  String category = 'food', String profile = 'a', DateTime? date,
}) => FinancialTransaction(
  id: id, profileId: profile, title: id, amountMinor: amount,
  type: type, categoryId: category, occurredAt: date ?? DateTime.utc(2026, 10, 15),
);

void main() {
  const calculator = BudgetCalculator();
  test('Uses actual income, distinguishes spending and savings, exposes overspending', () {
    final result = calculator.calculate(rule: monthlyRule(), transactions: [
      entry('salary', 100000, TransactionType.income),
      entry('food', 55000, TransactionType.expense),
      entry('dining', 10000, TransactionType.expense, category: 'dining'),
      entry('other', 2000, TransactionType.expense, category: 'other'),
    ]);
    expect(result.incomeMinor, 100000);
    expect(result.expenseMinor, 67000);
    expect(result.balanceMinor, 33000);
    expect(result.unallocatedExpenseMinor, 2000);
    final needs = result.buckets.first;
    expect(needs.targetMinor, 50000);
    expect(needs.spentMinor, 55000);
    expect(needs.isOverBudget, isTrue);
    expect(needs.progress, 1);
    expect(result.buckets.last.targetMinor, 20000);
    expect(result.buckets.last.spentMinor, 0);
  });

  test('Enforces profile scope and half-open reporting boundaries', () {
    final result = calculator.calculate(rule: monthlyRule(), transactions: [
      entry('at-start', 100, TransactionType.income, date: DateTime.utc(2026, 10)),
      entry('at-end', 200, TransactionType.income, date: DateTime.utc(2026, 11)),
      entry('before', 300, TransactionType.income, date: DateTime.utc(2026, 9, 30)),
      entry('other-profile', 400, TransactionType.income, profile: 'b'),
    ]);
    expect(result.incomeMinor, 100);
  });

  test('Zero income produces finite progress and zero targets', () {
    final result = calculator.calculate(rule: monthlyRule(), transactions: [
      entry('expense', 100, TransactionType.expense),
    ]);
    expect(result.buckets.map((bucket) => bucket.targetMinor), [0, 0, 0]);
    expect(result.buckets.first.isOverBudget, isTrue);
    expect(result.buckets.first.progress, 1);
    expect(result.buckets.last.progress, 0);
  });

  test('Largest-remainder rounding allocates all minor units deterministically', () {
    for (final amount in [1, 2, 3, 7, 101, 9007199254740993]) {
      final result = calculator.calculate(rule: monthlyRule(), transactions: [
        entry('income', amount, TransactionType.income),
      ]);
      expect(result.buckets.fold(0, (sum, bucket) => sum + bucket.targetMinor), amount);
    }
    final result = calculator.calculate(rule: monthlyRule(), transactions: [
      entry('income', 3, TransactionType.income),
    ]);
    expect(result.buckets.map((bucket) => bucket.targetMinor), [1, 1, 1]);
  });

  test('Reports aggregate overflow instead of wrapping a valid individual amount', () {
    expect(
      () => calculator.calculate(rule: monthlyRule(), transactions: [
        entry('a', 9223372036854775807, TransactionType.income),
        entry('b', 1, TransactionType.income),
      ]),
      throwsStateError,
    );
  });
}
