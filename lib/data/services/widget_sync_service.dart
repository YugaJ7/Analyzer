import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class WidgetSyncService {
  static Future<void> sync({
    required int completed,
    required int total,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final percent =
        total == 0 ? 0 : ((completed / total) * 100).round();

    await prefs.reload();

    await prefs.setInt('widget_completed', completed);
    await prefs.setInt('widget_total', total);
    await prefs.setInt('widget_percent', percent);

    log(
      'WIDGET SAVE => percent=$percent completed=$completed total=$total',
    );
  }
}