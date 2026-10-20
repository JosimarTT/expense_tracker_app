import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFFFF9F43);
  static const primaryLight = Color(0xFFFFEAD1);
  static const primaryDark = Color(0xFFE58325);
  static const secondary = Color(0xFFFF8577);
  static const secondaryLight = Color(0xFFFFE5E2);
  static const income = Color(0xFF2ECC71);
  static const incomeBg = Color(0xFFE8F8F0);
  static const expense = Color(0xFFFF5252);
  static const expenseBg = Color(0xFFFFEEEE);
  static const info = Color(0xFF54A0FF);
  static const infoBg = Color(0xFFEBF3FF);

  static const lightBg = Color(0xFFFAF7F2);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceWarm = Color(0xFFFFF9F2);
  static const lightBorder = Color(0xFFF0EAE1);
  static const lightTextPrimary = Color(0xFF2D2621);
  static const lightTextSecondary = Color(0xFF70655D);
  static const darkBg = Color(0xFF181614);
  static const darkSurface = Color(0xFF24201D);
  static const darkSurfaceWarm = Color(0xFF2D2824);
  static const darkBorder = Color(0xFF38322D);
  static const darkTextPrimary = Color(0xFFF7F2EC);
  static const darkTextSecondary = Color(0xFFA69D95);
}

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.income,
    required this.incomeContainer,
    required this.expense,
    required this.expenseContainer,
    required this.info,
    required this.infoContainer,
  });

  static const light = AppSemanticColors(
    income: Color(0xFF187344),
    incomeContainer: AppColors.incomeBg,
    expense: Color(0xFFBA3030),
    expenseContainer: AppColors.expenseBg,
    info: Color(0xFF245EA8),
    infoContainer: AppColors.infoBg,
  );

  static const dark = AppSemanticColors(
    income: Color(0xFF65DB97),
    incomeContainer: Color(0xFF183A28),
    expense: Color(0xFFFFB4AB),
    expenseContainer: Color(0xFF4B2424),
    info: Color(0xFFA6C8FF),
    infoContainer: Color(0xFF20334D),
  );

  final Color income;
  final Color incomeContainer;
  final Color expense;
  final Color expenseContainer;
  final Color info;
  final Color infoContainer;

  @override
  AppSemanticColors copyWith({
    Color? income,
    Color? incomeContainer,
    Color? expense,
    Color? expenseContainer,
    Color? info,
    Color? infoContainer,
  }) => AppSemanticColors(
    income: income ?? this.income,
    incomeContainer: incomeContainer ?? this.incomeContainer,
    expense: expense ?? this.expense,
    expenseContainer: expenseContainer ?? this.expenseContainer,
    info: info ?? this.info,
    infoContainer: infoContainer ?? this.infoContainer,
  );

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    return AppSemanticColors(
      income: Color.lerp(income, other.income, t)!,
      incomeContainer: Color.lerp(incomeContainer, other.incomeContainer, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      expenseContainer: Color.lerp(
        expenseContainer,
        other.expenseContainer,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
    );
  }
}
