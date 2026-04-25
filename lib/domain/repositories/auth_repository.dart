import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String email, String password);
  Future<void> logout();
  Stream<UserEntity?> get authStateChanges;
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<UserEntity> signInWithGoogle();
}