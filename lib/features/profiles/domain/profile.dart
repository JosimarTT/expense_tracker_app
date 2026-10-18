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
  });

  final String id;
  final String name;
  final TransactionType type;
}

abstract interface class ProfileRepository {
  Stream<List<LocalProfile>> watchProfiles();
  Stream<List<TransactionCategory>> watchCategories(String profileId);
  Future<void> create(LocalProfile profile);
}
