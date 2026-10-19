import 'package:expense_tracker_app/features/profiles/presentation/currency_picker_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Shows code above name, symbol on the right and selected check', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: CurrencyPickerDialog(selectedCode: 'USD')),
      ),
    );
    final search = find.widgetWithText(TextField, 'Search currencies');
    for (final (query, code, name, symbol) in [
      ('USD', 'USD', 'US dollar', r'$'),
      ('Peru', 'PEN', 'Peruvian sol', 'S/'),
      ('Euro', 'EUR', 'Euro', '€'),
    ]) {
      await tester.enterText(search, query);
      await tester.pumpAndSettle();
      final row = find.byType(ListTile);
      final codeLabel = find.descendant(of: row, matching: find.text(code));
      final nameLabel = find.descendant(of: row, matching: find.text(name));
      final tile = tester.widget<ListTile>(row);
      expect((tile.title! as Text).data, code);
      expect((tile.subtitle! as Text).data, name);
      final symbolFinder = find.descendant(
        of: row,
        matching: find.text(symbol),
      );
      expect(symbolFinder, findsOneWidget);
      expect(
        tester.getTopLeft(nameLabel).dy,
        greaterThan(tester.getTopLeft(codeLabel).dy),
      );
      expect(
        tester.getTopLeft(symbolFinder).dx,
        greaterThan(tester.getTopLeft(codeLabel).dx),
      );
      expect(tile.selected, code == 'USD');
      expect(
        find.byIcon(Icons.check),
        code == 'USD' ? findsOneWidget : findsNothing,
      );
      expect(find.textContaining('decimal places'), findsNothing);
    }
  });
}
