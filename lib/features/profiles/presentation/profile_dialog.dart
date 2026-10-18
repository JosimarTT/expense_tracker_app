import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../domain/profile.dart';

class ProfileDialog extends ConsumerStatefulWidget {
  const ProfileDialog({super.key});

  @override
  ConsumerState<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends ConsumerState<ProfileDialog> {
  final _name = TextEditingController();
  String _currency = 'USD';
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Enter a profile name.');
      return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      final profile = LocalProfile(
        id: ref.read(uuidProvider).v4(),
        name: _name.text.trim(),
        currencyCode: _currency,
        currencyScale: 2,
      );
      await ref.read(profileRepositoryProvider).create(profile);
      if (mounted) Navigator.pop(context, profile.id);
    } on Object catch (error) {
      if (mounted) setState(() { _saving = false; _error = 'Could not create profile: $error'; });
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Create local profile'),
    content: SingleChildScrollView(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
          controller: _name,
          enabled: !_saving,
          decoration: const InputDecoration(labelText: 'Profile name'),
        ),
        DropdownButtonFormField<String>(
          initialValue: _currency,
          decoration: const InputDecoration(labelText: 'Currency'),
          items: [
            for (final currency in ['USD', 'EUR', 'GBP'])
              DropdownMenuItem(value: currency, child: Text(currency)),
          ],
          onChanged: _saving ? null : (value) => setState(() => _currency = value!),
        ),
        const SizedBox(height: 8),
        const Text('Currency is fixed for this profile. Data stays on this device.'),
        if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ]),
    ),
    actions: [
      TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
      FilledButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Saving...' : 'Create')),
    ],
  );
}
