import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../data/repositories/user_repository_impl.dart';
import '../../../../data/services/preferences_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final UserRepositoryImpl _userRepo = UserRepositoryImpl();
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));

    FirebaseAuth.instance.authStateChanges().first.then((user) async {
      if (user == null) {
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      try {
        final userData = await _userRepo.getUser(user.uid);
        if (userData == null) {
          Get.offAllNamed(AppRoutes.parameterSetup);
          return;
        }

        // Check if biometric lock is enabled before navigating to home
        final biometricEnabled = PreferencesService.instance.biometricEnabled;
        if (biometricEnabled) {
          final passed = await _authenticateWithBiometric();
          if (!passed) {
            // Failed or cancelled — sign out and return to login
            await FirebaseAuth.instance.signOut();
            Get.offAllNamed(AppRoutes.login);
            return;
          }
        }

        Get.offAllNamed(AppRoutes.home);
      } catch (e) {
        Get.offAllNamed(AppRoutes.login);
      }
    });
  }

  Future<bool> _authenticateWithBiometric() async {
    try {
      final isAvailable = await _localAuth.isDeviceSupported();
      if (!isAvailable) return true; // device doesn't support it — skip lock

      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return true; // no biometrics enrolled — skip lock

      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access Personal Analyzer',
      );
    } on PlatformException {
      // If biometrics fail to initialise (device doesn't support the plugin),
      // do not block the user — just skip the lock.
      return true;
    } catch (_) {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3),
                    ),
                    child: const Icon(
                      Icons.insights_rounded,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(
                    duration: 2000.ms,
                    color: Colors.white.withValues(alpha: 0.3),
                  )
                  .fadeIn(duration: 600.ms)
                  .scale(delay: 200.ms),
              const SizedBox(height: 32),
              const Text(
                'Personal Analyzer',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.5,
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
              const SizedBox(height: 12),
              Text(
                'Track • Analyze • Grow',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
