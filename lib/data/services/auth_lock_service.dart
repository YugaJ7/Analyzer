import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AuthLockService {
  AuthLockService._();
  static final AuthLockService instance = AuthLockService._();

  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      if (!isSupported) {
        _show('Not Supported', 'Device does not support authentication');
        return false;
      }

      final result = await _auth.authenticate(
        localizedReason: 'Unlock Personal Analyzer',
        biometricOnly: false
      );

      return result;
    }

    // HANDLE LOCAL AUTH EXCEPTION PROPERLY
    on LocalAuthException catch (e) {
      switch (e.code) {
        case LocalAuthExceptionCode.noCredentialsSet:
          _show(
            'No Lock Found',
            'Please set a screen lock (PIN/Pattern/Password) in device settings.',
          );
          break;

        case LocalAuthExceptionCode.noBiometricsEnrolled:
          _show(
            'No Biometrics',
            'No fingerprint or face registered. Using device lock instead.',
          );
          break;

        case LocalAuthExceptionCode.userCanceled:
          break;

        case LocalAuthExceptionCode.systemCanceled:
          break;

        case LocalAuthExceptionCode.timeout:
          _show('Timeout', 'Authentication timed out. Try again.');
          break;

        case LocalAuthExceptionCode.biometricLockout:
        case LocalAuthExceptionCode.temporaryLockout:
          _show(
            'Locked Out',
            'Too many attempts. Use device password.',
          );
          break;

        case LocalAuthExceptionCode.uiUnavailable:
          _show(
            'UI Error',
            'Authentication UI not available.',
          );
          break;

        default:
          _show(
            'Auth Error',
            e.description ?? 'Authentication failed',
          );
      }

      return false;
    }

    
    on PlatformException catch (e) {
      _show('Platform Error', e.message ?? 'Something went wrong');
      return false;
    }

    // UNKNOWN
    catch (e) {
      _show('Error', "Something went wrong");
      return false;
    }
  }

  void _show(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}