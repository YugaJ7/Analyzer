import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';

class SignInWithGoogle {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  SignInWithGoogle(this.authRepository, this.userRepository);

  Future<UserEntity> call() async {
    final userAuth = await authRepository.signInWithGoogle();
    try {
      return await userRepository.ensureUser(
        userAuth.id,
        userAuth.email,
        userAuth.name,
      );
    } catch (_) {
      // Never leave a session without a profile; let the user retry cleanly.
      await authRepository.logout().catchError((_) {});
      rethrow;
    }
  }
}
