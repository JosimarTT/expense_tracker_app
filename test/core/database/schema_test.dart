import 'dart:io';

import 'package:drift/native.dart';
import 'package:expense_tracker_app/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    for (final profile in ['a', 'b']) {
      await database.customStatement(
        'INSERT INTO profiles '
        '(profile_id, name, currency_code, currency_scale, created_at, updated_at) '
        "VALUES (?, ?, 'USD', 2, 0, 0)",
        [profile, profile],
      );
      await database.customStatement(
        'INSERT INTO budgets '
        '(profile_id, budget_id, name, period_start, period_end, created_at, updated_at) '
        "VALUES (?, 'budget', 'Monthly', 0, 1, 0, 0)",
        [profile],
      );
      await database.customStatement(
        'INSERT INTO categories '
        '(profile_id, category_id, name, type, created_at, updated_at) '
        "VALUES (?, 'food', 'Food', 'expense', 0, 0)",
        [profile],
      );
    }
  });

  tearDown(() => database.close());

  Future<void> addBucket(String profile, String bucket, int bps) =>
      database.customStatement(
        'INSERT INTO budget_buckets '
        '(profile_id, budget_id, bucket_id, name, allocation_bps, created_at, updated_at) '
        "VALUES (?, 'budget', ?, ?, ?, 0, 0)",
        [profile, bucket, bucket, bps],
      );

  Future<void> link(String profile, String bucket) => database.customStatement(
    'INSERT INTO budget_category_allocations '
    '(profile_id, budget_id, bucket_id, category_id, created_at, updated_at) '
    "VALUES (?, 'budget', ?, 'food', 0, 0)",
    [profile, bucket],
  );

  Matcher constraintError(String constraint) => throwsA(
    predicate<Object>(
      (error) => error.toString().contains('$constraint constraint failed'),
    ),
  );

  test('Enables foreign keys on every database connection', () async {
    final row = await database.customSelect('PRAGMA foreign_keys').getSingle();
    expect(row.read<int>('foreign_keys'), 1);
  });

  test('Rejects cross-profile budget bucket references', () async {
    await addBucket('b', 'private', 10000);
    await expectLater(link('a', 'private'), constraintError('FOREIGN KEY'));
  });

  test(
    'A category belongs to one bucket per budget, independently per profile',
    () async {
      await addBucket('a', 'needs', 5000);
      await addBucket('a', 'wants', 5000);
      await addBucket('b', 'needs', 10000);
      await link('a', 'needs');
      await link('b', 'needs');
      await expectLater(link('a', 'wants'), constraintError('UNIQUE'));
    },
  );

  test(
    'Rejects invalid percentages and sync flags at the SQL boundary',
    () async {
      await expectLater(addBucket('a', 'bad', 10001), constraintError('CHECK'));
      await expectLater(
        database.customStatement('UPDATE profiles SET is_synced = 2'),
        constraintError('CHECK'),
      );
    },
  );

  test('Rejects zero amounts even when domain validation is bypassed', () async {
    await expectLater(
      database.customStatement(
        'INSERT INTO transactions '
        '(profile_id, transaction_id, notes, amount_minor, type, category_id, '
        'occurred_at, created_at, updated_at) '
        "VALUES ('a', 'tx', '', 0, 'expense', 'food', 0, 0, 0)",
      ),
      constraintError('CHECK'),
    );
  });

  test(
    'Creates the complete initial schema and preserves data on reopen',
    () async {
      await database.close();
      final directory = await Directory.systemTemp.createTemp(
        'expense_initial_schema_',
      );
      final file = File(
        '${directory.path}${Platform.pathSeparator}expenses.sqlite',
      );
      var prior = AppDatabase.forTesting(NativeDatabase(file));
      try {
        await prior
            .into(prior.profiles)
            .insert(
              ProfilesCompanion.insert(
                profileId: 'profile',
                name: 'Personal',
                currencyCode: 'USD',
                currencyScale: 2,
                createdAt: 0,
                updatedAt: 0,
              ),
            );
        expect(prior.schemaVersion, 1);
        expect(
          (await prior.customSelect('PRAGMA user_version').getSingle())
              .read<int>('user_version'),
          1,
        );
        final tables = await prior
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
            )
            .get();
        expect(tables.map((row) => row.read<String>('name')).toSet(), {
          'profiles',
          'categories',
          'transactions',
          'budgets',
          'budget_buckets',
          'budget_category_allocations',
          'transaction_schedules',
          'schedule_occurrences',
        });
        await prior.close();
        prior = AppDatabase.forTesting(NativeDatabase(file));
        expect(
          (await prior.select(prior.profiles).get()).single.name,
          'Personal',
        );
        expect(await prior.select(prior.categories).get(), isEmpty);
        expect(await prior.select(prior.transactions).get(), isEmpty);
        expect(await prior.select(prior.budgets).get(), isEmpty);
        expect(await prior.select(prior.transactionSchedules).get(), isEmpty);
        expect(await prior.select(prior.scheduleOccurrences).get(), isEmpty);
        expect(
          (await prior.customSelect('PRAGMA foreign_keys').getSingle())
              .read<int>('foreign_keys'),
          1,
        );
      } finally {
        await prior.close();
        await directory.delete(recursive: true);
      }
    },
  );
}
