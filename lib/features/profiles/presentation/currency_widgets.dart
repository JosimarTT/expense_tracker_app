import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/money/currency.dart';

class CurrencyBadge extends StatelessWidget {
  const CurrencyBadge({required this.code, super.key});

  final String code;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
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
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            symbol,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: colors.onPrimaryContainer),
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
    final colors = Theme.of(context).colorScheme;
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
              selectedColor: colors.primaryContainer,
              checkmarkColor: colors.onPrimaryContainer,
              labelStyle: TextStyle(
                color: code == selectedCode
                    ? colors.onPrimaryContainer
                    : colors.onSurface,
              ),
              onSelected: onSelected == null ? null : (_) => onSelected!(code),
            ),
          ),
      ],
    );
  }
}
