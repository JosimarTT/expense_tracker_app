import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../transactions/domain/entities/financial_transaction.dart';

/// Type pill shared by the Transactions header and the filter sheet. A
/// selected type uses its semantic container and foreground colors; "All"
/// (null) keeps the default selected style.
class TransactionTypePill extends StatelessWidget {
  const TransactionTypePill({
    super.key,
    required this.type,
    required this.selected,
    required this.onSelected,
  });

  final TransactionType? type;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<AppSemanticColors>()!;
    final (container, foreground) = switch (type) {
      TransactionType.income => (
        semantic.incomeContainer,
        semantic.onIncomeContainer,
      ),
      TransactionType.expense => (
        semantic.expenseContainer,
        semantic.onExpenseContainer,
      ),
      TransactionType.savings => (
        semantic.infoContainer,
        semantic.onInfoContainer,
      ),
      null => (null, null),
    };
    final label = Text(type?.label ?? 'All');
    return ChoiceChip(
      shape: container == null || !selected
          ? const StadiumBorder()
          : StadiumBorder(side: BorderSide(color: foreground!)),
      showCheckmark: false,
      label: foreground == null || !selected
          ? label
          : DefaultTextStyle.merge(
              style: TextStyle(color: foreground),
              child: label,
            ),
      selectedColor: container,
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}
