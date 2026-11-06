import 'package:flutter/services.dart';

class WidgetRefreshService {
  static const MethodChannel _channel = MethodChannel('habit_widget_channel');

  /// Last payload the native side accepted; identical refreshes are skipped.
  static String? _lastSentSignature;

  static Future<void> refresh({
    required int percent,
    required int completed,
    required int total,
    required bool loggedIn,
    String itemsJson = '[]',
  }) async {
    final signature = '$loggedIn|$percent|$completed|$total|$itemsJson';
    if (signature == _lastSentSignature) return;

    await _channel.invokeMethod('refreshWidget', {
      'percent': percent,
      'completed': completed,
      'total': total,
      'loggedIn': loggedIn,
      'itemsJson': itemsJson,
    });
    _lastSentSignature = signature;
  }

  static Future<List<Map<String, dynamic>>> getPendingWidgetActions() async {
    final raw = await _channel.invokeMethod<List<dynamic>>(
      'getPendingWidgetActions',
    );

    if (raw == null) {
      return const [];
    }

    return raw
        .whereType<Map<Object?, Object?>>()
        .map(Map<String, dynamic>.from)
        .toList();
  }

  static Future<bool> hasPendingWidgetActions() async {
    return await _channel.invokeMethod<bool>('hasPendingWidgetActions') ??
        false;
  }

  static Future<void> clearPendingWidgetActions() async {
    await _channel.invokeMethod('clearPendingWidgetActions');
  }

  /// Drops items, progress and queued actions; renders logged-out.
  static Future<void> clearWidgetData() async {
    // Forget first: the next refresh must repaint even if it matches.
    _lastSentSignature = null;
    await _channel.invokeMethod('clearWidgetData');
  }
}
