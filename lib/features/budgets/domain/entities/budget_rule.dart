class BudgetBucket {
  BudgetBucket({
    required this.id,
    required String name,
    required this.allocationBps,
    Iterable<String> categoryIds = const [],
  }) : name = name.trim(),
       categoryIds = Set.unmodifiable(categoryIds) {
    if (id.trim().isEmpty || this.name.isEmpty) {
      throw ArgumentError('Bucket identifier and name must not be empty.');
    }
    if (allocationBps < 0 || allocationBps > 10000) {
      throw ArgumentError.value(allocationBps, 'allocationBps', 'Must be 0-10000.');
    }
    if (this.categoryIds.any((id) => id.trim().isEmpty)) {
      throw ArgumentError('Category identifiers must not be empty.');
    }
  }

  final String id;
  final String name;
  final int allocationBps;
  final Set<String> categoryIds;
}

class BudgetRule {
  BudgetRule({
    required this.id,
    required this.profileId,
    required String name,
    required DateTime periodStart,
    required DateTime periodEnd,
    required Iterable<BudgetBucket> buckets,
  }) : name = name.trim(),
       periodStart = periodStart.toUtc(),
       periodEnd = periodEnd.toUtc(),
       buckets = List.unmodifiable(buckets) {
    if (id.trim().isEmpty || profileId.trim().isEmpty || this.name.isEmpty) {
      throw ArgumentError('Budget identifiers and name must not be empty.');
    }
    if (!this.periodEnd.isAfter(this.periodStart)) {
      throw ArgumentError('Budget end must be after its start.');
    }
    if (this.buckets.isEmpty ||
        this.buckets.fold(0, (sum, bucket) => sum + bucket.allocationBps) !=
            10000) {
      throw ArgumentError('Budget allocations must total exactly 10000 bps.');
    }
    final bucketIds = <String>{};
    final categoryIds = <String>{};
    for (final bucket in this.buckets) {
      if (!bucketIds.add(bucket.id)) {
        throw ArgumentError('Bucket identifiers must be unique within a budget.');
      }
      for (final categoryId in bucket.categoryIds) {
        if (!categoryIds.add(categoryId)) {
          throw ArgumentError('A category can belong to only one budget bucket.');
        }
      }
    }
  }

  final String id;
  final String profileId;
  final String name;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<BudgetBucket> buckets;
}
