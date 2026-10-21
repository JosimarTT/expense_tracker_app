import 'package:expense_tracker_app/app/expense_tracker_app.dart';
import 'package:expense_tracker_app/app/providers.dart';
import 'package:expense_tracker_app/app/theme/app_colors.dart';
import 'package:expense_tracker_app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final theme in [AppTheme.light, AppTheme.dark]) {
    final brightness = theme.brightness;

    test('$brightness uses the shared palette and component geometry', () {
      final isDark = brightness == Brightness.dark;
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(
        theme.scaffoldBackgroundColor,
        isDark ? AppColors.darkScaffoldBg : AppColors.scaffoldBg,
      );
      expect(
        theme.colorScheme.surface,
        isDark ? AppColors.darkSurface : AppColors.cardSurface,
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

    test('$brightness follows the exact Stitch palette tokens', () {
      final isDark = brightness == Brightness.dark;
      final scheme = theme.colorScheme;
      final semantic = theme.extension<AppSemanticColors>()!;
      expect(scheme.primary, AppColors.primary);
      expect(scheme.onPrimary, Colors.white);
      expect(
        scheme.primaryContainer,
        isDark ? AppColors.darkSurfaceWarm : AppColors.primaryLight,
      );
      expect(scheme.secondary, AppColors.coral);
      expect(scheme.tertiary, AppColors.sky);
      expect(scheme.error, AppColors.coral);
      expect(semantic.income, AppColors.mint);
      expect(
        semantic.incomeContainer,
        isDark ? AppColors.darkSurfaceWarm : AppColors.mintLight,
      );
      expect(semantic.expense, AppColors.coral);
      expect(
        semantic.expenseContainer,
        isDark ? AppColors.darkSurfaceWarm : AppColors.coralLight,
      );
      expect(semantic.info, AppColors.sky);
      expect(
        semantic.infoContainer,
        isDark ? AppColors.darkSurfaceWarm : AppColors.skyLight,
      );
      expect(
        theme.inputDecorationTheme.fillColor,
        isDark ? AppColors.darkSurfaceWarm : AppColors.surfaceWarm,
      );
      expect(
        theme.inputDecorationTheme.hintStyle!.color,
        isDark ? AppColors.darkTextMuted : AppColors.textPlaceholder,
      );
      final border =
          theme.inputDecorationTheme.enabledBorder! as OutlineInputBorder;
      final focus =
          theme.inputDecorationTheme.focusedBorder! as OutlineInputBorder;
      expect(
        border.borderSide.color,
        isDark ? AppColors.darkBorder : AppColors.borderInput,
      );
      expect(focus.borderSide.color, AppColors.borderInputFocused);
      expect(focus.borderSide.width, 2);
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

  test('palette tokens match the Stitch color schema exactly', () {
    expect(AppColors.primary, const Color(0xFFFF9E44));
    expect(AppColors.primaryLight, const Color(0xFFFFE8D2));
    expect(AppColors.primarySubtle, const Color(0xFFFFF3E6));
    expect(AppColors.primaryDark, const Color(0xFFE88523));
    expect(AppColors.coral, const Color(0xFFFF7E6B));
    expect(AppColors.coralLight, const Color(0xFFFFEDE9));
    expect(AppColors.mint, const Color(0xFF48D38A));
    expect(AppColors.mintLight, const Color(0xFFE6F9F0));
    expect(AppColors.sky, const Color(0xFF5AB4FF));
    expect(AppColors.skyLight, const Color(0xFFEBF6FF));
    expect(AppColors.lavender, const Color(0xFFB590F8));
    expect(AppColors.lavenderLight, const Color(0xFFF4EEFF));
    expect(AppColors.scaffoldBg, const Color(0xFFFFF9F2));
    expect(AppColors.cardSurface, Colors.white);
    expect(AppColors.surfaceWarm, const Color(0xFFFFF6ED));
    expect(AppColors.modalSurface, Colors.white);
    expect(AppColors.borderLight, const Color(0xFFF4ECE2));
    expect(AppColors.borderInput, const Color(0xFFEDE2D4));
    expect(AppColors.borderInputFocused, const Color(0xFFFF9E44));
    expect(AppColors.textHeadline, const Color(0xFF332923));
    expect(AppColors.textBody, const Color(0xFF4A3E36));
    expect(AppColors.textMuted, const Color(0xFF9E9188));
    expect(AppColors.textPlaceholder, const Color(0xFFC7BCB3));
    expect(AppColors.avatarNekoBg, const Color(0xFFFFF1DF));
    expect(AppColors.avatarPiggyBg, const Color(0xFFFFEAE7));
    expect(AppColors.avatarKumaBg, const Color(0xFFF7ECE1));
    expect(AppColors.avatarBobaBg, const Color(0xFFEFE9FC));
    expect(AppColors.darkScaffoldBg, const Color(0xFF1C1917));
    expect(AppColors.darkSurface, const Color(0xFF292420));
    expect(AppColors.darkSurfaceWarm, const Color(0xFF36302B));
    expect(AppColors.darkBorder, const Color(0xFF423B35));
    expect(AppColors.darkTextPrimary, const Color(0xFFFAF4EE));
    expect(AppColors.darkTextMuted, const Color(0xFFA89E96));
  });

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
