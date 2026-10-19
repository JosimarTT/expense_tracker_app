abstract interface class SavingsRepository {
  Future<void> setAutomatic(String profileId, bool enabled, DateTime now);
  Future<void> process(String profileId, DateTime now);
}
