import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../core/bindings/home_binding.dart';
import '../../core/errors/app_exception.dart';
import '../../core/routes/app_routes.dart';
import '../../data/services/preferences_service.dart';
import '../../data/services/user_session_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/logout_user.dart';

abstract final class SignOutFlow {
  /// Signs out first so a failure leaves the app fully usable; cleanup after
  /// is best-effort and never blocks navigation. False if sign-out failed.
  static Future<bool> run(LogoutUser logoutUser) async {
    try {
      await logoutUser();
    } on AppException catch (e) {
      Get.snackbar('Error', e.message, snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    await UserSessionStorage.clear();
    HomeBinding.tearDown();
    unawaited(Get.offAllNamed(AppRoutes.login));
    return true;
  }

  /// Escape from an app lock the device can no longer satisfy. Re-entry needs
  /// account credentials, so nothing is bypassed. The lock is dropped only
  /// once sign-out succeeds, so it can't trap the user again on next sign-in.
  static Future<void> fromUnusableLock() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final signedOut = await run(LogoutUser(Get.find<AuthRepository>()));
    if (signedOut && uid != null) {
      await PreferencesService.instance.disableAppLockFor(uid);
    }
  }
}
