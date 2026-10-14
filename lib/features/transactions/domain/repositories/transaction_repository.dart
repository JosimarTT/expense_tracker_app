import '../entities/financial_transaction.dart';

abstract interface class TransactionRepository {
  Stream<List<FinancialTransaction>> watchTransactions(String profileId);

  Future<void> save(FinancialTransaction transaction);

  Future<void> delete({
    required String profileId,
    required String transactionId,
  });
}
