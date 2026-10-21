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
              Text('Choose avatar', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final avatar in ProfileAvatar.values)
                    Semantics(
                      selected: avatar == _avatar,
                      child: OutlinedButton(
                        key: ValueKey('avatar-${avatar.name}'),
                        onPressed: _saving
                            ? null
                            : () => setState(() => _avatar = avatar),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(12),
                          backgroundColor: avatar == _avatar
                              ? (theme.brightness == Brightness.dark
                                    ? AppColors.darkSurfaceWarm
                                    : AppColors.primarySubtle)
                              : avatar.backgroundColor(theme.brightness),
                          foregroundColor: avatar == _avatar
                              ? (theme.brightness == Brightness.dark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textHeadline)
                              : colors.onSurface,
                          side: BorderSide(
                            color: avatar == _avatar
                                ? AppColors.primary
                                : (theme.brightness == Brightness.dark
                                      ? AppColors.darkBorder
                                      : AppColors.borderLight),
                            width: avatar == _avatar ? 2 : 1.5,
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
                                Text(avatar.label),
                              ],
                            ),
                            if (avatar == _avatar)
                              Positioned(
                                top: -18,
                                right: -18,
                                child: CircleAvatar(
                                  radius: 10,
                                  backgroundColor: AppColors.primary,
                                  child: const Icon(
                                    Icons.check,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                key: _nameFieldKey,
                controller: _name,
                enabled: !_saving,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Profile name',
                  hintText: 'e.g. Personal',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a profile name.'
                    : null,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              Text('Profile currency', style: theme.textTheme.titleMedium),
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
              Card(
                margin: EdgeInsets.zero,
                color: colors.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 20,
                        color: colors.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Currency is fixed for this profile. Data stays on this device.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Profile preview', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                key: const Key('profile-preview'),
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileAvatarIcon(avatar: _avatar),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _name.text.trim().isEmpty
                                  ? 'Your profile'
                                  : _name.text.trim(),
                              style: theme.textTheme.titleMedium,
                            ),
                            Text('${_avatar.label} • $_currency'),
                            Text(
                              'Starting total: ${formatMoney(0, _currency, currency.scale, locale: locale)}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
}
