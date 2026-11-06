import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../core/utils/app_strings.dart';
import '../../data/services/auth_lock_service.dart';

/// What the user was doing when authentication was requested; the same
/// failure needs different advice in each case.
enum AuthLockPurpose { unlock, enable, disable }

abstract final class AuthLockFeedback {
  static void show(AuthLockResult result, AuthLockPurpose purpose) {
    final copy = messageFor(result.failure, purpose);
    if (copy == null || Get.testMode) return;
    Get.snackbar(copy.title, copy.message, snackPosition: SnackPosition.BOTTOM);
  }

  /// Null when nothing should be shown: the user cancelled, or the lock
  /// screen already explains a missing device lock next to its sign-out.
  @visibleForTesting
  static ({String title, String message})? messageFor(
    AuthLockFailure? failure,
    AuthLockPurpose purpose,
  ) => switch (failure) {
    null ||
    AuthLockFailure.userCanceled ||
    AuthLockFailure.systemCanceled => null,
    AuthLockFailure.notSupported ||
    AuthLockFailure.noCredentialsSet => switch (purpose) {
      AuthLockPurpose.unlock => null,
      AuthLockPurpose.enable => (
        title: AppStrings.noScreenLockTitle,
        message: AppStrings.noScreenLockMessage,
      ),
      AuthLockPurpose.disable => (
        title: AppStrings.noScreenLockTitle,
        message: AppStrings.noScreenLockToDisableMessage,
      ),
    },
    AuthLockFailure.noBiometricsEnrolled => (
      title: AppStrings.noBiometricsTitle,
      message: AppStrings.noBiometricsMessage,
    ),
    AuthLockFailure.lockout => (
      title: AppStrings.authLockedOutTitle,
      message: AppStrings.authLockedOutMessage,
    ),
    AuthLockFailure.timeout => (
      title: AppStrings.authTimeoutTitle,
      message: AppStrings.authTimeoutMessage,
    ),
    AuthLockFailure.uiUnavailable ||
    AuthLockFailure.platform ||
    AuthLockFailure.unknown => (
      title: AppStrings.authFailedTitle,
      message: AppStrings.authFailedMessage,
    ),
  };
}
