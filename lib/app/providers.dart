import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../core/database/app_database.dart';
import '../features/transactions/data/repositories/local_transaction_repository.dart';
import '../features/transactions/domain/repositories/transaction_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => unawaited(database.close()));
  return database;
});

final uuidProvider = Provider<Uuid>((ref) => const Uuid());

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => LocalTransactionRepository(ref.watch(databaseProvider)),
);
