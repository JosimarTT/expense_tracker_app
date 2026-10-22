import 'package:drift/native.dart';
import 'package:expense_tracker_app/app/expense_tracker_app.dart';
import 'package:expense_tracker_app/app/providers.dart';
import 'package:expense_tracker_app/app/theme/app_theme.dart';
import 'package:expense_tracker_app/app/theme/app_colors.dart';
import 'package:expense_tracker_app/core/database/app_database.dart';
import 'package:expense_tracker_app/features/dashboard/presentation/dashboard_page.dart';
import 'package:expense_tracker_app/features/dashboard/presentation/dashboard_widgets.dart';
import 'package:expense_tracker_app/features/dashboard/presentation/spending_charts.dart';
import 'package:fl_chart/fl_chart.dart';
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
      expect(find.text(r'$0.00'), findsOneWidget);
      expect(find.text('Hi, Personal!'), findsOneWidget);
      expect(find.byType(SpendingOverview), findsOneWidget);
      expect(find.byType(PieChart), findsNothing);
      expect(
        find.text(
          'No expenses this month. Your category breakdown will appear here.',
        ),
        findsOneWidget,
      );
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
      expect(find.text(r'Savings: $200.00'), findsOneWidget);
      await tester.scrollUntilVisible(find.byType(SpendingOverview), 200);
      expect(find.byType(PieChart), findsOneWidget);
      final overview = tester.widget<SpendingOverview>(
        find.byType(SpendingOverview),
      );
      expect(overview.analytics.expenseMinor, BigInt.from(5000));
      expect(overview.analytics.expenseCount, 5);
      await tester.scrollUntilVisible(find.text('View all'), 200);
      await tester.tap(find.text('View all'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Purchase 4'), 200);
      final first = tester.widgetList<ListTile>(find.byType(ListTile)).first;
      expect((first.title! as Text).data, 'Groceries');
      expect(
        find.descendant(
          of: find.byWidget(first),
          matching: find.text('Purchase 4'),
        ),
        findsOneWidget,
      );
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
    'Remaining balance is truthful without income and expenses are charted',
    (tester) async {
      await tester.runAsync(() => save('Bill', TransactionType.expense, 2500));
      await open(tester);
      expect(
        tester.widget<Text>(find.byKey(const Key('remaining-amount'))).data,
        r'-$25.00',
      );
      await tester.scrollUntilVisible(find.byType(SpendingOverview), 200);
      final chart = tester.widget<PieChart>(find.byType(PieChart));
      expect(chart.data.sections.single.value, 100);
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
      expect(find.text('Stats'), findsWidgets);
      await tester.scrollUntilVisible(find.text('Monthly budget'), 200);
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

  testWidgets(
    'Transactions searches category and notes, sorts, clears, and keeps type filters',
    (tester) async {
      await tester.runAsync(() async {
        await save('Early coffee', TransactionType.expense, 100, day: 1);
        await save('Later market', TransactionType.expense, 300, day: 2);
        await save('Salary payment', TransactionType.income, 5000, day: 3);
      });
      await open(tester);
      await tester.tap(find.byKey(const Key('dashboard-tab-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Search transactions'));
      await tester.pumpAndSettle();
      final search = find.widgetWithText(TextField, 'Search transactions');
      await tester.enterText(search, ' COFFEE ');
      await tester.pumpAndSettle();
      expect(find.text('Early coffee'), findsOneWidget);
      expect(find.text('Later market'), findsNothing);
      await tester.enterText(search, 'groceries');
      await tester.pumpAndSettle();
      expect(find.text('Early coffee'), findsOneWidget);
      expect(find.text('Later market'), findsOneWidget);
      expect(find.text('Salary payment'), findsNothing);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Income'));
      await tester.pumpAndSettle();
      expect(find.text('No transactions match your filters.'), findsOneWidget);
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      expect(find.text('Salary payment'), findsOneWidget);
      await tester.tap(find.byTooltip('Close search'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Sort transactions'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(CheckedPopupMenuItem<bool>, 'Oldest first'),
      );
      await tester.pumpAndSettle();
      final first = tester.widgetList<ListTile>(find.byType(ListTile)).first;
      expect(
        find.descendant(
          of: find.byWidget(first),
          matching: find.text('Early coffee'),
        ),
        findsOneWidget,
      );
      await close(tester);
    },
  );

  testWidgets(
    'Stats charts use only the selected profile and month with exact daily values',
    (tester) async {
      await tester.runAsync(() async {
        await save('Coffee', TransactionType.expense, 100, day: 1);
        await save('Lunch', TransactionType.expense, 300, day: 2);
        await save('Invested', TransactionType.savings, 10000, day: 2);
        await LocalTransactionRepository(db).save(
          FinancialTransaction(
            id: 'previous',
            profileId: 'a',
            amountMinor: 800,
            type: TransactionType.expense,
            categoryId: 'groceries',
            occurredAt: DateTime(today.year, today.month, 0, 12),
          ),
        );

        await LocalProfileRepository(
          db,
        ).setArchived(profileId: 'a', categoryId: 'groceries', archived: true);
        await LocalProfileRepository(db).create(
          const LocalProfile(
            id: 'b',
            name: 'Other',
            currencyCode: 'USD',
            currencyScale: 2,
          ),
        );
        await LocalTransactionRepository(db).save(
          FinancialTransaction(
            id: 'other',
            profileId: 'b',
            amountMinor: 990000,
            type: TransactionType.expense,
            categoryId: 'groceries',
            occurredAt: DateTime(today.year, today.month, 1),
          ),
        );
      });
      await open(tester);
      await tester.tap(find.byKey(const Key('dashboard-tab-2')));
      await tester.pumpAndSettle();
      expect(
        find.text('Down 50.0% vs previous month (full month).'),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(find.byType(SpendingOverview), 200);
      final overview = tester.widget<SpendingOverview>(
        find.byType(SpendingOverview),
      );
      expect(overview.analytics.expenseMinor, BigInt.from(400));
      expect(overview.analytics.categoryMinor, {'groceries': BigInt.from(400)});
      await tester.scrollUntilVisible(find.byType(LineChart), 200);
      final chart = tester.widget<LineChart>(find.byType(LineChart));
      expect(
        chart.data.lineBarsData.single.spots[0].y,
        closeTo(1 / 3, 0.00001),
      );
      expect(chart.data.lineBarsData.single.spots[1].y, 1);
      expect(chart.data.lineBarsData.single.spots[2].y, 0);
      await tester.drag(find.byType(ListView).first, const Offset(0, 2000));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<ExpenseStatsCard>(find.byType(ExpenseStatsCard))
            .analytics
            .expenseMinor,
        BigInt.from(800),
      );
      await close(tester);
    },
  );

  testWidgets(
    'Empty Stats uses honest placeholders and no fabricated charts or comparison',
    (tester) async {
      await open(tester);
      await tester.tap(find.byKey(const Key('dashboard-tab-2')));
      await tester.pumpAndSettle();
      expect(
        find.text('No expenses recorded in the previous month to compare.'),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(find.byType(DailySpendingChart), 200);
      expect(
        find.text('Record an expense to see your daily trend.'),
        findsOneWidget,
      );
      expect(find.byType(LineChart), findsNothing);
      expect(find.byType(PieChart), findsNothing);
      await close(tester);
    },
  );

  testWidgets(
    'Chart segments use design tokens and semantic descriptions expose exact amounts',
    (tester) async {
      await tester.runAsync(() async {
        for (final (id, category, amount) in [
          ('Food', 'groceries', 300),
          ('Ride', 'transport', 200),
          ('Home', 'housing', 100),
        ]) {
          await LocalTransactionRepository(db).save(
            FinancialTransaction(
              id: id,
              profileId: 'a',
              amountMinor: amount,
              type: TransactionType.expense,
              categoryId: category,
              occurredAt: DateTime(today.year, today.month, 1),
            ),
          );
        }
      });
      final semantics = tester.ensureSemantics();
      try {
        await open(tester);
        await tester.scrollUntilVisible(find.byType(PieChart), 200);
        await tester.pumpAndSettle();
        final pie = tester.widget<PieChart>(find.byType(PieChart));
        expect(pie.data.sections.map((entry) => entry.color), [
          AppColors.coral,
          AppColors.sky,
          AppColors.lavender,
        ]);
        expect(pie.data.sections.first.value, 50);
        expect(find.text(r'Groceries  $3.00  50.0%'), findsOneWidget);
        expect(
          find.bySemanticsLabel(
            r'Total expenses: $6.00. Category breakdown follows.',
          ),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const Key('dashboard-tab-2')));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(find.byType(LineChart), 200);
        final semanticsWidget = tester.widget<Semantics>(
          find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                (widget.properties.label?.startsWith('Daily expenses. ') ??
                    false),
          ),
        );
        expect(semanticsWidget.properties.label, contains(r'$6.00'));
        final chart = tester.widget<LineChart>(find.byType(LineChart));
        expect(chart.data.lineBarsData.single.color, AppColors.mint);
        await close(tester);
      } finally {
        semantics.dispose();
      }
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
            await save(
              'Purchase',
              TransactionType.expense,
              9223372036854775807,
            );
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
          await tester.scrollUntilVisible(
            find.byType(DashboardSummaryCard),
            200,
          );
          expect(find.byType(DashboardSummaryCard), findsOneWidget);
          expect(tester.takeException(), isNull);
          for (final tab in [1, 2, 3, 0]) {
            await tester.tap(find.byKey(ValueKey('dashboard-tab-$tab')));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            if (tab == 0 || tab == 2) {
              await tester.scrollUntilVisible(find.byType(PieChart), 200);
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            }
            if (tab == 2) {
              await tester.scrollUntilVisible(find.byType(LineChart), 200);
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);
            }
            await tester.drag(
              find.byType(ListView).first,
              const Offset(0, -2000),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }
          await close(tester);
        },
      );
    }
  }
}
