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
import 'package:expense_tracker_app/features/profiles/presentation/category_avatar.dart';
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
    'Groups categories by type, sorts names and puts archived categories last',
    (tester) async {
      tester.view.physicalSize = const Size(1000, 2600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.runAsync(() async {
        await profiles.save(
          'a',
          const TransactionCategory(
            id: 'alpha',
            name: 'alpha income',
            type: TransactionType.income,
            iconKey: 'payments',
            colorArgb: 0xFF1565C0,
            defaultBudgetBucket: null,
          ),
        );
        await profiles.setArchived(
          profileId: 'a',
          categoryId: 'salary',
          archived: true,
        );
        await profiles.setArchived(
          profileId: 'a',
          categoryId: 'dining',
          archived: true,
        );
      });
      await open(tester, const CategoryManagerDialog(profileId: 'a'));
      expect(find.text('Salary'), findsNothing);
      expect(find.text('Dining out'), findsNothing);
      await tester.tap(find.text('Show archived'));
      await settle(tester);
      final rows = tester
          .widgetList<ListTile>(
            find.ancestor(
              of: find.byType(CategoryAvatar),
              matching: find.byType(ListTile),
            ),
          )
          .toList();
      expect(rows.map((row) => (row.title! as Text).data).toList(), [
        'alpha income',
        'Other income',
        'Entertainment',
        'Groceries',
        'Housing',
        'Other expense',
        'Transport',
        'Emergency fund',
        'Investments',
        'Retirement',
        'Unused money',
        'Salary',
        'Dining out',
      ]);
      expect(find.text('Archived'), findsOneWidget);
      for (final group in [
        'active-income',
        'active-expense',
        'active-savings',
        'archived-income',
        'archived-expense',
      ]) {
        expect(find.byKey(ValueKey('category-group-$group')), findsOneWidget);
      }
      for (final row in rows) {
        expect(row.leading, isA<CategoryAvatar>());
        expect(
          row.subtitle == null ||
              const ['Needs', 'Wants'].contains((row.subtitle! as Text).data),
          isTrue,
        );
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

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
      await tester.scrollUntilVisible(find.text('Dining out'), 200);
      expect(find.text('Dining out'), findsOneWidget);
      await tester.tap(find.byTooltip('Restore Dining out'));
      await settle(tester);
      await tester.scrollUntilVisible(
        find.byTooltip('Archive Dining out'),
        -200,
      );
      expect(find.byTooltip('Archive Dining out'), findsOneWidget);
      await tester.tap(find.byTooltip('Archive Dining out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Archive'));
      await settle(tester);
      await tester.scrollUntilVisible(
        find.byTooltip('Delete Dining out permanently'),
        200,
      );
      await tester.tap(find.byTooltip('Delete Dining out permanently'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete permanently'));
      await settle(tester);
      expect(find.text('Dining out'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

  for (final editing in [false, true]) {
    testWidgets(
      '${editing ? 'Editing' : 'Creating'} a budget only exposes percentages and preserves category mapping',
      (tester) async {
        final budgets = LocalBudgetRepository(db);
        final existing = editing
            ? BudgetRule(
                id: 'budget',
                profileId: 'a',
                name: 'Monthly',
                periodStart: DateTime(2026, 10),
                periodEnd: DateTime(2026, 11),
                buckets: [
                  BudgetBucket(id: 'needs', name: 'Needs', allocationBps: 5000),
                  BudgetBucket(
                    id: 'wants',
                    name: 'Wants',
                    allocationBps: 3000,
                    categoryIds: ['groceries'],
                  ),
                  BudgetBucket(
                    id: 'savings',
                    name: 'Savings',
                    allocationBps: 2000,
                  ),
                ],
              )
            : null;
        final categories = await tester.runAsync(() async {
          if (existing != null) await budgets.save(existing);
          return profiles.watchCategories('a').first;
        });
        await open(
          tester,
          BudgetDialog(
            profileId: 'a',
            month: DateTime(2026, 10),
            categories: categories!,
            existing: existing,
          ),
        );
        expect(find.byType(TextField), findsNWidgets(3));
        expect(find.byType(DropdownButtonFormField<String>), findsNothing);
        expect(find.text('Expense category mapping'), findsNothing);
        await tester.enterText(
          find.widgetWithText(TextField, 'Needs (%)'),
          '60',
        );
        await tester.tap(find.text('Save budget'));
        await settle(tester);
        expect(find.textContaining('Could not save budget:'), findsOneWidget);
        expect(
          await tester.runAsync(() => budgets.watchBudgets('a').first),
          hasLength(editing ? 1 : 0),
        );
        await tester.enterText(
          find.widgetWithText(TextField, 'Wants (%)'),
          '20',
        );
        await tester.tap(find.text('Save budget'));
        await settle(tester);
        expect(find.text('Monthly budget'), findsNothing);
        final saved = (await tester.runAsync(
          () => budgets.watchBudgets('a').first,
        ))!.single;
        expect(
          saved.buckets
              .singleWhere((bucket) => bucket.id == 'needs')
              .allocationBps,
          6000,
        );
        expect(
          saved.buckets
              .singleWhere((bucket) => bucket.id == 'wants')
              .allocationBps,
          2000,
        );
        for (final bucket in saved.buckets) {
          final expected = editing
              ? existing!.buckets
                    .singleWhere((entry) => entry.id == bucket.id)
                    .categoryIds
              : categories
                    .where(
                      (category) =>
                          !category.isArchived &&
                          category.type == TransactionType.expense &&
                          category.defaultBudgetBucket == bucket.id,
                    )
                    .map((category) => category.id)
                    .toSet();
          expect(bucket.categoryIds, expected);
        }
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
    );
  }

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
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    expect(find.text('Expense category mapping'), findsNothing);
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
    await tester.scrollUntilVisible(blockedDelete, 200);
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
