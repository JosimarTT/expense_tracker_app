import '../entities/budget_rule.dart';

abstract interface class BudgetRepository {
  Stream<List<BudgetRule>> watchBudgets(String profileId);

  /// Saves the rule, buckets, and category links in one database transaction.
  Future<void> save(BudgetRule budget);

  /// Tombstones the budget and its children atomically.
  Future<void> delete({required String profileId, required String budgetId});
}
