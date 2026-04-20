import 'dart:convert';

import 'package:analyzer/data/services/widget_refresh_service.dart';
import 'package:analyzer/presentation/controllers/entry_controller.dart';
import 'package:analyzer/presentation/controllers/parameter_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class WidgetSyncService {
  static Future<void>? _inFlightSync;
  static _WidgetSyncPayload? _queuedPayload;
  static String? _lastSentSignature;

  static Future<void> syncNow() async {
    final payload = _buildPayload();
    if (payload == null) {
      return;
    }

    _queuedPayload = payload;

    if (_inFlightSync != null) {
      await _inFlightSync;
      return;
    }

    while (_queuedPayload != null) {
      final nextPayload = _queuedPayload!;
      _queuedPayload = null;

      if (nextPayload.signature == _lastSentSignature) {
        continue;
      }

      final future = WidgetRefreshService.refresh(
        percent: nextPayload.percent,
        completed: nextPayload.completed,
        total: nextPayload.total,
        loggedIn: nextPayload.loggedIn,
        itemsJson: nextPayload.itemsJson,
      );

      _inFlightSync = future;
      await future;
      _lastSentSignature = nextPayload.signature;
      _inFlightSync = null;
    }
  }

  static _WidgetSyncPayload? _buildPayload() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _WidgetSyncPayload(
        percent: 0,
        completed: 0,
        total: 0,
        loggedIn: false,
        itemsJson: '[]',
      );
    }

    if (!Get.isRegistered<ParameterController>()) {
      return null;
    }

    final parameterController = Get.find<ParameterController>();
    final params = parameterController.parameters
        .where((p) => p.isActive)
        .toList();

    if (params.isEmpty) {
      return null;
    }

    Map<String, dynamic> entries = const {};
    var completed = 0;

    if (Get.isRegistered<EntryController>()) {
      final entryController = Get.find<EntryController>();
      entries = entryController.selectedDateEntries;
      completed = entries.length;
    }

    final totalHabits = params.length;
    final percent = totalHabits == 0
        ? 0
        : ((completed / totalHabits) * 100).round();

    final items = params.take(9).map((p) {
      final entry = entries[p.id];
      return {
        'id': p.id,
        'name': p.name,
        'type': p.type.name,
        'done': entry != null,
        'value': entry?.value?.toString() ?? '',
        'options': p.options ?? const <String>[],
      };
    }).toList();

    return _WidgetSyncPayload(
      percent: percent,
      completed: completed,
      total: totalHabits,
      loggedIn: true,
      itemsJson: jsonEncode(items),
    );
  }
}

class _WidgetSyncPayload {
  final int percent;
  final int completed;
  final int total;
  final bool loggedIn;
  final String itemsJson;
  final String signature;

  _WidgetSyncPayload({
    required this.percent,
    required this.completed,
    required this.total,
    required this.loggedIn,
    required this.itemsJson,
  }) : signature = '$loggedIn|$percent|$completed|$total|$itemsJson';
}
