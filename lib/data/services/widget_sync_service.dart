import 'package:analyzer/data/services/widget_refresh_service.dart';
import 'package:analyzer/presentation/controllers/entry_controller.dart';
import 'package:analyzer/presentation/controllers/parameter_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class WidgetSyncService {
  static Future<void> syncNow() async {
    final user = FirebaseAuth.instance.currentUser;

    // Logged out
    if (user == null) {
      await WidgetRefreshService.refresh(
        percent: 0,
        completed: 0,
        total: 0,
        loggedIn: false,
      );
      return;
    }

    if (!Get.isRegistered<ParameterController>()) {
      return;
    }

    final parameterController =
        Get.find<ParameterController>();

    final totalHabits = parameterController
        .parameters
        .where((p) => p.isActive)
        .length;

    int completed = 0;

    if (Get.isRegistered<EntryController>()) {
      final entryController =
          Get.find<EntryController>();

      completed = entryController
          .selectedDateEntries.length;
    }

    final percent = totalHabits == 0
        ? 0
        : ((completed / totalHabits) * 100)
            .round();

    await WidgetRefreshService.refresh(
      percent: percent,
      completed: completed,
      total: totalHabits,
      loggedIn: true,
    );
  }
}