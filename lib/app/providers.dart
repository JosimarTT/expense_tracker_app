import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/database/app_database.dart';
import '../core/ids/id_generator.dart';
import '../features/transactions/data/repositories/local_transaction_repository.dart';
import '../features/transactions/domain/repositories/transaction_repository.dart';
import '../features/profiles/data/local_profile_repository.dart';
import '../features/profiles/domain/profile.dart';
import '../features/budgets/data/local_budget_repository.dart';
import '../features/budgets/domain/entities/budget_rule.dart';
import '../features/budgets/domain/repositories/budget_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => unawaited(database.close()));
  return database;
});

final idGeneratorProvider = Provider<IdGenerator>(
  (ref) => UuidV7IdGenerator(),
);

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => LocalTransactionRepository(ref.watch(databaseProvider)),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => LocalProfileRepository(ref.watch(databaseProvider)),
);

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => LocalProfileRepository(ref.watch(databaseProvider)),
);

final budgetRepositoryProvider = Provider<BudgetRepository>(
  (ref) => LocalBudgetRepository(ref.watch(databaseProvider)),
);

final profilesProvider = StreamProvider<List<LocalProfile>>(
  (ref) => ref.watch(profileRepositoryProvider).watchProfiles(),
);

final categoriesProvider =
    StreamProvider.autoDispose.family<List<TransactionCategory>, String>(
      (ref, profileId) =>
          ref.watch(profileRepositoryProvider).watchCategories(profileId),
    );

final budgetsProvider = StreamProvider.autoDispose.family<List<BudgetRule>, String>(
  (ref, profileId) => ref.watch(budgetRepositoryProvider).watchBudgets(profileId),
);
