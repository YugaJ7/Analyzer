import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/app_navigation_controller.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<AppNavigationController>();

    return Obx(
      () => BottomNavigationBar(
        currentIndex: navController.currentIndex,
        onTap: navController.changeByIndex,
        backgroundColor: const Color(0xFF1E2749),
        selectedItemColor: const Color(0xFF6C63FF),
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: "Analytics"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}