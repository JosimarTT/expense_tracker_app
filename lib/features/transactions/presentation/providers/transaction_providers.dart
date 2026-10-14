import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../domain/entities/financial_transaction.dart';

final transactionsProvider =
    StreamProvider.autoDispose.family<List<FinancialTransaction>, String>(
      (ref, profileId) =>
          ref.watch(transactionRepositoryProvider).watchTransactions(profileId),
    );
