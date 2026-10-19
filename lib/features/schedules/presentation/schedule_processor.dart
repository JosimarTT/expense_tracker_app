import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../profiles/domain/profile.dart';
import 'schedules_page.dart';

class ScheduleProcessor extends ConsumerStatefulWidget {
  const ScheduleProcessor({
    required this.profiles,
    required this.child,
    super.key,
  });
  final List<LocalProfile> profiles;
  final Widget child;

  @override
  ConsumerState<ScheduleProcessor> createState() => _ScheduleProcessorState();
}

class _ScheduleProcessorState extends ConsumerState<ScheduleProcessor>
    with WidgetsBindingObserver {
  bool _running = false;
  bool _again = false;
  List<LocalProfile> _failedProfiles = [];
  List<LocalProfile> _failedSavings = [];

  Future<void> _review(LocalProfile profile) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => SchedulesPage(profile: profile)),
    );
    if (mounted) await _process();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _process();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(ScheduleProcessor oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldIds = oldWidget.profiles.map((profile) => profile.id).toSet();
    if (widget.profiles.any((profile) => !oldIds.contains(profile.id))) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _process();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _process();
  }

  Future<void> _process() async {
    if (_running) {
      _again = true;
      return;
    }
    setState(() {
      _running = true;
      _failedProfiles = [];
      _failedSavings = [];
    });
    do {
      _again = false;
      final failures = <LocalProfile>[];
      final savingsFailures = <LocalProfile>[];
      final repository = ref.read(scheduleRepositoryProvider);
      for (final profile in [...widget.profiles]) {
        try {
          await repository.processDue(profile.id, DateTime.now());
        } on Object {
          failures.add(profile);
        }
        try {
          await ref
              .read(savingsRepositoryProvider)
              .process(profile.id, DateTime.now());
        } on Object {
          savingsFailures.add(profile);
        }
      }
      if (!mounted) return;
      setState(() {
        _failedProfiles = failures;
        _failedSavings = savingsFailures;
      });
    } while (_again && mounted);
    if (mounted) setState(() => _running = false);
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (_running) const LinearProgressIndicator(),
      for (final profile in _failedSavings.where(
        (failed) => widget.profiles.any((profile) => profile.id == failed.id),
      ))
        MaterialBanner(
          content: Text(
            'Unused money savings for "${profile.name}" could not be updated. Check transaction amounts and try again.',
          ),
          actions: [
            TextButton(
              onPressed: _running ? null : _process,
              child: const Text('Retry savings'),
            ),
          ],
        ),
      for (final profile in _failedProfiles.where(
        (failed) => widget.profiles.any((profile) => profile.id == failed.id),
      ))
        MaterialBanner(
          content: Text(
            'Automatic transactions in "${profile.name}" need attention. '
            'Review your schedules to check categories and resolve posting issues.',
          ),
          actions: [
            TextButton(
              onPressed: _running ? null : () => _review(profile),
              child: const Text('Review schedules'),
            ),
          ],
        ),
      Expanded(child: widget.child),
    ],
  );
}
