import 'package:expense_tracker_app/app/theme/app_theme.dart';
import 'package:expense_tracker_app/core/money/currency.dart';
import 'package:expense_tracker_app/features/profiles/presentation/currency_picker_dialog.dart';
import 'package:expense_tracker_app/features/profiles/presentation/currency_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _openPicker(
  WidgetTester tester, {
  Brightness brightness = Brightness.light,
  Size size = const Size(800, 900),
  double scale = 1,
  ValueChanged<String?>? onResult,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              final result = await showDialog<String>(
                context: context,
                builder: (_) => const CurrencyPickerDialog(selectedCode: 'USD'),
              );
              onResult?.call(result);
            },
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('search keeps codes, names, badges and selection clear', (
    tester,
  ) async {
    await _openPicker(tester);
    final search = find.widgetWithText(TextField, 'Search currencies');
    for (final (query, code, name, symbol) in [
      ('USD', 'USD', 'US dollar', r'$'),
      ('Peru', 'PEN', 'Peruvian sol', 'S/'),
      ('Euro', 'EUR', 'Euro', '€'),
      ('  yen  ', 'JPY', 'Japanese yen', '¥'),
      ('kuwait', 'KWD', 'Kuwaiti dinar', 'din'),
    ]) {
      await tester.enterText(search, query);
      await tester.pumpAndSettle();
      final row = find.byKey(ValueKey('currency-$code'));
      final codeLabel = find.descendant(of: row, matching: find.text(code));
      final nameLabel = find.descendant(of: row, matching: find.text(name));
      final badge = find.descendant(
        of: row,
        matching: find.byType(CurrencyBadge),
      );
      expect(row, findsOneWidget);
      expect(nameLabel, findsOneWidget);
      expect(
        find.descendant(of: badge, matching: find.text(symbol)),
        findsOneWidget,
      );
      expect(
        tester.getTopLeft(nameLabel).dy,
        greaterThan(tester.getTopLeft(codeLabel.first).dy),
      );
      expect(
        find.byIcon(Icons.check_circle),
        code == 'USD' ? findsOneWidget : findsNothing,
      );
      expect(find.text('Popular currencies'), findsNothing);
      expect(find.textContaining('decimal places'), findsNothing);
    }
  });

  testWidgets(
    'no results and clear search restore all currencies and quick picks',
    (tester) async {
      await _openPicker(tester);
      await tester.enterText(find.byType(TextField), 'not a currency');
      await tester.pumpAndSettle();
      expect(find.text('No matching currencies.'), findsOneWidget);
      expect(find.text('0 matching currencies'), findsOneWidget);
      await tester.tap(find.byTooltip('Clear currency search'));
      await tester.pumpAndSettle();
      expect(
        find.text('All currencies (${Currency.supported.length})'),
        findsOneWidget,
      );
      expect(
        find.byType(CurrencyBadge),
        findsNWidgets(Currency.supported.length),
      );
      expect(find.byType(ChoiceChip), findsNWidgets(5));
      expect(find.text('No matching currencies.'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final code in ['EUR', 'JPY', 'GBP', 'BRL']) {
    testWidgets('popular $code returns the selected code', (tester) async {
      String? selected;
      await _openPicker(tester, onResult: (value) => selected = value);
      await tester.ensureVisible(find.byKey(ValueKey('quick-currency-$code')));
      await tester.tap(find.byKey(ValueKey('quick-currency-$code')));
      await tester.pumpAndSettle();
      expect(selected, code);
      expect(find.byType(CurrencyPickerDialog), findsNothing);
    });
  }

  for (final brightness in Brightness.values) {
    for (final (size, scale) in [
      (const Size(320, 568), 2.0),
      (const Size(390, 844), 1.0),
      (const Size(1280, 900), 1.0),
    ]) {
      testWidgets('currency picker fits $brightness at $size, scale $scale', (
        tester,
      ) async {
        String? selected;
        await _openPicker(
          tester,
          size: size,
          scale: scale,
          brightness: brightness,
          onResult: (value) => selected = value,
        );
        await tester.ensureVisible(find.byType(TextField));
        await tester.enterText(find.byType(TextField), 'yen');
        tester.view.viewInsets = const FakeViewPadding(bottom: 220);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const ValueKey('currency-JPY')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('currency-JPY')));
        await tester.pumpAndSettle();
        expect(selected, 'JPY');
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('cancel returns no replacement currency', (tester) async {
    String? selected = 'unchanged';
    await _openPicker(tester, onResult: (value) => selected = value);
    await tester.ensureVisible(find.text('Cancel'));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(selected, isNull);
    expect(find.byType(CurrencyPickerDialog), findsNothing);
  });
}
