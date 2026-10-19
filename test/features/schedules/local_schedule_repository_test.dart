import 'dart:io';

import 'package:drift/native.dart';
import 'package:expense_tracker_app/core/database/app_database.dart'
    hide TransactionSchedule;
import 'package:expense_tracker_app/core/ids/id_generator.dart';
import 'package:expense_tracker_app/features/profiles/data/local_profile_repository.dart';
import 'package:expense_tracker_app/features/profiles/domain/profile.dart';
import 'package:expense_tracker_app/features/schedules/data/local_schedule_repository.dart';
import 'package:expense_tracker_app/features/schedules/domain/transaction_schedule.dart';
import 'package:expense_tracker_app/features/transactions/data/repositories/local_transaction_repository.dart';
import 'package:expense_tracker_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

TransactionSchedule entry({
  String id = 'schedule',
  String profileId = 'a',
  bool automatic = true,
  RepeatUnit unit = RepeatUnit.month,
  DateTime? start,
  DateTime? end,
  String category = 'housing',
  int amount = 10000,
  int interval = 1,
}) => TransactionSchedule(
  id: id,
  profileId: profileId,
  name: 'Rent',
  notes: 'Scheduled rent',
  amountMinor: amount,
  type: TransactionType.expense,
  categoryId: category,
  startDate: start ?? DateTime(2026, 1, 31),
  endDate: end,
  automatic: automatic,
  repeatUnit: unit,
  interval: interval,
);

