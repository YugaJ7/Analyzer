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

    final parameterController = Get.find<ParameterController>();
    final entryController = Get.find<EntryController>();

    for (var i = 0; i < 20 && parameterController.isLoading.value; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
    }

    final actions = await WidgetRefreshService.getPendingWidgetActions();

    if (actions.isEmpty) {
      return;
    }

    _isProcessing = true;
    isStartupSyncing.value = true;

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
        entryController.selectedDate.value = normalizedToday;
      }

      await entryController.loadEntries(forceRefresh: true);

      final finalActions = <String, Map<String, dynamic>>{};

      for (final action in actions) {
        final parameterId = action['parameterId'] as String?;

        if (parameterId == null || parameterId.isEmpty) {
          continue;
        }

        finalActions[parameterId] = action;
      }

      for (final action in finalActions.values) {
        final parameterId = action['parameterId'] as String?;
        final type = action['type'] as String?;
        final done = action['done'] == true;
        final value = action['value'];

        if (parameterId == null || type == null) {
          continue;
        }

        final parameter = parameterController.getFromCache(parameterId);
        if (parameter == null || !parameter.isActive) {
          continue;
        }

        if (type == 'checklist') {
          final isCompleted =
              entryController.selectedDateEntries[parameterId] != null;

          if (isCompleted != done) {
            await entryController.toggleEntry(
              parameterId,
              true,
              syncWidget: false,
            );
          }
          continue;
        }

        if (type != 'optionSelector') {
          continue;
        }

        final nextValue = value?.toString();

        if (nextValue == null || nextValue.isEmpty) {
          continue;
        }

        final currentValue = entryController
            .selectedDateEntries[parameterId]
            ?.value
            ?.toString();

        if (currentValue != nextValue) {
          await entryController.toggleEntry(
            parameterId,
            nextValue,
            syncWidget: false,
          );
        }
      }

      await WidgetRefreshService.clearPendingWidgetActions();
      await WidgetSyncService.syncNow();
    } finally {
      _isProcessing = false;
      isStartupSyncing.value = false;
    }
  }
}
