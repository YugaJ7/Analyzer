import 'package:analyzer/core/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
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
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user data',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await loginUser(email, password);
      Get.snackbar('Success', 'Welcome back!',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      String message = 'Login failed';
      if (e.toString().contains('internal error')) {
        message = 'Check your internet connection';
      } else if (e.toString().contains('invalid-credential')) {
        message = 'Incorrect user credentials';
      } else if (e.toString().contains('too-many-requests')) {
        message = 'Too many login attempts. Please try again later.';
      }
      Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String email, String password, String name) async {
    try {
      isLoading.value = true;
      await registerUser(email, password, name);
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
      Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'An error occurred',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await logoutUser();
    } catch (e) {
      Get.snackbar('Error', 'Logout failed',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updateUserName(String newName) async {
    try {
      isLoading.value = true;
      await _userRepo.updateUser(firebaseUser.value!.uid, {'name': newName});
      await _loadUserData(firebaseUser.value!.uid);
      Get.snackbar('Success', 'Name updated',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update name',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}