import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/ids/id_generator.dart';
import '../../profiles/domain/profile.dart';
import '../domain/savings_repository.dart';

class LocalSavingsRepository implements SavingsRepository {
  LocalSavingsRepository(this._database, {IdGenerator? ids})
    : _ids = ids ?? UuidV7IdGenerator();

  final AppDatabase _database;
  final IdGenerator _ids;

  String _month(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';

  @override
  Future<void> setAutomatic(String profileId, bool enabled, DateTime now) =>
      _database.transaction(() async {
        final profile =
            await (_database.select(_database.profiles)..where(
                  (row) =>
                      row.profileId.equals(profileId) & row.deletedAt.isNull(),
                ))
                .getSingleOrNull();
        if (profile == null) {
          throw StateError('The selected profile no longer exists.');
        }
        if ((profile.autoSavings == 1) == enabled) return;
        await (_database.update(
          _database.profiles,
        )..where((row) => row.profileId.equals(profileId))).write(
          ProfilesCompanion(
            autoSavings: Value(enabled ? 1 : 0),
            autoSavingsSince: Value(enabled ? _month(now) : null),
            updatedAt: Value(now.toUtc().millisecondsSinceEpoch),
            localRevision: Value(profile.localRevision + 1),
            isSynced: const Value(0),
          ),
        );
        await process(profileId, now);
      });

  @override
  Future<void> process(String profileId, DateTime now) => _database.transaction(
    () async {
      final profile =
          await (_database.select(_database.profiles)..where(
                (row) =>
                    row.profileId.equals(profileId) & row.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (profile == null) {
        throw StateError('The selected profile no longer exists.');
      }
      final current = DateTime(now.year, now.month);
      final generated =
          await (_database.select(_database.transactions)..where(
                (row) =>
                    row.profileId.equals(profileId) &
                    row.savingsMonth.isNotNull(),
              ))
              .get();
      final months = generated.map((row) => row.savingsMonth!).toSet();
      if (profile.autoSavings == 1 && profile.autoSavingsSince != null) {
        var month = DateTime.parse('${profile.autoSavingsSince!}-01');
        while (month.isBefore(current)) {
          months.add(_month(month));
          month = DateTime(month.year, month.month + 1);
        }
      }
      for (final month in months) {
        final start = DateTime.parse('$month-01');
        if (!start.isBefore(current)) continue;
        final end = DateTime(start.year, start.month + 1);
        final entries =
            await (_database.select(_database.transactions)..where(
                  (row) =>
                      row.profileId.equals(profileId) &
                      row.deletedAt.isNull() &
                      row.savingsMonth.isNull() &
                      row.occurredAt.isBiggerOrEqualValue(
                        start.toUtc().millisecondsSinceEpoch,
                      ) &
                      row.occurredAt.isSmallerThanValue(
                        end.toUtc().millisecondsSinceEpoch,
                      ),
                ))
                .get();
        var remaining = BigInt.zero;
        for (final entry in entries) {
          final amount = BigInt.from(entry.amountMinor);
          remaining += entry.type == 'income' ? amount : -amount;
        }
        if (remaining > BigInt.parse('9223372036854775807')) {
          throw StateError('Unused money exceeds the supported amount range.');
        }
        final existing = generated
            .where((row) => row.savingsMonth == month)
            .firstOrNull;
        final timestamp = now.toUtc().millisecondsSinceEpoch;
        if (remaining <= BigInt.zero) {
          if (existing != null && existing.deletedAt == null) {
            await (_database.update(_database.transactions)..where(
                  (row) =>
                      row.profileId.equals(profileId) &
                      row.transactionId.equals(existing.transactionId),
                ))
                .write(
                  TransactionsCompanion(
                    deletedAt: Value(timestamp),
                    updatedAt: Value(timestamp),
                    localRevision: Value(existing.localRevision + 1),
                    isSynced: const Value(0),
                  ),
                );
          }
          continue;
        }
        final amount = remaining.toInt();
        if (existing?.deletedAt == null && existing?.amountMinor == amount) {
          continue;
        }
        await _database
            .into(_database.transactions)
            .insertOnConflictUpdate(
              TransactionsCompanion.insert(
                profileId: profileId,
                transactionId: existing?.transactionId ?? _ids.generate(),
                notes: Value('Unused money - $month'),
                amountMinor: amount,
                type: 'savings',
                categoryId: TransactionCategory.unusedMoneyId,
                savingsMonth: Value(month),
                occurredAt: end.toUtc().millisecondsSinceEpoch - 1,
                createdAt: existing?.createdAt ?? timestamp,
                updatedAt: timestamp,
                deletedAt: const Value(null),
                localRevision: Value((existing?.localRevision ?? 0) + 1),
                isSynced: const Value(0),
              ),
            );
      }
    },
  );
}
