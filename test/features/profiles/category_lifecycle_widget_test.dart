import 'package:drift/native.dart';
import 'package:expense_tracker_app/app/providers.dart';
import 'package:expense_tracker_app/core/database/app_database.dart'
    hide BudgetBucket;
import 'package:expense_tracker_app/features/budgets/data/local_budget_repository.dart';
import 'package:expense_tracker_app/features/budgets/domain/entities/budget_rule.dart';
import 'package:expense_tracker_app/features/budgets/presentation/budget_dialog.dart';
import 'package:expense_tracker_app/features/profiles/data/local_profile_repository.dart';
import 'package:expense_tracker_app/features/profiles/domain/profile.dart';
import 'package:expense_tracker_app/features/profiles/presentation/category_manager_dialog.dart';
import 'package:expense_tracker_app/features/transactions/data/repositories/local_transaction_repository.dart';
import 'package:expense_tracker_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pumpAndSettle();
}

void main() {
  late AppDatabase db;
  late LocalProfileRepository profiles;
  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    profiles = LocalProfileRepository(db);
    await profiles.create(
      const LocalProfile(
        id: 'a',
        name: 'Personal',
        currencyCode: 'USD',
        currencyScale: 2,
      ),
    );
  });
  tearDown(() => db.close());

  Future<void> open(WidgetTester tester, Widget dialog) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () =>
                    showDialog<void>(context: context, builder: (_) => dialog),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await settle(tester);
  }

  testWidgets(
    'Archives, restores and deletes categories after their transactions are deleted',
    (tester) async {
      await tester.runAsync(() async {
        final transactions = LocalTransactionRepository(db);
        await transactions.save(
          FinancialTransaction(
            id: 'tx',
            profileId: 'a',
            amountMinor: 500,
            type: TransactionType.expense,
            categoryId: 'dining',
            occurredAt: DateTime.utc(2026, 10, 10),
          ),
        );
        await transactions.delete(profileId: 'a', transactionId: 'tx');
      });
      await open(tester, const CategoryManagerDialog(profileId: 'a'));
      await tester.tap(find.byTooltip('Archive Dining out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Archive'));
      await settle(tester);
      expect(find.text('Dining out'), findsNothing);
      await tester.tap(find.text('Show archived'));
      await settle(tester);
      expect(find.text('Dining out'), findsOneWidget);
      await tester.tap(find.byTooltip('Restore Dining out'));
      await settle(tester);
      expect(find.byTooltip('Archive Dining out'), findsOneWidget);
      await tester.tap(find.byTooltip('Archive Dining out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Archive'));
      await settle(tester);
      await tester.tap(find.byTooltip('Delete Dining out permanently'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete permanently'));
      await settle(tester);
      expect(find.text('Dining out'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

  testWidgets('Saving budget percentages preserves hidden archived mappings', (
    tester,
  ) async {
    final budgets = LocalBudgetRepository(db);
    final rule = BudgetRule(
      id: 'budget',
      profileId: 'a',
      name: 'Monthly',
      periodStart: DateTime(2026, 10),
      periodEnd: DateTime(2026, 11),
      buckets: [
        BudgetBucket(
          id: 'needs',
          name: 'Needs',
          allocationBps: 5000,
          categoryIds: ['groceries'],
        ),
        BudgetBucket(id: 'wants', name: 'Wants', allocationBps: 3000),
        BudgetBucket(id: 'savings', name: 'Savings', allocationBps: 2000),
      ],
    );
    final categories = await tester.runAsync(() async {
      await budgets.save(rule);
      await profiles.setArchived(
        profileId: 'a',
        categoryId: 'groceries',
        archived: true,
      );
      return profiles.watchCategories('a').first;
    });
    await open(
      tester,
      BudgetDialog(
        profileId: 'a',
        month: DateTime(2026, 10),
        categories: categories!,
        existing: rule,
      ),
    );
    expect(
      find.widgetWithText(DropdownButtonFormField<String>, 'Groceries'),
      findsNothing,
    );
    await tester.enterText(find.widgetWithText(TextField, 'Needs (%)'), '60');
    await tester.enterText(find.widgetWithText(TextField, 'Wants (%)'), '20');
    await tester.tap(find.text('Save budget'));
    await settle(tester);
    expect(find.text('Monthly budget'), findsNothing);
    final saved = await tester.runAsync(() => budgets.watchBudgets('a').first);
    final needs = saved!.single.buckets.singleWhere((row) => row.id == 'needs');
    expect(needs.categoryIds, contains('groceries'));
    expect(needs.allocationBps, 6000);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await open(tester, const CategoryManagerDialog(profileId: 'a'));
    await tester.tap(find.text('Show archived'));
    await settle(tester);
    final blockedDelete = find.byTooltip(
      'Active transactions, budget mappings, or schedules prevent permanent deletion',
    );
    expect(blockedDelete, findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.ancestor(of: blockedDelete, matching: find.byType(IconButton)),
          )
          .onPressed,
      isNull,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
