import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../core/money/decimal_input.dart';
import '../../profiles/domain/profile.dart';
import '../domain/entities/financial_transaction.dart';

class TransactionDialog extends ConsumerStatefulWidget {
  const TransactionDialog({
    required this.profile,
    required this.categories,
    this.existing,
    super.key,
  });

  final LocalProfile profile;
  final List<TransactionCategory> categories;
  final FinancialTransaction? existing;

  @override
  ConsumerState<TransactionDialog> createState() => _TransactionDialogState();
}

class _TransactionDialogState extends ConsumerState<TransactionDialog> {
  late final _title = TextEditingController(text: widget.existing?.title);
  late final _amount = TextEditingController(
    text: widget.existing == null ? '' : _amountText(widget.existing!.amountMinor),
  );
  late TransactionType _type = widget.existing?.type ?? TransactionType.expense;
  late String _category = widget.existing?.categoryId ??
      widget.categories.firstWhere((category) => category.type == _type).id;
  late DateTime _date = widget.existing?.occurredAt.toLocal() ?? DateTime.now();
  bool _saving = false;
  String? _error;

  String _amountText(int minor) {
    final digits = minor.toString().padLeft(widget.profile.currencyScale + 1, '0');
    final split = digits.length - widget.profile.currencyScale;
    return widget.profile.currencyScale == 0 ? digits : '${digits.substring(0, split)}.${digits.substring(split)}';
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() { _saving = true; _error = null; });
    try {
      final value = FinancialTransaction(
        id: widget.existing?.id ?? ref.read(idGeneratorProvider).generate(),
        profileId: widget.profile.id,
        title: _title.text,
        amountMinor: parseScaledDecimal(_amount.text, widget.profile.currencyScale),
        type: _type,
        categoryId: _category,
        occurredAt: _date,
      );
      await ref.read(transactionRepositoryProvider).save(value);
      if (mounted) Navigator.pop(context);
    } on Object catch (error) {
      if (mounted) setState(() { _saving = false; _error = 'Could not save transaction: $error'; });
    }
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (selected != null && mounted) {
      setState(() => _date = DateTime(
        selected.year, selected.month, selected.day, _date.hour, _date.minute,
      ));
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.existing == null ? 'Add transaction' : 'Edit transaction'),
    content: SingleChildScrollView(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _title, enabled: !_saving, decoration: const InputDecoration(labelText: 'Title')),
        TextField(
          controller: _amount,
          enabled: !_saving,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: 'Amount (${widget.profile.currencyCode})', helperText: 'Use a dot for decimals, e.g. 12.50'),
        ),
        DropdownButtonFormField<TransactionType>(
          initialValue: _type,
          decoration: const InputDecoration(labelText: 'Type'),
          items: [
            for (final type in TransactionType.values)
              DropdownMenuItem(value: type, child: Text(type == TransactionType.income ? 'Income' : 'Expense')),
          ],
          onChanged: _saving ? null : (value) => setState(() {
            _type = value!;
            _category = widget.categories.firstWhere((category) => category.type == _type).id;
          }),
        ),
        DropdownButtonFormField<String>(
          key: ValueKey(_type),
          initialValue: _category,
          decoration: const InputDecoration(labelText: 'Category'),
          items: [
            for (final category in widget.categories.where((category) => category.type == _type))
              DropdownMenuItem(value: category.id, child: Text(category.name)),
          ],
          onChanged: _saving ? null : (value) => setState(() => _category = value!),
        ),
        TextButton(onPressed: _saving ? null : _pickDate, child: Text('Date: ${DateFormat.yMMMd().format(_date)}')),
        if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
      ]),
    ),
    actions: [
      TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
      FilledButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Saving...' : 'Save')),
    ],
  );
}
