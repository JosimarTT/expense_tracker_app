enum TransactionType { income, expense }

class FinancialTransaction {
  FinancialTransaction({
    required this.id,
    required this.profileId,
    String? notes,
    required this.amountMinor,
    required this.type,
    required this.categoryId,
    required DateTime occurredAt,
  }) : notes = notes?.trim() ?? '',
       occurredAt = occurredAt.toUtc() {
    if (id.trim().isEmpty ||
        profileId.trim().isEmpty ||
        categoryId.trim().isEmpty) {
      throw ArgumentError('Transaction identifiers must not be empty.');
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
  final String notes;
  final int amountMinor;
  final TransactionType type;
  final String categoryId;
  final DateTime occurredAt;
}
