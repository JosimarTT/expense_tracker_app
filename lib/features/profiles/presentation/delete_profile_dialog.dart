import 'package:flutter/material.dart';

class DeleteProfileDialog extends StatefulWidget {
  const DeleteProfileDialog({required this.profileName, super.key});

  final String profileName;

  @override
  State<DeleteProfileDialog> createState() => _DeleteProfileDialogState();
}

class _DeleteProfileDialogState extends State<DeleteProfileDialog> {
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Permanently delete profile?'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delete "${widget.profileName}" and permanently erase all of its '
          'transactions, categories, and budgets from this device. This cannot be undone.',
        ),
        const SizedBox(height: 16),
        const Text('Type DELETE to confirm.'),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmation,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Confirmation',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Cancel'),
      ),
      FilledButton(
        key: const Key('confirm-delete-profile'),
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError,
        ),
        onPressed: _confirmation.text == 'DELETE'
            ? () => Navigator.pop(context, true)
            : null,
        child: const Text('Delete Profile'),
      ),
    ],
  );
}
