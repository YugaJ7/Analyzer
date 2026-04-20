import 'dart:convert';
import 'dart:developer';

import 'package:analyzer/data/services/widget_refresh_service.dart';
import 'package:analyzer/presentation/controllers/entry_controller.dart';
import 'package:analyzer/presentation/controllers/parameter_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class WidgetSyncService {
  static Future<void> syncNow() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      await WidgetRefreshService.refresh(
        percent: 0,
        completed: 0,
        total: 0,
        loggedIn: false,
        itemsJson: '[]',
      );
      return;
    }

    if (!Get.isRegistered<ParameterController>()) {
      return;
    }

    final parameterController = Get.find<ParameterController>();

    final params = parameterController.parameters
        .where((p) => p.isActive)
        .toList();

    // IMPORTANT:
    // If params not loaded yet -> skip sync
    if (params.isEmpty) {
      log("WIDGET_SYNC skipped empty params");
      return;
    }

    Map<String, dynamic> entries = {};
    int completed = 0;

    if (Get.isRegistered<EntryController>()) {
      final entryController = Get.find<EntryController>();

      entries = entryController.selectedDateEntries;

      completed = entries.length;
    }

    final totalHabits = params.length;

    final percent = totalHabits == 0
        ? 0
        : ((completed / totalHabits) * 100).round();

    final items = params
        .map((p) {
          final entry = entries[p.id];

          return {
            "id": p.id,
            "name": p.name,
            "type": p.type.name,
            "done": entry != null,
            "value": entry?.value?.toString() ?? "",
            "options": p.options ?? const [],
          };
        })
        .take(9)
        .toList();

    final json = jsonEncode(items);

    log("WIDGET_SYNC json=$json");

    await WidgetRefreshService.refresh(
      percent: percent,
      completed: completed,
      total: totalHabits,
      loggedIn: true,
      itemsJson: json,
    );
  }
}
