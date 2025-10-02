import 'package:analyzer/core/bindings/auth_binding.dart';
import 'package:analyzer/core/routes/app_routes.dart';
import 'package:analyzer/presentation/screens/login_screen.dart';
import 'package:analyzer/presentation/screens/register_screen.dart';
import 'package:analyzer/presentation/screens/splash_screen.dart';
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
    // GetPage(
    //   name: AppRoutes.home,
    //   page: () => HomeScreen(),
    //   binding: HomeBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.parameterSetup,
    //   page: () => ParameterSetupScreen(),
    //   binding: HomeBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.analytics,
    //   page: () => AnalyticsScreen(),
    //   binding: HomeBinding(),
    // ),
    // GetPage(
    //   name: AppRoutes.profile,
    //   page: () => ProfileScreen(),
    //   binding: HomeBinding(),
    // ),
  ];
}