import 'package:analyzer/core/utils/app_strings.dart';
import 'package:analyzer/data/services/auth_lock_service.dart';
import 'package:analyzer/presentation/services/auth_lock_feedback.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const missingLock = [
    AuthLockFailure.notSupported,
    AuthLockFailure.noCredentialsSet,
  ];

  test('stays silent when the user cancels', () {
    for (final purpose in AuthLockPurpose.values) {
      for (final failure in [
        null,
        AuthLockFailure.userCanceled,
        AuthLockFailure.systemCanceled,
      ]) {
        expect(AuthLockFeedback.messageFor(failure, purpose), isNull);
      }
    }
  });

  test('tells the user to add a screen lock when enabling', () {
    for (final failure in missingLock) {
      final copy = AuthLockFeedback.messageFor(failure, AuthLockPurpose.enable);

      expect(copy?.title, AppStrings.noScreenLockTitle);
      expect(copy?.message, AppStrings.noScreenLockMessage);
    }
  });

  test('explains why the lock cannot be turned off without one', () {
    for (final failure in missingLock) {
      final copy = AuthLockFeedback.messageFor(
        failure,
        AuthLockPurpose.disable,
      );

      expect(copy?.message, AppStrings.noScreenLockToDisableMessage);
    }
  });

  test('leaves a missing lock to the lock screen while unlocking', () {
    for (final failure in missingLock) {
      expect(
        AuthLockFeedback.messageFor(failure, AuthLockPurpose.unlock),
        isNull,
      );
    }
  });

  test('has a message for every other failure in every flow', () {
    final silent = {
      AuthLockFailure.userCanceled,
      AuthLockFailure.systemCanceled,
      ...missingLock,
    };
    for (final failure in AuthLockFailure.values.where(
      (f) => !silent.contains(f),
    )) {
      for (final purpose in AuthLockPurpose.values) {
        expect(
          AuthLockFeedback.messageFor(failure, purpose),
          isNotNull,
          reason: '$failure / $purpose',
        );
      }
    }
  });
}
