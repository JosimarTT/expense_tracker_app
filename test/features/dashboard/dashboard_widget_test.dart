import 'package:drift/native.dart';
import 'package:expense_tracker_app/app/expense_tracker_app.dart';
import 'package:expense_tracker_app/app/providers.dart';
import 'package:expense_tracker_app/app/theme/app_theme.dart';
import 'package:expense_tracker_app/core/database/app_database.dart';
import 'package:expense_tracker_app/features/dashboard/presentation/dashboard_page.dart';
import 'package:expense_tracker_app/features/dashboard/presentation/dashboard_widgets.dart';
import 'package:expense_tracker_app/features/profiles/data/local_profile_repository.dart';
import 'package:expense_tracker_app/features/profiles/domain/profile.dart';
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
  final today = DateTime.now();
  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await LocalProfileRepository(db).create(
      const LocalProfile(
        id: 'a',
        name: 'Personal',
        currencyCode: 'USD',
        currencyScale: 2,
      ),
    );
  });
  tearDown(() => db.close());

  Future<void> save(
    String id,
    TransactionType type,
    int amount, {
    int day = 1,
  }) => LocalTransactionRepository(db).save(
    FinancialTransaction(
      id: id,
      profileId: 'a',
      notes: id,
      amountMinor: amount,
      type: type,
      categoryId: switch (type) {
        TransactionType.income => 'salary',
        TransactionType.expense => 'groceries',
        TransactionType.savings => 'investments',
      },
      occurredAt: DateTime(today.year, today.month, day, 9),
    ),
  );

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const ExpenseTrackerApp(),
      ),
    );
    await settle(tester);
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Empty month has the Stitch summary, illustrated state and working add action',
    (tester) async {
      await open(tester);
      expect(find.byType(AppBar), findsNothing);
      expect(find.byType(DashboardSummaryCard), findsOneWidget);
      expect(find.text('Clean slate'), findsOneWidget);
      expect(find.text(r'$0.00'), findsOneWidget);
      expect(find.text('Waiting for funds'), findsOneWidget);
      expect(find.text('No spend yet'), findsOneWidget);
      expect(find.byTooltip('Previous month'), findsOneWidget);
      expect(find.byTooltip('Next month'), findsOneWidget);
      expect(find.byKey(const Key('add-transaction')), findsOneWidget);
      await tester.scrollUntilVisible(find.byType(DashboardEmptyState), 200);
      await tester.ensureVisible(find.text('Add first transaction'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add first transaction'));
      await tester.pumpAndSettle();
      expect(find.text('Add transaction'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(
        await tester.runAsync(() => db.select(db.transactions).get()),
        isEmpty,
      );
      await close(tester);
    },
  );

  testWidgets(
    'Actual totals include savings, recent entries are newest first and View all opens filtered history',
    (tester) async {
      await tester.runAsync(() async {
        await save('Paycheck', TransactionType.income, 100000);
        await save('Invested', TransactionType.savings, 20000, day: 2);
        for (var index = 0; index < 5; index++) {
          await save(
            'Purchase $index',
            TransactionType.expense,
            1000,
            day: index + 3,
          );
        }
      });
      await open(tester);
      expect(find.text(r'$750.00'), findsOneWidget);
      expect(find.text('25.0% of income allocated'), findsOneWidget);
      expect(find.text(r'Savings: $200.00'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('View all'), 200);
      await tester.tap(find.text('View all'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Purchase 4'), 200);
      final first = tester.widgetList<ListTile>(find.byType(ListTile)).first;
      expect((first.title! as Text).data, 'Purchase 4');
      await tester.drag(find.byType(ListView).first, const Offset(0, 1500));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'Savings'));
      await tester.pumpAndSettle();
      expect(find.text('Invested'), findsOneWidget);
      expect(find.text('Purchase 4'), findsNothing);
      await tester.tap(find.text('Invested'));
      await tester.pumpAndSettle();
      expect(find.text('Edit transaction'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardEmptyState), findsOneWidget);
      await close(tester);
    },
  );

  testWidgets(
    'Over allocation is truthful and progress semantics stay valid without income',
    (tester) async {
      await tester.runAsync(() => save('Bill', TransactionType.expense, 2500));
      await open(tester);
      expect(find.text('Over allocated'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('remaining-amount'))).data,
        r'-$25.00',
      );
      expect(find.text('Record income to see your allocation'), findsOneWidget);
      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progress.value, 1);
      expect(progress.semanticsValue, '100.0%');
      await close(tester);
    },
  );

  testWidgets(
    'Navigation keeps management out of Home and every destination is functional',
    (tester) async {
      await open(tester);
      expect(find.text('Delete Profile'), findsNothing);
      expect(find.text('Manage categories'), findsNothing);
      await tester.tap(find.byTooltip('Settings and tracker management'));
      await tester.pumpAndSettle();
      expect(find.text('Profile & settings'), findsOneWidget);
      await tester.tap(find.byKey(const Key('manage-categories')));
      await settle(tester);
      expect(find.text('Manage categories'), findsNWidgets(2));
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Scheduled transactions'));
      await settle(tester);
      expect(find.text('Add schedule'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('dashboard-tab-2')));
      await tester.pumpAndSettle();
      expect(find.text('Monthly budget'), findsOneWidget);
      await tester.tap(find.text('Set monthly budget'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNWidgets(3));
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('add-transaction')));
      await tester.pumpAndSettle();
      expect(find.text('Add transaction'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await close(tester);
    },
  );

  testWidgets(
    'Aggregate overflow stays visible on Home and Budget without hiding history',
    (tester) async {
      await tester.runAsync(() async {
        await save('First income', TransactionType.income, 9223372036854775807);
        await save('Second income', TransactionType.income, 1, day: 2);
      });
      await open(tester);
      expect(find.textContaining('Monthly totals exceed'), findsOneWidget);
      await tester.tap(find.byKey(const Key('dashboard-tab-2')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Monthly totals exceed'), findsOneWidget);
      await tester.tap(find.byKey(const Key('dashboard-tab-1')));
      await tester.pumpAndSettle();
      expect(find.text('Second income'), findsOneWidget);
      await tester.tap(find.text('Second income'));
      await tester.pumpAndSettle();
      expect(find.text('Edit transaction'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await close(tester);
    },
  );

  for (final brightness in Brightness.values) {
    for (final (size, scale) in [
      (const Size(320, 568), 2.0),
      (const Size(390, 844), 1.0),
      (const Size(1280, 900), 1.0),
    ]) {
      testWidgets(
        'Dashboard fits $brightness at $size with text scale $scale',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.runAsync(() async {
            await save('Paycheck', TransactionType.income, 9223372036854775807);
            await save('Purchase', TransactionType.expense, 1250);
          });
          await tester.pumpWidget(
            ProviderScope(
              overrides: [databaseProvider.overrideWithValue(db)],
              child: MaterialApp(
                theme: brightness == Brightness.dark
                    ? AppTheme.dark
                    : AppTheme.light,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: const DashboardPage(),
              ),
            ),
          );
          await settle(tester);
          expect(find.byType(DashboardSummaryCard), findsOneWidget);
          for (final tab in [1, 2, 3, 0]) {
            await tester.tap(find.byKey(ValueKey('dashboard-tab-$tab')));
            await tester.pumpAndSettle();
            await tester.drag(
              find.byType(ListView).first,
              const Offset(0, -2000),
            );
            await tester.pumpAndSettle();
          }
          await close(tester);
        },
      );
    }
  }
}
