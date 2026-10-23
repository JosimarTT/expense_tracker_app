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
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

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
      expect(find.byKey(const ValueKey('summary-savings')), findsOneWidget);
      expect(find.text('Hi, Personal!'), findsNothing);
      expect(find.text("Let's manage your money"), findsNothing);
      expect(find.byTooltip('Settings and tracker management'), findsNothing);
      expect(find.text('Personal (USD)'), findsOneWidget);
      expect(find.byKey(const Key('monthly-summary')), findsNothing);
      expect(find.byKey(const Key('remaining-amount')), findsNothing);
      expect(find.text('Set monthly budget'), findsNothing);
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

  testWidgets('Summary arrows precede labels on the same row above amounts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await open(tester);
    for (final (label, icon, amount) in [
      ('Expenses', Icons.call_made_rounded, r'-$0.00'),
      ('Income', Icons.call_received_rounded, r'+$0.00'),
      ('Savings', Icons.savings_rounded, r'$0.00'),
    ]) {
      final card = find.byKey(ValueKey('summary-${label.toLowerCase()}'));
      final arrow = find.descendant(of: card, matching: find.byIcon(icon));
      final title = find.descendant(of: card, matching: find.text(label));
      final value = find.descendant(of: card, matching: find.text(amount));
      expect(tester.getRect(arrow).right, lessThan(tester.getRect(title).left));
      expect(
        tester.getCenter(arrow).dy,
        closeTo(tester.getCenter(title).dy, 1),
      );
      expect(
        tester.getRect(value).top,
        greaterThan(tester.getRect(title).bottom),
      );
      expect(tester.widget<Icon>(arrow).semanticLabel, isNull);
      expect(tester.widget<Icon>(arrow).size, 20);
    }
    final rects = [
      for (final k in ['expenses', 'income', 'savings'])
        tester.getRect(find.byKey(ValueKey('summary-$k'))),
    ];
    expect(rects[0].top, rects[1].top);
    expect(rects[1].top, rects[2].top);
    expect(rects[0].right, lessThan(rects[1].left));
    expect(rects[1].right, lessThan(rects[2].left));
    expect(rects[2].right, lessThanOrEqualTo(390));
    await close(tester);
  });

  testWidgets('Home savings tile follows month and profile, no separate card', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await save('Income', TransactionType.income, 100000);
      await save('Saved', TransactionType.savings, 5000);
      await LocalProfileRepository(db).create(
        const LocalProfile(
          id: 'b',
          name: 'Other profile',
          currencyCode: 'USD',
          currencyScale: 2,
        ),
      );
      await LocalTransactionRepository(db).save(
        FinancialTransaction(
          id: 'other-savings',
          profileId: 'b',
          categoryId: 'investments',
          amountMinor: 90000,
          type: TransactionType.savings,
          occurredAt: DateTime(today.year, today.month, 1),
        ),
      );
    });
    await open(tester);
    final tile = find.byKey(const ValueKey('summary-savings'));
    expect(
      find.descendant(of: tile, matching: find.text(r'$50.00')),
      findsOneWidget,
    );
    expect(find.text('Savings this month'), findsNothing);
    await tester.runAsync(
      () => save('More saved', TransactionType.savings, 5000),
    );
    await settle(tester);
    expect(
      find.descendant(of: tile, matching: find.text(r'$100.00')),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: tile, matching: find.text(r'$0.00')),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Next month'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Personal (USD)').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Other profile (USD)').last);
    await settle(tester);
    expect(
      find.descendant(of: tile, matching: find.text(r'$900.00')),
      findsOneWidget,
    );
    await close(tester);
  });

  testWidgets('Summary values fit one line each at 390px with Nunito', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final loader = FontLoader('Nunito')
        ..addFont(rootBundle.load('assets/fonts/Nunito-Variable.ttf'));
      await loader.load();
      await save('Income', TransactionType.income, 1250000);
      await save('Spend', TransactionType.expense, 85050);
      await save('Saved', TransactionType.savings, 25000);
    });
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await open(tester);
    for (final (key, text) in [
      ('expenses', r'-$850.50'),
      ('income', r'+$12,500.00'),
      ('savings', r'$250.00'),
    ]) {
      final tile = find.byKey(ValueKey('summary-$key'));
      final value = find.descendant(of: tile, matching: find.text(text));
      expect(tester.getSize(value).height, lessThan(30), reason: key);
    }
    expect(tester.takeException(), isNull);
    await close(tester);
  });

  testWidgets(
    'Summary stacks vertically on narrow width or large text without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await open(tester);
      final a = tester.getRect(find.byKey(const ValueKey('summary-expenses')));
      final b = tester.getRect(find.byKey(const ValueKey('summary-savings')));
      expect(b.top, greaterThan(a.bottom));
      expect(tester.takeException(), isNull);
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
      expect(find.text(r'$750.00'), findsNothing);
      expect(find.text(r'Savings: $200.00'), findsNothing);
      await tester.tap(find.byKey(const Key('dashboard-tab-2')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('monthly-summary')),
        200,
      );
      expect(find.text(r'Income: $1,000.00'), findsOneWidget);
      expect(find.text(r'Expenses: $50.00'), findsOneWidget);
      expect(find.text(r'Savings: $200.00'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('remaining-amount'))).data,
        r'$750.00',
      );
      await tester.tap(find.byKey(const Key('dashboard-tab-0')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.byType(SpendingOverview), 200);
      expect(find.byType(PieChart), findsOneWidget);
      final overview = tester.widget<SpendingOverview>(
        find.byType(SpendingOverview),
      );
      expect(overview.analytics.expenseMinor, BigInt.from(5000));
      expect(overview.analytics.expenseCount, 5);
      await tester.scrollUntilVisible(find.text('View all'), 200);
      final recentHeader = find
          .ancestor(
            of: find.text('Recent transactions'),
            matching: find.byType(Row),
          )
          .first;
      expect(
        find.descendant(of: recentHeader, matching: find.byType(Chip)),
        findsNothing,
      );
      expect(
        find.descendant(of: recentHeader, matching: find.text('View all')),
        findsOneWidget,
      );
      await tester.tap(find.text('View all'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Dismiss hint'));
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
      await tester.scrollUntilVisible(find.byType(SpendingOverview), 200);
      final chart = tester.widget<PieChart>(find.byType(PieChart));
      expect(chart.data.sections.single.value, 100);
      await tester.tap(find.byKey(const Key('dashboard-tab-2')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('monthly-summary')),
        200,
      );
      expect(find.text(r'Income: $0.00'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('remaining-amount'))).data,
        r'-$25.00',
      );
      await close(tester);
    },
  );

  testWidgets(
    'Navigation keeps management out of Home and every destination is functional',
    (tester) async {
      await open(tester);
      expect(find.text('Delete Profile'), findsNothing);
      expect(find.text('Manage categories'), findsNothing);
      await tester.tap(find.byKey(const Key('dashboard-tab-3')));
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
      await tester.scrollUntilVisible(find.text('Set monthly budget'), 100);
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
      expect(find.byType(DashboardSummaryCard), findsNothing);
      expect(find.byKey(const Key('monthly-summary')), findsNothing);
      await tester.tap(find.byKey(const Key('dashboard-tab-2')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Monthly totals exceed'), findsOneWidget);
      expect(find.byKey(const Key('monthly-summary')), findsNothing);
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

  testWidgets('Transaction date sits below amount on Home and Transactions', (
    tester,
  ) async {
    final loader = FontLoader('Nunito')
      ..addFont(rootBundle.load('assets/fonts/Nunito-Variable.ttf'));
    await loader.load();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(
      () => save('Coffee', TransactionType.expense, 1250, day: today.day),
    );
    await open(tester);
    for (final tab in [0, 1]) {
      if (tab == 1) {
        await tester.tap(find.byKey(const Key('dashboard-tab-1')));
        await tester.pumpAndSettle();
      }
      final date = find.byKey(const ValueKey('transaction-date-Coffee'));
      final amount = find.byKey(const ValueKey('transaction-amount-Coffee'));
      await tester.scrollUntilVisible(date, 100);
      await tester.pumpAndSettle();
      final time = DateFormat.jm().format(
        DateTime(today.year, today.month, today.day, 9),
      );
      expect(tester.widget<Text>(date).data, tab == 0 ? 'Today' : time);
      final tooltip = tester.widget<Tooltip>(
        find.ancestor(of: date, matching: find.byType(Tooltip)),
      );
      expect(
        tooltip.message,
        DateFormat.yMMMd().add_jm().format(
          DateTime(today.year, today.month, today.day, 9),
        ),
      );
      expect(
        tester.getRect(date).top,
        greaterThanOrEqualTo(tester.getRect(amount).bottom),
      );
      expect(
        tester.getRect(date).right,
        closeTo(tester.getRect(amount).right, 1),
      );
      final rowFinder = find.ancestor(
        of: date,
        matching: find.byType(ListTile),
      );
      final row = tester.widget<ListTile>(rowFinder);
      expect(
        find.descendant(of: find.byWidget(row.trailing!), matching: date),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byWidget(row.subtitle!),
          matching: find.text('Coffee'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: find.byWidget(row.subtitle!), matching: date),
        findsNothing,
      );
      expect(row.contentPadding, const EdgeInsets.symmetric(horizontal: 16));
      expect(
        tester.getRect(find.byWidget(row.leading!)).left -
            tester.getRect(rowFinder).left,
        closeTo(16, 0.1),
      );
      expect(tester.getSize(rowFinder).height, inInclusiveRange(48, 84));
      expect(row.onTap, isNotNull);
      expect(tester.takeException(), isNull);
    }
    await close(tester);
  });

  testWidgets(
    'Home keeps tap-to-edit without delete; Transactions confirms deletion',
    (tester) async {
      await tester.runAsync(
        () => save('Coffee', TransactionType.expense, 1250),
      );
      await open(tester);
      await tester.scrollUntilVisible(find.text('Coffee'), 100);
      await tester.ensureVisible(find.text('Coffee'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.delete_outline), findsNothing);
      await tester.tap(find.text('Coffee'));
      await tester.pumpAndSettle();
      expect(find.text('Edit transaction'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('dashboard-tab-1')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Coffee'), 100);
      await tester.tap(find.text('Coffee'));
      await tester.pumpAndSettle();
      expect(find.text('Edit transaction'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.delete_outline), findsNothing);
      expect(find.byTooltip('Delete Coffee'), findsNothing);
      await tester.drag(find.text('Coffee'), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(find.text('Delete transaction?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Coffee'), findsOneWidget);
      await tester.drag(find.text('Coffee'), const Offset(-500, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await settle(tester);
      expect(find.text('Coffee'), findsNothing);
      final rows = await tester.runAsync(
        () => LocalTransactionRepository(db).watchTransactions('a').first,
      );
      expect(rows, isEmpty);
      await close(tester);
    },
  );

  testWidgets(
    'Home groups three outlined preview rows inside the recent card',
    (tester) async {
      await tester.runAsync(() async {
        for (var index = 0; index < 4; index++) {
          await save(
            'Entry $index',
            TransactionType.expense,
            1250,
            day: index + 1,
          );
        }
      });
      await open(tester);
      await tester.scrollUntilVisible(
        find.byKey(const Key('recent-transactions')),
        100,
      );
      final module = find.byKey(const Key('recent-transactions'));
      final outer = tester.widget<Card>(module);
      expect(outer.margin, EdgeInsets.zero);
      expect((outer.child! as Padding).padding, const EdgeInsets.all(16));
      expect(
        find.descendant(of: module, matching: find.text('Recent transactions')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: module, matching: find.text('View all')),
        findsOneWidget,
      );
      final rows = find.descendant(of: module, matching: find.byType(ListTile));
      expect(rows, findsNWidgets(3));
      final cards = find.descendant(of: module, matching: find.byType(Card));
      expect(cards, findsNWidgets(3));
      for (final card in tester.widgetList<Card>(cards)) {
        expect(card.margin, EdgeInsets.zero);
      }
      final tiles = rows.evaluate().toList();
      for (var index = 1; index < tiles.length; index++) {
        expect(
          tester.getRect(find.byWidget(tiles[index].widget)).top -
              tester.getRect(find.byWidget(tiles[index - 1].widget)).bottom,
          closeTo(8, 0.1),
        );
      }
      await tester.ensureVisible(find.text('View all'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('View all'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('recent-transactions')), findsNothing);
      expect(find.text('Entry 3'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await close(tester);
    },
  );

  for (final populated in [false, true]) {
    testWidgets(
      'No generic footer on Home or Transactions (populated: $populated)',
      (tester) async {
        if (populated) {
          await tester.runAsync(
            () => save('Coffee', TransactionType.expense, 1250),
          );
        }
        await open(tester);
        for (final tab in [0, 1]) {
          await tester.tap(find.byKey(ValueKey('dashboard-tab-$tab')));
          await tester.pumpAndSettle();
          await tester.drag(
            find.byType(ListView).first,
            const Offset(0, -3000),
          );
          await tester.pumpAndSettle();
          expect(
            find.text('Keeping your money calm, intentional, and friendly.'),
            findsNothing,
          );
          if (populated) {
            expect(find.text('Coffee'), findsOneWidget);
          } else {
            expect(find.text('Add first transaction'), findsOneWidget);
          }
          expect(tester.takeException(), isNull);
        }
        await close(tester);
      },
    );
  }

  testWidgets(
    'Dashboard cards follow content, empty-state and list-row spacing rules',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await open(tester);
      void checkCards() {
        for (final card in tester.widgetList<Card>(find.byType(Card))) {
          expect(card.margin, EdgeInsets.zero);
          if (card.child case final Padding padding) {
            expect(
              padding.padding,
              card.key == const Key('dashboard-empty')
                  ? const EdgeInsets.all(24)
                  : (card.key.toString().contains('summary-') &&
                        padding.padding == const EdgeInsets.all(12))
                  ? const EdgeInsets.all(12)
                  : const EdgeInsets.all(16),
            );
          }
        }
      }

      checkCards();
      await tester.scrollUntilVisible(find.byType(DashboardEmptyState), 200);
      checkCards();
      await tester.tap(find.byKey(const Key('dashboard-tab-3')));
      await tester.pumpAndSettle();
      final toggle = find.byKey(const Key('automatic-unused-savings'));
      await tester.scrollUntilVisible(toggle, 100);
      expect(
        tester.widget<SwitchListTile>(toggle).contentPadding,
        const EdgeInsets.symmetric(horizontal: 16),
      );
      checkCards();
      await tester.tap(find.byKey(const Key('dashboard-tab-2')));
      await tester.pumpAndSettle();
      checkCards();
      await tester.scrollUntilVisible(find.text('Set monthly budget'), 200);
      await tester.tap(find.text('Set monthly budget'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save budget'));
      await settle(tester);
      for (final label in [
        'Needs (50.0%)',
        'Wants (30.0%)',
        'Savings (20.0%)',
      ]) {
        await tester.scrollUntilVisible(find.text(label), 100);
        checkCards();
        final cardFinder = find.ancestor(
          of: find.text(label),
          matching: find.byType(Card),
        );
        final card = tester.widget<Card>(cardFinder);
        expect((card.child! as Padding).padding, const EdgeInsets.all(16));
        expect(tester.getRect(cardFinder).left, closeTo(16, 0.1));
        expect(
          tester.getRect(cardFinder).right,
          closeTo(tester.view.physicalSize.width - 16, 0.1),
        );
      }
      expect(tester.takeException(), isNull);
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
      final search = find.byType(TextField);
      await tester.enterText(search, ' COFFEE ');
      await tester.pumpAndSettle();
      expect(find.text('Early coffee'), findsOneWidget);
      expect(find.text('Later market'), findsNothing);
      await tester.enterText(search, r'$3.00');
      await tester.pumpAndSettle();
      expect(find.text('Later market'), findsOneWidget);
      expect(find.text('Early coffee'), findsNothing);
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
      await tester.tap(find.text('Oldest first'));
      await tester.pumpAndSettle();
      expect(find.byType(Badge), findsOneWidget);
      await tester.tap(find.byTooltip('Dismiss hint'));
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
    'Transactions header: search and sort share the title row, pills, no profile picker, search replaces title',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.runAsync(
        () => save('Coffee', TransactionType.expense, 1250),
      );
      await open(tester);
      await tester.tap(find.byKey(const Key('dashboard-tab-1')));
      await tester.pumpAndSettle();
      final title = find.text('Transactions').first;
      final searchButton = find.byTooltip('Search transactions');
      final sortButton = find.byTooltip('Sort transactions');
      expect(
        tester.getCenter(searchButton).dy,
        closeTo(tester.getCenter(title).dy, 1),
      );
      expect(
        tester.getCenter(sortButton).dy,
        closeTo(tester.getCenter(title).dy, 1),
      );
      expect(
        tester.getRect(searchButton).right,
        lessThan(tester.getRect(sortButton).left + 1),
      );
      expect(find.text('Personal (USD)'), findsNothing);
      final month = tester.getRect(find.byTooltip('Previous month'));
      final pills = [
        for (final label in ['All', 'Income', 'Expense', 'Savings'])
          tester.getRect(find.widgetWithText(ChoiceChip, label)),
      ];
      expect(month.bottom, lessThan(pills.first.top));
      for (final pill in pills) {
        expect(pill.top, pills.first.top);
        expect(pill.right, lessThanOrEqualTo(390));
      }
      expect(
        tester.widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'All')).shape,
        isA<StadiumBorder>(),
      );
      await tester.tap(searchButton);
      await tester.pumpAndSettle();
      final content = find.byKey(const ValueKey('dashboard-content-1'));
      expect(
        find.descendant(of: content, matching: find.text('Transactions')),
        findsNothing,
      );
      expect(find.byType(TextField), findsOneWidget);
      expect(tester.getRect(find.byType(TextField)).top, lessThan(month.top));
      await tester.tap(find.byTooltip('Close search'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: content, matching: find.text('Transactions')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await close(tester);
    },
  );

  testWidgets('Swipe hint shows once per session and can be dismissed', (
    tester,
  ) async {
    await tester.runAsync(() => save('Coffee', TransactionType.expense, 1250));
    await open(tester);
    expect(find.byKey(const Key('swipe-hint')), findsNothing);
    await tester.tap(find.byKey(const Key('dashboard-tab-1')));
    await tester.pumpAndSettle();
    expect(find.text('Swipe left to delete. Tap to edit.'), findsOneWidget);
    await tester.tap(find.byTooltip('Dismiss hint'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('swipe-hint')), findsNothing);
    await close(tester);
  });

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
      await tester.scrollUntilVisible(
        find.byKey(const Key('monthly-summary')),
        200,
      );
      expect(find.text(r'Income: $0.00'), findsOneWidget);
      expect(find.text(r'Expenses: $0.00'), findsOneWidget);
      expect(find.text(r'Savings: $0.00'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('remaining-amount'))).data,
        r'$0.00',
      );
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
        expect(find.text('Groceries'), findsWidgets);
        expect(find.text(r'$3.00'), findsOneWidget);
        expect(find.text('50%'), findsOneWidget);
        expect(find.text('33%'), findsOneWidget);
        expect(find.text('17%'), findsOneWidget);
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

  testWidgets('Home Other opens the complete Stats breakdown', (tester) async {
    await tester.runAsync(() async {
      for (var index = 0; index < 7; index++) {
        final categoryId = 'overview-$index';
        await LocalProfileRepository(db).save(
          'a',
          TransactionCategory(
            id: categoryId,
            name: 'Category $index',
            type: TransactionType.expense,
            iconKey: 'category',
            colorArgb: 0xFF2E7D32,
            defaultBudgetBucket: 'needs',
          ),
        );
        await LocalTransactionRepository(db).save(
          FinancialTransaction(
            id: categoryId,
            profileId: 'a',
            categoryId: categoryId,
            amountMinor: 100 - index,
            type: TransactionType.expense,
            occurredAt: DateTime(today.year, today.month, 1),
          ),
        );
      }
    });
    await open(tester);
    await tester.scrollUntilVisible(find.text('Other'), 100);
    await tester.ensureVisible(find.text('Other'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<PieChart>(find.byType(PieChart)).data.sections,
      hasLength(5),
    );
    await tester.tap(find.text('Other'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byType(SpendingOverview), 100);
    expect(
      tester.widget<SpendingOverview>(find.byType(SpendingOverview)).compact,
      isFalse,
    );
    expect(
      tester.widget<PieChart>(find.byType(PieChart)).data.sections,
      hasLength(7),
    );
    expect(find.text('Other'), findsNothing);
    expect(find.text('Category 6'), findsOneWidget);
    await close(tester);
  });

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
          final semantic = Theme.of(
            tester.element(find.byType(DashboardSummaryCard)),
          ).extension<AppSemanticColors>()!;
          for (final (label, foreground, icon) in [
            ('Expenses', semantic.onExpenseContainer, Icons.call_made_rounded),
            ('Income', semantic.onIncomeContainer, Icons.call_received_rounded),
            ('Savings', semantic.onInfoContainer, Icons.savings_rounded),
          ]) {
            final card = find.byKey(ValueKey('summary-${label.toLowerCase()}'));
            final texts = tester.widgetList<Text>(
              find.descendant(of: card, matching: find.byType(Text)),
            );
            expect(texts, hasLength(2));
            for (final text in texts) {
              expect(text.style?.color, foreground);
            }
            expect(
              tester
                  .widget<Icon>(
                    find.descendant(of: card, matching: find.byIcon(icon)),
                  )
                  .color,
              foreground,
            );
          }
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
              await tester.scrollUntilVisible(
                find.byKey(const Key('monthly-summary')),
                200,
              );
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
