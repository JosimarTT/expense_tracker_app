import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static final light = _build(Brightness.light);
  static final dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final warmSurface = isDark
        ? AppColors.darkSurfaceWarm
        : AppColors.lightSurfaceWarm;
    final background = isDark ? AppColors.darkBg : AppColors.lightBg;
    final text = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final secondaryText = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final accentText = isDark
        ? AppColors.primaryLight
        : const Color(0xFF9C4C00);
    final semantic = isDark ? AppSemanticColors.dark : AppSemanticColors.light;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: brightness,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: AppColors.lightTextPrimary,
          primaryContainer: isDark ? warmSurface : AppColors.primaryLight,
          onPrimaryContainer: accentText,
          secondary: AppColors.secondary,
          onSecondary: AppColors.lightTextPrimary,
          secondaryContainer: isDark
              ? const Color(0xFF4B2B27)
              : AppColors.secondaryLight,
          onSecondaryContainer: isDark
              ? AppColors.secondaryLight
              : const Color(0xFF873B32),
          tertiary: semantic.info,
          onTertiary: isDark ? AppColors.darkBg : Colors.white,
          tertiaryContainer: semantic.infoContainer,
          onTertiaryContainer: semantic.info,
          surface: surface,
          onSurface: text,
          onSurfaceVariant: secondaryText,
          surfaceDim: background,
          surfaceBright: warmSurface,
          surfaceContainerLowest: background,
          surfaceContainerLow: warmSurface,
          surfaceContainer: warmSurface,
          surfaceContainerHigh: warmSurface,
          surfaceContainerHighest: warmSurface,
          outline: secondaryText,
          outlineVariant: border,
          error: semantic.expense,
          onError: isDark ? AppColors.darkBg : Colors.white,
          errorContainer: semantic.expenseContainer,
          onErrorContainer: semantic.expense,
          inverseSurface: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
          onInverseSurface: isDark
              ? AppColors.lightTextPrimary
              : AppColors.darkTextPrimary,
          inversePrimary: isDark
              ? const Color(0xFF9C4C00)
              : AppColors.primaryLight,
          surfaceTint: Colors.transparent,
        );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: 'Nunito',
      scaffoldBackgroundColor: background,
      extensions: [semantic],
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: BorderSide(color: border),
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: secondaryText),
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerColor: border,
      hintColor: secondaryText,
      appBarTheme: AppBarThemeData(
        backgroundColor: background,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: shape,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: shape,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 54),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          minimumSize: const Size(64, 54),
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentText,
          minimumSize: const Size(48, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentText,
          minimumSize: const Size(48, 48),
          shape: const StadiumBorder(),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: warmSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: accentText, width: 2),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        hintStyle: TextStyle(color: secondaryText),
        labelStyle: TextStyle(color: secondaryText),
        floatingLabelStyle: TextStyle(color: accentText),
      ),
    );
  }
}
