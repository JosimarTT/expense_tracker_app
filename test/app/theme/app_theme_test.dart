import 'package:expense_tracker_app/app/expense_tracker_app.dart';
import 'package:expense_tracker_app/app/providers.dart';
import 'package:expense_tracker_app/app/theme/app_colors.dart';
import 'package:expense_tracker_app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

double contrast(Color first, Color second) {
  final a = first.computeLuminance();
  final b = second.computeLuminance();
  return a > b ? (a + 0.05) / (b + 0.05) : (b + 0.05) / (a + 0.05);
}

void main() {
  for (final theme in [AppTheme.light, AppTheme.dark]) {
    final brightness = theme.brightness;

    test('$brightness uses the shared palette and component geometry', () {
      final isDark = brightness == Brightness.dark;
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(
        theme.scaffoldBackgroundColor,
        isDark ? AppColors.darkBg : AppColors.lightBg,
      );
      expect(
        theme.colorScheme.surface,
        isDark ? AppColors.darkSurface : AppColors.lightSurface,
      );
      expect(theme.textTheme.bodyLarge?.fontFamily, 'Nunito');
      expect(theme.textTheme.headlineMedium?.fontWeight, FontWeight.w800);
      expect(
        theme.cardTheme.shape,
        isA<RoundedRectangleBorder>().having(
          (shape) => shape.borderRadius,
          'borderRadius',
          BorderRadius.circular(24),
        ),
      );
      expect(
        theme.bottomSheetTheme.shape,
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      );
      expect(
        theme.filledButtonTheme.style?.minimumSize?.resolve({}),
        const Size(64, 54),
      );
      expect(
        theme.inputDecorationTheme.enabledBorder,
        isA<OutlineInputBorder>().having(
          (border) => border.borderRadius,
          'borderRadius',
          BorderRadius.circular(20),
        ),
      );
    });

    test('$brightness text and semantic pairs meet 4.5:1 contrast', () {
      final scheme = theme.colorScheme;
      final semantic = theme.extension<AppSemanticColors>()!;
      final pairs = [
        (scheme.onPrimary, scheme.primary),
        (scheme.onPrimaryContainer, scheme.primaryContainer),
        (scheme.onSecondary, scheme.secondary),
        (scheme.onSecondaryContainer, scheme.secondaryContainer),
        (scheme.onTertiary, scheme.tertiary),
        (scheme.onError, scheme.error),
        (scheme.onSurface, scheme.surface),
        (scheme.onSurface, theme.scaffoldBackgroundColor),
        (scheme.onSurfaceVariant, scheme.surface),
        (scheme.onSurfaceVariant, scheme.surfaceContainer),
        (scheme.onInverseSurface, scheme.inverseSurface),
        (scheme.inversePrimary, scheme.inverseSurface),
        (semantic.income, semantic.incomeContainer),
        (semantic.expense, semantic.expenseContainer),
        (semantic.info, semantic.infoContainer),
        (theme.inputDecorationTheme.hintStyle!.color!, scheme.surfaceContainer),
        (
          theme.textButtonTheme.style!.foregroundColor!.resolve({})!,
          scheme.surface,
        ),
      ];
      for (final (foreground, background) in pairs) {
        expect(
          contrast(foreground, background),
          greaterThanOrEqualTo(4.5),
          reason: '$foreground on $background',
        );
      }
      final border =
          theme.inputDecorationTheme.enabledBorder! as OutlineInputBorder;
      final focus =
          theme.inputDecorationTheme.focusedBorder! as OutlineInputBorder;
      expect(
        contrast(border.borderSide.color, scheme.surfaceContainer),
        greaterThanOrEqualTo(3),
      );
      expect(
        contrast(focus.borderSide.color, scheme.surfaceContainer),
        greaterThanOrEqualTo(3),
      );
    });

    testWidgets(
      '$brightness follows system preference and keeps creation usable',
      (tester) async {
        tester.platformDispatcher.platformBrightnessTestValue = brightness;
        addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              profilesProvider.overrideWith((ref) => Stream.value([])),
            ],
            child: const ExpenseTrackerApp(),
          ),
        );
        await tester.pumpAndSettle();
        final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(app.themeMode, ThemeMode.system);
        expect(
          Theme.of(tester.element(find.byType(Scaffold))).brightness,
          brightness,
        );
        await tester.ensureVisible(find.text('Create your first profile'));
        await tester.tap(find.text('Create your first profile'));
        await tester.pumpAndSettle();
        expect(find.text('Create local profile'), findsOneWidget);
        await tester.ensureVisible(find.text('Create'));
        await tester.tap(find.text('Create'));
        await tester.pumpAndSettle();
        expect(find.text('Enter a profile name.'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  test('semantic theme extension supports copy and animation', () {
    const light = AppSemanticColors.light;
    const dark = AppSemanticColors.dark;
    expect(light.copyWith().income, light.income);
    expect(light.copyWith(info: Colors.purple).info, Colors.purple);
    expect(light.lerp(null, 0.5), same(light));
    expect(light.lerp(dark, 0).expense, light.expense);
    expect(light.lerp(dark, 1).infoContainer, dark.infoContainer);
    expect(
      light.lerp(dark, 0.5).income,
      Color.lerp(light.income, dark.income, 0.5),
    );
  });

  testWidgets('bundled Nunito font is a valid TrueType asset', (tester) async {
    final data = await rootBundle.load('assets/fonts/Nunito-Variable.ttf');
    expect(data.getUint32(0), 0x00010000);
    final loader = FontLoader('Nunito')..addFont(Future.value(data));
    await loader.load();
  });
}
