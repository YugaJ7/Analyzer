import 'dart:async';

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/routes/app_routes.dart';
import '../../../data/services/preferences_service.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/login_user.dart';
import '../../../domain/usecases/register_user.dart';
import '../../../domain/usecases/logout_user.dart';
import '../../../domain/usecases/user_usecases.dart';

class AuthController extends GetxController {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final LogoutUser logoutUser;
  final GetUserProfile getUserProfile;

  AuthController({
    required this.loginUser,
    required this.registerUser,
    required this.logoutUser,
    required this.getUserProfile,
  });

  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<UserEntity?> currentUser = Rx<UserEntity?>(null);
  final RxBool isLoading = false.obs;

  final RxString errorMessage = ''.obs;

  Future<void> _loadUserData(String uid) async {
    try {
      final user = await getUserProfile(uid);
      currentUser.value = user;
    } on AppException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Failed to load user data.';
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await loginUser(email, password);

      final uid = FirebaseAuth.instance.currentUser!.uid;

      unawaited(_loadUserData(uid));

      await Future.delayed(const Duration(milliseconds: 700));

      Get.offAllNamed(AppRoutes.home);
    } on AppException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Login Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String email, String password, String name) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await registerUser(email, password, name);
      currentUser.value = user;

      await PreferencesService.instance.clearLegacyAppLock();
      await PreferencesService.instance.clearGuestAppLock();
      await PreferencesService.instance.setAppLockEnabled(false);

      // Cache display name locally via PreferencesService
      await PreferencesService.instance.setUserName(name);

      // Get.snackbar('Account created!', 'Welcome to Analyzer',
      //     snackPosition: SnackPosition.BOTTOM);
      Get.offNamed(AppRoutes.parameterSetup);
    } on AppException catch (e) {
      errorMessage.value = e.message;
      Get.snackbar(
        'Registration Failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      const msg = 'Registration failed. Please try again.';
      errorMessage.value = msg;
      Get.snackbar('Error', msg, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
