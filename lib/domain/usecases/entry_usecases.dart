import '../entities/entry_entity.dart';
import '../repositories/entry_repository.dart';

class GetEntriesForDate {
  final EntryRepository repository;
  GetEntriesForDate(this.repository);

  Future<List<EntryEntity>> call(
      String userId, DateTime date) {
    return repository.getEntriesForDate(userId, date);
  }
}

class SaveEntry {
  final EntryRepository repository;
  SaveEntry(this.repository);

  Future<void> call(EntryEntity entry) {
    return repository.saveEntry(entry);
  }
}

class UpdateEntry {
  final EntryRepository repository;
  UpdateEntry(this.repository);

  Future<void> call(
      String userId,
      DateTime date,
      String parameterId,
      Map<String, dynamic> updates) {
    return repository.updateEntry(
        userId, date, parameterId, updates);
  }
}

class DeleteEntry {
  final EntryRepository repository;
  DeleteEntry(this.repository);

  Future<void> call(
      String userId,
      DateTime date,
      String parameterId) {
    return repository.deleteEntry(
        userId, date, parameterId);
  }
}
