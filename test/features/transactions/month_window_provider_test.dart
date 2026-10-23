import 'package:drift/native.dart';
import 'package:expense_tracker_app/app/providers.dart';
import 'package:expense_tracker_app/core/database/app_database.dart';
import 'package:expense_tracker_app/features/transactions/data/repositories/local_transaction_repository.dart';
import 'package:expense_tracker_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:expense_tracker_app/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Month window loads only the month and the one before it', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await database
        .into(database.profiles)
        .insert(
          ProfilesCompanion.insert(
            profileId: 'a',
            name: 'a',
            currencyCode: 'USD',
            currencyScale: 2,
            createdAt: 0,
            updatedAt: 0,
          ),
        );
    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(
            profileId: 'a',
            categoryId: 'food',
            name: 'Food',
            type: 'expense',
            createdAt: 0,
            updatedAt: 0,
          ),
        );
    final repository = LocalTransactionRepository(database);
    for (final (id, at) in [
      ('older', DateTime(2026, 7, 20)),
      ('previous', DateTime(2026, 8, 20)),
      ('current', DateTime(2026, 9, 2)),
      ('later', DateTime(2026, 10, 2)),
    ]) {
      await repository.save(
        FinancialTransaction(
          id: id,
          profileId: 'a',
          notes: '',
          amountMinor: 100,
          type: TransactionType.expense,
          categoryId: 'food',
          occurredAt: at,
        ),
      );
    }
    final container = ProviderContainer(
      overrides: [transactionRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final key = (profileId: 'a', month: DateTime(2026, 9));
    container.listen(monthWindowTransactionsProvider(key), (_, _) {});
    final rows = await container.read(
      monthWindowTransactionsProvider(key).future,
    );
    expect(rows.map((r) => r.id), ['current', 'previous']);
  });
}