void main() {
  late AppDatabase db;
  late LocalScheduleRepository repo;
  late LocalProfileRepository profiles;
  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = LocalScheduleRepository(db, UuidV7IdGenerator());
    profiles = LocalProfileRepository(db);
    for (final id in ['a', 'b']) {
      await profiles.create(
        LocalProfile(id: id, name: id, currencyCode: 'USD', currencyScale: 2),
      );
    }
  });
  tearDown(() => db.close());

  test(
    'Savings schedules post savings transactions rather than expenses',
    () async {
      await repo.save(
        TransactionSchedule(
          id: 'retirement',
          profileId: 'a',
          name: 'Retirement',
          amountMinor: 20000,
          type: TransactionType.savings,
          categoryId: 'retirement',
          startDate: DateTime(2026, 10, 1),
          repeatUnit: RepeatUnit.month,
          automatic: true,
        ),
      );
      await repo.processDue('a', DateTime(2026, 11, 1));
      final entries = await db.select(db.transactions).get();
      expect(entries, hasLength(2));
      expect(
        entries.every(
          (row) => row.type == 'savings' && row.categoryId == 'retirement',
        ),
        isTrue,
      );
      await expectLater(
        repo.save(
          TransactionSchedule(
            id: 'reserved',
            profileId: 'a',
            name: 'Unused',
            amountMinor: 100,
            type: TransactionType.savings,
            categoryId: TransactionCategory.unusedMoneyId,
            startDate: DateTime(2026, 10),
          ),
        ),
        throwsStateError,
      );
    },
  );
  test('Schedule validation rejects unavailable profiles and mismatched categories', () async {
    await expectLater(repo.save(entry(profileId: 'missing')), throwsStateError);
    await expectLater(repo.save(entry(category: 'salary')), throwsStateError);
    await profiles.setArchived(
      profileId: 'a',
      categoryId: 'housing',
      archived: true,
    );
    await expectLater(repo.save(entry()), throwsStateError);
    expect(await db.select(db.transactionSchedules).get(), isEmpty);
  });

  test(
    'Canceled schedules never post again and retain already posted history',
    () async {
      await repo.save(entry());
      await repo.processDue('a', DateTime(2026, 1, 31));
      await repo.delete(profileId: 'a', scheduleId: 'schedule');
      await repo.processDue('a', DateTime(2026, 5));
      expect(await repo.watchSchedules('a').first, isEmpty);
      expect(await db.select(db.transactions).get(), hasLength(1));
      await expectLater(repo.save(entry()), throwsStateError);
    },
  );

  test('Automatic catch-up posts each due date exactly once under concurrent processing', () async {
    await repo.save(entry());
    await Future.wait([
      repo.processDue('a', DateTime(2026, 3, 31)),
      repo.processDue('a', DateTime(2026, 3, 31)),
    ]);
    final transactions = await LocalTransactionRepository(db)
        .watchTransactions('a')
        .first;
    expect(transactions, hasLength(3));
    expect(transactions.map((row) => row.occurredAt.toLocal().day).toList(), [
      31,
      28,
      31,
    ]);
    expect(
      transactions.every(
        (row) => row.amountMinor == 10000 && row.categoryId == 'housing',
      ),
      isTrue,
    );
    expect(
      transactions.every((row) => RegExp(r'^[0-9a-f-]{14}7').hasMatch(row.id)),
      isTrue,
    );
    expect(await db.select(db.scheduleOccurrences).get(), hasLength(3));
    expect(
      (await repo.watchSchedules('a').first).single.nextDate,
      DateTime.utc(2026, 4, 30),
    );
    await LocalTransactionRepository(db)
        .delete(profileId: 'a', transactionId: transactions.first.id);
    await repo.processDue('a', DateTime(2026, 3, 31));
    expect(
      await LocalTransactionRepository(db).watchTransactions('a').first,
      hasLength(2),
    );
  });

  test('Planned entries do not affect totals until confirmed and skips are durable', () async {
    await repo.save(entry(automatic: false));
    await repo.processDue('a', DateTime(2026, 3, 31));
    expect(await db.select(db.transactions).get(), isEmpty);
    await repo.resolve(
      profileId: 'a',
      scheduleId: 'schedule',
      expectedIndex: 0,
      now: DateTime(2026, 3, 31),
      skip: false,
    );
    await expectLater(
      repo.resolve(
        profileId: 'a',
        scheduleId: 'schedule',
        expectedIndex: 0,
        now: DateTime(2026, 3, 31),
        skip: false,
      ),
      throwsStateError,
    );
    await repo.resolve(
      profileId: 'a',
      scheduleId: 'schedule',
      expectedIndex: 1,
      now: DateTime(2026, 3, 31),
      skip: true,
    );
    expect(await db.select(db.transactions).get(), hasLength(1));
    expect((await repo.watchSchedules('a').first).single.nextIndex, 2);
    final occurrences = await db.select(db.scheduleOccurrences).get();
    expect(occurrences.last.transactionId, isNull);
  });

  test(
    'One-time completion, end dates, pause and resume are enforced',
    () async {
      await repo.save(entry(unit: RepeatUnit.once));
      await repo.setPaused(
        profileId: 'a',
        scheduleId: 'schedule',
        paused: true,
      );
      await repo.processDue('a', DateTime(2026, 5));
      expect(await db.select(db.transactions).get(), isEmpty);
      await repo.setPaused(
        profileId: 'a',
        scheduleId: 'schedule',
        paused: false,
      );
      await repo.processDue('a', DateTime(2026, 5));
      expect((await repo.watchSchedules('a').first).single.nextDate, isNull);
      await repo.save(entry(id: 'ended', end: DateTime(2026, 2, 28)));
      await repo.processDue('a', DateTime(2026, 5));
      expect(await db.select(db.transactions).get(), hasLength(3));
      expect(
        (await repo.watchSchedules('a').first).every(
          (row) => row.nextDate == null,
        ),
        isTrue,
      );
    },
  );

  test('Future dates cannot be confirmed early', () async {
    await repo.save(entry(automatic: false));
    await expectLater(
      repo.resolve(
        profileId: 'a',
        scheduleId: 'schedule',
        expectedIndex: 0,
        now: DateTime(2026, 1, 30),
        skip: false,
      ),
      throwsStateError,
    );
    expect(await db.select(db.transactions).get(), isEmpty);
  });

  test('Editing affects unposted entries only and cannot reset the recurrence cursor', () async {
    await repo.save(entry());
    await repo.processDue('a', DateTime(2026, 1, 31));
    await repo.save(entry(amount: 20000));
    expect((await repo.watchSchedules('a').first).single.nextIndex, 1);
    await repo.processDue('a', DateTime(2026, 2, 28));
    final amounts =
        (await db.select(db.transactions).get())
            .map((row) => row.amountMinor)
            .toList()
          ..sort();
    expect(amounts, [10000, 20000]);
    await expectLater(repo.save(entry(interval: 2)), throwsStateError);
  });

  test('Archived categories block posting with explicit errors and can be corrected', () async {
    await repo.save(entry());
    await profiles.setArchived(
      profileId: 'a',
      categoryId: 'housing',
      archived: true,
    );
    await expectLater(
      repo.processDue('a', DateTime(2026, 2, 28)),
      throwsStateError,
    );
    expect(await db.select(db.transactions).get(), isEmpty);
    expect((await repo.watchSchedules('a').first).single.nextIndex, 0);
    await repo.save(entry(category: 'groceries'));
    await repo.processDue('a', DateTime(2026, 2, 28));
    expect(await db.select(db.transactions).get(), hasLength(2));
  });

  test(
    'Posting failure rolls back transactions, occurrence ledger and cursor',
    () async {
      await repo.save(entry());
      await db.customStatement('''
      CREATE TRIGGER fail_occurrence BEFORE INSERT ON schedule_occurrences
      BEGIN SELECT RAISE(ABORT, 'Test failure'); END
    ''');
      await expectLater(
        repo.processDue('a', DateTime(2026, 2, 28)),
        throwsStateError,
      );
      expect(await db.select(db.transactions).get(), isEmpty);
      expect(await db.select(db.scheduleOccurrences).get(), isEmpty);
      expect((await repo.watchSchedules('a').first).single.nextIndex, 0);
    },
  );

  test('Failures in one schedule do not stop other schedules', () async {
    await repo.save(entry());
    await repo.save(entry(id: 'other', category: 'groceries'));
    await profiles.setArchived(
      profileId: 'a',
      categoryId: 'housing',
      archived: true,
    );
    await expectLater(
      repo.processDue('a', DateTime(2026, 1, 31)),
      throwsStateError,
    );
    expect(
      (await db.select(db.transactions).get()).single.categoryId,
      'groceries',
    );
  });

  test('Profile isolation, cancellation and category/profile deletion include schedules', () async {
    await repo.save(entry());
    await repo.save(entry(profileId: 'b'));
    await repo.processDue('a', DateTime(2026, 1, 31));
    expect(
      await LocalTransactionRepository(db).watchTransactions('b').first,
      isEmpty,
    );
    await expectLater(
      repo.delete(profileId: 'missing', scheduleId: 'schedule'),
      throwsStateError,
    );
    expect(
      await profiles.canDelete(profileId: 'b', categoryId: 'housing'),
      isFalse,
    );
    await repo.delete(profileId: 'b', scheduleId: 'schedule');
    await profiles.delete(profileId: 'b', categoryId: 'housing');
    expect(await repo.watchSchedules('b').first, isEmpty);
    await profiles.deletePermanently('a');
    expect(await db.select(db.transactionSchedules).get(), isEmpty);
    expect(await db.select(db.scheduleOccurrences).get(), isEmpty);
    expect(await db.select(db.transactions).get(), isEmpty);
  });

  test('Restart preserves automatic posting cursor and prevents duplicate catch-up', () async {
    await db.close();
    final directory = await Directory.systemTemp.createTemp('schedule_test_');
    final file = File('${directory.path}${Platform.pathSeparator}test.sqlite');
    var persistent = AppDatabase.forTesting(NativeDatabase(file));
    try {
      await LocalProfileRepository(persistent).create(
        const LocalProfile(
          id: 'a',
          name: 'a',
          currencyCode: 'USD',
          currencyScale: 2,
        ),
      );
      var schedules = LocalScheduleRepository(persistent, UuidV7IdGenerator());
      await schedules.save(entry());
      await schedules.processDue('a', DateTime(2026, 1, 31));
      await persistent.close();
      persistent = AppDatabase.forTesting(NativeDatabase(file));
      schedules = LocalScheduleRepository(persistent, UuidV7IdGenerator());
      await schedules.processDue('a', DateTime(2026, 2, 28));
      expect(
        await persistent.select(persistent.transactions).get(),
        hasLength(2),
      );
      expect(
        await persistent.select(persistent.scheduleOccurrences).get(),
        hasLength(2),
      );
    } finally {
      await persistent.close();
      await directory.delete(recursive: true);
    }
  });
}
