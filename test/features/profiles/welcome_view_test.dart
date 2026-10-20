import 'dart:async';

import 'package:expense_tracker_app/app/expense_tracker_app.dart';
import 'package:expense_tracker_app/app/providers.dart';
import 'package:expense_tracker_app/app/theme/app_theme.dart';
import 'package:expense_tracker_app/core/money/currency.dart';
import 'package:expense_tracker_app/features/profiles/domain/profile.dart';
import 'package:expense_tracker_app/features/profiles/presentation/welcome_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final (size, scale) in [
      (const Size(320, 568), 2.0),
      (const Size(390, 844), 1.0),
      (const Size(1280, 800), 1.0),
    ]) {
      testWidgets('welcome fits $brightness at $size with text scale $scale', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var creations = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: brightness == Brightness.dark
                ? AppTheme.dark
                : AppTheme.light,
            home: MediaQuery(
              data: MediaQueryData(
                size: size,
                textScaler: TextScaler.linear(scale),
              ),
              child: Scaffold(
                body: WelcomeView(onCreateProfile: () => creations++),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Hi there, friend!'), findsOneWidget);
        expect(
          find.text('${Currency.supported.length} supported currencies'),
          findsOneWidget,
        );
        expect(find.byType(SvgPicture), findsOneWidget);
        expect(find.byType(FilledButton), findsOneWidget);
        expect(find.textContaining('Restore'), findsNothing);
        expect(find.textContaining('150+'), findsNothing);
        expect(find.textContaining('Spending Rings'), findsNothing);
        await tester.ensureVisible(find.text('Create your first profile'));
        await tester.pumpAndSettle();
        final button = find.byType(FilledButton);
        expect(tester.getSize(button).height, greaterThanOrEqualTo(54));
        await tester.tap(button);
        expect(creations, 1);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('loading and storage failure do not show the welcome screen', (
    tester,
  ) async {
    final profiles = StreamController<List<LocalProfile>>();
    addTearDown(profiles.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [profilesProvider.overrideWith((ref) => profiles.stream)],
        child: const ExpenseTrackerApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(WelcomeView), findsNothing);
    profiles.addError(StateError('storage unavailable'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Could not load local profiles'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
    expect(find.byType(WelcomeView), findsNothing);
  });

  testWidgets(
    'empty profiles show one creation action and cancel preserves welcome',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [profilesProvider.overrideWith((ref) => Stream.value([]))],
          child: const ExpenseTrackerApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(WelcomeView), findsOneWidget);
      expect(find.byType(AppBar), findsNothing);
      expect(find.byTooltip('Create profile'), findsNothing);
      await tester.ensureVisible(find.text('Create your first profile'));
      await tester.tap(find.text('Create your first profile'));
      await tester.pumpAndSettle();
      expect(find.text('Create local profile'), findsOneWidget);
      await tester.ensureVisible(find.text('Cancel'));
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(WelcomeView), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
