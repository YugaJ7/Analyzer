import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';

class RegisterUser {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  RegisterUser(this.authRepository, this.userRepository);

  Future<UserEntity> call(String email, String password, String name) async {
    final userAuth = await authRepository.register(email, password);
    try {
      return await userRepository.createUser(userAuth.id, email, name);
    } catch (_) {
      // Roll back so a retry isn't blocked by "email already registered".
      await authRepository.deleteCurrentUser();
      rethrow;
    }
  }
}
