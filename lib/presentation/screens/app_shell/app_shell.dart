import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../../controllers/app_navigation_controller.dart';
import '../analytics/analytics_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.put(AppNavigationController());

    final controller = PersistentTabController(
      initialIndex: navController.currentIndex,
    );

    return PersistentTabView(
      controller: controller,
      tabs: [
        PersistentTabConfig(
          screen: const HomeScreen(),
          item: ItemConfig(
            icon: const Icon(Icons.home_rounded),
            inactiveIcon: const Icon(Icons.home_outlined),
            title: "Home",
            activeForegroundColor: const Color(0xFF6366F1),
            inactiveForegroundColor: const Color(0xFF8892A4),
          ),
        ),

        PersistentTabConfig(
          screen: const AnalyticsScreen(),
          item: ItemConfig(
            icon: const Icon(Icons.insights_rounded),
            inactiveIcon: const Icon(Icons.insights_outlined),
            title: "Analytics",
            activeForegroundColor: const Color(0xFF6366F1),
            inactiveForegroundColor: const Color(0xFF8892A4),
          ),
        ),

        PersistentTabConfig(
          screen: const ProfileScreen(),
          item: ItemConfig(
            icon: const Icon(Icons.person_rounded),
            inactiveIcon: const Icon(Icons.person_outline_rounded),
            title: "Profile",
            activeForegroundColor: const Color(0xFF6366F1),
            inactiveForegroundColor: const Color(0xFF8892A4),
          ),
        ),
      ],
      navBarBuilder: (navBarConfig) => Style7BottomNavBar(
        height: 68,
        navBarConfig: navBarConfig,
        navBarDecoration: NavBarDecoration(
          color: const Color(0xFF161C27),
          borderRadius: BorderRadius.circular(0),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.12), blurRadius: 8),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      handleAndroidBackButtonPress: true,
      keepNavigatorHistory: true,
      hideNavigationBar: false,

      screenTransitionAnimation: const ScreenTransitionAnimation(
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 250),
      ),
      onTabChanged: (index) {
        navController.changeByIndex(index);
      },
    );
  }
}
