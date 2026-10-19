import 'package:drift/native.dart';
import 'package:expense_tracker_app/app/expense_tracker_app.dart';
import 'package:expense_tracker_app/app/providers.dart';
import 'package:expense_tracker_app/core/database/app_database.dart'
    hide TransactionSchedule;
import 'package:expense_tracker_app/core/ids/id_generator.dart';
import 'package:expense_tracker_app/features/profiles/data/local_profile_repository.dart';
import 'package:expense_tracker_app/features/profiles/domain/profile.dart';
import 'package:expense_tracker_app/features/schedules/data/local_schedule_repository.dart';
import 'package:expense_tracker_app/features/schedules/domain/transaction_schedule.dart';
import 'package:expense_tracker_app/features/schedules/presentation/schedules_page.dart';
import 'package:expense_tracker_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const personal = LocalProfile(
  id: 'a',
  name: 'Personal',
  currencyCode: 'USD',
  currencyScale: 2,
);

Future<void> settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 100)),
  );
  await tester.pumpAndSettle();
}

void main() {
  late AppDatabase db;
  late LocalProfileRepository profiles;
  late LocalScheduleRepository schedules;
  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    profiles = LocalProfileRepository(db);
    schedules = LocalScheduleRepository(db, UuidV7IdGenerator());
    await profiles.create(personal);
  });
  tearDown(() => db.close());

  Future<void> open(WidgetTester tester, {bool dashboard = false}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: dashboard
            ? const ExpenseTrackerApp()
            : const MaterialApp(home: SchedulesPage(profile: personal)),
      ),
    );
    await settle(tester);
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  }

  for (final automatic in [false, true]) {
    testWidgets(
      'Creates ${automatic ? 'automatic' : 'planned'} schedule through the form',
      (tester) async {
        await open(tester);
        await tester.tap(find.text('Add schedule'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextField, 'Schedule name'),
          'Internet bill',
        );
        final amount = find.widgetWithText(TextField, 'Amount (USD)');
        await tester.ensureVisible(amount);
        await tester.enterText(amount, '25.50');
        if (automatic) {
          final toggle = find.byType(SwitchListTile);
          await tester.ensureVisible(toggle);
          await tester.tap(toggle);
          await tester.pumpAndSettle();
        }
        await tester.tap(find.text('Save schedule'));
        await settle(tester);
        expect(find.text('Internet bill'), findsOneWidget);
        expect(find.text('New schedule'), findsNothing);
        if (!automatic) {
          expect(
            await tester.runAsync(() => db.select(db.transactions).get()),
            isEmpty,
          );
          await tester.tap(find.text('Confirm entry'));
          await settle(tester);
        }
        final transactions = await tester.runAsync(
          () => db.select(db.transactions).get(),
        );
        expect(transactions, hasLength(1));
        expect(transactions!.single.amountMinor, 2550);
        expect(transactions.single.notes, 'Internet bill');
        await tester.tap(find.text('Pause'));
        await settle(tester);
        expect(find.text('Resume'), findsOneWidget);
        await tester.tap(find.text('Resume'));
        await settle(tester);
        expect(
          await tester.runAsync(() => db.select(db.transactions).get()),
          hasLength(1),
        );
        await tester.tap(find.text('Cancel schedule'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel schedule').last);
        await settle(tester);
        expect(find.text('No schedules yet.'), findsOneWidget);
        expect(
          await tester.runAsync(() => db.select(db.transactions).get()),
          hasLength(1),
        );
        await close(tester);
      },
    );
  }

  testWidgets(
    'App launch processes all profiles and resume posts new due entries once',
    (tester) async {
      await tester.runAsync(() async {
        await profiles.create(
          const LocalProfile(
            id: 'b',
            name: 'Household',
            currencyCode: 'USD',
            currencyScale: 2,
          ),
        );
        for (final id in ['a', 'b']) {
          await schedules.save(
            TransactionSchedule(
              id: 'auto',
              profileId: id,
              name: 'Salary',
              amountMinor: 10000,
              type: TransactionType.income,
              categoryId: 'salary',
              startDate: DateTime.now(),
              automatic: true,
              repeatUnit: RepeatUnit.once,
            ),
          );
        }
      });
      await open(tester, dashboard: true);
      expect(
        await tester.runAsync(() => db.select(db.transactions).get()),
        hasLength(2),
      );
      await tester.runAsync(
        () => schedules.save(
          TransactionSchedule(
            id: 'new',
            profileId: 'a',
            name: 'Bill',
            amountMinor: 2000,
            type: TransactionType.expense,
            categoryId: 'housing',
            startDate: DateTime.now(),
            automatic: true,
            repeatUnit: RepeatUnit.once,
          ),
        ),
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await settle(tester);
      expect(
        await tester.runAsync(() => db.select(db.transactions).get()),
        hasLength(3),
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await settle(tester);
      expect(
        await tester.runAsync(() => db.select(db.transactions).get()),
        hasLength(3),
      );
      expect(find.text('Scheduled transactions'), findsOneWidget);
      await tester.ensureVisible(find.text('Scheduled transactions'));
      await tester.tap(find.text('Scheduled transactions'));
      await settle(tester);
      expect(find.text('Add schedule'), findsOneWidget);
      expect(find.text('Salary'), findsOneWidget);
      await close(tester);
    },
  );

  for (final failedProfileId in ['a', 'b']) {
    testWidgets(
      'Review schedules opens affected profile $failedProfileId and clears resolved errors on return',
      (tester) async {
        await tester.runAsync(() async {
          if (failedProfileId == 'b') {
            await profiles.create(
              const LocalProfile(
                id: 'b',
                name: 'Household',
                currencyCode: 'USD',
                currencyScale: 2,
              ),
            );
          }
          await schedules.save(
            TransactionSchedule(
              id: 'blocked',
              profileId: failedProfileId,
              name: 'Rent',
              amountMinor: 100,
              type: TransactionType.expense,
              categoryId: 'housing',
              startDate: DateTime.now(),
              automatic: true,
              repeatUnit: RepeatUnit.once,
            ),
          );
          await profiles.setArchived(
            profileId: failedProfileId,
            categoryId: 'housing',
            archived: true,
          );
        });
        await open(tester, dashboard: true);
        expect(find.textContaining('need attention.'), findsOneWidget);
        expect(
          await tester.runAsync(() => db.select(db.transactions).get()),
          isEmpty,
        );
        expect(find.textContaining('Bad state:'), findsNothing);
        expect(find.text('Retry schedules'), findsNothing);
        await tester.tap(find.text('Review schedules'));
        await settle(tester);
        expect(find.text('Rent'), findsOneWidget);
        expect(
          find.text(
            'Category archived. Restore it or edit this schedule before posting.',
          ),
          findsOneWidget,
        );
        // Leaving without a fix must not dismiss the unresolved warning.
        await tester.pageBack();
        await settle(tester);
        expect(find.textContaining('need attention.'), findsOneWidget);
        await tester.tap(find.text('Review schedules'));
        await settle(tester);
        await tester.runAsync(
          () => profiles.setArchived(
            profileId: failedProfileId,
            categoryId: 'housing',
            archived: false,
          ),
        );
        await tester.pageBack();
        await settle(tester);
        expect(find.textContaining('need attention.'), findsNothing);
        expect(
          await tester.runAsync(() => db.select(db.transactions).get()),
          hasLength(1),
        );
        await close(tester);
      },
    );
  }
}
