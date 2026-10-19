import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DriftDatabase(include: {'schema.drift'})
class AppDatabase extends _$AppDatabase {
  AppDatabase()
    : super(driftDatabase(name: 'expense_tracker'));

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) =>
        destructiveFallback.onUpgrade(migrator, from, to),
    beforeOpen: (_) => customStatement('PRAGMA foreign_keys = ON'),
  );
}
