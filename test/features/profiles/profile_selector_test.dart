import 'package:expense_tracker_app/app/theme/app_theme.dart';
import 'package:expense_tracker_app/features/profiles/domain/profile.dart';
import 'package:expense_tracker_app/features/profiles/presentation/profile_avatar.dart';
import 'package:expense_tracker_app/features/profiles/presentation/profile_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        'selector handles long names in $brightness at $scale scale',
        (tester) async {
          tester.view.physicalSize = const Size(320, 568);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          const profiles = [
            LocalProfile(
              id: 'a',
              name: 'Personal household and daily spending',
              currencyCode: 'USD',
              currencyScale: 2,
            ),
            LocalProfile(
              id: 'b',
              name: 'Travel and holiday savings for next year',
              currencyCode: 'JPY',
              currencyScale: 0,
              avatar: ProfileAvatar.kuma,
            ),
          ];
          var selected = profiles.first;
          await tester.pumpWidget(
            MaterialApp(
              theme: brightness == Brightness.dark
                  ? AppTheme.dark
                  : AppTheme.light,
              home: MediaQuery(
                data: MediaQueryData(
                  size: const Size(320, 568),
                  textScaler: TextScaler.linear(scale),
                ),
                child: Scaffold(
                  body: StatefulBuilder(
                    builder: (context, setState) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: ProfileSelector(
                        profiles: profiles,
                        selected: selected,
                        onSelected: (id) => setState(
                          () => selected = profiles.singleWhere(
                            (profile) => profile.id == id,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.byType(DropdownButtonFormField<String>));
          await tester.pumpAndSettle();
          await tester.ensureVisible(
            find.text('${profiles.last.name} (JPY)').last,
          );
          await tester.tap(find.text('${profiles.last.name} (JPY)').last);
          await tester.pumpAndSettle();
          expect(selected.id, 'b');
          expect(
            tester
                .widget<ProfileAvatarIcon>(find.byType(ProfileAvatarIcon))
                .avatar,
            ProfileAvatar.kuma,
          );
          expect(
            find.byTooltip('${profiles.last.name} (JPY) - Kuma'),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
