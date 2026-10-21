import 'dart:async';

import 'package:expense_tracker_app/app/providers.dart';
import 'package:expense_tracker_app/app/theme/app_colors.dart';
import 'package:expense_tracker_app/app/theme/app_theme.dart';
import 'package:expense_tracker_app/features/profiles/domain/profile.dart';
import 'package:expense_tracker_app/features/profiles/presentation/currency_widgets.dart';
import 'package:expense_tracker_app/features/profiles/presentation/profile_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingRepository implements ProfileRepository {
  _RecordingRepository({this.profiles = const []});

  final created = <LocalProfile>[];
  final List<LocalProfile> profiles;
  var save = Completer<void>();

  @override
  Future<void> create(LocalProfile profile) {
    created.add(profile);
    return save.future;
  }

  @override
  Stream<List<LocalProfile>> watchProfiles() => Stream.value(profiles);

  @override
  Stream<List<TransactionCategory>> watchCategories(String profileId) =>
      Stream.value([]);

  @override
  Future<void> deletePermanently(String profileId) =>
      throw UnimplementedError();
}

Future<void> _openForm(
  WidgetTester tester,
  _RecordingRepository repository, {
  Size size = const Size(800, 900),
  Brightness brightness = Brightness.light,
  double scale = 1,
  ValueChanged<String?>? onResult,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [profileRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                final result = await showProfileDialog(context);
                onResult?.call(result);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pump();
}

void main() {
  test('profile currency and notice colors match the screen reference', () {
    expect(AppColors.currencyBadgeBackground, const Color(0xFFFEE2E2));
    expect(AppColors.currencyBadgeBorder, const Color(0xFFFECACA));
    expect(AppColors.currencyBadgeForeground, const Color(0xFFDC2626));
    expect(AppColors.securityNoticeBackground, const Color(0xFFFFFBEB));
    expect(AppColors.securityNoticeBorder, const Color(0xFFFDE68A));
    expect(AppColors.securityNoticeForeground, const Color(0xFFD97706));
  });

  for (final brightness in Brightness.values) {
    for (final (size, scale) in [
      (const Size(320, 568), 2.0),
      (const Size(390, 844), 1.0),
      (const Size(1000, 900), 1.0),
    ]) {
      testWidgets('profile form adapts to $brightness at $size, scale $scale', (
        tester,
      ) async {
        final isDark = brightness == Brightness.dark;
        final repository = _RecordingRepository();
        await _openForm(
          tester,
          repository,
          size: size,
          brightness: brightness,
          scale: scale,
        );
        expect(
          find.byType(BottomSheet),
          size.width < 600 ? findsOneWidget : findsNothing,
        );
        expect(
          find.byType(Dialog),
          size.width < 600 ? findsNothing : findsOneWidget,
        );
        final nekoStyle = tester
            .widget<OutlinedButton>(find.byKey(const ValueKey('avatar-neko')))
            .style!;
        final nekoBackground = nekoStyle.backgroundColor!.resolve({});
        expect(
          nekoBackground,
          isDark ? AppColors.darkSurfaceWarm : AppColors.primarySubtle,
        );
        final nekoBorder = nekoStyle.side!.resolve({})!;
        expect(nekoBorder.color, AppColors.primary);
        expect(nekoBorder.width, 2);
        final avatarButtons = [
          for (final avatar in ProfileAvatar.values)
            find.byKey(ValueKey('avatar-${avatar.name}')),
        ];
        final avatarWidths = [
          for (final button in avatarButtons) tester.getSize(button).width,
        ];
        expect(
          avatarWidths.reduce((a, b) => a > b ? a : b) -
              avatarWidths.reduce((a, b) => a < b ? a : b),
          lessThan(1),
        );
        for (final avatar in ProfileAvatar.values.skip(1)) {
          final style = tester
              .widget<OutlinedButton>(
                find.byKey(ValueKey('avatar-${avatar.name}')),
              )
              .style!;
          expect(
            style.backgroundColor!.resolve({}),
            isDark ? AppColors.darkSurface : AppColors.surfaceWarm,
          );
        }
        expect(
          find.byKey(const ValueKey('avatar-selected-badge')),
          findsOneWidget,
        );
        final currencyBadge = find.descendant(
          of: find.byKey(const Key('profile-currency')),
          matching: find.byType(CurrencyBadge),
        );
        final badgeContainer = tester.widget<Container>(
          find.descendant(of: currencyBadge, matching: find.byType(Container)),
        );
        expect(
          (badgeContainer.decoration! as BoxDecoration).color,
          isDark
              ? AppColors.darkSurfaceWarm
              : AppColors.currencyBadgeBackground,
        );
        expect(
          ((badgeContainer.decoration! as BoxDecoration).border! as Border)
              .top
              .color,
          isDark ? AppColors.darkBorder : AppColors.currencyBadgeBorder,
        );
        expect(
          tester
              .widget<Text>(
                find.descendant(of: currencyBadge, matching: find.text(r'$')),
              )
              .style!
              .color,
          isDark ? AppColors.coralLight : AppColors.currencyBadgeForeground,
        );
        final piggyStyle = tester
            .widget<OutlinedButton>(find.byKey(const ValueKey('avatar-piggy')))
            .style!;
        expect(
          piggyStyle.backgroundColor!.resolve({}),
          isDark ? AppColors.darkSurface : AppColors.surfaceWarm,
        );
        final selectedChip = tester.widget<ChoiceChip>(
          find.byKey(const ValueKey('quick-currency-USD')),
        );
        expect(selectedChip.selectedColor, AppColors.primary);
        expect(selectedChip.elevation, 0);
        expect(selectedChip.pressElevation, 0);
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('quick-currency-USD')),
            matching: find.text(r'$'),
          ),
          findsOneWidget,
        );
        await tapVisible(tester, find.byKey(const ValueKey('avatar-piggy')));
        final selectedPiggyStyle = tester
            .widget<OutlinedButton>(find.byKey(const ValueKey('avatar-piggy')))
            .style!;
        expect(
          selectedPiggyStyle.backgroundColor!.resolve({}),
          isDark ? AppColors.darkSurfaceWarm : AppColors.primarySubtle,
        );
        await tester.ensureVisible(find.byType(TextFormField));
        await tester.enterText(find.byType(TextFormField), 'Travel');
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
        await tapVisible(
          tester,
          find.byKey(const ValueKey('quick-currency-JPY')),
        );
        expect(find.byKey(const Key('profile-preview')), findsNothing);
        final noticeStyle =
            tester
                    .widget<Container>(find.byKey(const Key('currency-notice')))
                    .decoration!
                as BoxDecoration;
        expect(
          noticeStyle.color,
          isDark
              ? AppColors.darkSurfaceWarm
              : AppColors.securityNoticeBackground.withValues(alpha: 0.7),
        );
        expect(
          noticeStyle.border!.top.color,
          isDark
              ? AppColors.darkBorder
              : AppColors.securityNoticeBorder.withValues(alpha: 0.7),
        );
        expect(
          tester
              .widget<Icon>(
                find.descendant(
                  of: find.byKey(const Key('currency-notice')),
                  matching: find.byIcon(Icons.lock_outline),
                ),
              )
              .color,
          AppColors.securityNoticeForeground,
        );
        final avatarButton = find.byKey(const ValueKey('avatar-piggy'));
        final checkCenter = tester.getCenter(
          find.descendant(
            of: find.byKey(const ValueKey('avatar-selected-badge')),
            matching: find.byIcon(Icons.check),
          ),
        );
        final avatarRect = tester.getRect(avatarButton);
        expect(checkCenter.dx, closeTo(avatarRect.right, 1));
        expect(checkCenter.dy, closeTo(avatarRect.top, 1));
        final createStyle = tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Create'))
            .style!;
        expect(
          createStyle.shape!.resolve({}),
          isA<RoundedRectangleBorder>().having(
            (shape) => shape.borderRadius,
            'borderRadius',
            BorderRadius.circular(16),
          ),
        );
        tester.view.viewInsets = const FakeViewPadding(bottom: 240);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();
        await tapVisible(tester, find.text('Create'));
        expect(repository.created, hasLength(1));
        expect(repository.created.single.avatar, ProfileAvatar.piggy);
        expect(repository.created.single.currencyCode, 'JPY');
        expect(repository.created.single.currencyScale, 0);
        repository.save.complete();
        await tester.pumpAndSettle();
        expect(find.byType(ProfileDialog), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('blank names validate inline without saving', (tester) async {
    final repository = _RecordingRepository();
    await _openForm(tester, repository);
    await tester.enterText(find.byType(TextFormField), '   ');
    await tapVisible(tester, find.text('Create'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a profile name.'), findsOneWidget);
    expect(find.text('Enter a profile name.').hitTestable(), findsOneWidget);
    expect(repository.created, isEmpty);
    await tapVisible(tester, find.byTooltip('Close profile creation'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileDialog), findsNothing);
  });

  testWidgets('pending saves block duplicate submissions and dismissal', (
    tester,
  ) async {
    final repository = _RecordingRepository();
    String? savedId;
    await _openForm(tester, repository, onResult: (id) => savedId = id);
    await tester.enterText(find.byType(TextFormField), '  Personal  ');
    await tester.ensureVisible(find.text('Create'));
    final save = tester
        .widget<FilledButton>(find.widgetWithText(FilledButton, 'Create'))
        .onPressed!;
    save();
    save();
    await tester.pump();
    expect(repository.created, hasLength(1));
    expect(repository.created.single.name, 'Personal');
    expect(find.text('Saving...'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField)).enabled,
      isFalse,
    );
    expect(
      tester
          .widget<OutlinedButton>(find.byKey(const ValueKey('avatar-kuma')))
          .onPressed,
      isNull,
    );
    final context = tester.element(find.byType(ProfileDialog));
    await Navigator.of(context).maybePop();
    await tester.pump();
    expect(find.byType(ProfileDialog), findsOneWidget);
    await tester.tapAt(const Offset(2, 2));
    await tester.pump();
    expect(find.byType(ProfileDialog), findsOneWidget);
    repository.save.complete();
    await tester.pumpAndSettle();
    expect(savedId, repository.created.single.id);
    expect(find.byType(ProfileDialog), findsNothing);
  });

  testWidgets(
    'save failures are visible and allow retry with the same choices',
    (tester) async {
      final repository = _RecordingRepository();
      await _openForm(tester, repository);
      await tapVisible(tester, find.byKey(const ValueKey('avatar-boba')));
      await tester.enterText(find.byType(TextFormField), 'Coffee');
      await tapVisible(
        tester,
        find.byKey(const ValueKey('quick-currency-BRL')),
      );
      await tapVisible(tester, find.text('Create'));
      repository.save.completeError(StateError('disk full'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Could not create profile:'), findsOneWidget);
      expect(find.textContaining('disk full'), findsOneWidget);
      expect(find.byType(ProfileDialog), findsOneWidget);
      repository.save = Completer<void>();
      await tapVisible(tester, find.text('Create'));
      expect(repository.created, hasLength(2));
      expect(repository.created.last.avatar, ProfileAvatar.boba);
      expect(repository.created.last.currencyCode, 'BRL');
      expect(repository.created.last.name, 'Coffee');
      repository.save.complete();
      await tester.pumpAndSettle();
      expect(find.byType(ProfileDialog), findsNothing);
    },
  );

  testWidgets('currency picker cancellation preserves form choices', (
    tester,
  ) async {
    final repository = _RecordingRepository();
    await _openForm(tester, repository);
    await tapVisible(tester, find.byKey(const ValueKey('quick-currency-EUR')));
    await tapVisible(tester, find.byKey(const Key('profile-currency')));
    await tester.pumpAndSettle();
    expect(find.text('Choose currency'), findsOneWidget);
    await tester.ensureVisible(find.text('Cancel').last);
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();
    expect(find.text('EUR - Euro'), findsOneWidget);
    await tapVisible(tester, find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(repository.created, isEmpty);
    expect(find.byType(ProfileDialog), findsNothing);
  });

  testWidgets('duplicate profile names are rejected case-insensitively', (
    tester,
  ) async {
    final repository = _RecordingRepository(
      profiles: const [
        LocalProfile(
          id: 'existing',
          name: 'Personal',
          currencyCode: 'USD',
          currencyScale: 2,
        ),
      ],
    );
    await _openForm(tester, repository);
    await tester.enterText(find.byType(TextFormField), ' personal ');
    await tester.pumpAndSettle();
    expect(
      find.text('A profile with this name already exists.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.check_circle), findsNothing);
    await tapVisible(tester, find.text('Create'));
    await tester.pumpAndSettle();
    expect(repository.created, isEmpty);
    expect(find.byType(ProfileDialog), findsOneWidget);
  });
}
