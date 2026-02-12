import 'package:analyzer/domain/entities/entry_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EntryModel extends EntryEntity {
  EntryModel({
    required super.id,
    required super.userId,
    required super.parameterId,
    required super.date,
    required super.value,
    super.notes,
    required super.createdAt,
  });

  factory EntryModel.fromFirestore({
    required DocumentSnapshot<Map<String, dynamic>> doc,
    required String userId,
    required DateTime date,
  }) {
    final data = doc.data()!;

    return EntryModel(
      id: doc.id,
      userId: userId,
      parameterId: doc.id,
      date: date,
      value: data['value'],
      notes: data['notes'],
      createdAt:
          (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'value': value,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
