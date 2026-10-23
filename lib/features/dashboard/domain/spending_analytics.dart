import '../../transactions/domain/entities/financial_transaction.dart';
import '../../transactions/domain/transaction_filter.dart';

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

  SpendingAnalytics.aggregated({
    required this.month,
    required TransactionTotals totals,
    required Map<String, BigInt> categories,
    required List<PeriodTotal> periods,
    required this.granularity,
    required this.periodLabel,
    required this.comparePreviousMonth,
    BigInt? previousExpense,
  }) {
    expenseMinor = totals.expense;
    expenseCount = totals.expenseCount;
    previousExpenseMinor = previousExpense ?? BigInt.zero;
    categoryMinor.addAll(categories);
    dailyMinor = [for (final period in periods) period.totals.expense];
    periodStarts = [for (final period in periods) period.start];
  }

  final DateTime month;
  PeriodGranularity granularity = PeriodGranularity.day;
  String? periodLabel;
  bool comparePreviousMonth = true;
  List<DateTime>? periodStarts;
  BigInt expenseMinor = BigInt.zero;
  BigInt previousExpenseMinor = BigInt.zero;
  int expenseCount = 0;
  final Map<String, BigInt> categoryMinor = {};
  late final List<BigInt> dailyMinor;

  DateTime periodStart(int index) =>
      periodStarts?[index] ?? DateTime(month.year, month.month, index + 1);

  double? get changePercent => previousExpenseMinor == BigInt.zero
      ? null
      : (expenseMinor - previousExpenseMinor) / previousExpenseMinor * 100;
}
