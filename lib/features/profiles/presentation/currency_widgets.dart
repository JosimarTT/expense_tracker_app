import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/money/currency.dart';

class CurrencyBadge extends StatelessWidget {
  const CurrencyBadge({required this.code, super.key});

  final String code;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final symbol = NumberFormat.simpleCurrency(
      locale: View.of(context).platformDispatcher.locale.toString(),
      name: code,
    ).currencySymbol;
    return ExcludeSemantics(
      child: Container(
        width: 48,
        height: 48,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceWarm : AppColors.primarySubtle,
          borderRadius: BorderRadius.circular(16),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            symbol,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
            ),
          ),
        ),
      ),
    );
  }
}

class PopularCurrencyChips extends StatelessWidget {
  const PopularCurrencyChips({
    required this.selectedCode,
    required this.onSelected,
    super.key,
  });

  final String selectedCode;
  final ValueChanged<String>? onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final code in ['USD', 'EUR', 'JPY', 'GBP', 'BRL'])
          Tooltip(
            message: Currency.fromCode(code).name,
            child: ChoiceChip(
              key: ValueKey('quick-currency-$code'),
              label: Text(code),
              selected: code == selectedCode,
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              elevation: code == selectedCode ? 2 : 0,
              pressElevation: 3,
              shadowColor: AppColors.primary.withValues(alpha: 0.2),
              shape: StadiumBorder(
                side: BorderSide(
                  color: code == selectedCode
                      ? AppColors.primary
                      : (Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkBorder
                            : AppColors.borderLight),
                  width: code == selectedCode ? 1.5 : 1.2,
                ),
              ),
              labelStyle: TextStyle(
                color: code == selectedCode
                    ? Colors.white
                    : (Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkTextMuted
                          : AppColors.textBody),
                fontWeight: FontWeight.w700,
              ),
              onSelected: onSelected == null ? null : (_) => onSelected!(code),
            ),
          ),
      ],
    );
  }
}
