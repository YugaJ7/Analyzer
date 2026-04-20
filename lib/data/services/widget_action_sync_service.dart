import 'dart:developer';

import 'package:analyzer/data/services/widget_refresh_service.dart';
import 'package:analyzer/data/services/widget_sync_service.dart';
import 'package:analyzer/presentation/controllers/entry_controller.dart';
import 'package:analyzer/presentation/controllers/parameter_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class WidgetActionSyncService {
  static bool _isProcessing = false;
  static final RxBool isStartupSyncing = false.obs;

  static Future<void> processPendingActions() async {
    if (_isProcessing) {
      log(
        'widget-sync: skipped because sync already in progress',
        name: 'PERF',
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    if (!Get.isRegistered<ParameterController>() ||
        !Get.isRegistered<EntryController>()) {
      return;
    }

    final entryController = Get.find<EntryController>();
    final parameterController = Get.find<ParameterController>();

    final actions = await WidgetRefreshService.getPendingWidgetActions();

    if (actions.isEmpty) {
      log('widget-sync: no pending actions', name: 'PERF');
      return;
    }

    _isProcessing = true;
    isStartupSyncing.value = true;
    final totalStopwatch = Stopwatch()..start();

    try {
      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day);

      final selectedDate = entryController.selectedDate.value;
      final normalizedSelectedDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );

      if (normalizedSelectedDate != normalizedToday) {
        final loadTodayStopwatch = Stopwatch()..start();
        entryController.selectedDate.value = normalizedToday;
        await entryController.loadEntries(syncWidget: false);
        log(
          'widget-sync: switched to today and loaded entries in ${loadTodayStopwatch.elapsedMilliseconds}ms',
          name: 'PERF',
        );
      }

      final finalActions = <String, Map<String, dynamic>>{};

      for (final action in actions) {
        final parameterId = action['parameterId'] as String?;

        if (parameterId == null || parameterId.isEmpty) {
          continue;
        }

        finalActions[parameterId] = action;
      }

      log(
        'widget-sync: collapsed ${actions.length} raw actions into ${finalActions.length} final actions',
        name: 'PERF',
      );

      final applicableActions = finalActions.values.where((action) {
        final parameterId = action['parameterId'] as String?;
        if (parameterId == null || parameterId.isEmpty) {
          return false;
        }

        final parameter = parameterController.getFromCache(parameterId);
        return parameter == null || parameter.isActive;
      }).toList();

      final applyStopwatch = Stopwatch()..start();
      await entryController.applyWidgetActionsBatch(applicableActions);

      log(
        'widget-sync: final actions applied in ${applyStopwatch.elapsedMilliseconds}ms',
        name: 'PERF',
      );

      final refreshStopwatch = Stopwatch()..start();
      await WidgetRefreshService.clearPendingWidgetActions();
      await WidgetSyncService.syncNow();
      log(
        'widget-sync: clear + widget refresh in ${refreshStopwatch.elapsedMilliseconds}ms',
        name: 'PERF',
      );
    } finally {
      log(
        'widget-sync: total ${totalStopwatch.elapsedMilliseconds}ms',
        name: 'PERF',
      );
      _isProcessing = false;
      isStartupSyncing.value = false;
    }
  }
}
