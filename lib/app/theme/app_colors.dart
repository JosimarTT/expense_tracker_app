import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFFFF9E44);
  static const primaryLight = Color(0xFFFFE8D2);
  static const primarySubtle = Color(0xFFFFF3E6);
  static const primaryDark = Color(0xFFE88523);

  static const coral = Color(0xFFFF7E6B);
  static const coralLight = Color(0xFFFFEDE9);
  static const coralForeground = Color(0xFFA63D30);
  static const currencyBadgeBackground = Color(0xFFFEE2E2);
  static const currencyBadgeBorder = Color(0xFFFECACA);
  static const currencyBadgeForeground = Color(0xFFDC2626);
  static const securityNoticeBackground = Color(0xFFFFFBEB);
  static const securityNoticeBorder = Color(0xFFFDE68A);
  static const securityNoticeForeground = Color(0xFFD97706);
  static const mint = Color(0xFF48D38A);
  static const mintLight = Color(0xFFE6F9F0);
  static const mintForeground = Color(0xFF176B42);
  static const sky = Color(0xFF5AB4FF);
  static const skyLight = Color(0xFFEBF6FF);
  static const lavender = Color(0xFFB590F8);
  static const lavenderLight = Color(0xFFF4EEFF);

  static const scaffoldBg = Color(0xFFFFF9F2);
  static const cardSurface = Color(0xFFFFFFFF);
  static const surfaceWarm = Color(0xFFFFF6ED);
  static const modalSurface = Color(0xFFFFFFFF);

  static const borderLight = Color(0xFFF4ECE2);
  static const borderInput = Color(0xFFEDE2D4);
  static const borderInputFocused = Color(0xFFFF9E44);

  static const textHeadline = Color(0xFF332923);
  static const textBody = Color(0xFF4A3E36);
  static const textMuted = Color(0xFF9E9188);
  static const textPlaceholder = Color(0xFFC7BCB3);

  static const avatarNekoBg = Color(0xFFFFF1DF);
  static const avatarPiggyBg = Color(0xFFFFEAE7);
  static const avatarKumaBg = Color(0xFFF7ECE1);
  static const avatarBobaBg = Color(0xFFEFE9FC);

  static const darkScaffoldBg = Color(0xFF1C1917);
  static const darkSurface = Color(0xFF292420);
  static const darkSurfaceWarm = Color(0xFF36302B);
  static const darkBorder = Color(0xFF423B35);
  static const darkTextPrimary = Color(0xFFFAF4EE);
  static const darkTextMuted = Color(0xFFA89E96);
}

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.income,
    required this.incomeContainer,
    required this.onIncomeContainer,
    required this.expense,
    required this.expenseContainer,
    required this.onExpenseContainer,
    required this.info,
    required this.infoContainer,
  });

  static const light = AppSemanticColors(
    income: AppColors.mint,
    incomeContainer: AppColors.mintLight,
    onIncomeContainer: AppColors.mintForeground,
    expense: AppColors.coral,
    expenseContainer: AppColors.coralLight,
    onExpenseContainer: AppColors.coralForeground,
    info: AppColors.sky,
    infoContainer: AppColors.skyLight,
  );

  static const dark = AppSemanticColors(
    income: AppColors.mint,
    incomeContainer: AppColors.darkSurfaceWarm,
    onIncomeContainer: AppColors.mint,
    expense: AppColors.coral,
    expenseContainer: AppColors.darkSurfaceWarm,
    onExpenseContainer: AppColors.coral,
    info: AppColors.sky,
    infoContainer: AppColors.darkSurfaceWarm,
  );

  final Color income;
  final Color incomeContainer;
  final Color onIncomeContainer;
  final Color expense;
  final Color expenseContainer;
  final Color onExpenseContainer;
  final Color info;
  final Color infoContainer;

  @override
  AppSemanticColors copyWith({
    Color? income,
    Color? incomeContainer,
    Color? onIncomeContainer,
    Color? expense,
    Color? expenseContainer,
    Color? onExpenseContainer,
    Color? info,
    Color? infoContainer,
  }) => AppSemanticColors(
    income: income ?? this.income,
    incomeContainer: incomeContainer ?? this.incomeContainer,
    onIncomeContainer: onIncomeContainer ?? this.onIncomeContainer,
    expense: expense ?? this.expense,
    expenseContainer: expenseContainer ?? this.expenseContainer,
    onExpenseContainer: onExpenseContainer ?? this.onExpenseContainer,
    info: info ?? this.info,
    infoContainer: infoContainer ?? this.infoContainer,
  );

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    return AppSemanticColors(
      income: Color.lerp(income, other.income, t)!,
      incomeContainer: Color.lerp(incomeContainer, other.incomeContainer, t)!,
      onIncomeContainer: Color.lerp(
        onIncomeContainer,
        other.onIncomeContainer,
        t,
      )!,
      expense: Color.lerp(expense, other.expense, t)!,
      expenseContainer: Color.lerp(
        expenseContainer,
        other.expenseContainer,
        t,
      )!,
      onExpenseContainer: Color.lerp(
        onExpenseContainer,
        other.onExpenseContainer,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
    );
  }
}
