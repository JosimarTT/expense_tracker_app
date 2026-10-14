import 'package:expense_tracker_app/app/expense_tracker_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Shows the local-first scaffold without opening storage', (
    tester,
  ) async {
    await tester.pumpWidget(const ExpenseTrackerApp());

    expect(find.text('Expense Tracker'), findsOneWidget);
    expect(find.text('Your finances, local first'), findsOneWidget);
    expect(find.textContaining('Architecture scaffold ready'), findsOneWidget);
  });
}
