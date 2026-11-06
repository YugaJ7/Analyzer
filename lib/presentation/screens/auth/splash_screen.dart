import 'dart:async';
import 'dart:developer';

import 'package:analyzer/core/theme/app_background.dart';
import 'package:analyzer/presentation/screens/auth/splash_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/services/auth_lock_service.dart';
import '../../../data/services/preferences_service.dart';
import '../../../data/services/user_session_storage.dart';
import '../../services/auth_lock_feedback.dart';
import '../../services/sign_out_flow.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // The biometric sheet can be briefly unavailable right after launch.
  static const _biometricRetryDelay = Duration(milliseconds: 400);

  final RxBool showUnlock = false.obs;
  final RxBool isAuthenticating = false.obs;
  final RxBool isDeviceLockUnavailable = false.obs;

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
      unawaited(Get.offAllNamed(AppRoutes.login));
      return;
    }

    try {
      await UserSessionStorage.bindToUser(user.uid);

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
          isDeviceLockUnavailable.value = authResult.isDeviceLockUnavailable;
          showUnlock.value = true;
          return;
        }
      }

      await _ensureMinimumSplashTime(startedAt);
      log(
        'startup: splash -> home in ${totalStopwatch.elapsedMilliseconds}ms',
        name: 'PERF',
      );
      unawaited(Get.offAllNamed(AppRoutes.home));
    } catch (e) {
      await _ensureMinimumSplashTime(startedAt);
      log(
        'startup: splash failed -> login in ${totalStopwatch.elapsedMilliseconds}ms',
        name: 'PERF',
      );
      unawaited(Get.offAllNamed(AppRoutes.login));
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
    try {
      var result = await AuthLockService.instance.authenticate();

      if (result.failure == AuthLockFailure.uiUnavailable) {
        await Future<void>.delayed(_biometricRetryDelay);
        result = await AuthLockService.instance.authenticate();
      }

      return result;
    } finally {
      isAuthenticating.value = false;
    }
  }

  Future<void> _unlock() async {
    final result = await _authenticate();
    isDeviceLockUnavailable.value = result.isDeviceLockUnavailable;

    if (result.isAuthenticated) {
      unawaited(Get.offAllNamed(AppRoutes.home));
    } else {
      AuthLockFeedback.show(result, AuthLockPurpose.unlock);
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
              onSignOut: isDeviceLockUnavailable.value
                  ? SignOutFlow.fromUnusableLock
                  : null,
            );
          }),
        ),
      ),
    );
  }
}
