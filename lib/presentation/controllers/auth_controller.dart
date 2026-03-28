import 'dart:developer';

import 'package:analyzer/core/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/login_user.dart';
import '../../../domain/usecases/register_user.dart';
import '../../../domain/usecases/logout_user.dart';
import '../../../data/repositories/user_repository_impl.dart';

class AuthController extends GetxController {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final LogoutUser logoutUser;

  AuthController({
    required this.loginUser,
    required this.registerUser,
    required this.logoutUser,
  });

  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<UserEntity?> currentUser = Rx<UserEntity?>(null);
  final RxBool isLoading = false.obs;

  final UserRepositoryImpl _userRepo = UserRepositoryImpl();

  Future<void> _loadUserData(String uid) async {
    try {
      final user = await _userRepo.getUser(uid);
      currentUser.value = user;
    } catch (_) {
      Get.snackbar('Error', 'Failed to load user data',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await loginUser(email, password);

      final uid = FirebaseAuth.instance.currentUser!.uid;
      await _loadUserData(uid);

      Get.snackbar('Success', 'Welcome back!',
          snackPosition: SnackPosition.BOTTOM);

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar('Error', 'Login failed',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(
      String email,
      String password,
      String name,
      ) async {
    try {
      isLoading.value = true;
      log("Starting registration...");
      final user = await registerUser(email, password, name);
      log("User created in Firestore");

      currentUser.value = user;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);

      Get.snackbar('Success', 'Account created successfully!',
          snackPosition: SnackPosition.BOTTOM);

      Get.offNamed(AppRoutes.parameterSetup);
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed';
      if (e.code == 'weak-password') {
        message = 'Password is too weak';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email already registered';
      }

      Get.snackbar('Error', message,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
