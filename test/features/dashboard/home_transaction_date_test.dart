import 'package:expense_tracker_app/features/dashboard/presentation/home_transaction_date.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  final now = DateTime(2026, 10, 21, 0, 5);
  String label(DateTime date, {DateTime? month}) => homeTransactionDate(
    occurredAt: date,
    selectedMonth: month ?? DateTime(2026, 10),
    now: now,
  );

  test('Current month uses relative labels only for the past six days', () {
    expect(label(DateTime(2026, 10, 21, 23)), 'Today');
    expect(label(DateTime(2026, 10, 20, 23, 59)), 'Yesterday');
    for (var days = 2; days <= 6; days++) {
      expect(label(DateTime(2026, 10, 21 - days)), '$days days ago');
    }
    expect(
      label(DateTime(2026, 10, 14)),
      DateFormat.MMMd().format(DateTime(2026, 10, 14)),
    );
    expect(
      label(DateTime(2026, 10, 22)),
      DateFormat.MMMd().format(DateTime(2026, 10, 22)),
    );
  });

  test('Previous months use calendar dates, including year when needed', () {
    expect(
      label(DateTime(2026, 9, 30), month: DateTime(2026, 9)),
      DateFormat.MMMd().format(DateTime(2026, 9, 30)),
    );
    expect(
      label(DateTime(2025, 12, 31), month: DateTime(2025, 12)),
      DateFormat.yMMMd().format(DateTime(2025, 12, 31)),
    );
    expect(
      homeTransactionDate(
        occurredAt: DateTime(2026, 9, 30, 23, 59),
        selectedMonth: DateTime(2026, 9),
        now: DateTime(2026, 10, 1),
      ),
      DateFormat.MMMd().format(DateTime(2026, 9, 30)),
    );
  });

  test('Stored UTC instants use the local calendar date', () {
    final local = DateTime(2026, 10, 19, 23);
    expect(label(local.toUtc()), '2 days ago');
  });

  test(
    'Calendar comparisons span daylight-saving weekends without durations',
    () {
      for (final (today, yesterday) in [
        (DateTime(2026, 3, 9), DateTime(2026, 3, 8, 23, 59)),
        (DateTime(2026, 11, 2), DateTime(2026, 11, 1, 23, 59)),
      ]) {
        expect(
          homeTransactionDate(
            occurredAt: yesterday,
            selectedMonth: today,
            now: today,
          ),
          'Yesterday',
        );
      }
    },
  );
}
