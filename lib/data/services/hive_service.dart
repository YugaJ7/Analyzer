import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/utils/app_constants.dart';
import '../../core/utils/app_logger.dart';

class HiveService {
  HiveService._();

  @visibleForTesting
  static Future<Box<dynamic>> Function(String name) openBox =
      Hive.openBox<dynamic>;

  static Future<void> init() async {
    await Future.wait([
      _openOrReset(AppConstants.kAnalyticsCacheBox),
      _openOrReset(AppConstants.kStreakCacheBox),
      _openOrReset(AppConstants.kSessionMetaBox),
    ]);
  }

  /// Every box is a rebuildable cache of Firestore data, so an unreadable box
  /// is dropped rather than left to block startup. Losing `session_meta` only
  /// makes `UserSessionStorage` treat the remaining caches as foreign.
  static Future<Box<dynamic>> _openOrReset(String name) async {
    try {
      return await openBox(name);
    } catch (e, st) {
      AppLogger.error(
        'Box unreadable, resetting',
        name: 'HiveService',
        error: e.runtimeType,
        stackTrace: st,
      );
      await Hive.deleteBoxFromDisk(name);
      return openBox(name);
    }
  }

  static Box<dynamic> get analyticsBox =>
      Hive.box<dynamic>(AppConstants.kAnalyticsCacheBox);

  static Box<dynamic> get streakBox =>
      Hive.box<dynamic>(AppConstants.kStreakCacheBox);

  static Box<dynamic> get sessionMetaBox =>
      Hive.box<dynamic>(AppConstants.kSessionMetaBox);

  /// Data caches only; session metadata belongs to `UserSessionStorage`.
  static Future<void> clearAll() async {
    await analyticsBox.clear();
    await streakBox.clear();
  }

  static Future<void> closeAll() async {
    await Hive.close();
  }
}
