import 'package:expense_tracker_app/features/schedules/domain/transaction_schedule.dart';
import 'package:expense_tracker_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

TransactionSchedule schedule({
  DateTime? start,
  DateTime? end,
  RepeatUnit unit = RepeatUnit.month,
  int interval = 1,
  int index = 0,
  bool paused = false,
}) => TransactionSchedule(
  id: 'schedule',
  profileId: 'a',
  name: 'Rent',
  amountMinor: 10000,
  type: TransactionType.expense,
  categoryId: 'housing',
  startDate: start ?? DateTime(2026, 1, 31),
  endDate: end,
  repeatUnit: unit,
  interval: interval,
  nextIndex: index,
  paused: paused,
);

void main() {
  test('Monthly recurrence clamps dates without drifting the original day', () {
    final monthly = schedule();
    expect(monthly.occurrence(1), DateTime.utc(2026, 2, 28));
    expect(monthly.occurrence(2), DateTime.utc(2026, 3, 31));
    final quarterly = schedule(interval: 3);
    expect(quarterly.occurrence(1), DateTime.utc(2026, 4, 30));
    expect(quarterly.occurrence(2), DateTime.utc(2026, 7, 31));
  });

  test('Yearly leap day returns to February 29 in leap years', () {
    final yearly = schedule(
      start: DateTime(2024, 2, 29),
      unit: RepeatUnit.year,
    );
    expect(yearly.occurrence(1), DateTime.utc(2025, 2, 28));
    expect(yearly.occurrence(4), DateTime.utc(2028, 2, 29));
  });

  test(
    'Daily and weekly intervals use calendar dates, not local DST durations',
    () {
      final daily = schedule(
        start: DateTime(2026, 3, 7, 23),
        unit: RepeatUnit.day,
      );
      expect(daily.occurrence(2), DateTime.utc(2026, 3, 9));
      expect(
        schedule(unit: RepeatUnit.week, interval: 2).occurrence(1),
        DateTime.utc(2026, 2, 14),
      );
    },
  );

  test('End date is inclusive, one-time entries finish, paused entries are not due', () {
    expect(
      schedule(end: DateTime(2026, 2, 28), index: 1).nextDate,
      DateTime.utc(2026, 2, 28),
    );
    expect(schedule(end: DateTime(2026, 2, 28), index: 2).nextDate, isNull);
    expect(schedule(unit: RepeatUnit.once, index: 1).nextDate, isNull);
    expect(schedule(paused: true).isDue(DateTime(2026, 3)), isFalse);
    expect(schedule().isDue(DateTime(2026, 1, 30, 23, 59)), isFalse);
    expect(schedule().isDue(DateTime(2026, 1, 31)), isTrue);
  });

  test('Rejects invalid recurrence and date ranges', () {
    expect(() => schedule(interval: 0), throwsArgumentError);
    expect(() => schedule(interval: 1000), throwsArgumentError);
    expect(() => schedule(end: DateTime(2025)), throwsArgumentError);
    expect(() => schedule(index: -1), throwsArgumentError);
  });
}
