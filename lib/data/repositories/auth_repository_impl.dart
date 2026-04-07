import 'package:analyzer/core/utils/helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return UserEntity(
        id: credential.user!.uid,
        email: credential.user!.email!,
        name: credential.user!.displayName ?? '',
        createdAt: credential.user!.metadata.creationTime ?? DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      throw AppException(AuthFailure(mapAuthError(e.code)));
    } catch (e) {
      throw AppException(
        NetworkFailure('Login failed. Check your connection.'),
      );
    }
  }

  @override
  Future<UserEntity> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return UserEntity(
        id: credential.user!.uid,
        email: credential.user!.email!,
        name: '',
        createdAt: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      throw AppException(AuthFailure(mapAuthError(e.code)));
    } catch (e) {
      throw AppException(
        NetworkFailure('Registration failed. Check your connection.'),
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AppException(AuthFailure('Sign-out failed. Please try again.'));
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserEntity(
        id: user.uid,
        email: user.email!,
        name: user.displayName ?? '',
        createdAt: user.metadata.creationTime ?? DateTime.now(),
      );
    });
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AppException(const AuthFailure('No authenticated user found.'));
      }
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AppException(AuthFailure(mapAuthError(e.code)));
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(NetworkFailure('Password change failed.'));
    }
  }
}
