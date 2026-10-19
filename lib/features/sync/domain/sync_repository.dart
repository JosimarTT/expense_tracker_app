import '../../transactions/domain/entities/financial_transaction.dart';

class SyncTransaction {
  const SyncTransaction({
    required this.transaction,
    required this.localRevision,
    required this.updatedAt,
    this.deletedAt,
  });

  final FinancialTransaction transaction;
  final int localRevision;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool sameContent(SyncTransaction other) =>
      transaction.id == other.transaction.id &&
      transaction.profileId == other.transaction.profileId &&
      transaction.notes == other.transaction.notes &&
      transaction.amountMinor == other.transaction.amountMinor &&
      transaction.type == other.transaction.type &&
      transaction.categoryId == other.transaction.categoryId &&
      transaction.occurredAt == other.transaction.occurredAt &&
      updatedAt == other.updatedAt &&
      deletedAt == other.deletedAt;
}

class SyncConflict {
  const SyncConflict({required this.local, required this.remote});
  final SyncTransaction local;
  final SyncTransaction remote;
}

class SyncResult {
  SyncResult({
    required this.isPreview,
    required Iterable<SyncTransaction> changes,
    required Iterable<SyncConflict> conflicts,
    this.nextCursor,
  }) : changes = List.unmodifiable(changes),
       conflicts = List.unmodifiable(conflicts);

  final bool isPreview;
  final List<SyncTransaction> changes;
  final List<SyncConflict> conflicts;
  final String? nextCursor;
}

abstract interface class SyncRepository {
  /// Implementations must authenticate tenant access independently of profileId.
  Future<SyncResult> uploadUnsyncedTransactions({required String profileId});

  Future<SyncResult> downloadRemoteChanges({
    required String profileId,
    String? cursor,
  });
}
