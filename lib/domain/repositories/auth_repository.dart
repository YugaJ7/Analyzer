import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String email, String password);
  Future<void> logout();

  /// Best-effort removal of the signed-in account; signs out if deletion
  /// fails. Used to roll back a partially completed sign-up.
  Future<void> deleteCurrentUser();
  Future<UserEntity> signInWithGoogle();
}
