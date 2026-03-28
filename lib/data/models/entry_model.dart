import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/entry_entity.dart';

class EntryModel extends EntryEntity {
  const EntryModel({
    required super.id,
    required super.userId,
    required super.parameterId,
    required super.date,
    required super.value,
    super.notes,
    required super.createdAt,
  });

  // Factory constructors
  factory EntryModel.fromEntity(EntryEntity entity) {
    return EntryModel(
      id: entity.id,
      userId: entity.userId,
      parameterId: entity.parameterId,
      date: entity.date,
      value: entity.value,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }

  factory EntryModel.fromJson(Map<String, dynamic> json) {
    return EntryModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      parameterId: json['parameterId'] as String,
      date: DateTime.parse(json['date'] as String),
      value: json['value'],
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  factory EntryModel.fromFirestore({
    required DocumentSnapshot<Map<String, dynamic>> doc,
    required String userId,
    required DateTime date,
  }) {
    final data = doc.data()!;
    return EntryModel(
      id: doc.id,
      userId: userId,
      parameterId: data['parameterId'] as String? ?? doc.id,
      date: date,
      value: data['value'],
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  //Serialisation

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'parameterId': parameterId,
      'date': date.toIso8601String(),
      'value': value,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'parameterId': parameterId,
      'date': Timestamp.fromDate(date),
      'value': value,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  EntryEntity toEntity() => this;
}
