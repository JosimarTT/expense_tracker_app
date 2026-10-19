import '../../transactions/domain/entities/financial_transaction.dart';

class LocalProfile {
  const LocalProfile({
    required this.id,
    required this.name,
    required this.currencyCode,
    required this.currencyScale,
  });

  final String id;
  final String name;
  final String currencyCode;
  final int currencyScale;
}

class TransactionCategory {
  const TransactionCategory({
    required this.id,
    required this.name,
    required this.type,
    required this.iconKey,
    required this.colorArgb,
    required this.defaultBudgetBucket,
    this.isArchived = false,
  });

  final String id;
  final String name;
  final TransactionType type;
  final String iconKey;
  final int colorArgb;
  final String? defaultBudgetBucket;
  final bool isArchived;
}

abstract interface class CategoryRepository {
  Future<void> save(String profileId, TransactionCategory category);
  Future<void> setArchived({
    required String profileId,
    required String categoryId,
    required bool archived,
  });
  Future<void> delete({required String profileId, required String categoryId});
  Future<bool> canDelete({
    required String profileId,
    required String categoryId,
  });
}

abstract interface class ProfileRepository {
  Stream<List<LocalProfile>> watchProfiles();
  Stream<List<TransactionCategory>> watchCategories(String profileId);
  Future<void> create(LocalProfile profile);
  Future<void> deletePermanently(String profileId);
}
