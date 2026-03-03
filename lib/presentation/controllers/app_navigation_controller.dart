import 'package:get/get.dart';

enum AppTab { home, analytics, profile }

class AppNavigationController extends GetxController {
  final Rx<AppTab> currentTab = AppTab.home.obs;

  void changeTab(AppTab tab) {
    currentTab.value = tab;
  }

  int get currentIndex {
    switch (currentTab.value) {
      case AppTab.home:
        return 0;
      case AppTab.analytics:
        return 1;
      case AppTab.profile:
        return 2;
    }
  }

  void changeByIndex(int index) {
    switch (index) {
      case 0:
        changeTab(AppTab.home);
        break;
      case 1:
        changeTab(AppTab.analytics);
        break;
      case 2:
        changeTab(AppTab.profile);
        break;
    }
  }
}