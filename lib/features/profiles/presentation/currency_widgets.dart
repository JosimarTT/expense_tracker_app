import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/money/currency.dart';

String _currencySymbol(BuildContext context, String code) =>
    NumberFormat.simpleCurrency(
      locale: View.of(context).platformDispatcher.locale.toString(),
      name: code,
    ).currencySymbol;

class CurrencyBadge extends StatelessWidget {
  const CurrencyBadge({required this.code, super.key});

  final String code;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ExcludeSemantics(
      child: Container(
        width: 48,
        height: 48,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceWarm
              : AppColors.currencyBadgeBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder
                : AppColors.currencyBadgeBorder,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _currencySymbol(context, code),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 24,
              color: isDark
                  ? AppColors.coralLight
                  : AppColors.currencyBadgeForeground,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final code in ['USD', 'EUR', 'JPY', 'GBP', 'BRL'])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Tooltip(
                message: Currency.fromCode(code).name,
                child: ChoiceChip(
                  key: ValueKey('quick-currency-$code'),
                  showCheckmark: false,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currencySymbol(context, code),
                        style: TextStyle(
                          color: code == selectedCode
                              ? Colors.white
                              : (isDark
                                    ? AppColors.darkTextMuted
                                    : AppColors.textMuted),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(code),
                      if (code == selectedCode) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.check, size: 14),
                      ],
                    ],
                  ),
                  selected: code == selectedCode,
                  selectedColor: AppColors.primary,
                  backgroundColor: theme.colorScheme.surfaceContainerLow,
                  elevation: 0,
                  pressElevation: 0,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: code == selectedCode
                          ? AppColors.primary
                          : (isDark
                                ? AppColors.darkBorder
                                : AppColors.borderLight),
                      width: code == selectedCode ? 1.5 : 1,
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: code == selectedCode
                        ? Colors.white
                        : (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textBody),
                    fontWeight: FontWeight.w700,
                  ),
                  onSelected: onSelected == null
                      ? null
                      : (_) => onSelected!(code),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
