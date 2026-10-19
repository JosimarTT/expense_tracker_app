import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../core/money/decimal_input.dart';
import '../../profiles/domain/profile.dart';
import '../../transactions/domain/entities/financial_transaction.dart';
import '../domain/transaction_schedule.dart';

class ScheduleEditorDialog extends ConsumerStatefulWidget {
  const ScheduleEditorDialog({
    required this.profile,
    required this.categories,
    this.existing,
    super.key,
  });
  final LocalProfile profile;
  final List<TransactionCategory> categories;
  final TransactionSchedule? existing;

  @override
  ConsumerState<ScheduleEditorDialog> createState() =>
      _ScheduleEditorDialogState();
}

class _ScheduleEditorDialogState extends ConsumerState<ScheduleEditorDialog> {
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _notes = TextEditingController(text: widget.existing?.notes);
  late final _amount = TextEditingController(
    text: widget.existing == null
        ? ''
        : _amountText(widget.existing!.amountMinor),
  );
  late final _interval = TextEditingController(
    text: '${widget.existing?.interval ?? 1}',
  );
  late TransactionType _type =
      widget.existing?.type ??
      widget.categories.firstWhere((category) => !category.isArchived).type;
  late String? _categoryId =
      widget.existing?.categoryId ??
      widget.categories
          .where((category) => !category.isArchived && category.type == _type)
          .firstOrNull
          ?.id;
  late DateTime _start =
      widget.existing?.startDate ?? calendarDate(DateTime.now());
  late DateTime? _end = widget.existing?.endDate;
  late RepeatUnit _unit = widget.existing?.repeatUnit ?? RepeatUnit.month;
  late bool _automatic = widget.existing?.automatic ?? false;
  bool _saving = false;
  String? _error;

  String _amountText(int minor) {
    final scale = widget.profile.currencyScale;
    final digits = minor.toString().padLeft(scale + 1, '0');
    if (scale == 0) return digits;
    return '${digits.substring(0, digits.length - scale)}.${digits.substring(digits.length - scale)}';
  }

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    _amount.dispose();
    _interval.dispose();
    super.dispose();
  }

  Future<void> _date(bool end) async {
    final date = await showDatePicker(
      context: context,
      initialDate: end ? (_end ?? _start) : _start,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200, 12, 31),
    );
    if (date != null && mounted) {
      setState(() {
        if (end) {
          _end = calendarDate(date);
        } else {
          _start = calendarDate(date);
        }
      });
    }
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (_categoryId == null) throw StateError('Choose an active category.');
      await ref
          .read(scheduleRepositoryProvider)
          .save(
            TransactionSchedule(
              id:
                  widget.existing?.id ??
                  ref.read(idGeneratorProvider).generate(),
              profileId: widget.profile.id,
              name: _name.text,
              notes: _notes.text,
              amountMinor: parseScaledDecimal(
                _amount.text,
                widget.profile.currencyScale,
              ),
              type: _type,
              categoryId: _categoryId!,
              startDate: _start,
              endDate: _end,
              repeatUnit: _unit,
              interval: _unit == RepeatUnit.once
                  ? 1
                  : int.parse(_interval.text),
              automatic: _automatic,
            ),
          );
      if (mounted) Navigator.pop(context, true);
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Could not save schedule: $error';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.existing == null ? 'New schedule' : 'Edit schedule'),
    content: SizedBox(
      width: 440,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _name,
              enabled: !_saving,
              decoration: const InputDecoration(
                labelText: 'Schedule name',
                hintText: 'Salary, rent, subscription...',
              ),
            ),
            DropdownButtonFormField<TransactionType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: [
                for (final type in TransactionType.values)
                  if (type == _type ||
                      widget.categories.any(
                        (category) =>
                            !category.isArchived && category.type == type,
                      ))
                    DropdownMenuItem(
                      value: type,
                      child: Text(
                        type == TransactionType.income ? 'Income' : 'Expense',
                      ),
                    ),
              ],
              onChanged: _saving
                  ? null
                  : (value) => setState(() {
                      _type = value!;
                      _categoryId = widget.categories
                          .where(
                            (category) =>
                                !category.isArchived && category.type == _type,
                          )
                          .firstOrNull
                          ?.id;
                    }),
            ),
            DropdownButtonFormField<String>(
              key: ValueKey(_type),
              initialValue:
                  widget.categories.any(
                    (category) =>
                        !category.isArchived && category.id == _categoryId,
                  )
                  ? _categoryId
                  : null,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                for (final category in widget.categories)
                  if (!category.isArchived && category.type == _type)
                    DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    ),
              ],
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _categoryId = value),
            ),
            TextField(
              controller: _amount,
              enabled: !_saving,
              keyboardType: TextInputType.numberWithOptions(
                decimal: widget.profile.currencyScale > 0,
              ),
              decoration: InputDecoration(
                labelText: 'Amount (${widget.profile.currencyCode})',
                helperText: widget.profile.currencyScale == 0
                    ? 'Whole numbers only.'
                    : 'Use a dot for decimals (up to ${widget.profile.currencyScale} places).',
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Automatic posting'),
              subtitle: const Text(
                'Off: confirm each due entry. On: post when the app opens or resumes.',
              ),
              value: _automatic,
              onChanged: _saving
                  ? null
                  : (value) => setState(() => _automatic = value),
            ),
            DropdownButtonFormField<RepeatUnit>(
              initialValue: _unit,
              decoration: const InputDecoration(labelText: 'Repeat'),
              items: [
                for (final unit in RepeatUnit.values)
                  DropdownMenuItem(
                    value: unit,
                    child: Text(switch (unit) {
                      RepeatUnit.once => 'One-time',
                      RepeatUnit.day => 'Daily',
                      RepeatUnit.week => 'Weekly',
                      RepeatUnit.month => 'Monthly',
                      RepeatUnit.year => 'Yearly',
                    }),
                  ),
              ],
              onChanged: _saving || widget.existing != null
                  ? null
                  : (value) => setState(() => _unit = value!),
            ),
            if (_unit != RepeatUnit.once)
              TextField(
                controller: _interval,
                enabled: !_saving && widget.existing == null,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Every N ${_unit.name}s',
                  helperText: '1 to 999',
                ),
              ),
            TextButton(
              onPressed: _saving || widget.existing != null
                  ? null
                  : () => _date(false),
              child: Text('First date: ${DateFormat.yMMMd().format(_start)}'),
            ),
            if (widget.existing != null)
              const Text(
                'First date and recurrence are fixed. Changes affect only unposted entries. Cancel and create a new schedule to change recurrence.',
              ),
            TextButton(
              onPressed: _saving ? null : () => _date(true),
              child: Text(
                _end == null
                    ? 'Set optional end date'
                    : 'End date: ${DateFormat.yMMMd().format(_end!)}',
              ),
            ),
            if (_end != null)
              TextButton(
                onPressed: _saving ? null : () => setState(() => _end = null),
                child: const Text('Clear end date'),
              ),
            TextField(
              controller: _notes,
              enabled: !_saving,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
            const Text(
              'Amounts are fixed, not estimates. Overdue automatic entries are posted for every missed date. Paused schedules catch up when resumed.',
            ),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: const Text('Save schedule'),
      ),
    ],
  );
}
