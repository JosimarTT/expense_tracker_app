import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart' hide TransactionSchedule;
import '../../../core/database/app_database.dart'
    as rows
    show TransactionSchedule;
import '../../../core/ids/id_generator.dart';
import '../../transactions/data/repositories/local_transaction_repository.dart';
import '../../transactions/domain/entities/financial_transaction.dart';
import '../domain/transaction_schedule.dart';

String scheduleDateText(DateTime date) =>
    date.toIso8601String().substring(0, 10);

class LocalScheduleRepository implements ScheduleRepository {
  LocalScheduleRepository(this._database, this._ids);

  final AppDatabase _database;
  final IdGenerator _ids;

  TransactionSchedule _map(rows.TransactionSchedule row) => TransactionSchedule(
    id: row.scheduleId,
    profileId: row.profileId,
    name: row.name,
    notes: row.notes,
    amountMinor: row.amountMinor,
    type: TransactionType.values.byName(row.type),
    categoryId: row.categoryId,
    startDate: DateTime.parse(row.startDate),
    endDate: row.endDate == null ? null : DateTime.parse(row.endDate!),
    repeatUnit: RepeatUnit.values.byName(row.repeatUnit),
    interval: row.repeatInterval,
    automatic: row.automatic == 1,
    paused: row.paused == 1,
    nextIndex: row.nextIndex,
  );

  @override
  Stream<List<TransactionSchedule>> watchSchedules(String profileId) {
    final query = _database.select(_database.transactionSchedules)
      ..where((row) => row.profileId.equals(profileId) & row.deletedAt.isNull())
      ..orderBy([(row) => OrderingTerm.asc(row.name)]);
    return query.watch().map((rows) => rows.map(_map).toList());
  }

