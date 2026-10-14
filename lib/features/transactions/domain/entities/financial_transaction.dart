enum TransactionType { income, expense }

class FinancialTransaction {
  FinancialTransaction({
    required this.id,
    required this.profileId,
    required String title,
    required this.amountMinor,
    required this.type,
    required this.categoryId,
    required DateTime occurredAt,
  }) : title = title.trim(),
       occurredAt = occurredAt.toUtc() {
    if (id.trim().isEmpty ||
        profileId.trim().isEmpty ||
        categoryId.trim().isEmpty ||
        this.title.isEmpty) {
      throw ArgumentError('Transaction identifiers and title must not be empty.');
    }
    if (amountMinor <= 0 || amountMinor > 9223372036854775807) {
      throw ArgumentError.value(
        amountMinor,
        'amountMinor',
        'Must be a positive SQLite 64-bit integer.',
      );
    }
  }

  final String id;
  final String profileId;
  final String title;
  final int amountMinor;
  final TransactionType type;
  final String categoryId;
  final DateTime occurredAt;
}
