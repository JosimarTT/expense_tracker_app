import 'package:drift/native.dart';
import 'package:expense_tracker_app/app/expense_tracker_app.dart';
import 'package:expense_tracker_app/app/providers.dart';
import 'package:expense_tracker_app/core/database/app_database.dart';
import 'package:expense_tracker_app/features/profiles/data/local_profile_repository.dart';
import 'package:expense_tracker_app/features/profiles/domain/profile.dart';
import 'package:expense_tracker_app/features/savings/data/local_savings_repository.dart';
import 'package:expense_tracker_app/features/transactions/data/repositories/local_transaction_repository.dart';
import 'package:expense_tracker_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 100)),
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

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const ExpenseTrackerApp(),
      ),
    );
    await settle(tester);
  }

  testWidgets(
    'Records savings with categories and toggles automatic unused-money savings',
    (tester) async {
      await open(tester);
      final toggle = find.byKey(const Key('automatic-unused-savings'));
      expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await settle(tester);
      expect(tester.widget<SwitchListTile>(toggle).value, isTrue);
      await tester.scrollUntilVisible(find.text('Add transaction'), 200);
      await tester.tap(find.text('Add transaction'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Expense'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Savings').last);
      await tester.pumpAndSettle();
      expect(find.text('Unused money'), findsNothing);
      await tester.enterText(
        find.widgetWithText(TextField, 'Amount (USD)'),
        '50',
      );
      await tester.tap(find.text('Save'));
      await settle(tester);
      final transaction = await tester.runAsync(
        () => db.select(db.transactions).getSingle(),
      );
      expect(transaction!.type, 'savings');
      expect(transaction.amountMinor, 5000);
      expect(transaction.categoryId, isNot(TransactionCategory.unusedMoneyId));
      await tester.drag(find.byType(ListView).first, const Offset(0, 1500));
      await tester.pumpAndSettle();
      expect(find.text(r'Savings: $50.00'), findsOneWidget);
      expect(find.text(r'Expenses: $0.00'), findsOneWidget);
      expect(find.text(r'Remaining to allocate: -$50.00'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'Launch generates closed-month savings and its row is read-only',
    (tester) async {
      final today = DateTime.now();
      final priorMonth = DateTime(today.year, today.month - 1, 15);
      await tester.runAsync(() async {
        final repo = LocalTransactionRepository(db, now: () => priorMonth);
        await LocalSavingsRepository(db).setAutomatic('a', true, priorMonth);
        await repo.save(
          FinancialTransaction(
            id: 'salary',
            profileId: 'a',
            amountMinor: 10000,
            type: TransactionType.income,
            categoryId: 'salary',
            occurredAt: priorMonth,
          ),
        );
      });
      await open(tester);
      final sweeps = await tester.runAsync(
        () => (db.select(
          db.transactions,
        )..where((row) => row.savingsMonth.isNotNull())).get(),
      );
      expect(sweeps, hasLength(1));
      expect(sweeps!.single.amountMinor, 10000);
      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();
      final note = sweeps.single.notes;
      await tester.scrollUntilVisible(find.text(note), 200);
      final row = tester.widget<ListTile>(
        find.ancestor(of: find.text(note), matching: find.byType(ListTile)),
      );
      expect(row.onTap, isNull);
      final deleteButton = find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.tooltip == 'Delete $note',
      );
      expect(tester.widget<IconButton>(deleteButton).onPressed, isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
