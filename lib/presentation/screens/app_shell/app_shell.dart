import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../analytics/analytics_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // Owned here so the selected tab survives rebuilds; was recreated (and
  // leaked) on every build.
  final _tabController = PersistentTabController();

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      controller: _tabController,
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
            BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8),
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
    );
  }
}
