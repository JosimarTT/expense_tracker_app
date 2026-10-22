import 'package:intl/intl.dart';

String homeTransactionDate({
  required DateTime occurredAt,
  required DateTime selectedMonth,
  required DateTime now,
}) {
  final date = occurredAt.toLocal();
  final today = now.toLocal();
  if (selectedMonth.year == today.year && selectedMonth.month == today.month) {
    // Compare calendar days without daylight-saving duration shifts.
    final days = DateTime.utc(
      today.year,
      today.month,
      today.day,
    ).difference(DateTime.utc(date.year, date.month, date.day)).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days >= 2 && days <= 6) return '$days days ago';
  }
  return (date.year == today.year ? DateFormat.MMMd() : DateFormat.yMMMd())
      .format(date);
}
