import '../../transactions/domain/entities/financial_transaction.dart';

enum RepeatUnit { once, day, week, month, year }

DateTime calendarDate(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day);

class TransactionSchedule {
  TransactionSchedule({
    required this.id,
    required this.profileId,
    required this.name,
    required this.amountMinor,
    required this.type,
    required this.categoryId,
    required DateTime startDate,
    this.notes = '',
    this.automatic = false,
    this.repeatUnit = RepeatUnit.month,
    this.interval = 1,
    DateTime? endDate,
    this.nextIndex = 0,
    this.paused = false,
  }) : startDate = calendarDate(startDate),
       endDate = endDate == null ? null : calendarDate(endDate) {
    if (id.trim().isEmpty ||
        profileId.trim().isEmpty ||
        name.trim().isEmpty ||
        categoryId.trim().isEmpty) {
      throw ArgumentError('Schedule name and identifiers are required.');
    }
    if (amountMinor <= 0 || interval < 1 || interval > 999 || nextIndex < 0) {
      throw ArgumentError(
        'Enter a positive amount and an interval from 1 to 999.',
      );
    }
    if (this.endDate != null && this.endDate!.isBefore(this.startDate)) {
      throw ArgumentError('End date cannot be before the first date.');
    }
    if (this.startDate.year < 1900 ||
        this.startDate.year > 2200 ||
        (this.endDate != null && this.endDate!.year > 2200)) {
      throw ArgumentError('Schedule dates must be between 1900 and 2200.');
    }
  }

  final String id;
  final String profileId;
  final String name;
  final int amountMinor;
  final TransactionType type;
  final String categoryId;
  final String notes;
  final DateTime startDate;
  final DateTime? endDate;
  final bool automatic;
  final RepeatUnit repeatUnit;
  final int interval;
  final int nextIndex;
  final bool paused;

  DateTime occurrence(int index) {
    if (index < 0) throw ArgumentError.value(index, 'index');
    final steps = index * interval;
    switch (repeatUnit) {
      case RepeatUnit.once:
        return startDate;
      case RepeatUnit.day:
        return startDate.add(Duration(days: steps));
      case RepeatUnit.week:
        return startDate.add(Duration(days: steps * 7));
      case RepeatUnit.month:
      case RepeatUnit.year:
        final month = DateTime.utc(
          startDate.year,
          startDate.month + steps * (repeatUnit == RepeatUnit.year ? 12 : 1),
        );
        final lastDay = DateTime.utc(month.year, month.month + 1, 0).day;
        return DateTime.utc(
          month.year,
          month.month,
          startDate.day > lastDay ? lastDay : startDate.day,
        );
    }
  }

  DateTime? get nextDate {
    if (repeatUnit == RepeatUnit.once && nextIndex > 0) return null;
    final date = occurrence(nextIndex);
    if (date.year > 2200 || (endDate != null && date.isAfter(endDate!))) {
      return null;
    }
    return date;
  }

  bool isDue(DateTime now) =>
      !paused && nextDate != null && !nextDate!.isAfter(calendarDate(now));
}

abstract interface class ScheduleRepository {
  Stream<List<TransactionSchedule>> watchSchedules(String profileId);
  Future<void> save(TransactionSchedule schedule);
  Future<void> processDue(String profileId, DateTime now);
  Future<void> resolve({
    required String profileId,
    required String scheduleId,
    required int expectedIndex,
    required DateTime now,
    required bool skip,
  });
  Future<void> setPaused({
    required String profileId,
    required String scheduleId,
    required bool paused,
  });
  Future<void> delete({required String profileId, required String scheduleId});
}
