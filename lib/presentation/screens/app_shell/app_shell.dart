import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/app_navigation_controller.dart';
import '../home/home_screen.dart';
import '../analytics/analytics_screen.dart';
import '../profile/profile_screen.dart';
import 'app_bottom_nav.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.put(AppNavigationController());

    return Scaffold(
      extendBody: true,
      body: Obx(() {
        return IndexedStack(
          index: navController.currentIndex,
          children: const [
            HomeScreen(),
            AnalyticsScreen(),
            ProfileScreen(),
          ],
        );
      }),
      bottomNavigationBar: const AppBottomNav(),
    );
  }
}