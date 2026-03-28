import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../data/repositories/user_repository_impl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routes/app_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final UserRepositoryImpl _userRepo = UserRepositoryImpl();

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
        Get.offAllNamed(AppRoutes.home);
      } catch (e) {
        Get.offAllNamed(AppRoutes.login);
      }
    });
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
