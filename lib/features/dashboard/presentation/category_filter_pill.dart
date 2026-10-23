import 'package:flutter/material.dart';

import '../../profiles/domain/profile.dart';
import '../../profiles/presentation/category_avatar.dart';

class CategoryFilterPill extends StatelessWidget {
  const CategoryFilterPill({
    super.key,
    required this.category,
    required this.selected,
    required this.onSelected,
  });

  final TransactionCategory category;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorArgb);
    final foreground = color.computeLuminance() > 0.179
        ? Colors.black
        : Colors.white;
    return FilterChip(
      selected: selected,
      onSelected: onSelected,
      selectedColor: color,
      checkmarkColor: foreground,
      shape: const StadiumBorder(),
      avatar: selected
          ? null
          : Icon(
              categoryIcons[category.iconKey] ?? Icons.category,
              color: color,
              size: 18,
            ),
      labelStyle: selected ? TextStyle(color: foreground) : null,
      label: Text(
        category.isArchived ? '${category.name} (archived)' : category.name,
      ),
    );
  }
}
