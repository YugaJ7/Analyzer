import 'package:flutter/services.dart';

class WidgetRefreshService {
  static const MethodChannel _channel =
      MethodChannel('habit_widget_channel');

  static Future<void> refresh({
    required int percent,
    required int completed,
    required int total,
    required bool loggedIn,
    String itemsJson = '[]',
  }) async {
    await _channel.invokeMethod(
      'refreshWidget',
      {
        'percent': percent,
        'completed': completed,
        'total': total,
        'loggedIn': loggedIn,
        'itemsJson': itemsJson,
      },
    );
  }

  static Future<List<Map<String, dynamic>>> getPendingWidgetActions() async {
    final raw = await _channel.invokeMethod<List<dynamic>>(
      'getPendingWidgetActions',
    );

    if (raw == null) {
      return const [];
    }

    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  static Future<void> clearPendingWidgetActions() async {
    await _channel.invokeMethod('clearPendingWidgetActions');
  }
}
