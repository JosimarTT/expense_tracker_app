import '../entities/financial_transaction.dart';
import '../transaction_filter.dart';

abstract interface class TransactionRepository {
  Stream<List<FinancialTransaction>> watchTransactions(String profileId);

  /// Filtered rows, newest first unless [sort] says otherwise. A null [limit]
  /// returns every match; otherwise [TransactionPage.hasMore] flags extra rows.
  Stream<TransactionPage> watchPage(
    String profileId,
    TransactionFilter filter, {
    TransactionSort sort = TransactionSort.newestFirst,
    int? limit,
  });

  /// Exact totals and counts per type for the rows matching [filter].
  Stream<TransactionTotals> watchTotals(
    String profileId,
    TransactionFilter filter,
  );

  Stream<Map<String, BigInt>> watchExpenseCategoryTotals(
    String profileId,
    TransactionFilter filter,
  );

  /// Totals per [granularity] period across the filter range. An open range is
  /// bounded by the first and last matching transaction.
  Stream<List<PeriodTotal>> watchPeriodTotals(
    String profileId,
    TransactionFilter filter,
    PeriodGranularity granularity,
  );

  Future<void> save(FinancialTransaction transaction);

  Future<void> delete({
    required String profileId,
    required String transactionId,
  });
}
