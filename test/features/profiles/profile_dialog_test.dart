import 'dart:async';

import 'package:expense_tracker_app/app/providers.dart';
import 'package:expense_tracker_app/app/theme/app_colors.dart';
import 'package:expense_tracker_app/app/theme/app_theme.dart';
import 'package:expense_tracker_app/features/profiles/domain/profile.dart';
import 'package:expense_tracker_app/features/profiles/presentation/profile_avatar.dart';
import 'package:expense_tracker_app/features/profiles/presentation/profile_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingRepository implements ProfileRepository {
  final created = <LocalProfile>[];
  var save = Completer<void>();

  @override
  Future<void> create(LocalProfile profile) {
    created.add(profile);
    return save.future;
  }

  @override
  Stream<List<LocalProfile>> watchProfiles() => Stream.value([]);

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
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('avatar-neko')),
            matching: find.byIcon(Icons.check),
          ),
          findsOneWidget,
        );
        final piggyStyle = tester
            .widget<OutlinedButton>(find.byKey(const ValueKey('avatar-piggy')))
            .style!;
        expect(
          piggyStyle.backgroundColor!.resolve({}),
          isDark ? AppColors.darkSurfaceWarm : AppColors.avatarPiggyBg,
        );
        final selectedChip = tester.widget<ChoiceChip>(
          find.byKey(const ValueKey('quick-currency-USD')),
        );
        expect(selectedChip.selectedColor, AppColors.primary);
        expect(selectedChip.checkmarkColor, Colors.white);
        expect(selectedChip.labelStyle?.color, Colors.white);
        await tapVisible(tester, find.byKey(const ValueKey('avatar-piggy')));
        await tester.ensureVisible(find.byType(TextFormField));
        await tester.enterText(find.byType(TextFormField), 'Travel');
        await tapVisible(
          tester,
          find.byKey(const ValueKey('quick-currency-JPY')),
        );
        await tester.ensureVisible(find.byKey(const Key('profile-preview')));
        await tester.pumpAndSettle();
        final preview = find.byKey(const Key('profile-preview'));
        expect(
          find.descendant(of: preview, matching: find.text('Travel')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: preview, matching: find.text('Piggy • JPY')),
          findsOneWidget,
        );
        expect(
          tester
              .widget<ProfileAvatarIcon>(
                find.descendant(
                  of: preview,
                  matching: find.byType(ProfileAvatarIcon),
                ),
              )
              .avatar,
          ProfileAvatar.piggy,
        );
        expect(find.text('Starting total: ¥0'), findsOneWidget);
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
}
