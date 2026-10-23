import 'entities/financial_transaction.dart';

enum TransactionSort { newestFirst, oldestFirst }

/// Filter shared by the Transactions list and the Stats aggregates.
///
/// [start] is inclusive, [end] exclusive; a null bound is open, so a filter
/// without bounds covers all time.
class TransactionFilter {
  TransactionFilter({
    DateTime? start,
    DateTime? end,
    this.type,
    Iterable<String> categoryIds = const [],
    String query = '',
  }) : start = start?.toUtc(),
       end = end?.toUtc(),
       categoryIds = Set.unmodifiable(categoryIds),
       query = query.trim() {
    if (this.start != null &&
        this.end != null &&
        !this.start!.isBefore(this.end!)) {
      throw ArgumentError('The filter start must be before its end.');
    }
  }

  /// Covers the local calendar month containing [month].
  factory TransactionFilter.month(DateTime month) => TransactionFilter(
    start: DateTime(month.year, month.month),
    end: DateTime(month.year, month.month + 1),
  );

  final DateTime? start;
  final DateTime? end;
  final TransactionType? type;
  final Set<String> categoryIds;
  final String query;

  TransactionFilter withRange(DateTime? start, DateTime? end) =>
      TransactionFilter(
        start: start,
        end: end,
        type: type,
        categoryIds: categoryIds,
        query: query,
      );

  TransactionFilter withType(TransactionType? type) => TransactionFilter(
    start: start,
    end: end,
    type: type,
    categoryIds: categoryIds,
    query: query,
  );

  TransactionFilter withCategories(Iterable<String> categoryIds) =>
      TransactionFilter(
        start: start,
        end: end,
        type: type,
        categoryIds: categoryIds,
        query: query,
      );

  TransactionFilter withQuery(String query) => TransactionFilter(
    start: start,
    end: end,
    type: type,
    categoryIds: categoryIds,
    query: query,
  );

  @override
  bool operator ==(Object other) =>
      other is TransactionFilter &&
      other.start == start &&
      other.end == end &&
      other.type == type &&
      other.query == query &&
      other.categoryIds.length == categoryIds.length &&
      other.categoryIds.containsAll(categoryIds);

  @override
  int get hashCode => Object.hash(
    start,
    end,
    type,
    query,
    Object.hashAllUnordered(categoryIds),
  );
}

/// The first [items] of a filtered list; [hasMore] says more rows exist.
class TransactionPage {
  const TransactionPage({required this.items, required this.hasMore});

  final List<FinancialTransaction> items;
  final bool hasMore;
}

/// Exact totals; [BigInt] avoids overflowing 64-bit minor units.
class TransactionTotals {
  const TransactionTotals({
    this.incomeMinor,
    this.expenseMinor,
    this.savingsMinor,
    this.incomeCount = 0,
    this.expenseCount = 0,
    this.savingsCount = 0,
    this.firstOccurredAt,
    this.lastOccurredAt,
  });

  final BigInt? incomeMinor;
  final BigInt? expenseMinor;
  final BigInt? savingsMinor;
  final int incomeCount;
  final int expenseCount;
  final int savingsCount;
  final DateTime? firstOccurredAt;
  final DateTime? lastOccurredAt;

  int get count => incomeCount + expenseCount + savingsCount;

  BigInt get income => incomeMinor ?? BigInt.zero;
  BigInt get expense => expenseMinor ?? BigInt.zero;
  BigInt get savings => savingsMinor ?? BigInt.zero;
  BigInt get remaining => income - expense - savings;
}

enum PeriodGranularity {
  day,
  week,
  month;

  /// Daily up to a month, weekly up to about six months, monthly beyond, so a
  /// chart never has to plot an unbounded number of points.
  static PeriodGranularity suggest(DateTime start, DateTime end) {
    final days = end.difference(start).inDays;
    if (days <= 31) return day;
    if (days <= 190) return week;
    return month;
  }

  /// Start of the local period containing [date].
  DateTime floor(DateTime date) {
    final local = date.toLocal();
    return switch (this) {
      day => DateTime(local.year, local.month, local.day),
      week => DateTime(
        local.year,
        local.month,
        local.day - (local.weekday - DateTime.monday),
      ),
      month => DateTime(local.year, local.month),
    };
  }

  /// Start of the period after the one starting at [start].
  DateTime next(DateTime start) => switch (this) {
    day => DateTime(start.year, start.month, start.day + 1),
    week => DateTime(start.year, start.month, start.day + 7),
    month => DateTime(start.year, start.month + 1),
  };
}

class PeriodTotal {
  const PeriodTotal({
    required this.start,
    required this.end,
    required this.totals,
  });

  /// Local, inclusive.
  final DateTime start;

  /// Local, exclusive.
  final DateTime end;
  final TransactionTotals totals;
}
