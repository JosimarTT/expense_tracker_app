import '../../transactions/domain/entities/financial_transaction.dart';
import 'entities/budget_rule.dart';

class BucketProgress {
  const BucketProgress({
    required this.bucket,
    required this.targetMinor,
    required this.spentMinor,
  });

  final BudgetBucket bucket;
  final int targetMinor;
  final int spentMinor;
  bool get isOverBudget => spentMinor > targetMinor;
  double get progress => targetMinor == 0
      ? (spentMinor == 0 ? 0 : 1)
      : (spentMinor / targetMinor).clamp(0, 1);
}

class BudgetSummary {
  BudgetSummary({
    required this.incomeMinor,
    required this.expenseMinor,
    required this.unallocatedExpenseMinor,
    required Iterable<BucketProgress> buckets,
  }) : buckets = List.unmodifiable(buckets);

  final int incomeMinor;
  final int expenseMinor;
  final int unallocatedExpenseMinor;
  final List<BucketProgress> buckets;
  int get balanceMinor => incomeMinor - expenseMinor;
}

class BudgetCalculator {
  const BudgetCalculator();

  int _add(int left, int right) {
    final result = BigInt.from(left) + BigInt.from(right);
    if (result > BigInt.parse('9223372036854775807')) {
      throw StateError('Monthly totals exceed the supported 64-bit minor-unit range.');
    }
    return result.toInt();
  }

  BudgetSummary calculate({
    required BudgetRule rule,
    required Iterable<FinancialTransaction> transactions,
  }) {
    var income = 0;
    var expenses = 0;
    var unallocated = 0;
    final spent = {for (final bucket in rule.buckets) bucket.id: 0};
    final categoryBucket = {
      for (final bucket in rule.buckets)
        for (final category in bucket.categoryIds) category: bucket.id,
    };
    for (final transaction in transactions) {
      if (transaction.profileId != rule.profileId ||
          transaction.occurredAt.isBefore(rule.periodStart) ||
          !transaction.occurredAt.isBefore(rule.periodEnd)) {
        continue;
      }
      if (transaction.type == TransactionType.income) {
        income = _add(income, transaction.amountMinor);
      } else {
        expenses = _add(expenses, transaction.amountMinor);
        final bucketId = categoryBucket[transaction.categoryId];
        if (bucketId == null) {
          unallocated += transaction.amountMinor;
        } else {
          spent[bucketId] = spent[bucketId]! + transaction.amountMinor;
        }
      }
    }
    // BigInt prevents intermediate overflow; largest remainders preserve cents.
    final denominator = BigInt.from(10000);
    final products = [
      for (final bucket in rule.buckets)
        BigInt.from(income) * BigInt.from(bucket.allocationBps),
    ];
    final targets = [for (final product in products) (product ~/ denominator).toInt()];
    var remainder = income - targets.fold(0, (sum, value) => sum + value);
    final order = List.generate(targets.length, (index) => index)
      ..sort((a, b) {
        final compared = (products[b] % denominator).compareTo(products[a] % denominator);
        return compared != 0 ? compared : rule.buckets[a].id.compareTo(rule.buckets[b].id);
      });
    for (final index in order) {
      if (remainder == 0) break;
      targets[index]++;
      remainder--;
    }
    return BudgetSummary(
      incomeMinor: income,
      expenseMinor: expenses,
      unallocatedExpenseMinor: unallocated,
      buckets: [
        for (var index = 0; index < rule.buckets.length; index++)
          BucketProgress(
            bucket: rule.buckets[index],
            targetMinor: targets[index],
            spentMinor: spent[rule.buckets[index].id]!,
          ),
      ],
    );
  }
}
