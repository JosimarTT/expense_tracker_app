import 'package:drift/native.dart';
import 'package:expense_tracker_app/app/expense_tracker_app.dart';
import 'package:expense_tracker_app/app/providers.dart';
import 'package:expense_tracker_app/core/database/app_database.dart';
import 'package:expense_tracker_app/features/profiles/data/local_profile_repository.dart';
import 'package:expense_tracker_app/features/profiles/domain/profile.dart';
import 'package:expense_tracker_app/features/profiles/presentation/profile_avatar.dart';
import 'package:expense_tracker_app/features/profiles/presentation/profile_selector.dart';
import 'package:expense_tracker_app/features/transactions/data/repositories/local_transaction_repository.dart';
import 'package:expense_tracker_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

bool isUuidV7(String id) => RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
).hasMatch(id);

Future<void> settleDatabase(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final (query, code, name, scale) in [
    ('Peru', 'PEN', 'Peruvian sol', 2),
    ('yen', 'JPY', 'Japanese yen', 0),
    ('KWD', 'KWD', 'Kuwaiti dinar', 3),
  ]) {
    testWidgets('Searches currency by $query and creates a $code profile', (
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
      await tester.ensureVisible(find.text('Create your first profile'));
      await tester.tap(find.text('Create your first profile'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), 'Personal');
      await tester.ensureVisible(find.byKey(const Key('profile-currency')));
      await tester.tap(find.byKey(const Key('profile-currency')));
      await tester.pumpAndSettle();
      final search = find.widgetWithText(TextField, 'Search currencies');
      await tester.enterText(search, 'not a currency');
      await tester.pumpAndSettle();
      expect(find.text('No matching currencies.'), findsOneWidget);
      await tester.enterText(search, query);
      await tester.pumpAndSettle();
      final codeLabel = find.descendant(
        of: find.byKey(ValueKey('currency-$code')),
        matching: find.text(code),
      );
      expect(codeLabel, findsOneWidget);
      expect(find.text(name), findsOneWidget);
      expect(find.textContaining('decimal places'), findsNothing);
      await tester.ensureVisible(codeLabel);
      await tester.tap(codeLabel);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Create'));
      await tester.tap(find.text('Create'));
      await settleDatabase(tester);
      expect(find.text('Personal ($code)'), findsOneWidget);
      expect(find.text('Hi there, friend!'), findsNothing);
      expect(find.byTooltip('Settings and tracker management'), findsOneWidget);
      final profile = await tester.runAsync(
        () => db.select(db.profiles).getSingle(),
      );
      expect(profile!.currencyCode, code);
      expect(profile.currencyScale, scale);
      await tester.tap(find.byKey(const Key('add-transaction')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Amount ($code)'),
        scale == 0 ? '123' : (scale == 3 ? '12.345' : '12.34'),
      );
      await tester.tap(find.text('Save'));
      await settleDatabase(tester);
      final transaction = await tester.runAsync(
        () => db.select(db.transactions).getSingle(),
      );
      expect(
        transaction!.amountMinor,
        scale == 0 ? 123 : (scale == 3 ? 12345 : 1234),
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  }

  testWidgets('Empty installation offers profile creation', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [profilesProvider.overrideWith((ref) => Stream.value([]))],
        child: const ExpenseTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Create your first profile'), findsOneWidget);
    await tester.ensureVisible(find.text('Create your first profile'));
    await tester.tap(find.text('Create your first profile'));
    await tester.pumpAndSettle();
    expect(find.text('Create local profile'), findsOneWidget);
    await tester.ensureVisible(find.text('Create'));
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a profile name.'), findsOneWidget);
  });

  testWidgets(
    'Adding a profile uses the shared form and selects the saved profile',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      await tester.runAsync(
        () => LocalProfileRepository(db).create(
          const LocalProfile(
            id: 'existing',
            name: 'Personal',
            currencyCode: 'USD',
            currencyScale: 2,
          ),
        ),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const ExpenseTrackerApp(),
        ),
      );
      await settleDatabase(tester);
      await tester.tap(find.byKey(const Key('dashboard-tab-3')));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Create profile'));
      await tester.pumpAndSettle();
      expect(find.text('CHOOSE AVATAR'), findsOneWidget);
      await tester.tap(find.byTooltip('Close profile creation'));
      await tester.pumpAndSettle();
      expect(find.text('Personal (USD)'), findsOneWidget);
      await tester.tap(find.byTooltip('Create profile'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('avatar-kuma')));
      await tester.enterText(find.byType(TextFormField), 'Travel');
      await tester.ensureVisible(
        find.byKey(const ValueKey('quick-currency-EUR')),
      );
      await tester.tap(find.byKey(const ValueKey('quick-currency-EUR')));
      await tester.ensureVisible(find.text('Create'));
      await tester.tap(find.text('Create'));
      await settleDatabase(tester);
      expect(find.text('Travel (EUR)'), findsOneWidget);
      expect(
        tester
            .widget<ProfileAvatarIcon>(
              find.descendant(
                of: find.byType(ProfileSelector),
                matching: find.byType(ProfileAvatarIcon),
              ),
            )
            .avatar,
        ProfileAvatar.kuma,
      );
      final profiles = await tester.runAsync(
        () => LocalProfileRepository(db).watchProfiles().first,
      );
      expect(profiles, hasLength(2));
      expect(
        profiles!.singleWhere((profile) => profile.name == 'Travel').avatar,
        ProfileAvatar.kuma,
      );
      expect(
        profiles.singleWhere((profile) => profile.id == 'existing').avatar,
        ProfileAvatar.neko,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

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

  testWidgets(
    'Failed creation preserves active profile and deletion selects a survivor',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      await tester.runAsync(() async {
        for (final (id, avatar) in [
          ('Personal', ProfileAvatar.neko),
          ('Travel', ProfileAvatar.piggy),
        ]) {
          await LocalProfileRepository(db).create(
            LocalProfile(
              id: id,
              name: id,
              currencyCode: 'USD',
              currencyScale: 2,
              avatar: avatar,
            ),
          );
        }
        await db.customStatement(
          "CREATE TRIGGER reject_profile_insert BEFORE INSERT ON profiles "
          "BEGIN SELECT RAISE(ABORT, 'storage unavailable'); END",
        );
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const ExpenseTrackerApp(),
        ),
      );
      await settleDatabase(tester);
      await tester.tap(find.text('Personal (USD)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Travel (USD)').last);
      await settleDatabase(tester);
      await tester.tap(find.byKey(const Key('dashboard-tab-3')));
      await tester.pumpAndSettle();
      final add = tester
          .widget<IconButton>(
            find.ancestor(
              of: find.byTooltip('Create profile'),
              matching: find.byType(IconButton),
            ),
          )
          .onPressed!;
      add();
      add();
      await tester.pumpAndSettle();
      expect(find.text('Create local profile'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'Rejected');
      await tester.ensureVisible(find.text('Create'));
      await tester.tap(find.text('Create'));
      await settleDatabase(tester);
      expect(find.textContaining('Could not create profile:'), findsOneWidget);
      await tester.ensureVisible(find.text('Cancel'));
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Travel (USD)'), findsOneWidget);
      expect(
        tester
            .widget<ProfileAvatarIcon>(
              find.descendant(
                of: find.byType(ProfileSelector),
                matching: find.byType(ProfileAvatarIcon),
              ),
            )
            .avatar,
        ProfileAvatar.piggy,
      );
      expect(
        await tester.runAsync(() => db.select(db.profiles).get()),
        hasLength(2),
      );
      await tester.tap(find.byKey(const Key('delete-profile')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Confirmation'),
        'DELETE',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm-delete-profile')));
      await settleDatabase(tester);
      expect(find.text('Personal (USD)'), findsOneWidget);
      expect(find.text('Hi there, friend!'), findsNothing);
      expect(
        tester
            .widget<ProfileAvatarIcon>(
              find.descendant(
                of: find.byType(ProfileSelector),
                matching: find.byType(ProfileAvatarIcon),
              ),
            )
            .avatar,
        ProfileAvatar.neko,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'Profile deletion requires exact DELETE and cancellation preserves data',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      await tester.runAsync(() async {
        await LocalProfileRepository(db).create(
          const LocalProfile(
            id: 'profile',
            name: 'Personal',
            currencyCode: 'USD',
            currencyScale: 2,
          ),
        );
        await LocalTransactionRepository(db).save(
          FinancialTransaction(
            id: 'transaction',
            profileId: 'profile',
            notes: 'Lunch',
            amountMinor: 1250,
            type: TransactionType.expense,
            categoryId: 'groceries',
            occurredAt: DateTime.now(),
          ),
        );
      });
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: const ExpenseTrackerApp(),
        ),
      );
      await settleDatabase(tester);
      await tester.tap(find.byKey(const Key('dashboard-tab-3')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const Key('delete-profile')),
        200,
      );
      await tester.tap(find.byKey(const Key('delete-profile')));
      await tester.pumpAndSettle();
      expect(find.text('Permanently delete profile?'), findsOneWidget);
      expect(
        find.textContaining('permanently erase all of its'),
        findsOneWidget,
      );
      final confirmationButton = tester.widget<FilledButton>(
        find.byKey(const Key('confirm-delete-profile')),
      );
      expect(confirmationButton.onPressed, isNull);
      await tester.enterText(
        find.widgetWithText(TextField, 'Confirmation'),
        'delete',
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const Key('confirm-delete-profile')),
            )
            .onPressed,
        isNull,
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(
        await tester.runAsync(() => db.select(db.profiles).get()),
        hasLength(1),
      );
      expect(
        await tester.runAsync(() => db.select(db.transactions).get()),
        hasLength(1),
      );

      await tester.tap(find.byKey(const Key('delete-profile')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Confirmation'),
        'DELETE',
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(
              find.byKey(const Key('confirm-delete-profile')),
            )
            .onPressed,
        isNotNull,
      );
      await tester.tap(find.byKey(const Key('confirm-delete-profile')));
      await settleDatabase(tester);
      expect(find.text('Create your first profile'), findsOneWidget);
      expect(find.text('Hi there, friend!'), findsOneWidget);
      expect(
        await tester.runAsync(() => db.select(db.profiles).get()),
        isEmpty,
      );
      expect(
        await tester.runAsync(() => db.select(db.transactions).get()),
        isEmpty,
      );
      expect(
        await tester.runAsync(() => db.select(db.categories).get()),
        isEmpty,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );

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
    await tester.ensureVisible(find.text('Create your first profile'));
    await tester.tap(find.text('Create your first profile'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Personal');
    await tester.ensureVisible(find.text('Create'));
    await tester.tap(find.text('Create'));
    await settleDatabase(tester);
    expect(find.text('Personal (USD)'), findsOneWidget);
    final profile = await tester.runAsync(
      () => db.select(db.profiles).getSingle(),
    );
    expect(isUuidV7(profile!.profileId), isTrue);
    await tester.tap(find.byKey(const Key('dashboard-tab-3')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('manage-categories')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add category'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Category name'),
      'Streaming',
    );
    final budgetField = find.byKey(const Key('category-budget-bucket'));
    await tester.ensureVisible(budgetField);
    await tester.tap(
      find.descendant(
        of: budgetField,
        matching: find.byType(DropdownButton<String>),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wants').last);
    await tester.pumpAndSettle();
    final iconOption = find.byKey(
      const ValueKey('category-icon-subscriptions'),
    );
    await tester.ensureVisible(iconOption);
    await tester.tap(iconOption);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save category'));
    await settleDatabase(tester);
    expect(find.text('Manage categories'), findsWidgets);
    final streaming = await tester.runAsync(
      () => (db.select(
        db.categories,
      )..where((row) => row.name.equals('Streaming'))).getSingle(),
    );
    expect(streaming!.type, 'expense');
    expect(streaming.defaultBudgetBucket, 'wants');
    expect(streaming.iconKey, 'subscriptions');
    expect(streaming.colorArgb, 0xFF455A64);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-transaction')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Notes (optional)'),
      'Lunch with a friend',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Amount (USD)'),
      '12.50',
    );
    await tester.tap(find.text('Save'));
    await settleDatabase(tester);
    await tester.tap(find.byKey(const Key('dashboard-tab-0')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Lunch with a friend'), 200);
    expect(find.text('Lunch with a friend'), findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, 1200));
    await tester.pumpAndSettle();
    expect(find.text(r'-$12.50'), findsWidgets);
    final transaction = await tester.runAsync(
      () => db.select(db.transactions).getSingle(),
    );
    expect(isUuidV7(transaction!.transactionId), isTrue);
    await tester.ensureVisible(find.text('Set monthly budget'));
    await tester.tap(find.text('Set monthly budget'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Needs (%)'), '60');
    await tester.enterText(find.widgetWithText(TextField, 'Wants (%)'), '20');
    await tester.tap(find.text('Save budget'));
    await settleDatabase(tester);
    await tester.tap(find.byKey(const Key('dashboard-tab-2')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Needs (60.0%)'), 200);
    expect(find.text('Needs (60.0%)'), findsOneWidget);
    expect(find.textContaining('No income this month'), findsOneWidget);
    await tester.tap(find.byKey(const Key('add-transaction')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Notes (optional)'),
      'Salary',
    );
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
    await tester.scrollUntilVisible(find.text(r'$12.50 of $200.00'), 200);
    expect(find.text(r'$12.50 of $200.00'), findsOneWidget);
    expect(find.textContaining('No income this month'), findsNothing);
    expect(
      await tester.runAsync(() => db.select(db.budgets).get()),
      hasLength(1),
    );
    final streamingAllocation = await tester.runAsync(
      () =>
          (db.select(db.budgetCategoryAllocations)
                ..where((row) => row.categoryId.equals(streaming.categoryId)))
              .getSingle(),
    );
    expect(streamingAllocation!.bucketId, 'wants');
    final budget = await tester.runAsync(
      () => db.select(db.budgets).getSingle(),
    );
    expect(isUuidV7(budget!.budgetId), isTrue);
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
              avatar: id == 'Personal'
                  ? ProfileAvatar.neko
                  : ProfileAvatar.boba,
            ),
          );
          await LocalTransactionRepository(db).save(
            FinancialTransaction(
              id: 'same-id',
              profileId: id,
              notes: '$id purchase',
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
      await tester.scrollUntilVisible(find.text('Personal purchase'), 200);
      expect(find.text('Personal purchase'), findsOneWidget);
      expect(find.text('Household purchase'), findsNothing);
      await tester.tap(find.text('Personal (USD)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Household (USD)').last);
      await settleDatabase(tester);
      await tester.scrollUntilVisible(find.text('Household purchase'), 200);
      expect(find.text('Household purchase'), findsOneWidget);
      expect(find.text('Personal purchase'), findsNothing);
      await tester.drag(find.byType(ListView).first, const Offset(0, 1200));
      await tester.pumpAndSettle();
      expect(find.text(r'-$2.00'), findsWidgets);
      expect(
        tester
            .widget<ProfileAvatarIcon>(
              find.descendant(
                of: find.byType(ProfileSelector),
                matching: find.byType(ProfileAvatarIcon),
              ),
            )
            .avatar,
        ProfileAvatar.boba,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
