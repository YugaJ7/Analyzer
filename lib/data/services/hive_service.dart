import 'package:hive_flutter/hive_flutter.dart';
import '../../core/utils/app_constants.dart';

class HiveService {
  HiveService._();

  static Future<void> init() async {
    await Future.wait([
      Hive.openBox<dynamic>(AppConstants.kAnalyticsCacheBox),
      Hive.openBox<dynamic>(AppConstants.kStreakCacheBox),
    ]);
  }

  static Box<dynamic> get analyticsBox =>
      Hive.box<dynamic>(AppConstants.kAnalyticsCacheBox);
      
  static Box<dynamic> get streakBox =>
      Hive.box<dynamic>(AppConstants.kStreakCacheBox);

  static Future<void> clearAll() async {
    await analyticsBox.clear();
    await streakBox.clear();
  }

  static Future<void> closeAll() async {
    await Hive.close();
  }
}
