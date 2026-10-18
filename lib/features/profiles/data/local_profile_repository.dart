import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../transactions/domain/entities/financial_transaction.dart';
import '../domain/profile.dart';

class LocalProfileRepository implements ProfileRepository {
  LocalProfileRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<LocalProfile>> watchProfiles() {
    final query = _database.select(_database.profiles)
      ..where((row) => row.deletedAt.isNull())
      ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          LocalProfile(
            id: row.profileId,
            name: row.name,
            currencyCode: row.currencyCode,
            currencyScale: row.currencyScale,
          ),
      ],
    );
  }

  @override
  Stream<List<TransactionCategory>> watchCategories(String profileId) {
    if (profileId.trim().isEmpty) {
      throw ArgumentError('A profile is required.');
    }
    final query = _database.select(_database.categories)
      ..where((row) => row.profileId.equals(profileId) & row.deletedAt.isNull())
      ..orderBy([(row) => OrderingTerm.asc(row.name)]);
    return query.watch().map(
      (rows) => [
        for (final row in rows)
          TransactionCategory(
            id: row.categoryId,
            name: row.name,
            type: TransactionType.values.byName(row.type),
          ),
      ],
    );
  }

  @override
  Future<void> create(LocalProfile profile) {
    if (profile.id.trim().isEmpty || profile.name.trim().isEmpty) {
      throw ArgumentError('Profile name and identifier are required.');
    }
    if (!{'USD', 'EUR', 'GBP'}.contains(profile.currencyCode) ||
        profile.currencyScale != 2) {
      throw ArgumentError('The MVP supports USD, EUR and GBP with scale 2.');
    }
    return _database.transaction(() async {
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      await _database.into(_database.profiles).insert(
        ProfilesCompanion.insert(
          profileId: profile.id,
          name: profile.name.trim(),
          currencyCode: profile.currencyCode,
          currencyScale: profile.currencyScale,
          createdAt: now,
          updatedAt: now,
        ),
      );
      for (final category in const [
        TransactionCategory(id: 'salary', name: 'Salary', type: TransactionType.income),
        TransactionCategory(id: 'other_income', name: 'Other income', type: TransactionType.income),
        TransactionCategory(id: 'housing', name: 'Housing', type: TransactionType.expense),
        TransactionCategory(id: 'groceries', name: 'Groceries', type: TransactionType.expense),
        TransactionCategory(id: 'transport', name: 'Transport', type: TransactionType.expense),
        TransactionCategory(id: 'dining', name: 'Dining out', type: TransactionType.expense),
        TransactionCategory(id: 'entertainment', name: 'Entertainment', type: TransactionType.expense),
        TransactionCategory(id: 'other_expense', name: 'Other expense', type: TransactionType.expense),
      ]) {
        await _database.into(_database.categories).insert(
          CategoriesCompanion.insert(
            profileId: profile.id,
            categoryId: category.id,
            name: category.name,
            type: category.type.name,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
    });
  }
}
