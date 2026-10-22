import 'package:expense_tracker_app/features/dashboard/domain/spending_analytics.dart';
import 'package:expense_tracker_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

FinancialTransaction entry({
  required int amount,
  required DateTime date,
  String profile = 'a',
  String category = 'food',
  TransactionType type = TransactionType.expense,
}) => FinancialTransaction(
  id: '$profile-$category-$date-$amount',
  profileId: profile,
  amountMinor: amount,
  type: type,
  categoryId: category,
  occurredAt: date,
);

void main() {
  test('Groups expenses by category and local calendar day, excluding other types and profiles', () {
    final analytics = SpendingAnalytics(
      profileId: 'a',
      month: DateTime(2026, 10, 17),
      transactions: [
        entry(amount: 1250, date: DateTime(2026, 10, 1, 23)),
        entry(amount: 750, date: DateTime(2026, 10, 1, 9)),
        entry(amount: 500, date: DateTime(2026, 10, 3), category: 'transport'),
        entry(
          amount: 1000,
          date: DateTime(2026, 10, 3),
          type: TransactionType.savings,
        ),
        entry(
          amount: 10000,
          date: DateTime(2026, 10, 3),
          type: TransactionType.income,
        ),
        entry(amount: 5000, date: DateTime(2026, 10, 3), profile: 'b'),
      ],
    );
    expect(analytics.month, DateTime(2026, 10));
    expect(analytics.expenseMinor, BigInt.from(2500));
    expect(analytics.expenseCount, 3);
    expect(analytics.categoryMinor, {
      'food': BigInt.from(2000),
      'transport': BigInt.from(500),
    });
    expect(analytics.dailyMinor, hasLength(31));
    expect(analytics.dailyMinor[0], BigInt.from(2000));
    expect(analytics.dailyMinor[1], BigInt.zero);
    expect(analytics.dailyMinor[2], BigInt.from(500));
    expect(
      analytics.dailyMinor.fold(BigInt.zero, (a, b) => a + b),
      analytics.expenseMinor,
    );
    expect(analytics.changePercent, isNull);
  });

  test('Uses half-open local month bounds and compares only the previous full month', () {
    final analytics = SpendingAnalytics(
      profileId: 'a',
      month: DateTime(2026, 1),
      transactions: [
        entry(amount: 999, date: DateTime(2025, 11, 30, 23, 59)),
        entry(amount: 2000, date: DateTime(2025, 12, 1)),
        entry(amount: 1000, date: DateTime(2026, 1, 1)),
        entry(amount: 500, date: DateTime(2026, 1, 31, 23, 59, 59)),
        entry(amount: 999, date: DateTime(2026, 2, 1)),
      ],
    );
    expect(analytics.expenseMinor, BigInt.from(1500));
    expect(analytics.previousExpenseMinor, BigInt.from(2000));
    expect(analytics.changePercent, -25);
    expect(analytics.dailyMinor.last, BigInt.from(500));
  });

  test(
    'Includes every calendar day across leap years and daylight-saving months',
    () {
      for (final (month, length) in [
        (DateTime(2024, 2), 29),
        (DateTime(2025, 2), 28),
        (DateTime(2026, 3), 31),
        (DateTime(2026, 11), 30),
      ]) {
        final analytics = SpendingAnalytics(
          profileId: 'a',
          month: month,
          transactions: [
            entry(
              amount: 1,
              date: DateTime(month.year, month.month, length, 23),
            ),
          ],
        );
        expect(analytics.dailyMinor, hasLength(length));
        expect(analytics.dailyMinor.last, BigInt.one);
      }
    },
  );

  test(
    'Keeps totals exact beyond SQLite integer and floating-point limits',
    () {
      final analytics = SpendingAnalytics(
        profileId: 'a',
        month: DateTime(2026, 10),
        transactions: [
          entry(amount: 9223372036854775807, date: DateTime(2026, 10, 1)),
          entry(amount: 9223372036854775807, date: DateTime(2026, 10, 1)),
        ],
      );
      expect(analytics.expenseMinor, BigInt.parse('18446744073709551614'));
      expect(analytics.dailyMinor.first, analytics.expenseMinor);
      expect(analytics.categoryMinor['food'], analytics.expenseMinor);
    },
  );

  test('Empty months remain empty and comparison does not divide by zero', () {
    final empty = SpendingAnalytics(
      profileId: 'a',
      month: DateTime(2026, 10),
      transactions: [],
    );
    expect(empty.expenseMinor, BigInt.zero);
    expect(empty.categoryMinor, isEmpty);
    expect(empty.expenseCount, 0);
    expect(empty.changePercent, isNull);
    final reduction = SpendingAnalytics(
      profileId: 'a',
      month: DateTime(2026, 10),
      transactions: [entry(amount: 1000, date: DateTime(2026, 9, 10))],
    );
    expect(reduction.changePercent, -100);
  });
}
