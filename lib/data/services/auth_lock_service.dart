import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

enum AuthLockFailure {
  notSupported,
  noCredentialsSet,
  noBiometricsEnrolled,
  userCanceled,
  systemCanceled,
  timeout,
  lockout,
  uiUnavailable,
  platform,
  unknown,
}

class AuthLockResult {
  const AuthLockResult._({required this.isAuthenticated, this.failure});

  const AuthLockResult.success() : this._(isAuthenticated: true);

  const AuthLockResult.failure(AuthLockFailure failure)
    : this._(isAuthenticated: false, failure: failure);

  final bool isAuthenticated;
  final AuthLockFailure? failure;
}

class AuthLockService {
  AuthLockService._();
  static final AuthLockService instance = AuthLockService._();

  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> canAuthenticate() async {
    final canCheckBiometrics = await _auth.canCheckBiometrics;
    return canCheckBiometrics || await _auth.isDeviceSupported();
  }

  Future<AuthLockResult> authenticate({bool showErrors = true}) async {
    try {
      final isSupported = await canAuthenticate();
      if (!isSupported) {
        if (showErrors) {
          _show('Not Supported', 'Device does not support authentication');
        }
        return const AuthLockResult.failure(AuthLockFailure.notSupported);
      }

      final result = await _auth.authenticate(
        localizedReason: 'Unlock Personal Analyzer',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );

      return result
          ? const AuthLockResult.success()
          : const AuthLockResult.failure(AuthLockFailure.userCanceled);
    } on LocalAuthException catch (e) {
      switch (e.code) {
        case LocalAuthExceptionCode.noCredentialsSet:
          if (showErrors) {
            _show(
              'No Lock Found',
              'Please set a screen lock (PIN/Pattern/Password) in device settings.',
            );
          }
          return const AuthLockResult.failure(AuthLockFailure.noCredentialsSet);

        case LocalAuthExceptionCode.noBiometricsEnrolled:
          if (showErrors) {
            _show(
              'No Biometrics',
              'No fingerprint or face registered. Using device lock instead.',
            );
          }
          return const AuthLockResult.failure(
            AuthLockFailure.noBiometricsEnrolled,
          );

        case LocalAuthExceptionCode.userCanceled:
          return const AuthLockResult.failure(AuthLockFailure.userCanceled);

        case LocalAuthExceptionCode.systemCanceled:
          return const AuthLockResult.failure(AuthLockFailure.systemCanceled);

        case LocalAuthExceptionCode.timeout:
          if (showErrors) {
            _show('Timeout', 'Authentication timed out. Try again.');
          }
          return const AuthLockResult.failure(AuthLockFailure.timeout);

        case LocalAuthExceptionCode.biometricLockout:
        case LocalAuthExceptionCode.temporaryLockout:
          if (showErrors) {
            _show('Locked Out', 'Too many attempts. Use device password.');
          }
          return const AuthLockResult.failure(AuthLockFailure.lockout);

        case LocalAuthExceptionCode.uiUnavailable:
          if (showErrors) {
            _show(
              'UI Error',
              'Authentication UI not available on this device right now.',
            );
          }
          return const AuthLockResult.failure(AuthLockFailure.uiUnavailable);

        default:
          if (showErrors) {
            _show('Auth Error', e.description ?? 'Authentication failed');
          }
          return const AuthLockResult.failure(AuthLockFailure.unknown);
      }
    } on PlatformException catch (e) {
      if (showErrors) {
        _show('Platform Error', e.message ?? 'Something went wrong');
      }
      return const AuthLockResult.failure(AuthLockFailure.platform);
    } catch (e) {
      if (showErrors) {
        _show('Error', 'Something went wrong');
      }
      return const AuthLockResult.failure(AuthLockFailure.unknown);
    }
  }

  void _show(String title, String message) {
    Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM);
  }
}
