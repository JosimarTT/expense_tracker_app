import 'package:flutter/material.dart';

import '../../../core/money/currency.dart';

class CurrencyPickerDialog extends StatefulWidget {
  const CurrencyPickerDialog({required this.selectedCode, super.key});

  final String selectedCode;

  @override
  State<CurrencyPickerDialog> createState() => _CurrencyPickerDialogState();
}

class _CurrencyPickerDialogState extends State<CurrencyPickerDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final currencies = Currency.supported.where((item) => item.matches(_query));
    return AlertDialog(
      title: const Text('Choose currency'),
      content: SizedBox(
        width: 420,
        height: MediaQuery.sizeOf(context).height * 0.5,
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search currencies',
                hintText: 'Name, code, or country',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            Expanded(
              child: currencies.isEmpty
                  ? const Center(child: Text('No matching currencies.'))
                  : ListView(
                      children: [
                        for (final currency in currencies)
                          ListTile(
                            title: Text('${currency.code} - ${currency.name}'),
                            subtitle: Text('${currency.scale} decimal places'),
                            trailing: currency.code == widget.selectedCode
                                ? const Icon(Icons.check)
                                : null,
                            onTap: () => Navigator.pop(context, currency.code),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
