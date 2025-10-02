class UserEntity {
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;
  final List<String> parameterIds;

  UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
    this.parameterIds = const [],
  });
}