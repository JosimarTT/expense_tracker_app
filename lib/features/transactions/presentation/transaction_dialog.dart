import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../core/money/amount_input_formatter.dart';
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
  late final _notes = TextEditingController(text: widget.existing?.notes);
  late final _amount = TextEditingController(
    text: widget.existing == null
        ? ''
        : _amountText(widget.existing!.amountMinor),
  );
  late TransactionType _type =
      widget.existing?.type ??
      (widget.categories.any(
            (category) =>
                !category.isArchived &&
                !category.isSystem &&
                category.type == TransactionType.expense,
          )
          ? TransactionType.expense
          : widget.categories
                .firstWhere(
                  (category) => !category.isArchived && !category.isSystem,
                )
                .type);
  List<TransactionCategory> get _selectableCategories => [
    for (final category in widget.categories)
      if ((!category.isArchived && !category.isSystem) ||
          category.id == widget.existing?.categoryId)
        category,
  ];
  late String _category =
      widget.existing?.categoryId ??
      _selectableCategories.firstWhere((category) => category.type == _type).id;
  late DateTime _date = widget.existing?.occurredAt.toLocal() ?? DateTime.now();
  bool _saving = false;
  String? _error;

  String _amountText(int minor) {
    final digits = minor.toString().padLeft(
      widget.profile.currencyScale + 1,
      '0',
    );
    final split = digits.length - widget.profile.currencyScale;
    return widget.profile.currencyScale == 0
        ? digits
        : '${digits.substring(0, split)}.${digits.substring(split)}';
  }

  @override
  void dispose() {
    _notes.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final value = FinancialTransaction(
        id: widget.existing?.id ?? ref.read(idGeneratorProvider).generate(),
        profileId: widget.profile.id,
        notes: _notes.text,
        amountMinor: parseScaledDecimal(
          _amount.text,
          widget.profile.currencyScale,
        ),
        type: _type,
        categoryId: _category,
        occurredAt: _date,
      );
      await ref.read(transactionRepositoryProvider).save(value);
      if (mounted) Navigator.pop(context);
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save transaction: $error';
        });
      }
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
      setState(
        () => _date = DateTime(
          selected.year,
          selected.month,
          selected.day,
          _date.hour,
          _date.minute,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.existing == null ? 'Add transaction' : 'Edit transaction',
    ),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amount,
            inputFormatters: [
              AmountInputFormatter(widget.profile.currencyScale),
            ],
            enabled: !_saving,
            keyboardType: TextInputType.numberWithOptions(
              decimal: widget.profile.currencyScale > 0,
            ),
            decoration: InputDecoration(
              labelText: 'Amount (${widget.profile.currencyCode})',
            ),
          ),
          DropdownButtonFormField<TransactionType>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Type'),
            items: [
              for (final type in TransactionType.values)
                if (_selectableCategories.any(
                      (category) =>
                          category.type == type && !category.isArchived,
                    ) ||
                    type == _type)
                  DropdownMenuItem(value: type, child: Text(type.label)),
            ],
            onChanged: _saving
                ? null
                : (value) => setState(() {
                    if (value == _type) return;
                    _type = value!;
                    _category = _selectableCategories
                        .firstWhere(
                          (category) =>
                              category.type == _type && !category.isArchived,
                        )
                        .id;
                  }),
          ),
          DropdownButtonFormField<String>(
            key: ValueKey(_type),
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: [
              for (final category in _selectableCategories.where(
                (category) => category.type == _type,
              ))
                DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name),
                ),
            ],
            onChanged: _saving
                ? null
                : (value) => setState(() => _category = value!),
          ),
          TextButton(
            onPressed: _saving ? null : _pickDate,
            child: Text('Date: ${DateFormat.yMMMd().format(_date)}'),
          ),
          TextField(
            controller: _notes,
            enabled: !_saving,
            minLines: 1,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              hintText: 'Add details about this transaction',
            ),
          ),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: Text(_saving ? 'Saving...' : 'Save'),
      ),
    ],
  );
}
