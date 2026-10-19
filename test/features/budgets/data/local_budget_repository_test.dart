import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:expense_tracker_app/core/database/app_database.dart' hide BudgetBucket;
import 'package:expense_tracker_app/features/budgets/data/local_budget_repository.dart';
import 'package:expense_tracker_app/features/budgets/domain/entities/budget_rule.dart';
import 'package:expense_tracker_app/features/profiles/data/local_profile_repository.dart';
import 'package:expense_tracker_app/features/profiles/domain/profile.dart';
import 'package:flutter_test/flutter_test.dart';

BudgetRule rule({String profile = 'a', String id = 'budget', String category = 'groceries', bool move = false}) => BudgetRule(
  id: id, profileId: profile, name: 'Monthly',
  periodStart: DateTime.utc(2026, 10), periodEnd: DateTime.utc(2026, 11),
  buckets: [
    BudgetBucket(id: 'needs', name: 'Needs', allocationBps: 5000, categoryIds: move ? [] : [category]),
    BudgetBucket(id: 'wants', name: 'Wants', allocationBps: 3000, categoryIds: move ? [category] : []),
    BudgetBucket(id: 'savings', name: 'Savings', allocationBps: 2000),
  ],
);

Future<void> createProfile(AppDatabase db, String id) =>
    LocalProfileRepository(db).create(LocalProfile(id: id, name: id, currencyCode: 'USD', currencyScale: 2));

void main() {
  late AppDatabase db;
  late LocalBudgetRepository repository;
  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LocalBudgetRepository(db);
    await createProfile(db, 'a');
    await createProfile(db, 'b');
  });
  tearDown(() => db.close());

  test('Atomically round trips buckets and category links per profile', () async {
    await repository.save(rule());
    await repository.save(rule(profile: 'b'));
    final saved = (await repository.watchBudgets('a').first).single;
    expect(saved.buckets.fold(0, (sum, bucket) => sum + bucket.allocationBps), 10000);
    expect(saved.buckets.firstWhere((bucket) => bucket.id == 'needs').categoryIds, {'groceries'});
    expect(await repository.watchBudgets('b').first, hasLength(1));
  });

  test('Reassigns categories and increments revisions while clearing sync flags', () async {
    await repository.save(rule());
    await db.update(db.budgets).write(const BudgetsCompanion(isSynced: Value(1)));
    await db.update(db.budgetBuckets).write(const BudgetBucketsCompanion(isSynced: Value(1)));
    await repository.save(rule(move: true));
    final saved = (await repository.watchBudgets('a').first).single;
    expect(saved.buckets.firstWhere((bucket) => bucket.id == 'wants').categoryIds, {'groceries'});
    final parent = await db.select(db.budgets).getSingle();
    expect(parent.localRevision, 2);
    expect(parent.isSynced, 0);
    final buckets = await db.select(db.budgetBuckets).get();
    expect(buckets.every((bucket) => bucket.localRevision == 2 && bucket.isSynced == 0), isTrue);
  });

  test('Rejects overlapping budgets but allows independent profiles', () async {
    await repository.save(rule());
    await expectLater(repository.save(rule(id: 'overlap')), throwsStateError);
    await repository.save(rule(profile: 'b'));
    expect(await repository.watchBudgets('a').first, hasLength(1));
  });

  test('Rejects income and foreign categories without partial writes', () async {
    await expectLater(repository.save(rule(category: 'salary')), throwsArgumentError);
    await db.customStatement(
      "INSERT INTO categories (profile_id, category_id, name, type, created_at, updated_at) "
      "VALUES ('b', 'private', 'Private', 'expense', 0, 0)",
    );
    await expectLater(repository.save(rule(category: 'private')), throwsArgumentError);
    expect(await db.select(db.budgets).get(), isEmpty);
    expect(await db.select(db.budgetBuckets).get(), isEmpty);
  });

  test('Rolls back the entire matrix when a child write fails', () async {
    await db.customStatement(
      "CREATE TRIGGER reject_bucket BEFORE INSERT ON budget_buckets "
      "WHEN NEW.bucket_id = 'wants' BEGIN SELECT RAISE(ABORT, 'test failure'); END",
    );
    await expectLater(repository.save(rule()), throwsA(isA<Exception>()));
    expect(await db.select(db.budgets).get(), isEmpty);
    expect(await db.select(db.budgetBuckets).get(), isEmpty);
    expect(await db.select(db.budgetCategoryAllocations).get(), isEmpty);
  });

  test('Tombstones all children without affecting another profile', () async {
    await repository.save(rule());
    await repository.save(rule(profile: 'b'));
    await repository.delete(profileId: 'a', budgetId: 'budget');
    expect(await repository.watchBudgets('a').first, isEmpty);
    expect(await repository.watchBudgets('b').first, hasLength(1));
    final buckets = await (db.select(db.budgetBuckets)..where((row) => row.profileId.equals('a'))).get();
    expect(buckets.every((row) => row.deletedAt != null && row.isSynced == 0), isTrue);
    await expectLater(repository.delete(profileId: 'a', budgetId: 'budget'), throwsStateError);
    await repository.save(rule());
    expect(await repository.watchBudgets('a').first, hasLength(1));
  });

  test('Profile creation includes isolated starter categories and rejects duplicates', () async {
    final profiles = LocalProfileRepository(db);
    expect(await profiles.watchProfiles().first, hasLength(2));
    expect(await profiles.watchCategories('a').first, hasLength(12));
    await expectLater(createProfile(db, 'a'), throwsA(isA<Exception>()));
    expect(await profiles.watchProfiles().first, hasLength(2));
  });

  test('File-backed database survives close and reopen', () async {
    await db.close();
    final directory = await Directory.systemTemp.createTemp('expense_tracker_test_');
    final file = File('${directory.path}${Platform.pathSeparator}expenses.sqlite');
    var persistent = AppDatabase.forTesting(NativeDatabase(file));
    try {
      await createProfile(persistent, 'persisted');
      await LocalBudgetRepository(persistent).save(rule(profile: 'persisted'));
      await persistent.close();
      persistent = AppDatabase.forTesting(NativeDatabase(file));
      expect((await LocalProfileRepository(persistent).watchProfiles().first).single.id, 'persisted');
      expect(await LocalBudgetRepository(persistent).watchBudgets('persisted').first, hasLength(1));
    } finally {
      await persistent.close();
      await directory.delete(recursive: true);
    }
  });
}
