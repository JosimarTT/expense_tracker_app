import 'package:drift/native.dart';
import 'package:expense_tracker_app/app/expense_tracker_app.dart';
import 'package:expense_tracker_app/app/providers.dart';
import 'package:expense_tracker_app/core/database/app_database.dart';
import 'package:expense_tracker_app/features/profiles/data/local_profile_repository.dart';
import 'package:expense_tracker_app/features/profiles/domain/profile.dart';
import 'package:expense_tracker_app/features/transactions/data/repositories/local_transaction_repository.dart';
import 'package:expense_tracker_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> settleDatabase(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Empty installation offers profile creation', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [profilesProvider.overrideWith((ref) => Stream.value([]))],
        child: const ExpenseTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Create your first profile'), findsOneWidget);
    await tester.tap(find.text('Create your first profile'));
    await tester.pumpAndSettle();
    expect(find.text('Create local profile'), findsOneWidget);
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a profile name.'), findsOneWidget);
  });

  testWidgets('Shows storage failures explicitly with retry', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profilesProvider.overrideWith(
            (ref) => Stream.error(StateError('storage unavailable')),
          ),
        ],
        child: const ExpenseTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Could not load local profiles'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('Creates a profile, adds an expense and saves a custom budget', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const ExpenseTrackerApp(),
      ),
    );
    await settleDatabase(tester);
    await tester.tap(find.text('Create your first profile'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Profile name'),
      'Personal',
    );
    await tester.tap(find.text('Create'));
    await settleDatabase(tester);
    expect(find.text('Personal (USD)'), findsOneWidget);
    await tester.tap(find.text('Add transaction'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Lunch');
    await tester.enterText(
      find.widgetWithText(TextField, 'Amount (USD)'),
      '12.50',
    );
    await tester.tap(find.text('Save'));
    await settleDatabase(tester);
    expect(find.text('Lunch'), findsOneWidget);
    expect(find.text('Expenses: USD 12.50'), findsOneWidget);
    await tester.tap(find.text('Set monthly budget'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Needs (%)'), '60');
    await tester.enterText(find.widgetWithText(TextField, 'Wants (%)'), '20');
    await tester.tap(find.text('Save budget'));
    await settleDatabase(tester);
    expect(find.text('Needs (60.0%)'), findsOneWidget);
    expect(find.text('Savings target: USD 0.00'), findsOneWidget);
    expect(find.textContaining('No income this month'), findsOneWidget);
    await tester.ensureVisible(find.text('Add transaction'));
    await tester.tap(find.text('Add transaction'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Salary');
    await tester.enterText(
      find.widgetWithText(TextField, 'Amount (USD)'),
      '1000',
    );
    await tester.tap(find.text('Expense'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Income').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await settleDatabase(tester);
    await tester.drag(find.byType(ListView).first, const Offset(0, 500));
    await tester.pumpAndSettle();
    expect(find.text('Income: USD 1,000.00'), findsOneWidget);
    expect(find.text('Savings target: USD 200.00'), findsOneWidget);
    expect(find.text('USD 12.50 of USD 200.00'), findsOneWidget);
    expect(find.textContaining('No income this month'), findsNothing);
    expect(
      await tester.runAsync(() => db.select(db.budgets).get()),
      hasLength(1),
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets(
    'Profile switching replaces transaction data and monthly totals',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      await tester.runAsync(() async {
        for (final id in ['Personal', 'Household']) {
          await LocalProfileRepository(db).create(
            LocalProfile(
              id: id,
              name: id,
              currencyCode: 'USD',
              currencyScale: 2,
            ),
          );
          await LocalTransactionRepository(db).save(
            FinancialTransaction(
              id: 'same-id',
              profileId: id,
              title: '$id purchase',
              amountMinor: id == 'Personal' ? 100 : 200,
              type: TransactionType.expense,
              categoryId: 'groceries',
              occurredAt: DateTime.now(),
            ),
          );
        }
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const ExpenseTrackerApp(),
        ),
      );
      await settleDatabase(tester);
      expect(find.text('Personal purchase'), findsOneWidget);
      expect(find.text('Household purchase'), findsNothing);
      await tester.tap(find.text('Personal (USD)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Household (USD)').last);
      await settleDatabase(tester);
      expect(find.text('Household purchase'), findsOneWidget);
      expect(find.text('Personal purchase'), findsNothing);
      expect(find.text('Expenses: USD 2.00'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
