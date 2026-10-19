import 'package:expense_tracker_app/features/profiles/domain/category_options.dart';
import 'package:expense_tracker_app/features/profiles/presentation/category_avatar.dart';
import 'package:expense_tracker_app/features/profiles/presentation/category_editor_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Category picker and preview share the selected icon and color', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: CategoryEditorDialog(profileId: 'a')),
        ),
      ),
    );
    final iconOption = find.byKey(
      const ValueKey('category-icon-subscriptions'),
    );
    await tester.ensureVisible(iconOption);
    await tester.tap(iconOption);
    await tester.pumpAndSettle();
    final color = CategoryPresentationOptions.colors[1];
    final colorOption = find.byKey(ValueKey('category-color-$color'));
    await tester.ensureVisible(colorOption);
    await tester.tap(colorOption);
    await tester.pumpAndSettle();
    final avatars = tester
        .widgetList<CategoryAvatar>(find.byType(CategoryAvatar))
        .toList();
    expect(avatars, hasLength(categoryIcons.length + 1));
    expect(avatars.every((avatar) => avatar.colorArgb == color), isTrue);
    expect(avatars.last.iconKey, 'subscriptions');
  });

  testWidgets(
    'Every predefined category icon uses a colored circle and white icon',
    (tester) async {
      expect(categoryIcons.keys.toSet(), CategoryPresentationOptions.iconKeys);
      for (final key in [...categoryIcons.keys, 'unknown']) {
        await tester.pumpWidget(
          MaterialApp(
            home: CategoryAvatar(iconKey: key, colorArgb: 0xFF1565C0),
          ),
        );
        final circle = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
        final icon = tester.widget<Icon>(find.byType(Icon));
        expect(circle.backgroundColor, const Color(0xFF1565C0));
        expect(circle.radius, 20);
        expect(icon.color, Colors.white);
        expect(icon.icon, categoryIcons[key] ?? Icons.category);
      }
    },
  );
}
