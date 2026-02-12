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
}
