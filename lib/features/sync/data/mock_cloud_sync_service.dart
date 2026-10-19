import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../transactions/domain/entities/financial_transaction.dart';
import '../domain/sync_repository.dart';

/// Development-only preview: never acknowledges or applies changes to SQLite.
class MockCloudSyncService implements SyncRepository {
  MockCloudSyncService(this._database, {Iterable<SyncTransaction> remoteChanges = const []}) {
    for (final change in remoteChanges) {
      _append(change);
    }
  }

  final AppDatabase _database;
  final _remote = <String, Map<String, SyncTransaction>>{};
  final _logs = <String, List<SyncTransaction>>{};

  void _append(SyncTransaction change) {
    final profile = change.transaction.profileId;
    _remote.putIfAbsent(profile, () => {})[change.transaction.id] = change;
    _logs.putIfAbsent(profile, () => []).add(change);
  }

  void _requireProfile(String id) {
    if (id.trim().isEmpty) throw ArgumentError('A profile is required.');
  }

  SyncTransaction _map(Transaction row) => SyncTransaction(
    transaction: FinancialTransaction(
      id: row.transactionId,
      profileId: row.profileId,
      notes: row.notes,
      amountMinor: row.amountMinor,
      type: TransactionType.values.byName(row.type),
      categoryId: row.categoryId,
      occurredAt: DateTime.fromMillisecondsSinceEpoch(row.occurredAt, isUtc: true),
    ),
    localRevision: row.localRevision,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt, isUtc: true),
    deletedAt: row.deletedAt == null ? null : DateTime.fromMillisecondsSinceEpoch(row.deletedAt!, isUtc: true),
  );

  @override
  Future<SyncResult> uploadUnsyncedTransactions({required String profileId}) async {
    _requireProfile(profileId);
    final pending = await (_database.select(_database.transactions)
      ..where((row) => row.profileId.equals(profileId) & row.isSynced.equals(0)))
        .get();
    final changes = <SyncTransaction>[];
    final conflicts = <SyncConflict>[];
    for (final row in pending) {
      final local = _map(row);
      final remote = _remote[profileId]?[row.transactionId];
      if (remote != null && !local.sameContent(remote)) {
        conflicts.add(SyncConflict(local: local, remote: remote));
      } else if (remote == null) {
        _append(local);
        changes.add(local);
      }
    }
    return SyncResult(isPreview: true, changes: changes, conflicts: conflicts);
  }

  @override
  Future<SyncResult> downloadRemoteChanges({required String profileId, String? cursor}) async {
    _requireProfile(profileId);
    final log = _logs[profileId] ?? [];
    var offset = 0;
    if (cursor != null) {
      final prefix = '$profileId:';
      final parsed = cursor.startsWith(prefix) ? int.tryParse(cursor.substring(prefix.length)) : null;
      if (parsed == null || parsed < 0 || parsed > log.length) {
        throw ArgumentError('Invalid or cross-profile mock sync cursor.');
      }
      offset = parsed;
    }
    final rows = await (_database.select(_database.transactions)
      ..where((row) => row.profileId.equals(profileId))).get();
    final local = {for (final row in rows) row.transactionId: row};
    final changes = <SyncTransaction>[];
    final conflicts = <SyncConflict>[];
    final deltaIds = log.skip(offset).map((change) => change.transaction.id).toSet();
    for (final id in deltaIds) {
      final remote = _remote[profileId]![id]!;
      final row = local[id];
      if (row != null && !remote.sameContent(_map(row))) {
        conflicts.add(SyncConflict(local: _map(row), remote: remote));
      } else if (row == null) {
        changes.add(remote);
      }
    }
    return SyncResult(
      isPreview: true, changes: changes, conflicts: conflicts,
      nextCursor: '$profileId:${log.length}',
    );
  }
}
