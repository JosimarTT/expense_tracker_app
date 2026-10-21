import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/money/currency.dart';
import '../../../core/money/money_format.dart';
import '../domain/profile.dart';
import 'currency_picker_dialog.dart';
import 'currency_widgets.dart';
import 'profile_avatar.dart';

Future<String?> showProfileDialog(BuildContext context) {
  final barrier = Theme.of(context).colorScheme.onSurface
      .withValues(alpha: 0.25);
  if (MediaQuery.sizeOf(context).width < 600) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      enableDrag: false,
      barrierColor: barrier,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: const ProfileDialog(isBottomSheet: true),
      ),
    );
  }
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    barrierColor: barrier,
    builder: (_) => const ProfileDialog(),
  );
}

class ProfileDialog extends ConsumerStatefulWidget {
  const ProfileDialog({this.isBottomSheet = false, super.key});

  final bool isBottomSheet;

  @override
  ConsumerState<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends ConsumerState<ProfileDialog> {
  final _name = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _nameFieldKey = GlobalKey();
  ProfileAvatar _avatar = ProfileAvatar.neko;
  String _currency = 'USD';
  String? _error;
  String? _nameError;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) {
      await Scrollable.ensureVisible(
        _nameFieldKey.currentContext!,
        alignment: 0.2,
        duration: const Duration(milliseconds: 200),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    List<LocalProfile> profiles;
    try {
      profiles =
          ref.read(profilesProvider).asData?.value ??
          await ref.read(profilesProvider.future);
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not verify profile name: $error';
        });
      }
      return;
    }
    final nameError = _validateName(_name.text, profiles);
    if (nameError != null) {
      setState(() {
        _saving = false;
        _nameError = nameError;
      });
      await Scrollable.ensureVisible(
        _nameFieldKey.currentContext!,
        alignment: 0.2,
        duration: const Duration(milliseconds: 200),
      );
      return;
    }
    try {
      final profile = LocalProfile(
        id: ref.read(idGeneratorProvider).generate(),
        name: _name.text.trim(),
        currencyCode: _currency,
        currencyScale: Currency.fromCode(_currency).scale,
        avatar: _avatar,
      );
      await ref.read(profileRepositoryProvider).create(profile);
      if (mounted) {
        setState(() => _saving = false);
        Navigator.pop(context, profile.id);
      }
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not create profile: $error';
        });
      }
    }
  }

  String? _validateName(String? value, List<LocalProfile> profiles) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Enter a profile name.';
    if (profiles.any(
      (profile) => profile.name.trim().toLowerCase() == name.toLowerCase(),
    )) {
      return 'A profile with this name already exists.';
    }
    return null;
  }

  Future<void> _chooseCurrency() async {
    FocusScope.of(context).unfocus();
    final selected = await showDialog<String>(
      context: context,
      builder: (_) => CurrencyPickerDialog(selectedCode: _currency),
    );
    if (selected != null && mounted) {
      setState(() => _currency = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final profilesState = ref.watch(profilesProvider);
    final profiles = profilesState.asData?.value ?? const <LocalProfile>[];
    final nameError = _validateName(_name.text, profiles);
    final nameIsValid = profilesState.asData != null && nameError == null;
    final media = MediaQuery.of(context);
    final currency = Currency.fromCode(_currency);
    final locale = View.of(context).platformDispatcher.locale.toString();
    final content = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 520,
        maxHeight:
            (media.size.height -
                media.viewInsets.bottom -
                media.padding.vertical) *
            0.9,
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create local profile',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Make it yours. Everything stays on this device.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close profile creation',
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'CHOOSE AVATAR',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (
                    var index = 0;
                    index < ProfileAvatar.values.length;
                    index++
                  ) ...[
                    if (index > 0) const SizedBox(width: 8),
                    Expanded(
                      child: _buildAvatarButton(
                        ProfileAvatar.values[index],
                        theme,
                        colors,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'PROFILE NAME',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                key: _nameFieldKey,
                controller: _name,
                enabled: !_saving,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'e.g. Personal',
                  prefixIcon: const Icon(Icons.person_outline),
                  suffixIcon: nameIsValid
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.mint,
                          semanticLabel: 'Profile name is available',
                        )
                      : null,
                ),
                forceErrorText: _nameError,
                validator: (value) => profilesState.asData == null
                    ? (value == null || value.trim().isEmpty
                          ? 'Enter a profile name.'
                          : null)
                    : _validateName(value, profiles),
                onChanged: (_) => setState(() {
                  _error = null;
                  _nameError = null;
                }),
              ),
              const SizedBox(height: 20),
              Text(
                'PROFILE CURRENCY',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Material(
                color: colors.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: colors.outline),
                ),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  key: const Key('profile-currency'),
                  leading: CurrencyBadge(code: _currency),
                  title: Text('$_currency - ${currency.name}'),
                  subtitle: Text(
                    'Example: ${formatMoney(1250, _currency, currency.scale, locale: locale)}',
                  ),
                  trailing: const Icon(Icons.search),
                  onTap: _saving ? null : _chooseCurrency,
                ),
              ),
              const SizedBox(height: 8),
              PopularCurrencyChips(
                selectedCode: _currency,
                onSelected: _saving
                    ? null
                    : (code) => setState(() => _currency = code),
              ),
              const SizedBox(height: 16),
              Container(
                key: const Key('currency-notice'),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? colors.surfaceContainerLow
                      : AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: theme.brightness == Brightness.dark
                        ? AppColors.darkBorder
                        : AppColors.primaryLight,
                  ),
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 18,
                      color: AppColors.primaryDark,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Currency is fixed for this profile. Data stays on this device.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (profilesState.hasError) ...[
                const SizedBox(height: 16),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    'Could not load profiles to verify the name.',
                    style: TextStyle(color: colors.error),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 16),
                Semantics(
                  liveRegion: true,
                  child: Text(_error!, style: TextStyle(color: colors.error)),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(_saving ? 'Saving...' : 'Create'),
              ),
              TextButton(
                onPressed: _saving ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
    return PopScope(
      canPop: !_saving,
      child: widget.isBottomSheet
          ? SafeArea(
              top: false,
              child: SizedBox(width: double.infinity, child: content),
            )
          : Dialog(child: content),
    );
  }

  Widget _buildAvatarButton(
    ProfileAvatar avatar,
    ThemeData theme,
    ColorScheme colors,
  ) {
    final isSelected = avatar == _avatar;
    final isDark = theme.brightness == Brightness.dark;
    return Semantics(
      selected: isSelected,
      child: OutlinedButton(
        key: ValueKey('avatar-${avatar.name}'),
        onPressed: _saving ? null : () => setState(() => _avatar = avatar),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 76),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          backgroundColor: isSelected
              ? (isDark ? AppColors.darkSurfaceWarm : AppColors.primarySubtle)
              : (isDark ? AppColors.darkSurface : colors.surfaceContainerLow),
          foregroundColor: isSelected
              ? (isDark ? AppColors.darkTextPrimary : AppColors.primaryDark)
              : colors.onSurfaceVariant,
          side: BorderSide(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkBorder : AppColors.borderLight),
            width: isSelected ? 2 : 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ProfileAvatarIcon(avatar: avatar),
                const SizedBox(height: 4),
                Text(avatar.label, style: const TextStyle(fontSize: 12)),
              ],
            ),
            if (isSelected)
              Positioned(
                top: -18,
                right: -18,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
