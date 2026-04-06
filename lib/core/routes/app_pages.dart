import 'package:analyzer/core/bindings/auth_binding.dart';
import 'package:analyzer/core/bindings/home_binding.dart';
import 'package:analyzer/core/routes/app_routes.dart';
import 'package:analyzer/presentation/screens/app_shell/app_shell.dart';
import 'package:analyzer/presentation/screens/auth/login_screen.dart';
import 'package:analyzer/presentation/screens/auth/parameter_screen.dart';
import 'package:analyzer/presentation/screens/profile/manage_habits_screen.dart';
import 'package:analyzer/presentation/screens/auth/register_screen.dart';
import 'package:analyzer/presentation/screens/auth/splash_screen.dart';
import 'package:get/get.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => RegisterScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => AppShell(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.parameterSetup,
      page: () => ParameterSetupScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.manageHabits,
      page: () => const ManageHabitsScreen(),
      binding: HomeBinding(),
    )
  ];
}