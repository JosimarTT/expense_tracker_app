import 'package:drift/native.dart';
import 'package:expense_tracker_app/core/database/app_database.dart';
import 'package:expense_tracker_app/features/profiles/data/local_profile_repository.dart';
import 'package:expense_tracker_app/features/profiles/domain/profile.dart';
import 'package:expense_tracker_app/features/sync/data/mock_cloud_sync_service.dart';
import 'package:expense_tracker_app/features/sync/domain/sync_repository.dart';
import 'package:expense_tracker_app/features/transactions/data/repositories/local_transaction_repository.dart';
import 'package:expense_tracker_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

FinancialTransaction transaction(String id, String profile, [int amount = 100]) => FinancialTransaction(
  id: id, profileId: profile, notes: id, amountMinor: amount,
  type: TransactionType.expense, categoryId: 'groceries',
  occurredAt: DateTime.utc(2026, 10, 1),
);

SyncTransaction remote(String id, String profile) => SyncTransaction(
  transaction: transaction(id, profile, 200),
  localRevision: 1, updatedAt: DateTime.utc(2026, 10, 2),
);

void main() {
  late AppDatabase db;
  late LocalTransactionRepository repository;
  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LocalTransactionRepository(db);
    for (final id in ['a', 'b']) {
      await LocalProfileRepository(db).create(LocalProfile(
        id: id, name: id, currencyCode: 'USD', currencyScale: 2,
      ));
    }
  });
  tearDown(() => db.close());

  test('Upload previews only selected-profile dirty rows including tombstones', () async {
    await repository.save(transaction('a1', 'a'));
    await repository.save(transaction('a2', 'a'));
    await repository.delete(profileId: 'a', transactionId: 'a2');
    await repository.save(transaction('b1', 'b'));
    await repository.save(transaction('synced', 'a'));
    await db.customStatement("UPDATE transactions SET is_synced = 1 WHERE transaction_id = 'synced'");
    final service = MockCloudSyncService(db);
    final result = await service.uploadUnsyncedTransactions(profileId: 'a');
    expect(result.isPreview, isTrue);
    expect(result.changes.map((change) => change.transaction.id).toSet(), {'a1', 'a2'});
    expect(result.changes.firstWhere((change) => change.transaction.id == 'a2').deletedAt, isNotNull);
    expect((await service.uploadUnsyncedTransactions(profileId: 'a')).changes, isEmpty);
    final rows = await db.select(db.transactions).get();
    expect(rows.where((row) => row.transactionId != 'synced').every((row) => row.isSynced == 0), isTrue);
  });

  test('Divergent local and remote rows are conflicts, regardless of timestamp', () async {
    await repository.save(transaction('same', 'a'));
    final service = MockCloudSyncService(db, remoteChanges: [remote('same', 'a')]);
    final upload = await service.uploadUnsyncedTransactions(profileId: 'a');
    expect(upload.conflicts, hasLength(1));
    expect(upload.changes, isEmpty);
    final download = await service.downloadRemoteChanges(profileId: 'a');
    expect(download.conflicts, hasLength(1));
    expect((await repository.watchTransactions('a').first).single.amountMinor, 100);
  });

  test('Delta previews are scoped, cursor-based, and never apply remote records', () async {
    final service = MockCloudSyncService(db, remoteChanges: [
      remote('a-remote', 'a'), remote('b-remote', 'b'),
    ]);
    final first = await service.downloadRemoteChanges(profileId: 'a');
    expect(first.changes.single.transaction.profileId, 'a');
    expect(first.nextCursor, 'a:1');
    expect((await service.downloadRemoteChanges(profileId: 'a', cursor: first.nextCursor)).changes, isEmpty);
    await expectLater(
      service.downloadRemoteChanges(profileId: 'b', cursor: first.nextCursor),
      throwsArgumentError,
    );
    await expectLater(
      service.downloadRemoteChanges(profileId: 'a', cursor: 'a:999'),
      throwsArgumentError,
    );
    expect(await db.select(db.transactions).get(), isEmpty);
  });
}