  Future<rows.TransactionSchedule> _find(
    String profileId,
    String scheduleId,
  ) async {
    final row =
        await (_database.select(_database.transactionSchedules)..where(
              (row) =>
                  row.profileId.equals(profileId) &
                  row.scheduleId.equals(scheduleId) &
                  row.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    if (row == null) throw StateError('The schedule no longer exists.');
    return row;
  }

  @override
  Future<void> save(TransactionSchedule schedule) =>
      _database.transaction(() async {
        final profile =
            await (_database.select(_database.profiles)..where(
                  (row) =>
                      row.profileId.equals(schedule.profileId) &
                      row.deletedAt.isNull(),
                ))
                .getSingleOrNull();
        final category =
            await (_database.select(_database.categories)..where(
                  (row) =>
                      row.profileId.equals(schedule.profileId) &
                      row.categoryId.equals(schedule.categoryId) &
                      row.deletedAt.isNull() &
                      row.type.equals(schedule.type.name),
                ))
                .getSingleOrNull();
        if (profile == null || category == null) {
          throw StateError(
            'Choose an active profile and a matching active category.',
          );
        }
        final existing =
            await (_database.select(_database.transactionSchedules)..where(
                  (row) =>
                      row.profileId.equals(schedule.profileId) &
                      row.scheduleId.equals(schedule.id),
                ))
                .getSingleOrNull();
        if (existing != null) {
          if (existing.deletedAt != null) {
            throw StateError('A canceled schedule cannot be restored.');
          }
          if (existing.startDate != scheduleDateText(schedule.startDate) ||
              existing.repeatUnit != schedule.repeatUnit.name ||
              existing.repeatInterval != schedule.interval) {
            throw StateError(
              'Create a new schedule to change its first date or recurrence.',
            );
          }
        }
        final now = DateTime.now().toUtc().millisecondsSinceEpoch;
        await _database
            .into(_database.transactionSchedules)
            .insertOnConflictUpdate(
              TransactionSchedulesCompanion.insert(
                profileId: schedule.profileId,
                scheduleId: schedule.id,
                name: schedule.name.trim(),
                notes: Value(schedule.notes.trim()),
                amountMinor: schedule.amountMinor,
                type: schedule.type.name,
                categoryId: schedule.categoryId,
                startDate: scheduleDateText(schedule.startDate),
                endDate: Value(
                  schedule.endDate == null
                      ? null
                      : scheduleDateText(schedule.endDate!),
                ),
                repeatUnit: schedule.repeatUnit.name,
                repeatInterval: schedule.interval,
                automatic: schedule.automatic ? 1 : 0,
                nextIndex: Value(existing?.nextIndex ?? 0),
                paused: Value(existing?.paused ?? 0),
                createdAt: existing?.createdAt ?? now,
                updatedAt: now,
                localRevision: Value((existing?.localRevision ?? 0) + 1),
                isSynced: const Value(0),
              ),
            );
      });

  Future<void> _resolve(
    rows.TransactionSchedule row,
    DateTime now, {
    required bool skip,
  }) async {
    final schedule = _map(row);
    final due = schedule.nextDate;
    if (due == null || !schedule.isDue(now)) {
      throw StateError('This occurrence is not due or the schedule is paused.');
    }
    String? transactionId;
    if (!skip) {
      transactionId = _ids.generate();
      await LocalTransactionRepository(_database).save(
        FinancialTransaction(
          id: transactionId,
          profileId: schedule.profileId,
          notes: schedule.notes.isEmpty ? schedule.name : schedule.notes,
          amountMinor: schedule.amountMinor,
          type: schedule.type,
          categoryId: schedule.categoryId,
          occurredAt: DateTime(due.year, due.month, due.day),
        ),
      );
    }
    final timestamp = now.toUtc().millisecondsSinceEpoch;
    await _database
        .into(_database.scheduleOccurrences)
        .insert(
          ScheduleOccurrencesCompanion.insert(
            profileId: row.profileId,
            scheduleId: row.scheduleId,
            occurrenceIndex: row.nextIndex,
            dueDate: scheduleDateText(due),
            transactionId: Value(transactionId),
            resolvedAt: timestamp,
          ),
        );
    await (_database.update(_database.transactionSchedules)..where(
          (item) =>
              item.profileId.equals(row.profileId) &
              item.scheduleId.equals(row.scheduleId),
        ))
        .write(
          TransactionSchedulesCompanion(
            nextIndex: Value(row.nextIndex + 1),
            updatedAt: Value(timestamp),
            localRevision: Value(row.localRevision + 1),
            isSynced: const Value(0),
          ),
        );
  }

  @override
  Future<void> resolve({
    required String profileId,
    required String scheduleId,
    required int expectedIndex,
    required DateTime now,
    required bool skip,
  }) => _database.transaction(() async {
    final row = await _find(profileId, scheduleId);
    // A stale confirmation must never post the following occurrence.
    if (row.nextIndex != expectedIndex) {
      throw StateError(
        'This occurrence was already processed. Refresh and try again.',
      );
    }
    await _resolve(row, now, skip: skip);
  });

  @override
  Future<void> processDue(String profileId, DateTime now) async {
    final rows =
        await (_database.select(_database.transactionSchedules)..where(
              (row) =>
                  row.profileId.equals(profileId) &
                  row.deletedAt.isNull() &
                  row.automatic.equals(1) &
                  row.paused.equals(0),
            ))
            .get();
    final failures = <String>[];
    for (final candidate in rows) {
      try {
        await _database.transaction(() async {
          var row = await _find(profileId, candidate.scheduleId);
          while (row.automatic == 1 && _map(row).isDue(now)) {
            await _resolve(row, now, skip: false);
            row = await _find(profileId, row.scheduleId);
          }
        });
      } on Object catch (error) {
        failures.add('${candidate.name}: $error');
      }
    }
    if (failures.isNotEmpty) throw StateError(failures.join('\n'));
  }

  @override
  Future<void> setPaused({
    required String profileId,
    required String scheduleId,
    required bool paused,
  }) => _database.transaction(() async {
    final row = await _find(profileId, scheduleId);
    await (_database.update(_database.transactionSchedules)..where(
          (item) =>
              item.profileId.equals(profileId) &
              item.scheduleId.equals(scheduleId),
        ))
        .write(
          TransactionSchedulesCompanion(
            paused: Value(paused ? 1 : 0),
            updatedAt: Value(DateTime.now().toUtc().millisecondsSinceEpoch),
            localRevision: Value(row.localRevision + 1),
            isSynced: const Value(0),
          ),
        );
  });

  @override
  Future<void> delete({
    required String profileId,
    required String scheduleId,
  }) => _database.transaction(() async {
    final row = await _find(profileId, scheduleId);
    final now = DateTime.now().toUtc().millisecondsSinceEpoch;
    await (_database.update(_database.transactionSchedules)..where(
          (item) =>
              item.profileId.equals(profileId) &
              item.scheduleId.equals(scheduleId),
        ))
        .write(
          TransactionSchedulesCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
            localRevision: Value(row.localRevision + 1),
            isSynced: const Value(0),
          ),
        );
  });
}
