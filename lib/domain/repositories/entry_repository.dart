import '../entities/entry_entity.dart';

abstract class EntryRepository {
  Future<List<EntryEntity>> getEntriesForDate(String userId, DateTime date);

  Future<Map<DateTime, List<EntryEntity>>> getEntriesForLastNDays(
    String userId,
    int days,
  );

  Future<void> saveEntry(EntryEntity entry);

  Future<void> updateEntry(
    String userId,
    DateTime date,
    String parameterId,
    Map<String, dynamic> updates,
  );

  Future<void> deleteEntry(String userId, DateTime date, String parameterId);

  Future<void> deleteAllEntriesForParameter(String userId, String parameterId);
}
