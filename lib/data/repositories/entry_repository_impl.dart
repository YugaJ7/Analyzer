import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/entry_entity.dart';
import '../../domain/repositories/entry_repository.dart';

class EntryRepositoryImpl implements EntryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  CollectionReference<Map<String, dynamic>> _dailyParams(
    String userId,
    DateTime date,
  ) {
    final dateId = _formatDate(date);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('entries')
        .doc(dateId)
        .collection('parameters');
  }

  @override
  Future<List<EntryEntity>> getEntriesForDate(
    String userId,
    DateTime date,
  ) async {
    final snapshot = await _dailyParams(userId, date).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return EntryEntity(
        id: doc.id,
        userId: userId,
        parameterId: doc.id,
        date: date,
        value: data['value'],
        notes: data['notes'],
        createdAt: (data['createdAt'] as Timestamp).toDate(),
      );
    }).toList();
  }

  @override
  Future<void> saveEntry(EntryEntity entry) async {
    await _dailyParams(entry.userId, entry.date).doc(entry.parameterId).set({
      'value': entry.value,
      'notes': entry.notes,
      'createdAt': Timestamp.fromDate(entry.createdAt),
    });
  }

  @override
  Future<void> updateEntry(
    String userId,
    DateTime date,
    String parameterId,
    Map<String, dynamic> updates,
  ) async {
    await _dailyParams(userId, date).doc(parameterId).update(updates);
  }

  @override
  Future<void> deleteEntry(
    String userId,
    DateTime date,
    String parameterId,
  ) async {
    await _dailyParams(userId, date).doc(parameterId).delete();
  }

  @override
  Future<Map<DateTime, List<EntryEntity>>> getEntriesForLastNDays(
    String userId,
    int days,
  ) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    final entriesCollection = _firestore
        .collection('users')
        .doc(userId)
        .collection('entries');

    final snapshot = await entriesCollection.get();

    final Map<DateTime, List<EntryEntity>> result = {};

    for (final doc in snapshot.docs) {
      final dateParts = doc.id.split('-');
      if (dateParts.length != 3) continue;

      final date = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );

      if (date.isBefore(startDate)) continue;

      final paramsSnapshot = await doc.reference.collection('parameters').get();

      final entries = paramsSnapshot.docs.map((p) {
        final data = p.data();
        return EntryEntity(
          id: p.id,
          userId: userId,
          parameterId: p.id,
          date: date,
          value: data['value'],
          notes: data['notes'],
          createdAt: (data['createdAt'] as Timestamp).toDate(),
        );
      }).toList();

      result[date] = entries;
    }

    return result;
  }
}
