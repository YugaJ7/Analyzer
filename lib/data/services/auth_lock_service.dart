import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

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

  /// The device has no usable lock (e.g. removed after app lock was enabled),
  /// so retrying can never succeed.
  bool get isDeviceLockUnavailable =>
      failure == AuthLockFailure.notSupported ||
      failure == AuthLockFailure.noCredentialsSet;
}

class AuthLockService {
  AuthLockService._();
  static final AuthLockService instance = AuthLockService._();

  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> canAuthenticate() async {
    final canCheckBiometrics = await _auth.canCheckBiometrics;
    return canCheckBiometrics || await _auth.isDeviceSupported();
  }

  /// Reports the outcome only; wording belongs to the presentation layer,
  /// which knows whether the user is unlocking or changing the setting.
  Future<AuthLockResult> authenticate() async {
    try {
      if (!await canAuthenticate()) {
        // Android reports this when no screen lock is set, not only on
        // hardware that genuinely can't authenticate.
        return const AuthLockResult.failure(AuthLockFailure.notSupported);
      }

      final authenticated = await _auth.authenticate(
        localizedReason: 'Unlock Personal Analyzer',
        persistAcrossBackgrounding: true,
      );
      return authenticated
          ? const AuthLockResult.success()
          : const AuthLockResult.failure(AuthLockFailure.userCanceled);
    } on LocalAuthException catch (e) {
      return AuthLockResult.failure(_failureFor(e.code));
    } on PlatformException {
      return const AuthLockResult.failure(AuthLockFailure.platform);
    } catch (_) {
      return const AuthLockResult.failure(AuthLockFailure.unknown);
    }
  }

  static AuthLockFailure _failureFor(LocalAuthExceptionCode code) =>
      switch (code) {
        LocalAuthExceptionCode.noCredentialsSet =>
          AuthLockFailure.noCredentialsSet,
        LocalAuthExceptionCode.noBiometricsEnrolled =>
          AuthLockFailure.noBiometricsEnrolled,
        LocalAuthExceptionCode.userCanceled => AuthLockFailure.userCanceled,
        LocalAuthExceptionCode.systemCanceled => AuthLockFailure.systemCanceled,
        LocalAuthExceptionCode.timeout => AuthLockFailure.timeout,
        LocalAuthExceptionCode.biometricLockout ||
        LocalAuthExceptionCode.temporaryLockout => AuthLockFailure.lockout,
        LocalAuthExceptionCode.uiUnavailable => AuthLockFailure.uiUnavailable,
        _ => AuthLockFailure.unknown,
      };
}
