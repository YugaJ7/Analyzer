import 'package:flutter/services.dart';

import '../../core/utils/app_constants.dart';
import '../../core/utils/app_logger.dart';
import 'hive_service.dart';
import 'preferences_service.dart';
import 'widget_refresh_service.dart';

/// Single owner of user-scoped local state (Hive caches, cached profile,
/// widget data), tagged with the owning uid.
///
/// Call [bindToUser] on every authenticated entry: sessions can end without
/// a logout (revoked/expired token), so ownership is checked, not assumed.
class UserSessionStorage {
  UserSessionStorage._();

  /// Wipes local data unless it already belongs to [uid].
  static Future<void> bindToUser(String uid) async {
    final box = HiveService.sessionMetaBox;
    final ownerUid = box.get(AppConstants.kSessionOwnerUidKey) as String?;

    if (ownerUid == uid) return;

    // Null owner = pre-upgrade data; can't prove it's this user's.
    await clear();
    await box.put(AppConstants.kSessionOwnerUidKey, uid);
  }

  /// Best-effort per store: one failure must not leave the others populated.
  static Future<void> clear() async {
    await _runStep('hive caches', HiveService.clearAll);
    await _runStep('display name', PreferencesService.instance.clearUserName);
    await _runStep('avatar', PreferencesService.instance.clearAvatarEmoji);
    await _runStep('widget data', _clearWidget);
    await _runStep(
      'session owner',
      () => HiveService.sessionMetaBox.delete(AppConstants.kSessionOwnerUidKey),
    );
  }

  static Future<void> _clearWidget() async {
    try {
      await WidgetRefreshService.clearWidgetData();
    } on MissingPluginException {
      // Widget is Android-only.
    }
  }

  static Future<void> _runStep(
    String name,
    Future<void> Function() step,
  ) async {
    try {
      await step();
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to clear $name',
        name: 'UserSessionStorage',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
