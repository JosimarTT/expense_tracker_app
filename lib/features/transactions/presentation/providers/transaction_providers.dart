import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../domain/entities/financial_transaction.dart';
import '../../domain/transaction_filter.dart';

final transactionsProvider = StreamProvider.autoDispose
    .family<List<FinancialTransaction>, String>(
      (ref, profileId) =>
          ref.watch(transactionRepositoryProvider).watchTransactions(profileId),
    );

/// Rows of [month] and the month before it, which is all Home, Stats and
/// Budget need, so the whole profile history is never loaded for them.
final monthWindowTransactionsProvider = StreamProvider.autoDispose
    .family<List<FinancialTransaction>, ({String profileId, DateTime month})>(
      (ref, key) => ref
          .watch(transactionRepositoryProvider)
          .watchPage(
            key.profileId,
            TransactionFilter(
              start: DateTime(key.month.year, key.month.month - 1),
              end: DateTime(key.month.year, key.month.month + 1),
            ),
          )
          .map((page) => page.items),
    );
