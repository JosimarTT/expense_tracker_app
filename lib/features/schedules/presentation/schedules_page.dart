import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../core/money/money_format.dart';
import '../../profiles/domain/profile.dart';
import '../domain/transaction_schedule.dart';
import 'schedule_editor_dialog.dart';

class SchedulesPage extends ConsumerStatefulWidget {
  const SchedulesPage({required this.profile, super.key});
  final LocalProfile profile;

  @override
  ConsumerState<SchedulesPage> createState() => _SchedulesPageState();
}

class _SchedulesPageState extends ConsumerState<SchedulesPage>
    with WidgetsBindingObserver {
  bool _busy = false;
  String? _error;

  String _recurrence(TransactionSchedule schedule) {
    if (schedule.repeatUnit == RepeatUnit.once) return 'One-time';
    return 'Every ${schedule.interval} ${schedule.repeatUnit.name}${schedule.interval == 1 ? '' : 's'}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) setState(() {});
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on Object catch (error) {
      if (mounted) setState(() => _error = 'Schedule action failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _edit(
    TransactionSchedule? existing,
    List<TransactionCategory> categories,
  ) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ScheduleEditorDialog(
        profile: widget.profile,
        categories: categories,
        existing: existing,
      ),
    );
    if (saved == true && mounted) {
      await _run(
        () => ref
            .read(scheduleRepositoryProvider)
            .processDue(widget.profile.id, DateTime.now()),
      );
    }
  }

  Future<void> _cancel(TransactionSchedule schedule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel schedule?'),
        content: const Text(
          'Future entries will stop. Transactions already posted remain unchanged.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep schedule'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel schedule'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _run(
        () => ref
            .read(scheduleRepositoryProvider)
            .delete(profileId: widget.profile.id, scheduleId: schedule.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final schedules = ref.watch(schedulesProvider(widget.profile.id));
    final categories = ref.watch(categoriesProvider(widget.profile.id));
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scheduled transactions'),
        actions: [
          IconButton(
            tooltip: 'Process due schedules',
            onPressed: _busy
                ? null
                : () => _run(
                    () => ref
                        .read(scheduleRepositoryProvider)
                        .processDue(widget.profile.id, DateTime.now()),
                  ),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Planned entries do not affect totals until confirmed. Automatic entries are processed on app launch/resume. No background execution or notifications.',
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (_busy) const LinearProgressIndicator(),
          if (categories.hasError)
            TextButton(
              onPressed: () =>
                  ref.invalidate(categoriesProvider(widget.profile.id)),
              child: const Text('Could not load categories. Retry'),
            ),
          Expanded(
            child: schedules.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: TextButton(
                  onPressed: () =>
                      ref.invalidate(schedulesProvider(widget.profile.id)),
                  child: Text('Could not load schedules: $error. Retry'),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(child: Text('No schedules yet.'));
                }
                final sorted = [...items]
                  ..sort(
                    (a, b) => (a.nextDate ?? DateTime.utc(9999)).compareTo(
                      b.nextDate ?? DateTime.utc(9999),
                    ),
                  );
                return ListView(
                  children: [
                    for (final schedule in sorted)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                schedule.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${schedule.type.name} - ${formatMoney(schedule.amountMinor, widget.profile.currencyCode, widget.profile.currencyScale, locale: View.of(context).platformDispatcher.locale.toString())}',
                              ),
                              Text(
                                schedule.nextDate == null
                                    ? 'Completed'
                                    : '${schedule.paused
                                          ? 'Paused'
                                          : schedule.isDue(now)
                                          ? 'Due / overdue'
                                          : 'Upcoming'}: ${DateFormat.yMMMd().format(schedule.nextDate!)}',
                              ),
                              Text(
                                schedule.automatic
                                    ? 'Automatic'
                                    : 'Planned - confirmation required',
                              ),
                              Text(_recurrence(schedule)),
                              if (schedule.endDate != null)
                                Text(
                                  'Through ${DateFormat.yMMMd().format(schedule.endDate!)}',
                                ),
                              if (categories.hasValue &&
                                  categories.requireValue.any(
                                    (category) =>
                                        category.id == schedule.categoryId &&
                                        category.isArchived,
                                  ))
                                const Text(
                                  'Category archived. Restore it or edit this schedule before posting.',
                                ),
                              Wrap(
                                spacing: 8,
                                children: [
                                  if (!schedule.automatic &&
                                      schedule.isDue(now)) ...[
                                    FilledButton(
                                      onPressed: _busy
                                          ? null
                                          : () => _run(
                                              () => ref
                                                  .read(
                                                    scheduleRepositoryProvider,
                                                  )
                                                  .resolve(
                                                    profileId:
                                                        widget.profile.id,
                                                    scheduleId: schedule.id,
                                                    expectedIndex:
                                                        schedule.nextIndex,
                                                    now: now,
                                                    skip: false,
                                                  ),
                                            ),
                                      child: const Text('Confirm entry'),
                                    ),
                                  ],
                                  if (schedule.isDue(now))
                                    TextButton(
                                      onPressed: _busy
                                          ? null
                                          : () => _run(
                                              () => ref
                                                  .read(
                                                    scheduleRepositoryProvider,
                                                  )
                                                  .resolve(
                                                    profileId:
                                                        widget.profile.id,
                                                    scheduleId: schedule.id,
                                                    expectedIndex:
                                                        schedule.nextIndex,
                                                    now: now,
                                                    skip: true,
                                                  ),
                                            ),
                                      child: const Text('Skip occurrence'),
                                    ),
                                  TextButton(
                                    onPressed:
                                        _busy ||
                                            !categories.hasValue ||
                                            !categories.requireValue.any(
                                              (category) =>
                                                  !category.isArchived,
                                            )
                                        ? null
                                        : () => _edit(
                                            schedule,
                                            categories.requireValue,
                                          ),
                                    child: const Text('Edit'),
                                  ),
                                  if (schedule.nextDate != null)
                                    TextButton(
                                      onPressed: _busy
                                          ? null
                                          : () => _run(() async {
                                              final repo = ref.read(
                                                scheduleRepositoryProvider,
                                              );
                                              await repo.setPaused(
                                                profileId: widget.profile.id,
                                                scheduleId: schedule.id,
                                                paused: !schedule.paused,
                                              );
                                              if (schedule.paused) {
                                                await repo.processDue(
                                                  widget.profile.id,
                                                  DateTime.now(),
                                                );
                                              }
                                            }),
                                      child: Text(
                                        schedule.paused ? 'Resume' : 'Pause',
                                      ),
                                    ),
                                  TextButton(
                                    onPressed: _busy
                                        ? null
                                        : () => _cancel(schedule),
                                    child: const Text('Cancel schedule'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed:
                  _busy ||
                      !categories.hasValue ||
                      !categories.requireValue.any(
                        (category) => !category.isArchived,
                      )
                  ? null
                  : () => _edit(null, categories.requireValue),
              icon: const Icon(Icons.add),
              label: const Text('Add schedule'),
            ),
          ),
        ],
      ),
    );
  }
}
