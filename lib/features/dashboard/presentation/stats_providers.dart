import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../transactions/domain/transaction_filter.dart';

typedef StatsQuery = ({String profileId, TransactionFilter filter});
typedef TrendQuery = ({
  String profileId,
  TransactionFilter filter,
  PeriodGranularity granularity,
});

final statsTotalsProvider = StreamProvider.autoDispose
    .family<TransactionTotals, StatsQuery>(
      (ref, key) => ref
          .watch(transactionRepositoryProvider)
          .watchTotals(key.profileId, key.filter),
    );

final statsCategoriesProvider = StreamProvider.autoDispose
    .family<Map<String, BigInt>, StatsQuery>(
      (ref, key) => ref
          .watch(transactionRepositoryProvider)
          .watchExpenseCategoryTotals(key.profileId, key.filter),
    );

final statsPeriodsProvider = StreamProvider.autoDispose
    .family<List<PeriodTotal>, TrendQuery>(
      (ref, key) => ref
          .watch(transactionRepositoryProvider)
          .watchPeriodTotals(key.profileId, key.filter, key.granularity),
    );
