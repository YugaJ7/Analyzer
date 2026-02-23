class EntryEntity {
  final String id;
  final String userId;
  final String parameterId;
  final DateTime date;
  final dynamic value;
  final String? notes;
  final DateTime createdAt;

  const EntryEntity({
    required this.id,
    required this.userId,
    required this.parameterId,
    required this.date,
    required this.value,
    this.notes,
    required this.createdAt,
  });

  EntryEntity copyWith({
    String? id,
    String? userId,
    String? parameterId,
    DateTime? date,
    dynamic value,
    String? notes,
    DateTime? createdAt,
  }) {
    return EntryEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      parameterId: parameterId ?? this.parameterId,
      date: date ?? this.date,
      value: value ?? this.value,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
