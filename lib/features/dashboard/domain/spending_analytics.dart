import '../../transactions/domain/entities/financial_transaction.dart';

class SpendingAnalytics {
  SpendingAnalytics({
    required String profileId,
    required DateTime month,
    required Iterable<FinancialTransaction> transactions,
  }) : month = DateTime(month.year, month.month) {
    final end = DateTime(month.year, month.month + 1);
    final previous = DateTime(month.year, month.month - 1);
    dailyMinor = List.filled(
      DateTime(month.year, month.month + 1, 0).day,
      BigInt.zero,
    );
    for (final transaction in transactions) {
      if (transaction.profileId != profileId ||
          transaction.type != TransactionType.expense) {
        continue;
      }
      final date = transaction.occurredAt.toLocal();
      final amount = BigInt.from(transaction.amountMinor);
      if (!date.isBefore(this.month) && date.isBefore(end)) {
        expenseMinor += amount;
        expenseCount++;
        categoryMinor.update(
          transaction.categoryId,
          (value) => value + amount,
          ifAbsent: () => amount,
        );
        dailyMinor[date.day - 1] += amount;
      } else if (!date.isBefore(previous) && date.isBefore(this.month)) {
        previousExpenseMinor += amount;
      }
    }
  }

  final DateTime month;
  BigInt expenseMinor = BigInt.zero;
  BigInt previousExpenseMinor = BigInt.zero;
  int expenseCount = 0;
  final Map<String, BigInt> categoryMinor = {};
  late final List<BigInt> dailyMinor;

  double? get changePercent => previousExpenseMinor == BigInt.zero
      ? null
      : (expenseMinor - previousExpenseMinor) / previousExpenseMinor * 100;
}
