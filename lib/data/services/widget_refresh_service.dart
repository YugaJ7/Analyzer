import 'package:flutter/services.dart';

class WidgetRefreshService {
  static const MethodChannel _channel =
      MethodChannel('habit_widget_channel');

  static Future<void> refresh({
    required int percent,
    required int completed,
    required int total,
    required bool loggedIn,
  }) async {
    await _channel.invokeMethod(
      'refreshWidget',
      {
        'percent': percent,
        'completed': completed,
        'total': total,
        'loggedIn': loggedIn,
      },
    );
  }
}