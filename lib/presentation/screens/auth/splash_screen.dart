import 'dart:developer';
import 'package:analyzer/core/theme/app_background.dart';
import 'package:analyzer/core/utils/app_strings.dart';
import 'package:analyzer/presentation/screens/auth/splash_content.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/services/auth_lock_service.dart';
import '../../../data/services/preferences_service.dart';

import '../../../core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final RxBool showUnlock = false.obs;
  final RxBool isAuthenticating = false.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final totalStopwatch = Stopwatch()..start();
    final startedAt = DateTime.now();
    log('startup: splash init', name: 'PERF');

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      await _ensureMinimumSplashTime(startedAt);
      log(
        'startup: splash -> login in ${totalStopwatch.elapsedMilliseconds}ms',
        name: 'PERF',
      );
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    try {
      final isLockEnabled = PreferencesService.instance.appLockEnabled;

      log('App Lock Enabled: $isLockEnabled');

      if (isLockEnabled) {
        final authStopwatch = Stopwatch()..start();
        final authResult = await _authenticate();
        log(
          'startup: app lock auth finished in ${authStopwatch.elapsedMilliseconds}ms',
          name: 'PERF',
        );

        if (!authResult.isAuthenticated) {
          showUnlock.value = true;
          return;
        }
      }

      await _ensureMinimumSplashTime(startedAt);
      log(
        'startup: splash -> home in ${totalStopwatch.elapsedMilliseconds}ms',
        name: 'PERF',
      );
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      await _ensureMinimumSplashTime(startedAt);
      log(
        'startup: splash failed -> login in ${totalStopwatch.elapsedMilliseconds}ms',
        name: 'PERF',
      );
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<void> _ensureMinimumSplashTime(DateTime startedAt) async {
    final elapsed = DateTime.now().difference(startedAt);
    const minimum = Duration(milliseconds: 250);

    if (elapsed < minimum) {
      await Future.delayed(minimum - elapsed);
    }
  }

  Future<AuthLockResult> _authenticate() async {
    if (isAuthenticating.value) {
      return const AuthLockResult.failure(AuthLockFailure.systemCanceled);
    }

    isAuthenticating.value = true;

    var result = await AuthLockService.instance.authenticate(showErrors: false);

    if (result.failure == AuthLockFailure.uiUnavailable) {
      await Future.delayed(const Duration(milliseconds: 400));
      result = await AuthLockService.instance.authenticate(showErrors: false);
    }

    isAuthenticating.value = false;

    return result;
  }

  Future<void> _unlock() async {
    final result = await _authenticate();

    if (result.isAuthenticated) {
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
