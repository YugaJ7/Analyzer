import 'dart:developer';
import 'package:analyzer/core/theme/app_background.dart';
import 'package:analyzer/core/utils/app_strings.dart';
import 'package:analyzer/presentation/screens/auth/splash_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/services/auth_lock_service.dart';
import '../../../data/services/preferences_service.dart';
import '../../../data/repositories/user_repository_impl.dart';

import '../../../core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final UserRepositoryImpl _userRepo = UserRepositoryImpl();

  final RxBool showUnlock = false.obs;
  final RxBool isAuthenticating = false.obs;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    try {
      final userData = await _userRepo.getUser(user.uid);

      if (userData == null) {
        Get.offAllNamed(AppRoutes.parameterSetup);
        return;
      }

      final isLockEnabled =
          PreferencesService.instance.appLockEnabled;

      log('App Lock Enabled: $isLockEnabled');

      if (isLockEnabled) {
        final isAuthenticated = await _authenticate();

        if (!isAuthenticated) {
          showUnlock.value = true;
          return;
        }
      }

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<bool> _authenticate() async {
    if (isAuthenticating.value) return false;

    isAuthenticating.value = true;

    final result =
        await AuthLockService.instance.authenticate();

    isAuthenticating.value = false;

    return result;
  }

  Future<void> _unlock() async {
    final success = await _authenticate();

    if (success) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.snackbar(
        AppStrings.accessDeniedTitle,
        AppStrings.accessDeniedMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: Obx(() {
            return AnimatedSplashContent(
              isLocked: showUnlock.value,
              onUnlock: _unlock,
            );
          }),
        ),
      ),
    );
  }
}