import 'package:analyzer/core/bindings/auth_binding.dart';
import 'package:analyzer/core/bindings/home_binding.dart';
import 'package:analyzer/core/routes/app_routes.dart';
import 'package:analyzer/presentation/screens/app_shell/app_shell.dart';
import 'package:analyzer/presentation/screens/auth/lock_screen.dart';
import 'package:analyzer/presentation/screens/auth/login_screen.dart';
import 'package:analyzer/presentation/screens/auth/parameter_screen.dart';
import 'package:analyzer/presentation/screens/auth/register_screen.dart';
import 'package:analyzer/presentation/screens/auth/splash_screen.dart';
import 'package:analyzer/presentation/screens/manage_habits/manage_habits_screen.dart';
import 'package:get/get.dart';

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.lock, page: () => const LockScreen()),
    GetPage(
      name: AppRoutes.login,
      page: LoginScreen.new,
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: RegisterScreen.new,
      binding: AuthBinding(),
    ),
    GetPage(name: AppRoutes.home, page: AppShell.new, binding: HomeBinding()),
    GetPage(
      name: AppRoutes.parameterSetup,
      page: ParameterSetupScreen.new,
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.manageHabits,
      page: () => const ManageHabitsScreen(),
      binding: HomeBinding(),
    ),
  ];
}
