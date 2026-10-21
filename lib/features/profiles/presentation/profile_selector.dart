import 'package:flutter/material.dart';

import '../domain/profile.dart';
import 'profile_avatar.dart';

class ProfileSelector extends StatelessWidget {
  const ProfileSelector({
    required this.profiles,
    required this.selected,
    required this.onSelected,
    this.compact = false,
    super.key,
  });

  final List<LocalProfile> profiles;
  final LocalProfile selected;
  final ValueChanged<String> onSelected;
  final bool compact;

  String _label(LocalProfile profile) =>
      '${profile.name} (${profile.currencyCode})';

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    key: ValueKey(selected.id),
    initialValue: selected.id,
    isExpanded: true,
    itemHeight: null,
    decoration: InputDecoration(
      labelText: compact ? null : 'Active profile',
      fillColor: compact ? Theme.of(context).colorScheme.surface : null,
      contentPadding: compact
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
          : null,
      prefixIcon: Padding(
        padding: const EdgeInsets.all(8),
        child: Semantics(
          label: '${selected.avatar.label} avatar',
          child: ProfileAvatarIcon(avatar: selected.avatar),
        ),
      ),
    ),
    selectedItemBuilder: (context) => [
      for (final profile in profiles)
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Tooltip(
            message: '${_label(profile)} - ${profile.avatar.label}',
            child: Text(
              _label(profile),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
    ],
    items: [
      for (final profile in profiles)
        DropdownMenuItem(
          value: profile.id,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Semantics(
                  label: '${profile.avatar.label} avatar',
                  child: ProfileAvatarIcon(avatar: profile.avatar),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(_label(profile))),
              ],
            ),
          ),
        ),
    ],
    onChanged: (id) {
      if (id != null) onSelected(id);
    },
  );
}
