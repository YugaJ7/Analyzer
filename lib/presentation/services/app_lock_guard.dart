import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../data/services/preferences_service.dart';

/// Re-locks the app when it returns from the background, not just at cold
/// start.
class AppLockGuard extends GetxService with WidgetsBindingObserver {
  AppLockGuard({
    DateTime Function()? now,
    bool Function()? isLockRequired,
    Future<void> Function()? showLock,
  }) : _now = now ?? DateTime.now,
       _isLockRequired = isLockRequired ?? _defaultIsLockRequired,
       _showLock = showLock ?? _defaultShowLock;

  /// Grace period so quick trips (share sheet, notifications) don't re-lock.
  static const relockAfter = Duration(seconds: 30);

  final DateTime Function() _now;
  final bool Function() _isLockRequired;
  final Future<void> Function() _showLock;

  DateTime? _backgroundedAt;
  bool _isLocked = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      // `inactive` is skipped: the biometric prompt itself triggers it.
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _backgroundedAt ??= _now();
      case AppLifecycleState.resumed:
        final backgroundedAt = _backgroundedAt;
        _backgroundedAt = null;
        if (backgroundedAt != null &&
            _now().difference(backgroundedAt) >= relockAfter) {
          _lock();
        }
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _lock() async {
    if (_isLocked || !_isLockRequired()) return;

    _isLocked = true;
    try {
      await _showLock();
    } finally {
      _isLocked = false;
    }
  }

  static bool _defaultIsLockRequired() {
    // Splash runs its own lock check on cold start.
    if (Get.currentRoute == AppRoutes.splash) return false;
    return FirebaseAuth.instance.currentUser != null &&
        PreferencesService.instance.appLockEnabled;
  }

  static Future<void> _defaultShowLock() async {
    await Get.toNamed<void>(AppRoutes.lock);
  }
}
