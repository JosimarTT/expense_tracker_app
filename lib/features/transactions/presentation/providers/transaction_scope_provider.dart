import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../domain/entities/financial_transaction.dart';
import '../../domain/transaction_filter.dart';

enum DateRangeMode { month, allTime, custom }

/// The date range of the shared scope. Custom ends are inclusive local days.
class DateScope {
  DateScope.month(DateTime month)
    : mode = DateRangeMode.month,
      month = DateTime(month.year, month.month),
      customStart = null,
      customEnd = null;

  const DateScope.allTime()
    : mode = DateRangeMode.allTime,
      month = null,
      customStart = null,
      customEnd = null;

  DateScope.custom(DateTime start, DateTime end)
    : mode = DateRangeMode.custom,
      month = null,
      customStart = DateUtils.dateOnly(start.isAfter(end) ? end : start),
      customEnd = DateUtils.dateOnly(start.isAfter(end) ? start : end);

  final DateRangeMode mode;
  final DateTime? month;
  final DateTime? customStart;
  final DateTime? customEnd;

  /// Inclusive local start, or null when open.
  DateTime? get start => switch (mode) {
    DateRangeMode.month => month,
    DateRangeMode.allTime => null,
    DateRangeMode.custom => customStart,
  };

  /// Exclusive local end, or null when open.
  DateTime? get end => switch (mode) {
    DateRangeMode.month => DateTime(month!.year, month!.month + 1),
    DateRangeMode.allTime => null,
    DateRangeMode.custom => DateTime(
      customEnd!.year,
      customEnd!.month,
      customEnd!.day + 1,
    ),
  };

  @override
  bool operator ==(Object other) =>
      other is DateScope &&
      other.mode == mode &&
      other.month == month &&
      other.customStart == customStart &&
      other.customEnd == customEnd;

  @override
  int get hashCode => Object.hash(mode, month, customStart, customEnd);
}

/// The filter and sort choices shared by the Transactions and Stats views of
/// one profile. Home keeps its own month picker and does not read this.
class TransactionScope {
  TransactionScope({
    required this.filter,
    this.sort = TransactionSort.newestFirst,
    this.showArchived = false,
    DateScope? dates,
  }) : dates = dates ?? DateScope.month(DateTime.now());

  final TransactionFilter filter;
  final TransactionSort sort;
  final DateScope dates;
  final bool showArchived;

  /// [filter] with the date range applied.
  TransactionFilter get ranged => filter.withRange(dates.start, dates.end);

  /// Choices made in the filter sheet. Search is cleared from its own field.
  int get activeCount =>
      (filter.type == null ? 0 : 1) +
      filter.categoryIds.length +
      (sort == TransactionSort.newestFirst ? 0 : 1) +
      (dates.mode == DateRangeMode.month ? 0 : 1);

  TransactionScope copyWith({
    TransactionFilter? filter,
    TransactionSort? sort,
    DateScope? dates,
    bool? showArchived,
  }) => TransactionScope(
    filter: filter ?? this.filter,
    sort: sort ?? this.sort,
    dates: dates ?? this.dates,
    showArchived: showArchived ?? this.showArchived,
  );
}

class TransactionScopeNotifier extends Notifier<TransactionScope> {
  TransactionScopeNotifier(this.profileId);

  final String profileId;

  @override
  TransactionScope build() => TransactionScope(filter: TransactionFilter());

  void setDates(DateScope dates) => state = state.copyWith(dates: dates);

  void setType(TransactionType? type) {
    var filter = state.filter.withType(type);
    if (filter.categoryIds.isNotEmpty) {
      final categories = ref.read(categoriesProvider(profileId)).requireValue;
      filter = filter.withCategories(
        categories
            .where(
              (category) =>
                  (type == null || category.type == type) &&
                  (state.showArchived || !category.isArchived) &&
                  filter.categoryIds.contains(category.id),
            )
            .map((category) => category.id),
      );
    }
    state = state.copyWith(filter: filter);
  }

  void setShowArchived(bool showArchived) {
    var filter = state.filter;
    if (!showArchived && filter.categoryIds.isNotEmpty) {
      final categories = ref.read(categoriesProvider(profileId)).requireValue;
      filter = filter.withCategories(
        categories
            .where(
              (category) =>
                  !category.isArchived &&
                  filter.categoryIds.contains(category.id),
            )
            .map((category) => category.id),
      );
    }
    state = state.copyWith(filter: filter, showArchived: showArchived);
  }

  void setCategories(Iterable<String> ids) =>
      state = state.copyWith(filter: state.filter.withCategories(ids));

  void setQuery(String query) =>
      state = state.copyWith(filter: state.filter.withQuery(query));

  void setSort(TransactionSort sort) => state = state.copyWith(sort: sort);

  /// Clears type, categories, sort and dates (back to the current month),
  /// keeping the search text.
  void reset() => state = TransactionScope(
    filter: TransactionFilter(query: state.filter.query),
  );
}

final transactionScopeProvider =
    NotifierProvider.family<TransactionScopeNotifier, TransactionScope, String>(
      TransactionScopeNotifier.new,
    );

typedef FilteredTransactionsKey = ({
  String profileId,
  TransactionFilter filter,
  TransactionSort sort,
  int limit,
});

final filteredTransactionsProvider = StreamProvider.autoDispose
    .family<TransactionPage, FilteredTransactionsKey>(
      (ref, key) => ref
          .watch(transactionRepositoryProvider)
          .watchPage(
            key.profileId,
            key.filter,
            sort: key.sort,
            limit: key.limit,
          ),
    );

typedef FilteredCountKey = ({String profileId, TransactionFilter filter});

final filteredCountProvider = StreamProvider.autoDispose
    .family<int, FilteredCountKey>(
      (ref, key) => ref
          .watch(transactionRepositoryProvider)
          .watchTotals(key.profileId, key.filter)
          .map((totals) => totals.count),
    );
