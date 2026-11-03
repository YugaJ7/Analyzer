import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failures.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/services/preferences_service.dart';
import '../../../data/services/user_session_storage.dart';
import '../../../domain/usecases/login_user.dart';
import '../../../domain/usecases/register_user.dart';
import '../../../domain/usecases/sign_in_with_google.dart';

class AuthController extends GetxController {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final SignInWithGoogle signInWithGoogle;

  AuthController({
    required this.loginUser,
    required this.registerUser,
    required this.signInWithGoogle,
  });

  final RxBool isLoading = false.obs;

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      await loginUser(email, password);

      await UserSessionStorage.bindToUser(
        FirebaseAuth.instance.currentUser!.uid,
      );

      Get.offAllNamed(AppRoutes.home);
    } on AppException catch (e) {
      Get.snackbar(
        'Login Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogleMethod() async {
    try {
      isLoading.value = true;

      final user = await signInWithGoogle();
      await UserSessionStorage.bindToUser(user.id);

      await PreferencesService.instance.clearLegacyAppLock();
      await PreferencesService.instance.clearGuestAppLock();

      // Cache display name locally
      await PreferencesService.instance.setUserName(
        user.name.isEmpty ? 'User' : user.name,
      );

      Get.offAllNamed(AppRoutes.home);
    } on AppException catch (e) {
      if (e.failure is! AuthCancelledFailure) {
        Get.snackbar(
          'Login Failed',
          e.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {
      const msg = 'Google sign-in failed. Please try again.';
      Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String email, String password, String name) async {
    try {
      isLoading.value = true;

      final user = await registerUser(email, password, name);
      await UserSessionStorage.bindToUser(user.id);

      await PreferencesService.instance.clearLegacyAppLock();
      await PreferencesService.instance.clearGuestAppLock();

      // Cache display name locally via PreferencesService
      await PreferencesService.instance.setUserName(name);

      Get.offNamed(AppRoutes.parameterSetup);
    } on AppException catch (e) {
      Get.snackbar(
        'Registration Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      const msg = 'Registration failed. Please try again.';
      Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
