import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_background.dart';
import '../../../data/services/auth_lock_service.dart';
import 'splash_content.dart';

/// Shown over the current route when the app resumes locked. Pops on unlock
/// so the user returns exactly where they left off.
class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  Future<void> _unlock() async {
    if (_isAuthenticating) return;

    _isAuthenticating = true;
    try {
      final result = await AuthLockService.instance.authenticate();
      if (result.isAuthenticated && mounted) Get.back<void>();
    } finally {
      _isAuthenticating = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: AppBackground(
          child: Center(
            child: AnimatedSplashContent(isLocked: true, onUnlock: _unlock),
          ),
        ),
      ),
    );
  }
}
