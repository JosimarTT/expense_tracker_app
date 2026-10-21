import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static final light = _build(Brightness.light);
  static final dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.cardSurface;
    final warmSurface = isDark
        ? AppColors.darkSurfaceWarm
        : AppColors.surfaceWarm;
    final background = isDark ? AppColors.darkScaffoldBg : AppColors.scaffoldBg;
    final text = isDark ? AppColors.darkTextPrimary : AppColors.textHeadline;
    final secondaryText = isDark
        ? AppColors.darkTextMuted
        : AppColors.textMuted;
    final border = isDark ? AppColors.darkBorder : AppColors.borderLight;
    final accentText = isDark ? AppColors.primaryLight : AppColors.textBody;
    final semantic = isDark ? AppSemanticColors.dark : AppSemanticColors.light;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: brightness,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          primaryContainer: isDark
              ? AppColors.darkSurfaceWarm
              : AppColors.primaryLight,
          onPrimaryContainer: isDark ? AppColors.darkTextPrimary : text,
          secondary: AppColors.coral,
          onSecondary: AppColors.textHeadline,
          secondaryContainer: isDark
              ? AppColors.darkSurfaceWarm
              : AppColors.coralLight,
          onSecondaryContainer: isDark ? AppColors.darkTextPrimary : text,
          tertiary: AppColors.sky,
          onTertiary: AppColors.textHeadline,
          tertiaryContainer: isDark
              ? AppColors.darkSurfaceWarm
              : AppColors.skyLight,
          onTertiaryContainer: isDark ? AppColors.darkTextPrimary : text,
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
          outline: isDark ? AppColors.darkTextMuted : AppColors.borderInput,
          outlineVariant: border,
          error: AppColors.coral,
          onError: AppColors.textHeadline,
          errorContainer: isDark
              ? AppColors.darkSurfaceWarm
              : AppColors.coralLight,
          onErrorContainer: isDark ? AppColors.darkTextPrimary : text,
          inverseSurface: isDark
              ? AppColors.darkTextPrimary
              : AppColors.textHeadline,
          onInverseSurface: isDark
              ? AppColors.textHeadline
              : AppColors.darkTextPrimary,
          inversePrimary: AppColors.primaryDark,
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
      borderSide: BorderSide(
        color: isDark ? AppColors.darkBorder : AppColors.borderInput,
        width: isDark ? 1 : 1.2,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textHeadline,
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textHeadline,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textHeadline,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textBody,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          color: secondaryText,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerColor: border,
      hintColor: isDark ? AppColors.darkTextMuted : AppColors.textPlaceholder,
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
        backgroundColor: isDark ? surface : AppColors.modalSurface,
        shape: shape,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? surface : AppColors.modalSurface,
        modalBackgroundColor: isDark ? surface : AppColors.modalSurface,
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
          borderSide: const BorderSide(
            color: AppColors.borderInputFocused,
            width: 2,
          ),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        hintStyle: TextStyle(
          color: isDark ? AppColors.darkTextMuted : AppColors.textPlaceholder,
        ),
        labelStyle: TextStyle(color: secondaryText),
        floatingLabelStyle: const TextStyle(
          color: AppColors.borderInputFocused,
        ),
      ),
    );
  }
}
