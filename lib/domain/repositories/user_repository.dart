import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity> createUser(String id, String email, String name);
  Future<UserEntity?> getUser(String id);

  /// Returns the stored profile, creating it first if missing.
  Future<UserEntity> ensureUser(String id, String email, String name);
  Future<void> updateUser(String id, Map<String, dynamic> data);
  Future<void> deleteUser(String id);
}
